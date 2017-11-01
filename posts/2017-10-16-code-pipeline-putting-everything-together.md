---
layout: post
title: Pipeline as Code - putting everything together
date:  2017-10-16 20:10:18
category: Devops CI CD
---

In this post we shall implement a continuous deployment pipeline using
[ansible], [travis ci] and [git].

During implementation we don't have steps such as planning, provisioning,
configuration management etc that we mentioned in the [previous post]; those are
conceptual. The flowchart below represents the actual places that our software
should live at all times. Think of each component in the flowchart as a service
that exposes an API.

![](/images/Content/Flowcharts/Pipeline_as_code_putting.svg)

## Deploy server
In the diagram above we introduce an deploy server. This is the
host from which you can access your other servers such production, staging etsc.

> Exposes: ansible, ssh


## Git (Version Control)
We want to have playbooks, deploy scripts and code in version control.

What we get from version control that is necessary for continuous deployment is:

 - tags get deployed to the main production environment
 - master branch gets deployed to the main staging environment
 - other major branches get deployed to other staging environments of our
 choosing

Not all these steps need to be done for it to be a continuous deployment
pipeline. For example: for this blog, changes that get merged into master go
straight into production. This is because the application is really small and
simple so before anything goes into master I know it's error free.
Moreover, even if the blog were to experience downtime I have very little to
lose compared to a business. This is the same model that github pages uses;
what is in master is pushed into the `gh-pages` branch which is basically a
github pages blog's production environment.

> Exposes: git branches and git tags

## Ansible (Provisioning and Configuration Management)
Assuming you have a fresh server such as the one Digital Ocean would offer
or a fresh EC2 instance. We want an ansible play that creates an unprivileged
user with SSH authentication.
So we have to do the following locally or on our deploy server:

 - generate an SSH key pair **without a passphrase**
 - add the public key of the generated key to the deploy user's known_hosts file
 - push the private key of the generated key to travis ci so that the travis
 container can autheniticate as that user.

#### Generate an SSH keypair without a passphrase
Under `Enter file in which to save the key...` type in `travis-ci`.  
Under `Enter passphrase (empty for no passphrase):` just press enter
```
$ ssh-keygen -t ed25519 -C "travis@travis-ci.org"
```
This will create two files `travis-ci` and `travis-ci.pub`.

#### Add the public key to the deploy user's known_hosts
Write a play to prepare the deploy environment.

Copy the contents of `travis-ci.pub` file to a vars file in your the playbooks
For example [here's my vars file].

```yml
travis_ci_pubkey: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINFzeaPrMXDVS1/+V4hKsgC+Pzoa9tnGGP+VCPT21QXP travis@travis-ci.org"
```
Add a section in a play of your choosing that copies the public key to the
deploy user's known_hosts.
```yml
- include_vars: vars.yml

- name: Create deploy user
  user: name=deploy
        group=www

- name: copy travis-ci public ssh key to deploy user
  authorized_key: key="{{ travis_ci_pubkey }}"
                  path=/home/deploy/.ssh/authorized_keys
                  user=deploy
```
This creates the deploy user and adds the travis-ci.pub
to the deploy user's `~/.ssh/known_hosts`.

#### Make your target a git server
For commands like `git push` to work from travis-ci to your deploy user
you have to have your server be ready to receive git push commands.
I will explain this later in a different post but for now what you need is a
play that:

 - Installs git
 - Creates a target git repo which we shall push to
 - Is able to overwrite the current contents of the repo when a change occurs.

```yaml
# creates a blog.git dir which is a bare git repo
- name:    Create a bare blog.git repo
  command: "git init --bare blog.git"

- name: Add a post-receive hook to update blog
  copy: src=../files/git/hooks/post-receive
        dest=blog.git/hooks/post-receive
        owner=deploy
        group=www
        mode=0550
        backup=yes
```

```bash
#! /bin/bash

# post-recieve hook to handle updates
# delete the current blog
rm -rf ~/blog
cd ~/
# clone from the blog.git bare repo into a blog dir
git clone blog.git blog
```

If you take notice this is similar to the bare git repo that github provides.
For example: to clone this blog from github via ssh we would run:
```bash
$ git clone git@github.com:urbanslug/blog.git
```
and if you had ssh access to the server hosting this blog you would run:
```bash
$ git clone deploy@git.urbanslug.com:blog.git
```
I hope you can draw some interesting parallels there.
Here's my [blog's play] for reference.

In the case of this blog I run the below command from my deploy server.
```bash
$ ansible-playbook base.yml --ask-sudo-pass --ask-vault-pass
```

