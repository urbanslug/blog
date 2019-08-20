---
layout: post
title: Google Summer of Code 2019—Final Submission
date: 2019-09-20 11:15:16
tags: GSoC, Google Summer of Code, Variation Graphs, Bioinformatics
---

The end of Google Summer of Code 2019 is here. 
The aim of my project, [Graphite], was to [Add Variant Graph (VG) support to BioD].
This means representing the reference genome as a graph and not as a linear consensus as is currently done.

A lot has been written about why the current linear method of representing genomes is far from ideal and better ways to represent them have been written about such as: [On a reference pan-genome model], [Untangling graphical pangenomics], and my very own [An Introduction to Variation Graphs].


# Why Racket?
You may wonder why Graphite is written in Racket yet the project name is [Add Variant Graph (VG) support to BioD].

We went with utility over support. What I mean by this is we decided to build something people can use
over just adding support variation graph support to [BioD]. We felt that it would've taken much longer to write something people could use in D.
But why Racket? I have a history in functional programming and LISP. Racket is a language that is easy to prototype in. We also wanted something that would be easy for biologists to set up, something that is quite rare in bioinformatics. We feel that Racket makes it very easy compared to other functional languages or LISPs.

However, given what we know now and the lessons we learn from Graphite which is in Racket we can always go back and re-implement it in D.

# Done
For the fine detail install and set up Graphite as instructed in the [README] and run `graphite --help`.

## Construct
Graphite allows you to build an initial graph out of a reference(or a linear sequence) and a VCF file.
In this case, we read the reference in fasta and a variation data in VCF.

## Update
This allows the user to update an existing graph, also called a progressive update.
The construct argument earlier allows you to output a serialized version of the graph which we store
under the extension gra.

In the update, we read new variation data in VCF and the serialized graph and update it where it needs updating while avoiding duplicates.

## View
Graphite allows you to generate graphs in DOT for visualization via GraphViz or GFA for visualization with tools like bandage. 
The view command takes a serialized graph as an argument. However one can always output these formats using the `--output` flag.


# To Do
I have been implementing these but failing on corner cases or certain kmers or just plainly not impressed with how I am implementing them so I prefer to consider them not done but I am working on.
You could always look at the [Graphite project boards] for further detail.

## Partial Order Alignment
This would be a final step in the variation graph which would allow for aligning reads to a graph or against each other totally bypassing the reference and avoiding reference bias. It has shown to have promising results for example in [Variation graph toolkit improves read mapping by representing genetic variation in the reference]. 

For now, graphite can only align against strings mainly because graphite only stores forward edges which makes it hard to just implement POA which strictly depends on backward edges. The short term options are adding a pre-processing step to generate backward edges or using Racket's FFI to call [spoa] or [gssw] However, long term Graphite's nodes should support backward edges which would allow for encoding more complex mutations such as inversions.

## Search
This involves having a kmer, the substring of a genome, and searching for its most likely position in the graph.
I have multiple problems with this as of now.

### Complementarity
Graphite doesn't support complementarity (only supports the positive strands) therefore searching for a kmer in the negative strand wouldn't even work. I am evaluating different ways of implementing complementarity.

### A Graph Extension of the Burrows-Wheeler Transform
Search doesn't work for some strings and even worse the method I am using to build the index is not ideal. Currently, I am building it via a plain BWT which is in turn built from rotating the string.
A better strategy I am considering is generating a suffix array via [Ukkonen's algorithm] and using it to generate the BWT, complementing it and then generate the FM index. I think this is the basic idea behind [A Graph Extension of the Positional Burrows-Wheeler Transform and its Applications]

## Adding a Metadata Field
We could add a metadata field to the graph nodes which will allow for something like inbuilt annotation support.

## Other
One feature not related to Bioinformatics but is surprisingly lacking in Racket is to extend 
[cmdline] to have command-line options as is described in [Multi-command-line in Racket].

To reiterate, you can look at these 3 other posts regarding Graphite here:

 - [An Introduction to Variation Graphs]
 - [Creating the Initial Variation Graph]
 - [Justifying SHA256 in Graphite]



[BioD]: https://github.com/biod/biod
[Graphite]: https://github.com/urbanslug/graphite
[An Introduction to Variation Graphs]: 2019-06-22-Introduction-to-Variation-Graphs.html
[Creating the Initial Variation Graph]: 2019-07-15-Creating-the-Initial-Variation-Graph.html
[Justifying SHA256 in Graphite]: 2019-07-21-Justifying-SHA256-in-Graphite.html
[Add Variant Graph (VG) support to BioD]: https://summerofcode.withgoogle.com/projects/#4733198808907776
[cmdline]: https://github.com/racket/racket/blob/master/racket/collects/racket/cmdline.rkt
[Multi-command-line in Racket]: https://pavpanchekha.com/blog/multi-command-line.html
[Graphite project boards]: https://github.com/urbanslug/graphite/projects
[A Graph Extension of the Positional Burrows-Wheeler Transform and its Applications]: https://www.biorxiv.org/content/10.1101/051409v1
[Variation graph toolkit improves read mapping by representing genetic variation in the reference]: https://www.nature.com/articles/nbt.4227
[spoa]: https://github.com/rvaser/spoa
[gssw]: https://github.com/vgteam/gssw
[Untangling graphical pangenomics]: https://ekg.github.io/2019/07/09/Untangling-graphical-pangenomics
[On a reference pan-genome model]: https://lh3.github.io/2019/07/08/on-a-reference-pan-genome-model
[Ukkonen's algorithm]: https://en.wikipedia.org/wiki/Ukkonen%27s_algorithm
[README]: https://github.com/urbanslug/graphite#graphite