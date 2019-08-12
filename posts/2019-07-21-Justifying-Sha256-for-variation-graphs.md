---
layout: post
title: Jusifying SHA256 in variation graphs
date: 2019-07-21 10:12:30
tags: probability, cryptography, variation
---

The underlying graph implementation in graphite uses a [hash table] to implement
an adjacency hash table.
The keys in the hash table are SHA256 hashes of: the sequence, a plus symbol,
and the offset.
Hashes grant us outgoing edge representations, constant time lookups for
some queries, and eliminate duplicates.

# Cost of hashing

## Time
I couldn't find any useful cost data on either the [SHA-2 racket implementation]
or SHA-2 the algorithm but being a string algorithm you can assume
it works in O(n) time, n being the length of the string being hashed.

This isn't worrying to me because hashing is a one off cost which hasn't proved
expensive with the data I've tested it on so far.

## Space
This is more of a concern because we expect graphs to grow with time.
For individual variations; sequences of a length less than 32 (8 * 32 = 256)
nucleotides end up with a hash that is longer than the original sequence.
However, for sequences longer than 32 nucleotides we store a much smaller hash.

## Graph comparison
A nice effect from hashing is that we can compare simple graphs derived from the
same reference by comparing their hashes.

# Probability of collision
An approximation for the probability of a collision is


P(n) = 1-e<sup>-n<sup>2</sup>/(2d)</sup>

Where *n is the sample size* and *d is the total number of "buckets"*.
To avoid a collision we need to make sure that our variations are fewer than the
square root of the bucket size--the point at which we get 0.5 chance of having
two different strings sharing the same hash.

Read more about it on [Birthday Problem Approximations].

Here's the Racket code I used to generate plots and approximate collision
probability.
```
#lang racket

(require plot)

(define (probability-of-collison  d n)
  (- 1 (/ 1 (exp (/ (expt n 2) (* 2 d))))))

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
In line with the function above, for every group of 23 randomly selected people
the **probability** that two of them share a birthday is 0.507.
The probability is 1 for 357 individuals.
![birthday plot]

## SHA 256
For SHA 256 the halfway probability of a hash collision occurs at 2<sup>128</sup>.
![sha256 plot]

*This may be hard to interpret because exponential functions grow very quickly.*


## The birthday attack
Hashing collisions are studied in cryptography where an attacker comes up with
a string that will generate the same hash (cause a collision).
I won't go more into collisions but [birthday attack] and [birthday problem] can
provide further reading. The [birthday attack] wikipedia page even contains a
table showing the sample size and the probability of random collision.
There's also this lecture on YouTube from the Coursera cryptography course
[Cryptography generic birthday attack (collision resistance)].


# Applied to variation
For a 256 bit hash we have 2<sup>256</sup> as our bucket size.
We then have the square root of that being
2<sup>(256/2)</sup> = 2<sup>128</sup> approximately 3.4\*10<sup>38</sup> as
the sample size which has 0.5 chance of collision. The number of variations
we expect is much smaller than 2<sup>128</sup>.

For comparison, consider the human genome which is approximately 3 giga (billion)
nucleotides in length. As you can see, 3*10<sup>6</sup> is much much smaller
than 3.4\*10<sup>38</sup>.

Viruses have much shorter genomes ranging in kilo (thousand) nucleotides.
For example RSV is approximately 15\*10<sup>3</sup> which is even much than
than 3.4*10<sup>38</sup> compared to the human genome.

As a side note, SHA256 is [used to uniquely identify bitcoin] which there are a
lot of.

# How much variation can actually occur
The short answer is we don't know for sure but we can estimate its upper bound.

Given we look at genomes that are in the same species or quasi species we expect
99% similarity.

  - 1% of the human genome would be approximately 3\*10<sup>4</sup> (thirty thousand)
nucleotides long.

  - 1% of RSV would be approximately 15\*10<sup>3</sup> (a hundred and fifty)
nucleotides long.

This is the space within which we expect the variation to occur.

Granted, we still don't know just how much variation could occur, which in
reality would depend on the organism, we have reduced the problem space by
orders of magnitude below 2<sup>128</sup> making SHA256 look really good.

I expect the biggest problem with SHA256 to come from the space cost of
hashing in terms of both disk and/or memory.


[Cryptography generic birthday attack (collision resistance)]: https://www.youtube.com/watch?v=5VY2KEh9WrE
[birthday attack]: https://en.wikipedia.org/wiki/Birthday_attack
[birthday problem]: https://en.wikipedia.org/wiki/Birthday_problem
[birthday plot]: /images/Content/Graphs/birthday.png
[sha256 plot]: /images/Content/Graphs/sha256.png
[Birthday Problem Approximations]: https://en.wikipedia.org/wiki/Birthday_problem#Approximations
[hash table]: https://en.wikipedia.org/wiki/Hash_table
[SHA-2 racket implementation]: https://docs.racket-lang.org/sha/index.html
[used to uniquely identify bitcoin]:  https://youtu.be/bBC-nXj3Ng4?t=343
