---
layout: post
title: Jusifying SHA256 in Graphite
date: 2019-07-21 10:12:30
tags: probability, cryptography, variation, bioinformatics
---

Graphite's underlying graph implementation is an adjacency hash table, a
complicated way of saying that graphite uses a [hash table] to implement the
graph. The keys of the hash table are SHA256 hashes of the concatenation of the
sequence, a plus symbol, and the offset.

Hashes also grant us outgoing edge representations, constant time lookups for
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

A SHA 256 hash takes the same amount of space as a 32 characters string
(8*32=256) therefore in variations containing sequences below 32 nucleotides
long we store a hash that is larger than the variation we are hashing.
This is exemplified in SNP data.

## Graph comparison
A nice effect from hashing is that we can compare simple graphs derived from the
same reference by comparing their hashes.

# Probability of collision
We can approximate the probability of a collision using the function
P(n) = 1-e<sup>-n<sup>2</sup>/(2d)</sup>. Where *n is the sample size* and *d
is the total number of "buckets"*.
For more about calculating this probability check out [Birthday Problem Approximations].

To avoid a collision we need to make sure that our variations are fewer than the
square root of the bucket size—the point at which we get 0.5 chance of having
two different strings sharing the same hash.
Think of it as the halfway point in a [binomial distribution] where past 0.5 we
consider a collision to have occurred. In reality the halfway point occurs
**above** the square root but it's still an easy way of verifying that your
sample size is within a safe range.



Here's a Racket function derived from the one above that I used to approximate
collision probability.
```
(define (probability-of-collision  d n)
  (- 1 (/ 1 (exp (/ (expt n 2) (* 2 d))))))
```

## The birthday paradox
Using the approximation function above we calculate that for every group of 23
randomly selected people, the probability that two of them share a birthday is
0.5; and in a sample of 357 people the probability that two of them share a
birthday is 1.
![birthday plot]

## SHA 256
For SHA 256 the halfway probability of a hash collision occurs at a point above
2<sup>128</sup>
![sha256 plot]

*This may be hard to interpret because exponential functions grow very quickly.*

Here's the Racket code I used to generate these plots
```
#lang racket

(require plot)

(define (probability-of-collision  d x)
  (- 1 (/ 1 (exp (/ (expt x 2) (* 2 d))))))

(define (label-point-at x y)
  (let* ([fn (lambda (v) (if (> v (expt 10 6)) 'exponential 'positional))]
        [x* (~r #:precision 4 #:notation fn x)]
        [y* (~r #:precision 4 y)])
    (list (vrule x 0 y #:style 'long-dash)
          (hrule y 0 x #:style 'long-dash)
          (point-label (vector x y) (format "x = ~a    y = ~a" x* y*)))))

(define (plot-probability-of-collison bucket-size label [halfway-probability #f])
  (let ([g (if halfway-probability halfway-probability (sqrt bucket-size))]
        [bucket-size-root (sqrt bucket-size)]
        [fn               ((curry probability-of-collision) bucket-size)])
    (parameterize ([plot-x-transform  log-transform]
                   [plot-width 750])
      (plot
       (list
        (function fn 1  bucket-size #:label label)
        (label-point-at g (fn g)))
       #:x-label "Sample size"
       #:y-label "Probability of collision"))))

(plot-probability-of-collison 365 "Birthday" 23)

(plot-probability-of-collison (expt 2 256) "SHA 256")
```

## The birthday attack
Hash collisions are studied in cryptography. In the [birthday attack] an attacker
comes up with a string that will generate the same hash as an unknown or
different but known string causing a collision.

This is out of the scope of this post but [birthday attack] and
[birthday problem] wikipedia pages can provide further reading.
There's also this lecture on YouTube from the Coursera cryptography course
[Cryptography generic birthday attack (collision resistance)].


# Applied to variation
For a 256 bit hash we have 2<sup>256</sup> as our bucket size.
We then have the square root of that being
2<sup>(256/2)</sup> = 2<sup>128</sup> approximately 3.4\*10<sup>38</sup> as
the sample size below which we have 0.5 chance of collision.

For context, consider the human genome which is approximately 3 giga (billion)
nucleotides in length. As you can see, 3*10<sup>6</sup> is much much smaller
than  3.4\*10<sup>38</sup>.

Viruses have much shorter genomes ranging in kilo (thousand) nucleotides.
For example RSV is approximately 15\*10<sup>3</sup> which is even much than
than 3.4*10<sup>38</sup> compared to the human genome.

The number of variations we expect in these genomes is therefore much smaller
than 2<sup>128</sup>. As a side note, SHA256 is
[used to uniquely identify bitcoin] which there are a lot of.

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
[binomial distribution]: https://en.wikipedia.org/wiki/Binomial_distribution
