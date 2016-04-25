---
layout: post
title: Packaging python projects.
date: 2016-02-14 17:45:13
category: Python packaging
---

A while ago I had quite a problem figuring out how to package a python project.
This is because the python community has no set standard on how to
package python projects.

So I decided to fix this for those who shall come after me
and wish to make something quick in python.
As an example project I came up with [Arithmetic]
and had to come up with [WaterInfrastructure].

It is something close to a python project quickstart.  
Incidentally, it also happens to be an example of
**functional programming in python**.


The point is to show you how to structure:

- your tests (which testing framework might be good)
- code
- package it for distribution via a tool like pip or pypy and so forth
- (all these in functional style)

> *I use Python 3.*

### Arithmetic
The directory structure for this is as follows:
```
.
├── README.md
├── arithmetic
│   ├── __init__.py
│   ├── __main__.py
│   ├── division
│   │   ├── __init__.py
│   │   ├── __main__.py
│   │   └── divide.py
│   ├── multiplication
│   │   ├── __init__.py
│   │   ├── __main__.py
│   │   └── multiply.py
│   └── tests
│       ├── __init__.py
│       ├── __main__.py
│       ├── division
│       │   └── test_divide.py
│       └── multiplication
│           └── test_multiply.py
└── setup.py
```

### WaterInfrastructure
[WaterInfrastructure] is the other project I wrote following the above guidelines.
This was as an interview question (this is a form of attribution :D).

*Question: I have a problem, do python projects have to have pyc files in
the same directory as the source file?*

There really isn't much to say here you can learn more by browsing through
the code.

[Arithmetic]: https://github.com/urbanslug/Arithmetic
[WaterInfrastructure]: https://github.com/urbanslug/WaterInfrastructure
