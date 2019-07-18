---
layout: post
title: Creating the Intial Variation Graph
date: 2019-07-15 19:54:49
tags: variation graphs, graphs, bioinformatics
---

First off, a re-cap on variation graphs; a core concept in the variation graph
is that the graph has to maintain a tight mapping between the stable sequence
(or reference) and the graph.
To do this we have to establish a coordinate system, that is, a way to reliably
associate a section on the graph within the reference and vice versa.

# A coordinate system
We use the concepts of  `offset` and  `ref` in each node to maintain a coordinate
system.

An **offset** is the number of bases from the first node where the variation occurs.
We chose this because it lends itself nicely to how genomes are treated anyway.
There are some problems with this which I shall delve into in a later post
because  they are more of a matter of progressive graph update not initial
graph creation.

They are however:

 1. Dealing with nodes that are from a alignments i.e. not aligned to a linear sequence
 2. Chances in the linear reference which change the coordinate system.

A **ref** is a way of identifying the stable sequence from which a variation has
been derived.

# Core structure of our graph

Properties of our graph:

 1. a directed acyclic graph
 2. offsets are increasing integers as we walk through the graph

## Node
A node is built out of a racket structure, a struct in many languages.

| Name     | Description                                                |
| :------: | :---------------------------------------------------:      |
| Segment  | a string of alphabet A,T,C and G                       |
| offset   | offset from zero on the stable sequence                    |
| id       | sha256 hash of the concatenation of: segment, "+" & offset |
| ref      | stable sequence from which the segment is derived          |
| links    | a list of the IDs of the next nodes                        |

The names segment and links are inspired by [A proposal of the Graphical Fragment Assembly format].

*Due to the historical confusion between vertices and edges, I will avoid using
these terminologies. I will use a segment for a piece of sequence and a link for
a connection between segments.*

The possibility of a clash in our hashes is low dealing even with 15,000 size virus
genomes plus the current vg uses UUIDs so I think graphite can get away with it.

## Variation
A structure of:

| Name       | Description                               |
| :-------:  | :---------------------------------------: |
| kmer       | a string of single or multiple bases      |
| position   | offset from zero on the stable sequence   |



## The graph itself
The graph is built out of a hash table of ID to a node where a node is a
structure (struct) in many other langs of
A hash table of `ID` to `node` where ID is the node's ID repeated.

A `hash table` has the advantage of:
 - not having duplicates
 - O(1) lookup time if I know the `segment` and its `offset` unlike a `hash set`
   * we can compute the hash

# Construction
The general idea is:

 1. Take a list of variation and a linear reference
 2. Treat the reference as a single node graph
    * There's no need to generate an actual node of out it
 3. Recursively break the reference at the point each variation inserting an
    alternative node/path.

We recursively split the reference into a list of pairs/tuples.

We then have a function `gen-directed-graph` that takes a list of pairs and
generates a directed graph from it.


It can be viewed as occurring in 3 stages:

I chose to go with saving time over saving memory if I had to make a trade-off.

## 1. Generate a node list (of pairs)

O(n) n being the size of the variation list
```
gen-node-list(reference, variations, prev-position = f, prev-nodes = <empty-list>)
  if empty-list? variations
    // the base case of gen node list
    cap(reference, previous-position, previous-nodes)
  else if (is-number previous-position) and (previous-position = current-offset)
    // we have more than one variation in this position
    handle-duplicate(reference, variations, previous-position, previous-nodes)
  else
    // we have just one variation in this position
    handle-unique(reference, variations, previous-position, previous-nodes)


```

 - **reference**: the linear reference
 - **variations**: a list of variations
 - **prev-position**: the offset of the previous variation
     - the default value is false. (I wish I used an int here)
 - **prev-nodes**: the previous node or nodes with relation to the current one
     - the default value is an empty list.

A mutually recursive function takes from the `tail` of variation list,
`variations`, and returns a list of pair of nodes `(a, b)` where the direction
of the nodes is `a -> b` for example a list like `[(a b), (b c), (c d)]` should
later  translate to `a -> b -> c -> d`.


### a. cap
`cap` creates the initial variation i.e "caps" the directed graph.
It creates a first node that points to the first variations.
```
cap(reference, previous-position, previous-nodes)
  map(
    lambda node: (substring(reference, 0, previous-position), node)
    previous-nodes
    )
```

### b. handle unique
`handle-unique`  a variation where there isn't an alternative.
In a case where there's only 1 alternative path so we break the current sequence
and insert our alternative path, for example,  `a -> b` and `a -> c`.
```
handle-unique(reference, variations, previous-position, previous-nodes)
  ...
```

### c. handle duplicate
`handle-duplicate` inserts extra alternative variations where they already exist.
for example `a -> b`, `a -> c` and `a -> d`.

```
handle-duplicate(reference, variations, previous-position, previous-nodes)
  ...
```



## 2. Generate a directed graph out of a list of pairs
O(n) with n being the size of the list of pairs
```
gen-directed-graph(g, l)
  foldl(
  // make sure that you're not overwriting the list of edges of a node as you
  // update it. This check is what makes this function slow more like a running
  // time of 4n.
  lambda x: add-adjacent-node(g, (first x), (second x))
  l // list of pairs
  )
```

 - **g**: a graph
 - **l**: a list of pairs

The reason for the bad performance of `gen-directed-graph` is that it checks to
avoid overwriting any existing nodes.
This is to mean that if there's a relationship like:
`(a -> b)` and `(a -> c)`
we have to make sure not to lose the edge `a -> b` when creating `a -> c`.

It however, does suffice for virus data.

## 3. Return a variation graph
`gen-vg` is a composition of `gen-node-list` and `gen-directed-graph`

```
gen-vg(reference, variations)
  node-list <- gen-node-list(reference, variation)
  graph     <- gen-directed-graph(node-list)
  return graph
```

# Serialization
Serialization is important for progressively updating the graph.
I had to stop using the [racket graph library] and implement the graph natively
in graphite. This was because:

 1. It didn't implement serialization.
 2. I didn't feel that I could add generic serialization support and still stay
    on track with graphite.


# Visualization and output
Graphite supports the output of files in [gfa].
This is important for interoperability with other tools such as bandage and vg.
A quite from [Untangling graphical pangenomics], *The important thing is that
we learn to read and write the same (text) data.*

[A proposal of the Graphical Fragment Assembly format]: https://lh3.github.io/2014/07/19/a-proposal-of-the-grapical-fragment-assembly-format
[Untangling graphical pangenomics]: https://ekg.github.io/2019/07/09/Untangling-graphical-pangenomics
[racket graph library]: https://github.com/stchang/graph
[gfa]: https://github.com/GFA-spec/GFA-spec
