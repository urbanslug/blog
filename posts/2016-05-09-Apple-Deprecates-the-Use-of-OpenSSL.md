---
layout: post
title: Apple Deprecates the Use of OpenSSL
date: 2016-05-09 13:33:13
tags: OpenSSL, Apple, OSX
---

During a brew upgrade I noticed that apple has deprecated the use of OpenSSL.

Apple has deprecated use of OpenSSL in favour of its own TLS and crypto libraries

```
==> Downloading https://homebrew.bintray.com/bottles/openssl-1.0.2h.el_capitan.bottle.tar.gz
######################################################################## 100.0%
==> Pouring openssl-1.0.2h.el_capitan.bottle.tar.gz
==> Caveats
A CA file has been bootstrapped using certificates from the system
keychain. To add additional certificates, place .pem files in
  /usr/local/etc/openssl/certs

and run
  /usr/local/opt/openssl/bin/c_rehash

This formula is keg-only, which means it was not symlinked into /usr/local.

Apple has deprecated use of OpenSSL in favor of its own TLS and crypto libraries

Generally there are no consequences of this for you. If you build your
own software and it requires this formula, you'll need to add to your
build variables:

    LDFLAGS:  -L/usr/local/opt/openssl/lib
    CPPFLAGS: -I/usr/local/opt/openssl/include
```


I know people are getting tired of all openSSL holes but this sounds like PR or overkill.
Why not use something that exists? Why not name the lib they are favouring over openSSL?
Is this security by obscurity or do they assume their users won't understand it?
Notice this: *"Generally there are no consequences of this for you."*

I’ve heard good things about libreSSL which I would assume is what they’d use.
Since it's a BSD thing and OSX is BSD.

I wonder what the future of OpenSSL is though this has been a long time coming.
I also wonder whether we'll start seeing more of this in the Linux server world.
