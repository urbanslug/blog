---
layout: post
title:  ThreadScope patch.
date: 2014-03-05 22:45:12
tags: Programming, Haskell
---

So I had some issues installing threadscope earlier.

After having installed the dependencies I had problems with building ThreadScope due to changes in ghc. The errors are right here: [gist to threadscope errors]

A few tips on haskell on archlinux: 
```text
     Don't use Pacman, AUR or another package manager to install anything other than:
     ghc and cabal.
     For everything else use cabal install i.e `cabal install package_name`
```

Anyhoo the real matter here is that there was a problem with the source in ThreadScope.


The assumption is that you have all the dependencies met.
Get ThreadScope source files from: [ThreadScope source]

Here is the patch: {% gist 9367418 threadscope.diff %}


If you have issues applying the patch read on it here: [How to apply a patch quickly.]({% post_url 2014-03-05-How-to-apply-a-patch-quickly %})


99% of it is really thanks to [source of diff] where you can see the patch was submitted by Bob Ippolito as an attachment.

The issue with the patch there is that it misses the tiny change GUI/Main.hs 

[gist to threadscope errors]: https://gist.github.com/urbanslug/9365829
[source of diff]: http://trac.haskell.org/ThreadScope/ticket/32
[ThreadScope source]: http://hackage.haskell.org/package/threadscope
