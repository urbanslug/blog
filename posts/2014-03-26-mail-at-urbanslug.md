---
layout: page
title: mail at urbanslug
date: 2014-03-26 21:30:16
tags: Email
---


So uh since I am not allowed by society to wear a tinfoil hat and I believe that the we are under attack I have decided to leave gmail and set up my own mail server. Futile efforts but at least I shall have a fighting chance.

FYI I heard not to wear a tinfoil hat because amplify the waves instead wear a wet towel on your head but you might get a cold or worse.

### Hosting.


I will get hosting from [@computionist] on twitter. I don't know him personally but I know him from #nothaskell on freenode and twitter. A great guy to say the least.

He is passionate about a ton of things.

He gave me **free** hosting.

He's got free hosting for minorities, LGBT, newbies, [haskell-now] members and #nothaskell members. I don't know under which criteria I qualified but I thank him.



### The Stack.


The plan was for a full FOSS stack and if possible GPL compatibilty and copyleft.

**Operating System**

Linux
CentOS because systemd baybie :) and my redhat fanboyism.

**Mail Server**

I decided to go with IMAP and SMTP because well it is the most flexible as far as I can tell.

**_SMTP_**

The [SMTP] server I have decided to use will be **[Postfix]**. I had issues with the choice because it is [IPL (IBM Public Licence)] . It's [free] and [copyleft] but not [GPL] compatible. A moral conundrum ey? Anyway it has a community around it and having read on it's incompatibility with the GPL I decided to go with it. This is the cause iof incompatibility: "The IPL differs from the GPL in the handling of patents, as IPL terminates the license upon patent disputes."

**_IMAP_**

The [IMAP] server I will use will be **[Cyrus]**. This was a hard choice due to it's [original BSD license]. I honestly don't like anything BSD licensed let alone an older one with an advertising clause that I just learned about.

However I was consoled by this statement. "the Free Software Foundation, recommends developers not use the license, though it states there is no reason not to use software already using it."




Worth noting that the choice in Cyrus and Postfix was mostly because [@computionist] already uses them and recommended them. I just wanted to make sure I was using FOSS and my choices were well documented plus had communities around them.




### Security.


Well I will be hosting in the USA so I have to try extra hard to make sure the NSA doesn't listen in. The can break my encryption in 5 years after they have quantum computers strong enough. I don't care.

What I know I want:

- Ensure the server hardware and software are secure.
- Reduce to a minimum and if possible eliminate any chances of mail being in plaintext whilst in the server.
- TLS connection to the server.
- Outgoing mail to be encrypted opportunistically i.e where the remote end supports it.
- Hopefully encrypt mail while it is on the server.
- Key pair per user and when they get a message, generate a random symmetric key and encrypt their email with it. Then encrypt that symmetric key to the users public key and store that with the encrypted message. This way even I can't decrypt it. Only the user with the secret key can.

How to achieve all this I am not yet sure since it might get tricky but not much worry since most of the time I, and any other users if there will be, will be using end to end encyption for my mail.




### Visual Representation.


Below is a high overview diagram of how a mail server works with the IMAP server routing local mail to the IMAP server and foward the rest to another SMTP server. This may change depending on one's configuration of course. I left out the crypto bits.

*Created with GIMP and my mad graphics skills lulz*

![mail image](/images/Content/Educate/mail.png "mail image overview")

[IPL (IBM Public Licence)]: https://en.wikipedia.org/wiki/IBM_Public_License
[free]: http://en.wikipedia.org/wiki/Free_software
[copyleft]: http://en.wikipedia.org/wiki/Copyleft
[GPL]: http://en.wikipedia.org/wiki/GNU_General_Public_License
[haskell-now]:  http://www.haskellnow.org/CodeOfConduct
[@computionist]: https://twitter.com/computionist
[original BSD license]: https://en.wikipedia.org/wiki/BSD_licenses#4-clause_license_.28original_.22BSD_License.22.29
[IMAP]: https://en.wikipedia.org/wiki/Transport_Layer_Security
[SMTP]: https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol 
[Postfix]: http://www.postfix.org/
[Cyrus]: https://en.wikipedia.org/wiki/Cyrus_IMAP_server
