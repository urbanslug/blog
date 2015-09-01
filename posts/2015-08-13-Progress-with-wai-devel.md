---
layout: post
title: Progress with wai-devel
date: 2015-08-13 15:58:24
categories: Programming Haskell WAI wai-devel
---

wai-devel is a  development server for wai compliant haskell web applications.  

Its name changed from yesod-devel (the haskell reddit community suggested this).
You can find it at: [https://github.com/urbanslug/wai-devel]

## What wai-devel expects from your application
Since wai-devel is very loosely coupled to your application it expects mainly two things from your application:
a **host:port** pair and a function, **Application.develMain**.

Due to it's dependence on ide-backend it also expects you to set the environment variable `GHC_PACKAGE_PATH`.

Mine for example is: `export GHC_PACKAGE_PATH=~/.stack/snapshots/x86_64-linux/lts-2.22/7.8.4/pkgdb:`

The host:port pair is expected to be passed in as two environment variables:
wai_host and wai_port for example:

* export wai_host=127.0.0.1
* export wai_port=3001

Better yet, the application itself should set the environment variables as in the example code below.

wai-devel looks for a function Application.develMain
I have a [fork of yesod], that builds a yesod binary which
generates a scaffold with this function implemented.
I recommend using it to generate the scaffold with which to try out wai-devel with.

The specifics of how to set the port and host within yesod applications will obviously change.
The point of this fork is to generate a scaffold that works with wai-devel out of the box.

Here is a snippet develMain function from my yesod fork.

```haskell
-- | main function for use by yesod devel
develMain :: IO ()
develMain = develMainHelper' getApplicationDev

develMainHelper' :: IO (Settings, Application) -> IO ()
develMainHelper' getSettingsApp = do
    (settings, app) <- getSettingsApp

    _ <- unsetEnv "wai_port" >> setEnv "wai_port" "3001"
    _ <- unsetEnv "wai_host" >> setEnv "wai_host" "127.0.0.1"

    let settings'  = setPort (3001 :: Port) settings
        settings'' = setHost ((read "127.0.0.1") :: HostPreference) settings\'

    sock <- createSocket

    runSettingsSocket settings'' sock app

    where -- | Create the socket that we will use to communicate with
          -- localhost:3001 here.
          createSocket :: IO Socket
          createSocket = do

            sock <- socket AF_INET Stream defaultProtocol

            -- Tell the OS *not* to reserve the socket after your program exits.
            setSocketOption sock ReuseAddr 1

            -- Bind the socket to localhost:3000 and listen.
            -- I wonder why I can't specify localhost instead of iNADDR_ANY
            bindSocket sock (SockAddrInet 3001 iNADDR_ANY)
            listen sock 2
            return sock
```


> During socket creation I made sure that the socket option ReuseAddr has been set to 1.  
> This way the operating system doesn't hold on to the socket after the program exits.
> This is important for when wai-devel takes note of file changes and the development server is restarted.


## Ignoring files and directories
wai-devel expects that there will be a single `Main.main` function.
In the case of having more than one, for example with yesod, we ignore all but one.
Specifically, we ignore the file app/DevelMain.hs.
There is no need for app/devel.hs so it has been removed in my fork.

Moreover, wai-devel ignores files in your `test/` directory.  
This is because wai-devel depends on ide-backend which will attempt to build all files in the current working diretory,
including your test directory. This leads to a world of hurt because the test/ directory also has a `Main.main` function.  


*Please report an issue if you would like any file ignored during builds.*

# Moved to stack
Since the Haskell community has moved in this direction, so has wai-devel.  
wai-devel only depends on cabal in that stack and ide-backend depend on Cabal the library.
Otherwise, the cabal binary is not used and hasn't been tested to work with wai-devel.

## Compatible versions of GHC
Currently wai-devel is built and tested against:

* GHC-7.8
* GHC-7.10


## Regarding file watching
wai-devel watches for file changes on files with the following extensions:

* hamlet
* shamlet
* julius
* lucius
* hs
* yaml

When a change takes place wai-devel will recompile and re-run your application
on localhost:3001 or display an error if any on the browser at localhost:3000

*If you would want another extension added to the list of file extensions to watch for please report it as an issue.*

## Command line arguments

Currently wai-devel takes only these two arguments and the two are optional.
If you feel the need for more arguments please report it as an issue on github.

* -r *to turn off reverse proxying*
If this is turned on you will access your application at an address that is specific to
your web application or web framework.

* --show-iface [hi file] *passes this command to ghc*
Same as ghc --show-iface

[fork of yesod]: https://github.com/urbanslug/yesod
[https://github.com/urbanslug/wai-devel]: https://github.com/urbanslug/wai-devel
