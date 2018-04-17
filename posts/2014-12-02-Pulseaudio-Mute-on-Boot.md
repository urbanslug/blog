---
layout: post
title: Pulseaudio mute on boot.
date: 2014-12-02 04:38:32
tags: Linux, Pulseaudio
---

This might work for you or fail to. Doesn't hurt to try.
  
I got this info at [Pulseaudio original post] and just refined it.

Open /usr/share/pulseaudio/alsa-mixer/paths/analog-output.conf

Locate the following sections:

    [Element Speaker]
    switch = mute
    volume = off

    [Element Desktop Speaker]
    switch = mute
    volume = off

  
Change the "volume" value so that it reads:

    [Element Speaker]
    switch = mute
    volume = merge

    [Element Desktop Speaker]
    switch = mute
    volume = merge

I have noticed after installing rythmbox this issue has returned. I shall find a fix for it soon. Also music on rhythmbox is awesome. Gnome music looks good but it doesn't work. Ever. I shall update with a fix for rhythmbox.


[Pulseaudio original post]: http://www.pclinuxos.com/forum/index.php?topic=112440.0
