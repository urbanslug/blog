---
layout: post
title: Pipeline as Code - microservices
date:  2017-11-28 20:45:54
category: ECS AWS Microservices CI CD Devops
---

I assume you know about docker and docker container clusters. If you.
don't you can familiarize yourself with the [previous post].

Since our target platform is AWS we shall start right off with AWS.

## ECS
One of it's biggest disadvantages is that it's a tool only available on
AWS that means that relying on it means that you're locked into their
ecosystem.
The upside is that it works almost out of the box on AWS compared to
say figuring out how to network your <insert favourite cluster management
system name here> over several AWS EC2 instances.

It's important at this point to install the [AWS CLI tool] this makes
it possible to create everything on a common host and then version
controlling required files before pushing them to ECS.

 - OSX: `$ brew install awscli`
 - Ubuntu: `# apt install awscli`
 - Archlinux: `# pacman -S aws-cli`


### Amazon ECS agent
ECS (cluser) is basically the [Amazon ECS agent] running on an EC2 instance but
what is this agent and what good is it?
// to do: add content

Amazon breaks down it's container cluster management offereing into 3:

 - Registry
 - Task definitions
 - Clusters

and it sure helps to think of them in that order because your
microservice will go through those three in that order.

#### Registry
This is where you publish your private docker images so that you can
use them in ECS. You can also pull images from docker hub into an ECS
EC2 instance.

#### Task definitions
This is a JSON representation of low level information about your
docker container. A task defintion is something close to  the JSON you
get from `docker inspect` — in fact you create a task definition
from the aws cli tool  but another way to create it is through the
AWS console in your browser.
We obviously prefer generating it from docker inspect and pushing it to
AWS so that it's in a version contollable form.

```
```

#### ECS clusters

## Implementing the code pipeline in a microservice arcitechture on ECS
// should this sub title be "code pipeline on ECS" ?

We finally get to what this post was all about. Implementing the code
pipeline in a microservice arcitechture.

What we want is for our CI tool to build a docker image for us and push
it to the ECS registry. You can write your tool for this but since I'm
pragmatic I use [travis ecs deploy] with travis ci (obviously).

Since travis doesn't officially support ECS as a "provider" we use
`script` as the provider. Here we call the travis-ecs-deploy script on
```
```

You should have an IAM User that has permission to use ECR,ECS and
logging services. Probably create one called travis ci.



[next post]: 2017-10-30-microservices-using-docker-container-clusters.html
[Amazon ECS agent]: https://github.com/aws/amazon-ecs-agent
[travis ecs deploy]: https://github.com/motleyagency/travis-ecs-deploy
[AWS CLI tool]: http://docs.aws.amazon.com/cli/latest/reference/index.html#cli-aws
[previous post]: 2017-10-30-microservices-using-docker-container-clusters.html
