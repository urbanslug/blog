---
layout: post
title: Universal environment variables
date: 2015-04-02 03:15:33
Categories: Emacs, Shell
---

## The problem

We want to have environment variables that are accessible from within emacs and our shell as well as other REPLs (cabal repl or ghci if you're writing haskell).

Why would we want to use environment variables? It depends really, mainly if we want to pass info to our app/code and we can't put that in config files plus we are clever enough not to hardcode such things.

I run emacs from withing Xorg like most people do. The problem with this is that it couldn't read the environment variables set in my `~/.bashrc`, `~/.zshrc` et cetera. So I needed to find a way to set these variables in a place where they could be accessible from other "places" and not just emacs. Something more *universal*.

There is a solution that involves setting environment variables that will be used **WITHIN** emacs in the ~/.emacs file but that isn't what I wanted. In case you want to read on it here's the [environment variables within link.]


## The solution

Short version: Add the environment variables to your `~/.profile` or `/etc/profile`

Long version: Lo and behold this file `~/.profile` or `/etc/profile`.  
You can set your environment variables there that will be loaded before X starts and that will be loaded even when you log in via SSH. You can then access these variables accross everything that runs in the terminal, from within xorg and so forth.

So the basic workflow is:
```text
open or create ~/.profile or /etc/profile depending on your purpose
add your environment variables.
Save the file.
```
I recommend that look at this [stack overflow question] which is where I drew my answer.

[stack overflow question]: http://stackoverflow.com/questions/11005478/how-to-access-a-bash-environment-variable-from-within-r-in-emacs-ess
[environment variables within link.]: http://ergoemacs.org/emacs/emacs_env_var_paths.html 
