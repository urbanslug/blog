---
layout: post
title: Pipeline as Code - overview
date:  2017-10-13 14:23:19
category: Devops Travis CI CD
---

The code pipeline is a collection the steps software goes through from planning to deployment. 
Pipeline as code is having the code pipeline be stored in an executable or at least a version controllable way. 
Why should this matter?

 - Easy to keep track of changes.
 - Reduced repitition
 - Saves time
 - Automatation
 - Clear and consistent history
 - Immutable code pipeline meaning we easy reversion to previous stable state and perform post moterms

To explain: Great for microservice arch where deploying each component is tedious and downright dangerous.

Pipeline as code is really the next step in planning, software provisioning, configuration management and application deployment, continuous integration and continuous deployment. 
A ton of buzzwords. Let me explain each of them and why they matter. 
It's important to note that these tools have a lot of overlap between them and they might show up in multple sections.

### Planning
Since we can't execute plans as code yet (AI isn't quite there yet, lucky for me);
we have to settle for version controlling them.

Save your execution plans as documentation in a `docs/` directory or a git submodule (or any other format) files and put them in version control. 
Pro tip: You can also commit `.org` files you created during meetings or export them into `.md` and commit those.

> Tools: version control systems

### Provisioning
This is the infrastructure needed to run the software, where to host it. 
How many servers, whether to use a vendor solution like AWS Lamda, or ECS would 
lie here. 
This is basically an implementation of the infrastructure diagram (note that I didn't say architecture because that is likely application dependent).
Server requirements, dependencies, file system, directory structure.
You probably need to do this once or at least 3 times ever unless you keep switching infrastructure.
You could put this in an ansible script, ECS task definitions, publish docker images, Amazon Machine Images, virtual machine images et cetera.
Dependency management and installing
Have this creation and urls be in a version controllable place luckily in an executable form such as an ansible play.

> Tools: Packer, Terraform, Ansible, kubernetes pods, ECS Clusters.

### Configuration management
![](https://i.giphy.com/media/3oz8xOOWHS2MYEJXXO/giphy.gif)

Applications today are a collection of tools combined to solve a need.
In the example of a simple web application we have a database, an app, an app server and a webserver
Configuration management is basically storing the glue that ties these tools
 together.
So this is basically which commands to run, which services to start and stop and when, arguments, environment variables, order of running them.

> Tools: asible vars and vault, ansible plays

### Application deployment
In this case you have vendor tools such as Identity and Access Management from AWS which you can build on top of. 
The deploy server, their user, deploy scripts avaible to them, actual deploy commands to run. 
You will only need to this once or if something goes terribly wrong and you have to rollback but even then it's still going to be a few commands or just one needed.

> Tools: ansible, puppet, chef

### Continuous integration
This is running tests and building the application to catch errors either in the 
code or the way parts of it integrate with each other. 
Running tests, style checks and catching errors in the code.

> Tools: travis ci, circle ci, gitlab ci

### Continuous deployment
Once the tests run and pass, have a tool compile a binary or create a commit and 
push it to a deploy environment. 

> Tools: travis-ecs-deploy, deploy scripts

In this post I have explained how the pipeline can be put in code as seperate components. 
However, I have not examplained how these tools can be combined to work as one. 
In the next post I will explain how you can use free tools and some open source 
tools to create a code pipeline that runs from provisioning, configuration 
management, version control, continuous integration and continuous deployment. 
Requiring little input from the user.
