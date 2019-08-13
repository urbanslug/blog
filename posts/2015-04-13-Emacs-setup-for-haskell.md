---
layout: post
title: Emacs Setup for Haskell
date: 2015-04-13 03:15:33
Categories: Emacs, Haskell
---

This post assumes that you have a little experience with emacs and maybe some experience writing haskell.  
I assume that you're using emacs and not xemacs or something else and therefore your init file is ~/.emacs. You can also find your init file via `M-: RET (find-file user-init-file) RET`.  
To set up emacs so that you can install packages add the following to your ~/.emacs:

```lisp
(require 'package)
(add-to-list 'package-archives
  '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)
```

I personally believe that melpa alone is enough.

Then to install packages:
```lisp
M-x RET package-install RET <package-name> RET RET
```

Every time you make a save your ~/.emacs file instead of restarting emacs to make sure everything is still okay, run
```lisp
M-x eval-buffer RET
```

To install haskell packages (I assume you already have cabal) use:
```lisp
$ cabal install <package-name>
```



Let's get started. Here's a list of all the things that we'll need.  
You can chose to install them all now or install them as we go on and as you see the need for them.

#### Haskell packages to install  

* [structured-haskell-mode](https://github.com/chrisdone/structured-haskell-mode)
* [hasktags](http://hackage.haskell.org/package/hasktags)

#### Emacs packages to install  

* [flycheck](http://www.flycheck.org/)
* [flycheck-haskell](https://github.com/chrisdone/haskell-flycheck)
* [haskell-mode](https://github.com/haskell/haskell-mode/wiki)
* [rainbow-delimiters](www.emacswiki.org/emacs/RainbowDelimiters)
* shm (the emacs package isn't called structured-haskell-mode but shm)
* [ace-jump-mode](http://www.emacswiki.org/emacs/AceJump)
* [auto-complete-mode](http://www.emacswiki.org/emacs/AutoComplete)


## Setting up the PATH for emacs.
To have emacs point to where your haskell packages are installed add this to your ~/.emacs:
```lisp
(let ((my-cabal-path (expand-file-name "~/.cabal/bin")))
  (setenv "PATH" (concat my-cabal-path ":" (getenv "PATH")))
  (add-to-list 'exec-path my-cabal-path))
```
  
You can replace `"~/.cabal/bin"` with a sandbox but I had issues with this when the sandbox cabal version didn't keep up with the universal packages. So I would recommend you use the user-wide one ~/.cabal/bin.  
*Mind you, you can can use this to add anything to your emacs specific PATH.*

## Haskell mode

I hope you are already using haskell mode but if you aren't it's okay. This post is for you. This is going to be the major mode that you will be using. It would be wise to read the [haskell mode wiki].

Install haskell-mode from within emacs.
```lisp
M-x RET package-install RET haskell-mode RET RET
```


To enable the minor mode which activates keybindings associated with interactive mode, add:
```lisp
(require 'haskell-interactive-mode)
(require 'haskell-process)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
```

*Make sure to use haskell-interactive-mode as done above and not inferor haskell mode which has been deprecated.*

To jump to the import list add this. *I prefer to bind this to f12.*
```lisp
(define-key haskell-mode-map [f12] 'haskell-navigate-imports)
```

To get import suggestions. For adding, removing or commenting out of imports and a process log use:
```lisp
(custom-set-variables
  '(haskell-process-suggest-remove-import-lines t)
  '(haskell-process-auto-import-loaded-modules t)
  '(haskell-process-log t))
```

General emacs haskell-mode bindings from the haskell-mode wiki:
```lisp
(define-key haskell-mode-map (kbd "C-c C-l") 'haskell-process-load-or-reload)
(define-key haskell-mode-map (kbd "C-`") 'haskell-interactive-bring)
(define-key haskell-mode-map (kbd "C-c C-t") 'haskell-process-do-type)
(define-key haskell-mode-map (kbd "C-c C-i") 'haskell-process-do-info)
(define-key haskell-mode-map (kbd "C-c C-c") 'haskell-process-cabal-build)
(define-key haskell-mode-map (kbd "C-c C-k") 'haskell-interactive-mode-clear)
(define-key haskell-mode-map (kbd "C-c c") 'haskell-process-cabal)
(define-key haskell-mode-map (kbd "SPC") 'haskell-mode-contextual-space)
```
*It will always prompt to begin a new project. Don't fight it, just go with it. It won't create any files.*

Same as the ones above but are good to have in cabal-mode i.e when one is in the repl.
```lisp
(define-key haskell-cabal-mode-map (kbd "C-`") 'haskell-interactive-bring)
(define-key haskell-cabal-mode-map (kbd "C-c C-k") 'haskell-interactive-mode-clear)
(define-key haskell-cabal-mode-map (kbd "C-c C-c") 'haskell-process-cabal-build)
(define-key haskell-cabal-mode-map (kbd "C-c c") 'haskell-process-cabal)
```

Which GHCi process will we use in our repl? I prefer using cabal-repl instead of ghci because it loads one entire project automatically.
If you're using a modern version of cabal I would go with cabal repl.  
To use cabal-repl as your GHCi process add the following:
```lisp
(custom-set-variables
  '(haskell-process-type 'cabal-repl))
```

##### Tags
You sometimes need to jump to the definition of a function that you are using in the same file. For this we have tags within haskell-mode. It however requires the haskell package hasktags so:
```lisp
$ cabal install hasktags
```

To enable generation of tags when you save a file use:
```lisp
(custom-set-variables
  '(haskell-tags-on-save t))
```

To use both ghci and tags for jumping to a definition you can use the following. This way when GHCi fails because the code can't compile it will fall back to tags.
```lisp
(define-key haskell-mode-map (kbd "M-.") 'haskell-mode-jump-to-def-or-tag)
```
*This will be generating a file with the name TAGS within your projects. It's a good idea to put this file in your .gitignore*

To have what we see in our repl look good we could use, [printing in the repl]
```lisp
(setq haskell-interactive-mode-eval-mode 'haskell-mode)
```


##### Debugging
Check out how to use the [debugger in haskell mode].

##### Autocompletion.
Since ghc version 7.8 you can use the `TAB` key to auto complete suggestions.

## Flycheck and haskell-flycheck.

These are gems my friend. GEMS I TELL YA!!

They compliment each other to compile your code in the background each time you save the file you are working on. If there is an error in your code the line with an error is underlined in red and in case of a warning it's underlined in yellow. You get a pop up when you hover over the error with the mouse, the minibuffer also shows the error when the cursor is over the line in question. This means you don't have to wait for compilation to fix those tiny errors.

Much to my surprise [flycheck] and [haskell-flycheck] also give style suggestions as I assume HLint would top of error and warning checking.

I previously used ghc-mod for the purposes for which I am using flycheck now. I prefer flycheck because it does this for many more langauges.

To install
Install flycheck and haskell-flycheck from within emacs.
```lisp
M-x RET package-install RET flycheck flycheck-haskell RET RET
```


To use flycheck add this to your .emacs
```lisp
(add-hook 'after-init-hook #'global-flycheck-mode)
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-haskell-setup))
```

## Structured Haskell Mode and shm

The emacs package `shm` depends on the haskell package `structured-haskell-mode` so you have to install both.
{% highlight bash%}
$ cabal install structured-haskell-mode
```

```lisp
M-x RET package-install RET shm RET RET
```

It's the most impressive haskell in emacs "feature" for me. You should definitely read the [structured haskell mode README] if you want to know how to use it well.

It helps you write in a clear and consistent style all through. It also helps with those little things that IDEs do and text editors don't plus much more. You'll understand what I mean after you use it.

To enable this I you should add the following to your init file:
```lisp
(add-hook 'haskell-mode-hook 'structured-haskell-mode)
(define-key shm-map (kbd "C-c C-s") 'shm/case-split)
```

If you try structured haskell mode and you don't like it replace the above with:
```lisp
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
```

## Rainbow delimiters.
I haven't yet actually felt the value addition of this yet but it's purpose it to show you brackets in different colours so that it's simple to identify when you have an open bracket or something.

You can check it out in the [rainbow delimiters wiki page].

It's not very useful when I have structured haskell mode which automatically closes brackets. I'll probably unistall it. You can however try it if you want.

Installing rainbow delimiters mode:
```lisp
M-x RET package-install RET rainbow-delimiters RET RET
```

For usage:
```lisp
(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
```

## Auto-compelete mode
This does just that. I'm not sure if there's need for it or haskell-mode already does auto complete but I love it because I get autocomplete in other modes not just haskell mode.
```lisp
(package-initialize) (global-auto-complete-mode)
(add-hook 'prog-mode-hook 'auto-complete-mode) ;; Added for all programming modes.
```

## Ace jump mode.
This also has nothing to do with haskell it's just really handy and you can use it anywhere.
Use it to jump to a letter that is at the start of a word. It eliminates a whole lot of scrolling about.

Installing ace jump mode:
```lisp
M-x RET package-install RET ace-jump-mode RET RET
```

To use it, add the following to your init file:
```lisp
(add-to-list 'load-path "which-folder-ace-jump-mode-file-in/")
(require 'ace-jump-mode)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)
(setq ace-jump-mode-gray-background) ;; This line makes it work in black background coloured terminals.
```

*You can use ace-jump mode with other backgrounds not just grey, I use grey because it just worked great for me.*

#### Stuff that I think would be fun to try out:

* present *(this failed to install due to ghc 7.10 dependency issues so I will update this post regarding it after I have used it.)*


## Handy keybindings to remember:
There are many more of course but I really love these:



| Key binding | Purpose                                                                                                 |
|:-----------:|:-------------------------------------------------------------------------------------------------------:|
|C-j          |Newline indent, also automatically adds a newline and comma when creating a list.                        |
|M-^          |Delete indentation relative to parent. Opposite of C-j.                                                  |
|M-a          |Jump to start of a parent                                                                                |
|)            |Jump to end of a parent                                                                                  |
|M-r          |Raise the current node to replace its parent                                                             |
|C-c C-s      |Case split.                                                                                              |
|M-;          |Wrap in multiline comment i.e   `{- <code>  -}`                                                          |
|C-c C-q      |Works with C-j to add imports, this qualifies/unqualifies them.                                          |
|M-k          |Kill/paste node taking indentation to account.                                                           |
|C-k          |Kill/paste line taking indentation to account.                                                           |
|C-y          |Yank/copy take indentation into account                                                                  |
|C- \`        |Start the REPL buffer. The project not loaded in it.                                                     |
|C-c C-l      |Compile and load a Haskell module into your REPL.                                                        |
|C-c C-c      |Compile the whole Cabal project.                                                                         |
|C-x \`       |Jump to the next error, or you can move your cursor to an error in the REPL and hit `RET` to jump to it. |
|C-c C-k      |Clear screen in REPL.                                                                                    |
|F12          |Jump to import list.                                                                                     |
|C-u C-c c    |To run an arbitrary Cabal command.                                                                       |
|C-c c        |To run some common Cabal commands.                                                                       |
|C-u C-c C-t  |To print the type of the top-level identifier at point.                                                  |
|C-c C-t      |To print the type of the top-level identifier at point in the REPL and in the message buffer.            |
|C-c C-i      |To print the info of the identifier at point in a buffer. Hit q to close.                                |
|M-.          |Jump to definition or tag.                                                                               |
|C-c SPC      |Use ace jump mode.                                                                                       |




## Finally

All that init file code in one file that you can conveniently paste in your init file.

```lisp
;; --------- Package lists
(require 'package)
(add-to-list 'package-archives
  '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)
;; --------- </ Package lists


;; ---------------- Haskell-mode
(let ((my-cabal-path (expand-file-name "~/.cabal/bin")))
  (setenv "PATH" (concat my-cabal-path ":" (getenv "PATH")))
  (add-to-list 'exec-path my-cabal-path))

(require 'haskell-interactive-mode)
(require 'haskell-process)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
  
; Makes editor focus on imports block in source file
;; (eval-after-load 'haskell-mode
;;          '(define-key haskell-mode-map [f12] 'haskell-navigate-imports))
(define-key haskell-mode-map [f12] 'haskell-navigate-imports)

;;; For module import suggestions.
(custom-set-variables
  '(haskell-process-suggest-remove-import-lines t)
  '(haskell-process-auto-import-loaded-modules t)
  '(haskell-process-log t))

;; Key bindings from the wiki
(define-key haskell-mode-map (kbd "C-c C-l") 'haskell-process-load-or-reload)
(define-key haskell-mode-map (kbd "C-`") 'haskell-interactive-bring)
(define-key haskell-mode-map (kbd "C-c C-t") 'haskell-process-do-type)
(define-key haskell-mode-map (kbd "C-c C-i") 'haskell-process-do-info)
(define-key haskell-mode-map (kbd "C-c C-c") 'haskell-process-cabal-build)
(define-key haskell-mode-map (kbd "C-c C-k") 'haskell-interactive-mode-clear)
(define-key haskell-mode-map (kbd "C-c c") 'haskell-process-cabal)
(define-key haskell-mode-map (kbd "SPC") 'haskell-mode-contextual-space)

; The below commands pretty much match the ones above, but are handy to have in cabal-mode, too:
(define-key haskell-cabal-mode-map (kbd "C-`") 'haskell-interactive-bring)
(define-key haskell-cabal-mode-map (kbd "C-c C-k") 'haskell-interactive-mode-clear)
(define-key haskell-cabal-mode-map (kbd "C-c C-c") 'haskell-process-cabal-build)
(define-key haskell-cabal-mode-map (kbd "C-c c") 'haskell-process-cabal)

; ghci process within emacs
(custom-set-variables
  '(haskell-process-type 'cabal-repl))

; Hasktags
; customization variable to enable tags generation on save
(custom-set-variables
  '(haskell-tags-on-save t))

(define-key haskell-mode-map (kbd "M-.") 'haskell-mode-jump-to-def-or-tag)

;printing mode
(setq haskell-interactive-mode-eval-mode 'haskell-mode)
;; ---------------- </ Haskell-mode

;; --------------- flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-haskell-setup))
;; --------------- </ flycheck


;; -------------- structured haskell mode
(require 'shm)
;; use indentation from structured haskell mode
(add-hook 'haskell-mode-hook 'structured-haskell-mode)
(define-key shm-map (kbd "C-c C-s") 'shm/case-split)
;; -------------- structured haskell mode


;; ------------------- Auto complete mode
(package-initialize) (global-auto-complete-mode)
(add-hook 'prog-mode-hook 'auto-complete-mode) ;; Added for all programming modes.
;; -------------------- </ Auto complete mode


;; -------------------- Ace jump
(add-to-list 'load-path "which-folder-ace-jump-mode-file-in/")
(require 'ace-jump-mode)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)
(setq ace-jump-mode-gray-background) ;; Otherwise it will set background to same as emacs backgorund in terminal.
;; ---------------------- </ ace jump


;; --------- Rainbow delimiters
; show each level of parenthesis or braces in a different color.
(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
;;--------- </ Rainbow delimiters

```

[structured haskell mode README]: https://github.com/chrisdone/structured-haskell-mode#structured-haskell-mode
[flycheck]: http://www.flycheck.org/
[haskell-flycheck]: https://github.com/chrisdone/haskell-flycheck
[haskell mode]: https://github.com/haskell/haskell-mode/wiki
[structured haskell mode]: https://github.com/chrisdone/structured-haskell-mode
[haskell mode wiki]: https://github.com/haskell/haskell-mode/wiki
[printing in the repl]: https://github.com/haskell/haskell-mode/wiki/Haskell-Interactive-Mode-REPL#printing-mode
[rainbow delimiters wiki page]: http://www.emacswiki.org/emacs/RainbowDelimiters
[debugger in haskell mode]: https://github.com/haskell/haskell-mode/wiki/Haskell-Interactive-Mode-Debugger
[hasktags]: http://hackage.haskell.org/package/hasktags
    
