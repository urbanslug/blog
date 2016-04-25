---
layout: post
title: Emacs cheatsheet
date: 2015-09-11 01:33:45
category: Emacs
---

These bindings should work for emacs from 24 upwards.  
My emacs config is in my [dotfiles].

| Key binding |            Name         |                  Purpose               |   Package  | From emacs version |
|:-----------:|:-----------------------:|:--------------------------------------:|:----------:|:------------------:|
| C-x SPC     | (rectangle-mark-mode)   | Select a rectangular region.           |    None    |        24.4        |
| C-c SPC     | (ace-jump mode)         | Jump to a letter at start of a word.   |  ace-jump  |       unknown      |
| C-s C-w     | (write-file)            | Save current file as a different file  |    None    |       unknown      |
| C-g C-/     | Redo                    | Redo something you've undone.          |    None    |       unknown      |
| C-/         | Undo                    | Undo something you've done.            |    None    |       unknown      |
| C-x k       | (kill-buffer)           | Close the current buffer.              |    None    |       unknown      |
| C-x C-f     | (find-file)             | Visit a file                           |    None    |       unknown      |
| C-x C-v     | (find-alternate-file)   | Visit a different file                 |    None    |       unknown      |
| C-x C-r     | (find-file-read-only)   | Visit a file as read-only              |    None    |       unknown      |
| C-x 4 f     | (find-file-other-window)| Visit a file in another window/buffer  |    None    |       unknown      |
| C-x 5 f     | (find-file-other-frame) | Visit a file in a new frame            |    None    |       unknown      |
| C-a         | Jump to start of line   | Not emacs specific but IBM home        |    None    |         all        |
| C-e         | Jump to end of line     | Not emacs specific but IBM end         |    None    |         all        |
| C-s M-%     |                         | Queried search and replace             |    None    |         all        |

### Handy information
- For redo keep repeating C-/ to keep redoing, C-g isn't repeated.
- If you “visit” a file that is actually a directory, Emacs invokes Dired, the Emacs directory browser. See [Dired]. You can disable this behavior by setting the variable find-file-run-dired to nil; in that case, it is an error to try to visit a directory.
- When the emacs version is unknown it will most likely work for your version of emacs.
- Here's an awesome [emacs manual] 
- Update emacs packages with M-x package-list-packages RET U x then follow the prompts as you wish.


#### To learn
- General indentation
- Indenting blocks.


#### Handy emacs packages I like
- ace-jump
- auto-complete


#### Extra
- **Updating emacs packages**: `M-x package-list-packages U x` then follow the prompts
- **emacs-nox**: In the arch repos there's emacs-nox described as "The extensible, customizable, self-documenting real-time display editor, without X11 support" Good for SSH.
- My [emacs config](https://github.com/urbanslug/dotfiles/blob/master/.emacs)
- **Installing packages**: "i" mark for install. "x" to install
- `M-x` to run any command. e.g `M-x erc` to IRC from emacs.

[emacs manual]: http://www.gnu.org/software/emacs/manual/html_node/emacs/index.html#SEC_Content
[Dired]: http://www.gnu.org/software/emacs/manual/html_node/emacs/Dired.html#Dired
[dotfiles]: https://github.com/urbanslug/dotfiles/blob/master/.emacs
