---
layout: post
title: What is a runtime system (Overview).
date: 2015-05-22 11:36:45
Categories: Haskell, RTS
---

This post is aimed at total beginners. Especially those who have no idea what a runtime system is and is a gross oversimplification. :) Let's go. Later I will write something about the haskell runtime system.

This post was inspired by [The GHC Runtime System by Edward Z. Yang (2013)] and [A Runtime System by Andrew W. Appel (1989)].
I also tried reading: [The Implementation of Functional Programming Languages by Simon Peyton Jones, published by Prentice Hall, 1987.] and [Implementing functional languages: a tutorial by Simon Peyton Jones and David Lester. Published by Prentice Hall, 1992.] but they're really big and quite dated. You may also read [wikipedia on runtime systems].

So what is a runtime system? It is a program that is invoked by the compiler to wrap your compiled program/code and gives it bindings to the "API" provided by the environment(*operating system*) that the program is running in.
So the runtime system can't run on it's own. It only runs when the program, for example a haskell program, is running and as you would expect the runtime system would vary between operating systems because the environments are different.

It provides primitive langauge features unlike a standard library which is typically implemented in the language itself.

We count on the runtime system to provide the following services among others:

* Garbage collection.
* Streaming input and output.
* Structured input and output.
* Process suspension
* Handling interrupts and asynchronous events.
* Operating system calls.
* Arithmetic interrupts.
* Execution profiling.
* Assembly language implementation of language primitives.
* Debugging.
* Fun with continuation.
* Foreign language procedure calls.

### Haskell runtime system.
Haskell features that complicate the design of the runtime system:

* Lazy evaluation. *No clear order of execution*
* Ubiquitous concurrency.

However, **emphasis on pure computation** simplifies the design of the garbage collector and Software Transactional Memory.

### GHC and the haskell runtime system.
GHC is broken down into three parts.

  * The compiler
  * The runtime system
  * The boot/base libraries.

As you can see the runtime system is developed as part of GHC but not part of the compiler itself.

### Conclusion
I can't keep this on without turning these into notes I wrote down when reading a paper. So I'll write a different and more specific post later.

### References:

* [The GHC Runtime System by Edward Z. Yang (2013)]
* [A Runtime System by Andrew W. Appel (1989)]
* [wikipedia on runtime systems]

[The GHC Runtime System by Edward Z. Yang (2013)]: http://ezyang.com/jfp-ghc-rts-draft.pdf
[A Runtime System by Andrew W. Appel (1989)]: https://users-cs.au.dk/hosc/local/LaSC-3-4-pp343-380.pdf
[Implementing functional languages: a tutorial by Simon Peyton Jones and David Lester. Published by Prentice Hall, 1992.]: http://research.microsoft.com/en-us/um/people/simonpj/Papers/pj-lester-book/
[The Implementation of Functional Programming Languages by Simon Peyton Jones, published by Prentice Hall, 1987.]: http://research.microsoft.com/en-us/um/people/simonpj/papers/slpj-book-1987/
[wikipedia on runtime systems]: http://en.wikipedia.org/wiki/Runtime_system
