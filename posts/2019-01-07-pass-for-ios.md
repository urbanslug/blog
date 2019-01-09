---
layout: post
title: Pass for iOS
date: 2019-01-07 20:48:34
tags: passwords, pass, iOS, password management
---


If you have a GPG keypair, believe in using strong passwords and are paranoid (don't trust password management tools), then [pass](https://www.passwordstore.org/) is the tool for you.
I've been using it for so long that I can't remember when I started using it and I have to say, I really like it.

Pass is a FOSS tool that lets you roll your own password management tool-chain and if that sounds hard, it's not.
It works by storing your password, security questions etc in version controlled plain text files and encrypting them using your keys.
You then clone your passwords repo and copy your GPG keys to the devices which you would like to access your passwords on.

> Pass is a FOSS that lets you roll your own password management tool-chain.

A known downside of pass is that it **leaks metadata**.
The workaround to this is storing all your passwords in a single file.
Guys in the ##crypto on Freenode also recommend [keepassxc].

A short overview of pass:

 1. Have a GPG keypair and (not required but a really good idea) a hosted version control system.
 2. Set up pass so that it knows which keypair to use.
 3. Create a git repo (password-store) which will hold your encrypted passwords.
 4. Start generating and version controlling your passwords.


However, this isn't a post about pass; it's about how to use pass on iOS and
there's a tool, [pass for iOS], that does that.
Assuming you're already a pass user the question is how
to get pass working on your iPad, iPhone or whatever.

# How do we transfer our SSH and GPG keys?
I think the easiest way would be via iTunes but that doesn't feel right at all.
Why would I trust a 3rd party server with my private key?

What I decided to go with is a tool, [asc-key-to-qr-code-gif],
that converts converts ASCII (amored for GPG) keys to QR codes
and then I scan those QR codes on [Pass for iOS].
It's all open source tools and no 3rd party servers involved.
Tell me what you think about this "convert your keys to QR code"
business [via a tweet](https://twitter.com/urbanslug).

> It’s all open source tools and no 3rd party servers involved.

## Setup and installing dependencies
First, I had to install some dependencies via homebrew. I felt it important to install zbar in case there were any errors during QR code generation.

```bash
brew install libqrencode imagemagick zbar
```

<br/>Clone the [asc-key-to-qr-code-gif] repo to get the QR code generation script, asc-to-gif.sh.
```bash
git clone git@github.com:yishilin14/asc-key-to-qr-code-gif.git
```

## GPG


### Export your GPG keys into ASCII armored files

```bash
gpg --export --armor <key id> > public.asc
gpg --export-secret-keys --armor <key id> > private.asc

```

### Generate and scan the GPG gifs:
```bash
asc-to-gif.sh public.asc public.gif
asc-to-gif.sh private.asc private.gif
```

## SSH
I prefer to have different SSH keys for different devices
that way it's easy to revoke access for different devices.
Moreover, using ed25519 keys on phones often fails because of the versions of OpenSSH
they ship with so I just go with RSA which is the default anyway.
In this case it even had to be PEM due to the version of GitSSH on iOS.
Based on the [Supported Unsupported Key Algorithms wiki page] and [issue 218],
generate device keys with:
```bash
ssh-keygen -t rsa -b 4096 -m PEM -f ~/.ssh/id_rsa_<device> -C "<user>@<device>"
```

Then copy the pubkey to the version control tool of your choice.

### Generate and scan the SSH gif:

Generate a GIF for it.
```bash
asc-to-gif.sh ~/.ssh/id_rsa_<device> ssh.gif
```


#### Cloning your password-store repo into your device

Set the URL in this format:
```bash
ssh://git@gitlab.com/<gitlab username>/<password store repo>.git
```

and set your username to `git` according to [issue 112].

I'll assume you can do the rest, like cloning the password store repository into your device and decrypting your password files, by yourself ;).


[issue 112]: https://github.com/mssun/passforios/issues/112#issuecomment-318342043
[issue 218]: https://github.com/mssun/passforios/issues/218
[pass for iOS]: https://github.com/mssun/passforios
[asc-key-to-qr-code-gif]: https://github.com/yishilin14/asc-key-to-qr-code-gif
[Supported Unsupported Key Algorithms wiki page]: https://github.com/mssun/passforios/wiki/Supported-Unsupported-Key-Algorithms
[keepassxc]: https://keepassxc.org/
