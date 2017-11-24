---
layout: post
title: Pipeline as Code - microservices
date:  2017-10-30 22:20:40
category: ECS AWS Microservices CI CD Devops
---

## Microservices and modularized applications
Again another buzzword, well more of a former buzzword, but still what
does it mean? A microservice is just an application with a single task
that exposes an API with which to interact with. Think of it as
breaking down a large application into small pieces of abstraction.
Basically modularizing an application.

// microservice diagram

Modularizing your monolithic application sounds fun and all — don't we
just love to  wipe clean the slate and strart over with the lessons learned.
So say you've done this successfully or better yet you started building
your application with a microservice architechture in mind Now comes the
beast. How do we deploy these many small applications, keep them in
sync and up at all times?

Moreover, these microservices interface over HTTP. Yaaay overhead! If you care so
much you can have them talk over sockets and avoid the rest of the
network stack. I have never actually done this but I know it can be done.

## Enter containers
How can we even manage a single microservice? There these old things
called containers that have gained a great surge in popularity over the
last few years mainly thanks to docker.
They're an easy way to create a single service
operating system/computer/machine abstraction with little overhead
compared to virtual machines such as needing a hypervisor layer.
I hope I've made a case for containers there.

A low bar of entry into them being docker containers. To create a docker
conainer all you need is a [Dockerfile] at the root of your application's
project. This file will then contain instructions on how to construct
this virtual operating system, how to run it, which ports it should use,
environment variables it needs and so forth. You can learn more about
docker containers [here](https://docs.docker.com/).

### Docker
These guys have created a real container ecosystem around their product.
The offer [docker hub] a registry to share containers and a place to pull
images, we shall talk about docker hub soon.

#### Images
These are  lightweight, standalone instances of operating
systems in an archived or froezen state.

#### Registry
These are respositories not of code but of images. Think of them as
package managers for your docker images.

#### Containers
These are runtime instances of your docker image. It lacks persistent
state, cheap to create and tear down and archive.

## Managing multiple container clusters
So we have figured out what docker is or at least have an idea of
what it would entail and say we've created containers for each service.
How do we make sure they're all up at the same time, running the versions
of your services that you want?
Let's save ourselves the pain of creating a tool to do this. There are
three famous ones: [Kubernetes from Google], [ECS from AWS] and
[docker swarm from docker].

### Container clusters
So we've decided to go with ECS to manage our container cluster but what
are clusters anyway?
// to do: explain

To keep this post concise and on topic I'll
talk about ECS.

## ECS
One of it's biggest disadvantages is that it's a tool only available on
AWS that means that relying on it means that you're locked into their
ecosystem which defintely doesn't feel free at all.
The upside is that it works almost out of the box on AWS compared to
say figuring out how to network your <insert favourite cluster management
system name here> over several AWS EC2 instances.

### Amazon ECS agent
ECS is basically the [Amazon ECS agent] running on an EC2 instance but
what is this agent and what good is it?
// to do: add content

Amazon breaks down it's cluster management offereing into 3:

 - Registry
 - Task definitions
 - Clusters

and it sure helps to think of them in that order because your
microservice will go throught those three in that order.

#### Registry
#### Task definitions
#### ECS clusters

## Implementing the code pipeline in a microservice arcitechture on ECS
// should this sub title be "code pipeline on ECS" ?

We finally get to what this post was all about. Implementing the code
pipeline in a microservice arcitechture.

What we want is for our CI tool to build a docker image for us and push
it to the ECS registry. You can write your tool for this but since I'm
pragmatic I use [travis ecs deploy] with travis ci (obviously).



[Dockerfile]: https://docs.docker.com/engine/reference/builder/
[Kubernetes from Google]: https://kubernetes.io/
[ECS from AWS]: https://aws.amazon.com/ecs/
[docker swarm from docker]: https://docs.docker.com/swarm/overview/
[Amazon ECS agent]: https://github.com/aws/amazon-ecs-agent
[docker hub]: https://hub.docker.com/
[travis ecs deploy]: https://github.com/motleyagency/travis-ecs-deploy
