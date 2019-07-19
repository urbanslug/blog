---
layout: post
title: Creating the Intial Variation Graph
date: 2019-07-15 19:54:49
tags: variation graphs, graphs, bioinformatics
---
First off, Erik Garrison, the creator of [vg], wrote  a very good post on
variation graphs titled [Untangling graphical pangenomics].

A core concept in the variation graph is that there has to be a tight mapping
between the stable sequence (or reference) and the graph.
To do this we have to establish a *coordinate system*, a way to reliably
associate a section on the graph within the reference and vice versa.

# A Coordinate System
We use the concepts of  `offset` and  `ref` in each node to maintain a coordinate
system.

An **offset** is a 1 indexed number of bases from the first node where the
variation occurs.
We chose this because it lends itself nicely to how genomes are treated anyway.

The following are some problems that arise from this coordinate system that I
shall delve into in a later post. The problems are a matter of progressive
update and alignment not a matter of initial graph construction.

 1. Dealing with nodes that are from alignments i.e. not aligned to a linear
    sequence
 2. Changes in the linear reference which change the coordinate system.

A **ref** is a unique identifier of the stable sequence from which a variation has
been derived.

# Structure of the Graph

Properties of our graph:

 1. Directed acyclic graph
 2. Offsets are **increasing/ascending** natural numbers as we walk through the graph

## Node
A node is built out of a racket `structure`, a `struct` in many
languages, with the following fields:

| Name     | Description                                                  |
| :------: | :----------------------------------------------------------: |
| segment  | a string of alphabet A, T, C, and G                          |
| offset   | offset from zero on the stable sequence                      |
| id       | sha256 hash of the concatenation of segment, "+" and offset  |
| ref      | stable sequence from which the segment is derived            |
| links    | a list of the IDs of the next nodes                          |
|          |                                                              |


The names `segment` and `links` are inspired by
[A proposal of the Graphical Fragment Assembly format]\:
*Due to the historical confusion between vertices and edges, I will avoid using
these terminologies. I will use a segment for a piece of sequence and a link for
a connection between segments.*

For the *id* we generate a sha256 hash out of the segment, a plus
symbol and the offset.
For example, given a segment *"ATCGATG"* at offset *34* we can generate an ID
like so:
```
compute-id(segment, offset)
  // take note of the + sign in the concatenation
  string-and-offset  <- concatenate("ATCGATG", "+","34")
  hash-as-bytestring <- sha256hash(string-and-offset)
  id                 <- bytestring-to-hex-string(hash-as-bytestring)
  return id
```
I went with hashes over UUIDs because they are reproducible and therefore we can
have constant time lookups in the occasion that we want to get a node given we
know its sequence and offset. This should come in handy in visualization
especially on the web.

I also considered the possibility of collisions in the hashes but the likelihood
is low especially given we are dealing with approximately 15,000 base pair size
viruses.
Moreover, the sha256 hash generates a 256-bit hash which translates to
2^256 possibilities.
One thing to note is that [vg] uses UUIDs and they work for
human genome so I believe [graphite] can get away with sha256 hashes for more
complex genomes.

## Variation
A `structure` of:

| Name      | Description                                             |
| :-------: | :-----------------------------------------------------: |
| segment   | a string of single of alphabet A, T, C, and G           |
| offset    | offset from zero on the stable sequence                 |
| ref       | an identifier of the stable sequence it's derived from  |

A variation is extracted from a VCF file.
A node is what graphite creates and is a vertex in the variation graph. As you
would expect the variation graph is a graph of variations.

## The Graph Itself

Mainly due to the lack of serialization, which is very important for
progressive updates, in the [racket graph library] I had to implement a graph
in graphite. I would have preferred to [add serialization support to graph]
but I could not do that and still stay on track with graphite.

The graph is built out of an adjacency map of `id`, key, to `node`, value.


Using a `hash table` and not a `list` has the following pros:

 - No duplicates
 - Constant-time lookups if we have a `segment` and its `offset`

and cons:

 - Lacks ordering despite linear offsets which would come in handy for updates

# Construction
The general idea is:

 1. Given a `list` of variation `structures` **sorted** by `offset` and a
    linear reference (`string`)
 2. Loop through each variation and insert an alternative segment into the
    reference at the position specified in the variation.

In the case of graphite, we recursively split the reference into a *list* of
*pairs* that imply directionality.
For example, the pair `(a b)` would translate to an edge from *node a* to *node b*.

We then have a function `gen-directed-graph` that takes this `list` of `pairs`
and generates a directed graph from it using `foldl`. Graphite creates the graph in the
3 steps detailed below.

## 1. Generate a Node List (of Pairs)
*O(n)*; n being the size of the variation list
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


### 1.1 Cap
Creates the initial variation i.e "caps" the directed graph.
It creates a first node that points to the first variations.
```
cap(reference, previous-position, previous-nodes)
  map(
    lambda node: (substring(reference, 0, previous-position), node)
    previous-nodes
    )
```

### 1.2 Handle Unique
Inserts a variation where there isn't an alternative.
In a case where there's only 1 alternative path so we break the current sequence
and insert our alternative path, for example,  `a -> b` and `a -> c`.
```
handle-unique(reference, variations, previous-position, previous-nodes)
  ...
```

### 1.3 Handle Duplicate
Inserts extra alternative variations where they already exist.
for example `a -> b`, `a -> c` and `a -> d`.

```
handle-duplicate(reference, variations, previous-position, previous-nodes)
  ...
```


## 2. Generate a Directed Graph Out of a List of Pairs
*O(n)*; with n being the size of the list of pairs
```
gen-directed-graph(g, list-of-pairs)
  foldl(
  // make sure that you're not overwriting the list of edges of a node as you
  // update it. This check makes `gen-directed-graph` slow approx 4n.
  lambda pair: add-adjacent-node(g, first(pair), second(pair))
  g
  list-of-pairs)
```

 - **g**: a graph
 - **list-of-pairs**: a list of pairs

The reason for the bad performance of `gen-directed-graph` is that it checks to
avoid overwriting any existing nodes.
This is to mean that if there's a relationship like:
`a -> b` and `a -> c`
we have to make sure not to lose the edge `a -> b` when creating `a -> c`.
It, however, does suffice for virus data.

## 3. Return a Variation Graph
A composition of `gen-node-list` and `gen-directed-graph`

```
gen-vg(reference, variations)
  node-list <- gen-node-list(reference, variation)
  graph     <- gen-directed-graph(node-list)
  return graph
```

# Visualization and Output
Graphite supports the generation of graphs in [gfa].
This is important for interoperability with other tools such as [bandage] and
[vg]. To quote from [Untangling graphical pangenomics], *The important thing is
that we learn to read and write the same (text) data.*


# Optimization Ideas
Representing the alphabet in 2 bits, for example, A as 00, C as 01, T as 10 and
G as 11. However, most of the optimization would come from graph creation, graph
update and search so I'm focused on that for now at least.

[A proposal of the Graphical Fragment Assembly format]: https://lh3.github.io/2014/07/19/a-proposal-of-the-grapical-fragment-assembly-format
[Untangling graphical pangenomics]: https://ekg.github.io/2019/07/09/Untangling-graphical-pangenomics
[racket graph library]: https://github.com/stchang/graph
[gfa]: https://github.com/GFA-spec/GFA-spec
[vg]: https://github.com/vgteam/vg
[bandage]: https://rrwick.github.io/Bandage/
[add serialization support to graph]: https://github.com/stchang/graph/issues/47
[graphite]: https://github.com/urbanslug/graphite
