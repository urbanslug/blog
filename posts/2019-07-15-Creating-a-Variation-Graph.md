---
layout: post
title: Creating a Variation Graph
date: 2019-07-15 19:54:49
tags: variation graphs, graphs, bioinformatics
---

## Core structure of a variation graph

Some of the naming is inspired by [A proposal of the Grapical Fragment Assembly format].

*Due to the historical confusion between vertices and edges, I will avoid using 
these terminologies. I will use a segment for a piece of sequence and a link for
a connection between segments.*

The variation graph is a directed acyclic graph

## Node
A node is build out of a racket strucuture, a struct in many languages.

| Name     | Description                                                   |
| :------: | :---------------------------------------------------:         |
| Segment  | kmer                                                          |
| offset   | offset from zero on the stable sequence                       |
| id       | sha256 hash of the concatenation of: segment, "+" & offset    |
| ref      | stable sequence from which the segment is derived             |
| edges    | a list of the IDs of the next nodes                           |


## A graph
The graph is built out of a hash table of ID to a node where a node is a 
strucuture (struct) in many other langs of 
A hash table of `ID` to `node` where ID is the node's ID repeated.

A `hash table` has the advantage of not having duplicates and
unlike a `set` has O(1) lookup time if I know the `segment` and its `offset`.

## Variation
A structure of 

| Name       | Description                               |
| :-------:  | :---------------------------------------: |
| kmer       | single or multiple bases                  |
| position   | offset from zero on the stable sequence   |

## The coordinate system
A coordinate system is a way of reliably mapping from the graph to the 
One of the requirements of a variation graph is that 
the nodes in the graph should have a tight association with the linear 
sequence/reference.
We use `offset` and the `ref` in the node to maintain a coordinate system.
The coordinate system in use is reference based and therefore wouldn't work
 when aligning reads against each other.

## Core functions
We use a mutually recursive function to generate the node list
```
gen-node-list(reference, variations, prev-position = 0, )
```

```
gen-directed-graph(g, l)
```


```
gen-vg(reference, variations)
  node-list <- gen-node-list(reference, variation)
  graph <- gen-directed-graph(node-list)
  return graph
```

```
update-vg(g, variations)
```

## Construction
### Initial graph
We recursively split the reference into a list of pairs/tuples.

We then have a function `gen-directed-graph` that takes a list of pairs and 
generates a directed graph from it.

## Serialization
One of the major reasons I stepped away from the graph library in racket was it
didn't implement serialization and I didn't feel that I could add generic 
serialization support fast enough.

## Visualization and output
graphite supports output of files in gfa which allows for graphite to talk to
bandage and vg. An important thing to keep in mind in all this is a bit from 
[Untangling graphical pangenomics], *The important thing is that we learn to
read and write the same (text) data.*

[A proposal of the Grapical Fragment Assembly format]: https://lh3.github.io/2014/07/19/a-proposal-of-the-grapical-fragment-assembly-format
[Untangling graphical pangenomics]: https://ekg.github.io/2019/07/09/Untangling-graphical-pangenomics
