---
layout: post
title: Pipeline as Code - putting everything together
date:  2017-10-16 20:10:18
category: Devops CI CD
---

In this post we shall implement a continuous deployment pipeline using free
(and some open source) tools to make your life a lot easier.

We will use the flowchart below as a visual guide of all major components and
the way we move from one to the other:
![](/images/Content/Flowcharts/CD\ flowchart\ 0.svg)

In this post we don't have steps such as planning, configuration management and
the like; those are conceptual. The diagram represents the actual places that
our program should live in at all times. It's a flowchart but for the actual
program to follow.

Think of each component in the flowchart as a tool that exposes an API with
everything else abstracted away. However, going onward I shall explain the
easiest way to create something to build each component.

## Version control
I assume the tool you're using for Version Control is git. If it isn't it will
work as long as it has a way of branching off a the main codebase, making
changes then mergeing those changes back into the main codebase. It should also
be able to create tags.
Git is used in a lot of places and is supported by a lot of tools further down
the pipeline.

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

## Testing and Integration
### Continuous integration and continuous deployment with Travis CI
Travis CI is a mix of open source and some propertary tools .
To quote them "Travis CI is run as a hosted service, free for Open Source, a
paid product for private code, and it’s available as an on-premises version
(Travis CI Enterprise)."

Their [github page](https://github.com/travis-ci) and
[info page](https://github.com/travis-ci/travis-ci).
To learn how to get started with travis in your project you can read
[get started doc](https://docs.travis-ci.com/user/getting-started/).
Moving on, I assume you have (gained) enough experience with travis to go on.

`after_success` vs `deploy`

> Exposes: deploy

## Deployment
### Preparing the deploy environment

### Deploying to a host
#### Digital ocean
#### AWS
