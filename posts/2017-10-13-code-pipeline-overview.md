---
layout: post
title: Pipeline as Code - overview
date:  2017-10-13 14:23:19
category: Devops CI CD
---

Pipeline in this context refers to the collection of steps software goes through
from planning to deployment. Pipeline as code is having this pipeline be stored
in an executable or/and a version controllable way.

Why does this matter? A code pipeline that is executable and/or version
controllable:

 - is easy to keep tracking of as changes occur
 - makes it possible to keep track of the actual and all possible agents of change (people and/or hosts)
 - reduces repitition and consequently saves time
 - is easy to delegate parts of to tools or completely automate
 - has clear and consistent history
 - has immutable code pipeline history meaning we can revert to previous stable state
 - in case of failure, the broken state can be reproduced and post moterms performed
 - is much it easier to maintain and keep track of its components in complex architechtures such as microservices
 - makes it much easier to build tools that lower the bar of entry into ops such as running ansible plays and chatops bots

Pipeline as code is the next step in planning, provisioning, configuration
management and application deployment, continuous integration and continuous
deployment.

It's also a great way to manage growing complexity in terms of both
the architechture and teams involved. I just threw a number of buzzwords around
so let me explain each of them and why they matter.

> It's important to note that the tools used in each step have a lot of overlap between them and a tool is likely to show up in multple sections.

### Planning
Since we can't execute plans as code, yet; we have to settle for version
controlling them.
Save your execution plans as documentation in a `docs/` directory or a git
submodule (or any other format) files and put them in version control.

You can also commit `.org` files you created during meetings, export them into
`.md` and add them as docs.

> Tools: version control systems

### Provisioning
Provision is the past participle of provide, in this context it means providing
everything that your application will need to run.

It is an implementation of the infrastructure diagram/plan; it involves the
to run the software. That is: where to host it, how many servers, OS versions,
server requirements, dependencies, file system, directory structure. The answer
to whether to use a vendor solution like AWS Lamda, or ECS would lie here.

You probably need to do this once or at most 3 times **ever** unless you keep
changing core infrastructure. You could put this in an ansible script, ECS task
definitions, docker images, Amazon Machine Images, virtual machine
images et cetera.

> Tools: Packer, Terraform, Ansible, Kubernetes pods, ECS clusters.

### Configuration management
![](https://i.giphy.com/media/3oz8xOOWHS2MYEJXXO/giphy.gif)

Applications today are a collection of tools combined to solve a need.
In the example of a simple web application we have a database, an app, an app
server and a webserver. Configuration management is basically managing the glue
that binds these tools together; which commands to run, which services to start
and stop and when, arguments, environment variables, order of running them and
so forth.

> Tools: ansible vars/vault, ansible plays

### Application deployment
This is putting all the parts of the application that need to run on their
respective servers, starting them and making sure they're all working together
and correctly.
In this case you have vendor tools such as Identity and Access Management from
AWS which you can build on top of.
This will mean having the following in an executable and version controllable
form: the deploy server, their user, deploy scripts avaible to them,
actual deploy commands to run and the order in which to run them.
You will only need to this during the first deployment or when something goes
terribly wrong and you have to rollback but even then it's still going to be a
few commands or just one. You can also use other tools for deployment such as
bots.

> Tools: ansible, puppet, chef

### Continuous integration
This is running tests and building the application to catch errors either in the
code or the way parts of it integrate with each other.
Running tests, style checks and catching errors in the code.

> Tools: travis ci, circle ci, gitlab ci

### Continuous deployment
Once the continuous integration tests run and pass, have a tool compile a binary
or create a commit, push it to a deploy environment and make sure it's running.

This is comparable to continuous delivery which accordingo to Wikipedia:
["Continuous Delivery means that the team ensures every change can be deployed to production but may choose not to do it, usually due to business reasons"](https://en.wikipedia.org/wiki/Continuous_delivery)

> Tools: travis-ecs-deploy, deploy scripts, terraformy

&nbsp;

&nbsp;

In this post I've explained how the pipeline can be presented as code but only
as seperate components not how these components can be combined to work as one.

In the next post I'll explain how you can use free tools and some open source
tools to create a code pipeline that runs from provisioning, configuration
management, version control, continuous integration and continuous deployment
requiring very little input from devops and with as little complexity as
possible.
