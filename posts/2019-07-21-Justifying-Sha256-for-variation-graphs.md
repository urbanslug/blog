---
layout: post
title: Jusifying sha256 for variation graphs
date: 2019-07-21 10:12:30
tags: probability, cryptography, variation
---

# The birthday paradox
It basically states that for every randomly selected 23 people the chance that two people in that sample share a birthday is 50.7 and goes up to 1 for 367 individuals.
This leads to the birthday attack in cryptography where an attacker comes up with a string that will generate the same hash. I won't go more into that right now but you can read more about the [birthday attack] and [birthday problem].
The [birthday attack] wikipedia page even contains a table showing the sample size and the probability of random collision.

# The formula
The formula used is that the 0.5 probability of a collision is the square root of the sample size.

# Applied to variation
For a 256 bit hash we have 2^256 as our sample size. 
We then have the square root of that being 
2^(256/2) = 2^128 approximately 3.4\*10^38 as
the sample size which has 0.5% chance of collision. 

# The human genome
Even with the human genome that is approximately
3 giga base pairs in length 3*10^6 << 3.4\*10^38

# Viruses
Viruses have much shorter genomes in the length of kilo base pairs, that is, tens of thousands of base pairs.
For RSV this is 15,000 which is also much smaller than 3.4*10^38.

# How much variation can actually occur
The short answer is we don't know for sure. We can however estimate it.

Given we look at genomes that are in the same species or quasi species we expect 99% similarity.
1% of the human genome would be 3\*10^4 and for RSV about 15\*10^3 about 150 base pairs as the length within which the variation occurs. Granted we don't actually know how variation in this space could happen or the most complicated way and I believe it would vary depending on the organism.
However, I'm still very confident sha256 is large enough to uniquely identify each variation.

# Time taken to generate the hash
Our message size is small...

TODO: Watch [Cryptography generic birthday attack (collision resistance)](https://www.youtube.com/watch?v=5VY2KEh9WrE).

[birthday attack]: https://en.wikipedia.org/wiki/Birthday_attack
[birthday problem]: https://en.wikipedia.org/wiki/Birthday_problem
