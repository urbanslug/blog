---
layout: post
title: Progressive Update of Variation Graphs
date: 2019-07-19 02:47:41
tags: variation graphs, graphs, bioinformatics
---

Properties of our graph:
 
 1. We have an acyclic directed graph
 2. offsets are increasing integers as we walk through the graph

We chose DFS because the nature of our graph is likely to be deeper than wider

Say we want to insert a node in position x

1. We search the graph for a node that is offset less than x
2. Once found walk down the path through it's edges until you find a node that is greater than x
 - If
     * **found** return the node and it's 2 previous nodes
     * **not found** return false


How to insert:

 If the node is:
 
  - **less than pos** our insertion node -> add our node as one of the adj ones
  - **equal to pos** split node and modify it
