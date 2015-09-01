---
title: wai-devel final submission.
date: 2015-08-21 19:14:34
categories: Programming Haskell GSoC WAI wai-devel
---

This is the final day of code submissions to Google for Google Summer of Code.
So it's only fair that I give the community a report on the current state of affairs regarding wai-devel.  
This is more of a very detailed changelog than a blog post about wai-devel.

## What wai-devel expects from your application.
**NOTHING**  
Yes, wai-devel expects nothing from your application.
However, your application shall receive a port number through the environment variable `PORT`.

*UPDATE:*
Due to it's reliance on ide-backend you also have to set the environment variable `GHC_PACKAGE_PATH`

### What PORT is used for:
Your application shall listen for connections on `localhost:<PORT>`
wai-devel by default creates a reverse proxy from port number 3000 to your application which is listening in on PORT.  
You can change the port from the default port 3000 by setting the environment variable PORT yourself.

wai-devel takes PORT and then cycles through various port numbers adding 1 to PORT to find a port that is free, sets that as the destination port and changes the PORT environment variable to that destination port. Therefore we can reverse proxy from PORT to a random port.

Reverse proxying is important for error reporting, future proofing and other ways of abstracting away the services wai-devel provides to your application.

## More reliable dirtiness checking.
wai-devel will use the the module you have chosen to find the files to watch for changes in.
It watches the files it imports and their Template Haskell dependencies as well as the cabal file.

## Compatibility with Haskell wai-applications.
wai-devel works with your usual yesod scaffold from yesod-bin out of the box and should work with other haskell wai apps as long as they use the PORT environment variable.  

You can pass the filepath and function to run via command line arguments `--path` or `-p` and function `--function` or `-f`.
When these aren't passed it assumes Application.develMain (borrowed from yesod).

## Yet to come.
I will be actively developing wai-devel well after Google Summer of Code is over (that is today).

The following are coming next:

- Show build progress in the browser.
- Provide a dashboard page with compilation status, garbage collection statistics, and other useful meta-information.
- Port to Windows. (This depends on ide-backend getting ported to Windows.)

