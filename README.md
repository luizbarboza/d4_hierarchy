<h1 align="center">
  d4_hierarchy
</h1>

<p align="center">
  2D layout algorithms for visualizing hierarchical data.
</p>

<p align="center">
  <a href="https://github.com/luizbarboza/d4_hierarchy/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/luizbarboza/d4_hierarchy" alt="license" />
  <a href="https://github.com/luizbarboza/d4_hierarchy/actions/workflows/ci.yml">
    <img src="https://github.com/luizbarboza/d4_hierarchy/actions/workflows/ci.yml/badge.svg" alt="Dart CI" />
  </a>
  <a href="https://pub.dev/packages/d4_hierarchy">
    <img src="https://img.shields.io/pub/v/d4_hierarchy.svg" alt="pub package" />
  </a>
  <a href="https://pub.dev/packages/d4_hierarchy/publisher">
    <img src="https://img.shields.io/pub/publisher/d4_hierarchy.svg" alt="package publisher" />
  </a>
</p>

<h3 align="center">
  <a href="https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/d4_hierarchy-library.html">Documentation</a>
</h3>

Many datasets are intrinsically hierarchical: [geographic entities](https://www.census.gov/programs-surveys/geography/guidance/hierarchy.html), such as census blocks, census tracts, counties and states; the command structure of businesses and governments; file systems; software packages. And even non-hierarchical data may be arranged hierarchically as with [*k*-means clustering](https://en.wikipedia.org/wiki/K-means_clustering) or [phylogenetic trees](https://observablehq.com/@d3/tree-of-life). A good hierarchical visualization facilitates rapid multiscale inference: micro-observations of individual elements and macro-observations of large groups.

This package implements several popular techniques for visualizing hierarchical data:

**Node-link diagrams** show topology using discrete marks for nodes and links, such as a circle for each node and a line connecting each parent and child. The [“tidy” tree](https://pub.dev/documentation/d4_hierarchy/latest/topics/Tree-topic.html) is delightfully compact, while the [dendrogram](https://pub.dev/documentation/d4_hierarchy/latest/topics/Cluster-topic.html) places leaves at the same level. (These have both polar and Cartesian forms.) [Indented trees](https://observablehq.com/@d3/indented-tree) are useful for interactive browsing.

**Adjacency diagrams** show topology through the relative placement of nodes. They may also encode a quantitative dimension in the area of each node, for example to show revenue or file size. The [“icicle” diagram](https://pub.dev/documentation/d4_hierarchy/latest/topics/Partition-topic.html) uses rectangles, while the “sunburst” uses annular segments.

**Enclosure diagrams** also use an area encoding, but show topology through containment. A [treemap](https://pub.dev/documentation/d4_hierarchy/latest/topics/Treemap-topic.html) recursively subdivides area into rectangles. [Circle-packing](https://pub.dev/documentation/d4_hierarchy/latest/topics/Pack-topic.html) tightly nests circles; this is not as space-efficient as a treemap, but perhaps more readily shows topology.

See one of:

* [Hierarchies](https://pub.dev/documentation/d4_hierarchy/latest/topics/Hierarchies-topic.html) - represent and manipulate hierarchical data
* [Stratify](https://pub.dev/documentation/d4_hierarchy/latest/topics/Stratify-topic.html) - organize tabular data into a [hierarchy](https://pub.dev/documentation/d4_hierarchy/latest/topics/Hierarchies-topic.html)
* [Tree](https://pub.dev/documentation/d4_hierarchy/latest/topics/Tree-topic.html) - construct “tidy” tree diagrams of hierarchies
* [Cluster](https://pub.dev/documentation/d4_hierarchy/latest/topics/Cluster-topic.html) - construct tree diagrams that place leaf nodes at the same depth
* [Partition](https://pub.dev/documentation/d4_hierarchy/latest/topics/Partition-topic.html) - construct space-filling adjacency diagrams
* [Pack](https://pub.dev/documentation/d4_hierarchy/latest/topics/Pack-topic.html) - construct enclosure diagrams by tightly nesting circles
* [Treemap](https://pub.dev/documentation/d4_hierarchy/latest/topics/Treemap-topic.html) -  recursively subdivide rectangles by quantitative value