#### Push the private key to travis ci
Install the [travis cli tool](https://docs.travis-ci.com/user/encryption-keys/#Usage)
```bash
$ gem install travis
```

Encrypt your private key and add the decryption command to your .travis.yml file
using the travis cli tool and also push your public key to travis-ci with:
```bash
$ travis encrypt-file travis-ci --add
```

The `--add` flag  should add a  `before_install` phase to your .travis.yml file
that resembles the following:
```yml
before_install:
 - openssl aes-256-cbc -K $encrypted_7f9f7befb56d_key -iv $encrypted_7f9f7befb56d_iv -in travis-ci.enc -out travis-ci -d
```
That line decrypts your travis-ci private key in the travis container at runtime
and creates a `~/travis-ci` which is the private key. Make sure not to have
multiple before-install phases.

> Exposes: travis encrypt-file, ssh-keygen, ansible-playbook, ansible vars


## Travis CI (Continuous Integration and Continuous Deployment)
Travis CI is a mix of open source and some proprietary tools.  
To quote them "Travis CI is run as a hosted service, free for Open Source, a
paid product for private code, and it’s available as an on-premises version
(Travis CI Enterprise)."

Here's their [github page](https://github.com/travis-ci) and
[info page](https://github.com/travis-ci/travis-ci).
To learn how to get started with travis in your project you can read
[get started doc](https://docs.travis-ci.com/user/getting-started/).
Moving on, I assume you have (gained) enough experience with travis to go on.

Travis will run tests and/or build our application on every branch or
specific branches based on rules that we set. We then build on this
functionality to deploy to a target based on various
rules. The obvious one being when our tests pass.

In our case: we want to run tests then after that deploy to the relevant target.
In your .travis.yml file you can use one of the following
[travis ci build phases] `after_success` or `deploy` steps.
I prefer to use `after_success` when I want to run a deploy script and then list
all the commands that my script would run and `deploy` for already supported
deploy environments.
This is because the script feature is experimental at the time of writing this.

> Exposes: .travis.yml

### Continuously deploying to a host
We want to push code from our travis container to our server.
Here are some essesntials that would guide you in creating a .travis.yml file
that would deploy to your target.

#### Using after_success
The `branches` section is essential in this case because it ensures that the
.travis.yml file will only be ran for the master branch.
```yaml
branches:
  only:
    - master

addons:
  # add the target server to the containers known_hosts
  # this prevents a blocking prompt to add the server to travis-ci's
  # known_hosts when attempting to git push
  ssh_known_hosts:
    - git.urbanslug.com

# decrypt our public key
before_install:
  - openssl aes-256-cbc -K $encrypted_7f9f7befb56d_key -iv $encrypted_7f9f7befb56d_iv -in travis-ci.enc -out travis-ci -d

env:
  global:
    - GIT_EMAIL: travis@travis-ci.org
    - GIT_NAME: Travis CI


script:
  - ./site.hs build

# run the following commends after the script phase is successful
after_success:
  - eval "$(ssh-agent -s)" # start the ssh agent
  - chmod 600 travis-ci
  - ssh-add  travis-ci # add travis-ci private key to the ssh agent
  - cd _site
  - git init
  - git config --global user.email "$GIT_EMAIL"
  - git config --global user.name  "$GIT_NAME"
  - git remote add deploy "deploy@git.urbanslug.com:blog.git"
  - git add --all
  - git status
  - git commit -m "Built by Travis ( build $TRAVIS_BUILD_NUMBER )"
  - git push -q --force deploy master:master
```

#### Github pages
Here's the way [borq, a library from goodbot.ai,] has its docs deployed to
github pages every time a tag is created and here's the
[complete travis.yml file for borq].

In the above case `travis-encrypt` is used to encrypt the github token like so
```bash
$ travis encrypt GH_TOKEN=super_secret_token --add
```

The essentials of our .travis.yml file

```yaml
env:
  global:
    - GH_REF: github.com/goodbotai/borq.git
    - secure: S567U/zOMKOddrGtQBmFyA6ROzinMgheQ7rGoyVbw9i43hBzvKVgk+C77+cVCLPr8ps6qwqhV9Ex5ehM3ic9gXDJt9ZlpzlevP+epKxG11WL3S3RwAOGlp/wOkSM+KhEqYqNOSzjA5WLttzg5GFSqs+T3l7HelQfZk55t2O4HSmmKUKPbFfDZ/84suvPSf1pm+d8f99k5KQFnTO3JHbIkbdx76Hsa8KRsZFJ2oA3DgQOXPOf+W3AdlG5zT5t1hAv0wg1O1Q45zB1MDcMfAUYcJOk72eajWTx9E0jreAgEVNUG2oyBG+GNdN2eMtbO4hANcdbBAH6wQq797OK76YVN6MM2HiMMZ1W7emNmo5wP6nc23w7YXJ88a1Ysffxxi4aLOMD1rBlVT5/cjcjvRUeR/OHx+9fOLPo/G6KioC5oz0iXwNPSYkZBHQ3nKf4uribXAPV/8f+n9HzjSQTnILWXiYaaGqIJAjEzL8WL5dBBGhngkILzCX/Ur4LeYJkhLnrVTg089X8urjtWnBpZKMKAwhPfV768prfKurmRbirIlgJfw5WfRoiV34Bl3O7bcNQMQ0nIobgaNhF8JZRq6adp0K8ChVnfNl3oplXN1kiVr9YJRRb4ErLzRSJZqkP/TNUqOs5wFeiSoFGgCUvAyjQZN5IkKIr4VrdKcnbEgj/3Co=

deploy:
  skip_cleanup: true
  provider: pages
  local_dir: out
  github_token: $GH_TOKEN
  on:
    tags: true
```


I just explained how we can set up a project so that the CI tool handles all
deploys going forward after the inital setting up. If anything goes wrong we can
go into the deploy server and then run an ansible script and have it roll back
to a specific tag/branch.

In the next post we shall talk about continuous deployment in a microservice
architechture using the same tools but deploying to AWS ECS.

[here's my vars file]: https://github.com/urbanslug/playbooks/blob/master/roles/base/vars/vars.yml#L1
[travis ci build phases]: https://docs.travis-ci.com/user/customizing-the-build/#The-Build-Lifecycle
[travis ci]: https://travis-ci.org/
[ansible]: https://www.ansible.com/
[git]: https://git-scm.com/
[previous post]: /posts/2017-10-13-code-pipeline-overview.html
[blog's play]: https://github.com/urbanslug/playbooks/blob/master/roles/blog/tasks/main.yml
[complete travis.yml file for borq]: https://github.com/goodbotai/borq/blob/master/.travis.yml
[borq, a library from goodbot.ai,]: https://github.com/goodbotai/borq
