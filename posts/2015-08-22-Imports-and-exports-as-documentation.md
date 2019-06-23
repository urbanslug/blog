---
layout: post
title: Imports and exports as documentation
date: 2015-08-22 20:16:12
tags: Programming, Haskell
---

Lately I've been reading huge haskell code bases quite a lot.
One thing that I have noted to be helpful when documentated
has been the imports section as well as the code having a list of the code it exports.

I don't know whether this is just a non-experienced programmer issue or it cuts across the board.

Documenting imports can happen:

- explicitly through:
    - comments

- implicity through:
    - uniquely qualified imports.
    ```haskell
        import A qualified as X
        import B qualified as Y
    ```
    over
    ```haskell
        import A qualified as X
        import B qualified as X
    ```
    - importing of specific instances (i.e using brackets to specify what one wants to import)

Basically anything that saves the programmer effort or time in:

- Understanding what you're importing
- Why you're importing it
- See the usage of a function and quickly know where it's from

I can't quantify or explain exactly how this helps me understand the code but it really does.
Especially when I can't hoogle a function name
(the internet connections aren't too fast in these parts).
It saves me the time of have to go through several modules trying to figure out where this import is from.

Most of time we are in just too much of a hurry to do this I understand.
I'm a victim of some terrible coding practices but I think it's a good habit to adopt.

Well, the user can use tools like the repl to query where these imports are from
but again when you can save the user time and effort of querying for meta information please do so.
I know it's not possible to do it all the time and everywhere but please do it when and where you can.


Let me illustrate this in some example code:

```haskell
{-|
Module      : Devel.Build
Description : Attempts to compile the WAI application.
Copyright   : (c)
License     : GPL-3
Maintainer  : njagi@urbanslug.com
Stability   : experimental
Portability : POSIX

compile compiles the app to give:
Either a list of source errors or an ide-backend session.
-}

{-# LANGUAGE PackageImports, OverloadedStrings #-}

module Devel.Compile (compile) where

-- Almost everything is dependent on ide-backend.
import IdeSession

-- From Cabal-ide-backend
-- for parsing the cabal file and extracting lang extensions used.
import Distribution.PackageDescription
import Distribution.PackageDescription.Parse
import Distribution.PackageDescription.Configuration
import Language.Haskell.Extension

-- Used internally for showing errors.
import Data.Text (unpack)

-- Utility functions
import Data.Monoid ((<>))
import System.Directory (createDirectoryIfMissing, getCurrentDirectory)

-- Local imports
import Devel.Paths
import Devel.Types
```

Compare with this which I wrote in a hurry.

```haskell
{-|
Module      : Devel.Paths
Description : For filepath related matters.
Copyright   : (c)
License     : GPL-3
Maintainer  : njagi@urbanslug.com
Stability   : experimental
Portability : POSIX

Uses the GHC package to parse .hi files.
Will hopefully be moved upstream to ide-backend.
-}

{-# LANGUAGE OverloadedStrings #-}

module Devel.Paths where

import System.Directory (getCurrentDirectory, doesDirectoryExist, getDirectoryContents)
import Control.Monad (forM)
import Control.Concurrent (forkIO)
import System.FilePath.Glob
import System.FilePath ((</>))
import Data.List
import IdeSession
import Devel.Modules
import System.FilePath.Posix (replaceExtension, dropExtension, takeExtensions)
import qualified Data.ByteString.Char8 as C8
import Control.Monad.IO.Class
import System.FilePath (pathSeparator)
import System.Directory (removeFile)
```

As you can see one can learn quite a bit just from looking at the imports and module documentation alone.

The issue is that it sometimes takes a while for one to clean up their code like this
so it's okay if your imports aren't legible before refactoring.

Another thing, I don't know if it's just an emacs thing but I
can just to my imports and jump between sections of imports with f12.
This is both advantageous to both the one writing the code and the one reading it.  
The point of all of this is that well structured and well documented imports and exports are
a win for both the programmer and the one reading the code.
