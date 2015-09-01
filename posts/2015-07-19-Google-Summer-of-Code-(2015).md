---
layout: post
title: Google Summer of Code (2015).
date: 2015-07-19 13:30:44
categories: Programming GSoC Yesod Yesod-Devel
---

This post is long overdue and I should've started writing on this a while ago but oh well I will write as much in the remaining time and try to make up for lost time.

So I sent in a proposal for Google Summer of Code aimed at [haskell.org].
The aim of the proposal was **To build an improved yesod-devel server**. Let the name not fool you, this server is supposed to work with all [WAI] compliant haskell web applications such as yesod, spock, scotty applications among others.
My mentor has been [Michael Snoyman]. I've also been working closely with [Michael Sloan] and [Daniel Beskin].
It started on a high note. I was added to the [FP Complete github organisation]. That had me very excited because of the kind of people who are in that organisation plus it's **THE HASKELL** organisation in my opinion. So that's the social aspect. Let's talk programming.

# ide-backend
So FP Complete recently released a library that acts as a wrapper around the [GHC API], that is, [ide-backend] (I wrote about it in an earlier post).
This library was extracted from the online FP Complete haskell ide. It was therefore still aimed at working  a cleint - server model where the client and server are on different boxes. The client (the package depending on ide-backend) had to explicitly specify the files to be copied from the cleint to the server. This worked in the FP Complete use case but wouldn't work in our use case.

So we had to make it work in a local environment. This was my first task.

The aim here was to enable automatic source file (as well as data files and everything else) discovery by ide-backend so that it can submit these files for compilationa by GHC.  
To do this, one has to specify that they want to use ide-backend with a local working directory under `configLocalWorkingDir` in [`defaultSessionConfig`]. `configLocalWorkingDir` is a value of type `Maybe FilePath`. It defaults to (Nothing :: Maybe FilePath) and has ide-backend working in a client-server environment. When `configLocalWorkingDir` is set it uses the given file path as the place it will look for source files, data files and everything in between.

Functionality for ide-backend to work in a non-server environment was finally merged in [this commit onwards on github]. It's not yet on the hackage version of ide-backend as of writing this post but it will be pushed soon enough.

# yesod-devel
Then came the challenge of yesod-devel. This is the "client" in our case that depends on ide-backend. 
Quite honestly the fact is that ide-backend is the one doing most of the heavy lifting while yesod-devel coordinates everything.

The objectives of yesod-devel are:

  * Automatic source and data file discovery.
  * Load code
  * Compile to bytecode
  * Run the code
  * Read environment variables
  * Grab compiler error messages and display them on the browser
  * Listening for changes in the current working directory
  * Automatic code reloading and recompilation
  * Perform reverse proxying for the web application

[haskell.org]: https://www.haskell.org
[WAI]: https://www.yesodweb.com/book/web-application-interface
[Michael Snoyman]: https://github.com/snoyberg
[Michael Sloan]: https://github.com/mgsloan
[Daniel Beskin]: https://github.com/ncreep
[FP Complete github organisation]: https://github.com/fpco
[GHC API]: https://wiki.haskell.org/GHC/As_a_library
[ide-backend]: https://hackage.haskell.org/package/ide-backend-0.9.0.2
[`defaultSessionConfig`]: http://hackage.haskell.org/package/ide-backend-0.9.0.2/docs/IdeSession.html#v:defaultSessionConfig
[this commit onwards on github]: https://github.com/fpco/ide-backend/tree/19561d9ff5f496d6556f38992bc8d08896d54091
