---
layout: post
title: Pipeline as Code - putting everything together
date:  2017-10-16 20:10:18
category: Devops CI CD
---

In this post we shall implement a continuous deployment pipeline using [ansible],
[travis ci] and [git].

During implementation we don't have steps such as planning,
configuration management etc that we mentioned in the [previous post]; those are
conceptual. The flowchart below represents the actual places that our software
should live at all times. Think of each component in the flowchart as a tool
that exposes an API with everything else abstracted away.

![](/images/Content/Flowcharts/CD\ flowchart\ 0.svg)

## Version control (Git)
We want to have playbooks, deploy scripts and the actual application repo in
version control.

The gist is that:

 - tags get deployed to the main production environment
 - master branch gets deployed to the main staging environment
 - other major branches get deployed to other staging environments of your
 choosing

Not all these steps need be done for it to be a continuous deployment
pipeline. For example for this blog, changes that get merged into master go
straight into production. This is because the application is really small and
simple so before anything goes into master I know it's error free.
Moreover, even if the blog were to experience downtime I have very little to
lose compared to a business. This is the same model that github pages uses what
is in master is pushed into the gh-pages branch which is basically a gh pages
blog's production environment.

> Exposes: git branches and git tags

## CI
Travis CI is a mix of open source and some propertary tools.
To quote them "Travis CI is run as a hosted service, free for Open Source, a
paid product for private code, and it’s available as an on-premises version
(Travis CI Enterprise)."
Their [github page](https://github.com/travis-ci) and
[info page](https://github.com/travis-ci/travis-ci).
To learn how to get started with travis in your project you can read
[get started doc](https://docs.travis-ci.com/user/getting-started/).
Moving on, I assume you have (gained) enough experience with travis to go on.

### Continuous integration and continuous deployment with Travis CI
We want to run tests then after that deploy to the relevant target.
In your .travis.yml file you can use one of the following
[travis ci build phases] `after_success` or `deploy` steps.
I prefer to use `after_success` when I want to run a deploy scipt and `deploy`
for already supported deploy environments because deploy script feature is
experimental at the time of writing this.

> Exposes: .travis.yml


## Deployment
Deployments vary depending on the target, assuming you're using a fresh server
instance you want to create an unprivileged deploy user to whom travis pushes
code.

### Preparing the deploy environment
Locally generate an SSH key that has no passphrase for the travis user and add
the public key to the deploy user's known_hosts
```
$ ssh-keygen -t ed25519 -C "travis@travis-ci.org"
```
Under "Enter file in which to save the key..." enter `travis-ci`
This will create two files `travis-ci` and `travis-ci.pub`.

Copy the contents of `travis-ci.pub` file to the playbooks so that it's added to
that user's known_hosts every time.
For example [here's my public key in my playbooks](https://github.com/urbanslug/playbooks/blob/master/roles/base/vars/vars.yml#L1)

Install the [travis cli tool](https://docs.travis-ci.com/user/encryption-keys/#Usage)
```
gem install travis
```

Encrypt your private key and add the decryption command to your .travis.yml file
using the travis cli tool
```
travis encrypt-file travis-ci --add
```

At this point your .travis.yml should a `before_install` phase that resembles
the following:
```
 - openssl aes-256-cbc -K $encrypted_7f9f7befb56d_key -iv $encrypted_7f9f7befb56d_iv -in travis-ci.enc -out travis-ci -d
```
That line decrypts your travis-ci private key in the travis container at runtime
and saves it as a travis-ci file.

Write a play to prepare the deploy environment we want to create a deploy/devops
user with minimal privileges.
In the case of this blog I run
```
ansible-playbook base.yml --ask-sudo-pass --ask-vault-pass
```
from my devops server. This creates the deploy user and adds the travis-ci.pub
to the deploy user's `~/.ssh/known_hosts`. It also creates this user amongst
other functions.


> Exposes: travis encrypt-file, ssh-keygen, ansible-playbook

### Deploying to a host
We want to have push code from our travis container to our server or target.

#### Digital ocean
```
after_success:
  - eval "$(ssh-agent -s)" #start the ssh agent
  - chmod 600 travis-ci
  - ssh-add travis-ci
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
```
deploy:
  skip_cleanup: true
  provider: pages
  local_dir: out
  github_token: $GH_TOKEN
  on:
    tags: true
```


#### AWS ECS
```
deploy:
  # deploy to staging environment
  skip_cleanup: true
  provider: script
  ECS_CLUSTER_MASTER: sofia-staging
  ECS_SERVICE_MASTER: sofia-staging
  script:
    - yarn run travis-ecs-deploy
  on:
    branch: master

  # deploy to production environment
  skip_cleanup: true
  provider: script
  ECS_CLUSTER_MASTER: sofia-production
  ECS_SERVICE_MASTER: sofia-production
  script:
    - yarn run travis-ecs-deploy
  on:
    tags: true
```

[travis ci build phases]: https://docs.travis-ci.com/user/customizing-the-build/#The-Build-Lifecycle
[travis ci]: https://travis-ci.org/
[ansible]: https://www.ansible.com/
[git]: https://git-scm.com/
[previous post]: 
