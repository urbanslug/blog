---
layout: post
title: Microservices using docker container clusters
date:  2017-10-30 22:20:40
category: ECS AWS Microservices CI CD Devops
---

While writing the post on [implementing a code pipeline in a
microservice architechture]. I realised I have a lot of introduction to
do regarding what some of the tools are and how they work.

## Microservices and modularized applications
A microservice is an application with a single task
that exposes an API with which to interact with.  
Think of it as breaking down a large application into small pieces of
abstraction --- in short, modularizing the application itself.

![](/images/Content/software_architechture/microservices_combined.png)

Modularizing your monolithic application sounds fun and all — don't
programmers just love to wipe clean the slate and strart over with
the lessons learned. So say you've done this successfully or better
yet you started building your application with a microservice
architechture in mind. Now comes the real questions:

- How do we deploy these many small applications, keep them in sync and up at all times?
- How do we  deploying only a single one of them without affecting the rest?

Moreover, these microservices interface over HTTP. Yaaay overhead!
If you care so much you can have them talk over sockets and avoid the
rest of the network stack. I have never actually done this but I know
it can be done.

At this point you probably feel something like

![](https://media.giphy.com/media/LJemLPJs6dBhm/giphy.gif)


## Enter containers
How can we even manage a single microservice? There old things called
containers that have gained a great surge in popularity over the last
few years mainly thanks to docker.
They're an easy way to create a single service
operating system/computer/machine abstraction with little overhead
compared to virtual machines such as needing a [hypervisor layer]
because they make direct calls to the host operating systems' kernel.
I hope I've made a case for containers there.

A low bar of entry into them being docker containers. To create a docker
conainer all you need is a [Dockerfile] at the root of your application's
project. This file will then contain instructions on how to construct
this virtual operating system, how to run it, which ports it should use,
environment variables it needs and so forth. You can learn more about
docker containers [here](https://docs.docker.com/).

### Docker
These guys have created a container ecosystem around their product.
They offer documentation, a registry and docker containers. The biggest
concerns being they make breaking changes and that the security might
not be the best. I personally have not ran into issues with docker.
Docker can be broken down into 3 main categories:

#### Images
These are  lightweight, standalone filesystem instances in an
archived/froezen state. You can pull and push them to docker registries
as well as production environments giving you a server environment that
mirrors the development one, something that can be of great help.

#### Registry
These are respositories not of code but of docker images. Think of them as
package managers for your docker images.
Docker offers [docker hub] a registry to share containers and a place to
pull images, we shall talk about docker hub soon. There are other registries
such as the ones offered per AWS region to ECS users.

#### Containers
These are runtime instances of your docker image. They lack persistent
state, are cheap to create, tear down and archive.

## Managing multiple containers in production
So we've figured out what docker is or at least have an idea of
what it would entail.
Assumging we've created containers for each service. How do we make sure
they're all up at the same time, running the versions of your services
that you want? Let's save ourselves the pain of creating a tool to do
this. There are three famous ones: [Kubernetes from Google],
[ECS from AWS] and [docker swarm from docker].
To stay on topic let's focus on ECS.

### Container clusters
We've decided to go with ECS to manage our containers. To manage multiple
containers in production it's wise to use a cluster management and
orchestration system. But what are clusters let alone container clusters?

Sometimes it's much cheaper to create a large computer out of networking
together small computers. For a hardware example scaleway [clusters ARM
processors to offer a cloud computing service]. Sometimes it's just plain
impossible to build a computer of the capabilities one needs so you have
to combine many of them into one big one.

This post is about containers so let's focus on those clusters instead.
Clustered containers are groups of containers working together to achieve
a goal. For example nginx and a web application can form a cluster
where you can increase nginx or your web application containers
depending on the load you are handling.

[implementing a code pipeline in a microservice architechture]: 2017-11-28-code-pipeline-microservices.html
[Dockerfile]: https://docs.docker.com/engine/reference/builder/
[Kubernetes from Google]: https://kubernetes.io/
[ECS from AWS]: https://aws.amazon.com/ecs/
[docker swarm from docker]: https://docs.docker.com/swarm/overview/
[docker hub]: https://hub.docker.com/
[hypervisor layer]: https://en.wikipedia.org/wiki/Hypervisor
[clusters ARM processors to offer a cloud computing service]: https://www.scaleway.com/armv8-cloud-servers/
