---
layout: post
title: Jusifying SHA256 for variation graphs
date: 2019-07-21 10:12:30
tags: probability, cryptography, variation
---

# Cost of hashing
The cost of hashing a string would vary from library to library and I
couldn't find exact data on the [SHA-2 racket implementation].
However, the biggest issue with hashing is the cost in terms of time (to generate the hashes)
and space (to store the hashes).

Because the the underlying graph representation uses a [hash table]
I needed a way to correctly generate keys for the values (variations).

## Time
We pay a one off cost for generating a hash which hasn't proved expensive
with the data I've tested it on so far.

## Space
For variations containing sequences of size less than 32 (8 * 32 = 256)
nucleotides we end up storing a hash that is longer than the original sequence.
However, for sequences longer than 32 nucleotides we store a much smaller hash.

## Comparison of graphs
A nice side effect is that we can compare simple graphs derived
from the same reference by comparing their hashes.

# Probability of collision
An approximation for the probability of a collision is


P(n) = 1-e<sup>-n<sup>2</sup>/(2d)</sup>

Where *n is the sample size* and *d is the total number of "buckets"*.
To avoid a collision we stay within a safe zone which is below
0.5 probability of a collision--approximately the square root of the bucket size.

Read more about it on [Birthday Problem Approximations].

Here's the Racket code I used to generate plots and approximate collision probability.
```racket
#lang racket

(require plot)

(define (probability-of-collison  d x)
  (- 1 (/ 1 (exp (/ (expt x 2) (* 2 d))))))

(define (plot-probability-of-collison bucket-size label)
  (parameterize ([plot-x-transform  log-transform]
                 [plot-width 750])
    (plot
     (function ((curry probability-of-collison) bucket-size)
               1
               bucket-size
               #:label label)
          #:x-label "Sample size"
          #:y-label "Probability of collision")))
```

## The birthday paradox
For every randomly selected 23 people the **probability** that two 
people in that sample share a birthday is 50.7 and goes up to 1 for 357 individuals.
![birthday plot]

### The birthday attack
The birthday attack in cryptography where an attacker
comes up with a string that will generate the same hash. 
I won't go more into that right now but you can read more about the [birthday attack] and [birthday problem].
The [birthday attack] wikipedia page even contains a table showing the
sample size and the probability of random collision.

There's also this lecture on YouTube from the Coursera cryptography course
[Cryptography generic birthday attack (collision resistance)].

## SHA 256
For SHA 256 the halfway probability of a hash collision occurs at 2^128.
![sha256 plot]

*This may be hard to interpret because exponential functions grow very quickly.*

# Applied to variation
For a 256 bit hash we have 2^256 as our sample size. 
We then have the square root of that being 
2^(256/2) = 2^128 approximately 3.4\*10^38 as
the sample size which has 0.5 chance of collision. 

The number of variations I expect to deal with is much
smaller than the square root of 2^256 or 2^128.

# The human genome
Even with the human genome that is approximately
3 giga base pairs in length 3*10^6 << 3.4\*10^38

# Viruses
Viruses have much shorter genomes in the length of kilo base
pairs, that is, tens of thousands of base pairs.
For RSV this is 15,000 which is also much smaller than 3.4*10^38.


# How much variation can actually occur
The short answer is we don't know for sure but we can estimate it's upper bound.

Given we look at genomes that are in the same species or quasi species we expect 99% similarity.
1% of the human genome would be 3\*10^4 and for RSV about 15\*10^3 about 
150 base pairs as the length within which the variation occurs. 
Granted we don't actually know how variation in this space could
happen or the most complicated way and I believe it would vary depending on the organism.
However, I'm still very confident SHA256 is large enough to uniquely identify each variation.

As a side note, SHA256 is [used in bitcoin] which there are a lot of :)

[Cryptography generic birthday attack (collision resistance)]: https://www.youtube.com/watch?v=5VY2KEh9WrE
[birthday attack]: https://en.wikipedia.org/wiki/Birthday_attack
[birthday problem]: https://en.wikipedia.org/wiki/Birthday_problem
[birthday plot]: /images/Content/Graphs/birthday.png
[sha256 plot]: /images/Content/Graphs/sha256.png
[Birthday Problem Approximations]: https://en.wikipedia.org/wiki/Birthday_problem#Approximations
[used in bitcoin]: https://youtu.be/bBC-nXj3Ng4?t=343
[hash table]: https://en.wikipedia.org/wiki/Hash_table
[SHA-2 racket implementation]: https://docs.racket-lang.org/sha/index.html
