/// 2D layout algorithms for visualizing hierarchical data.
///
/// Many datasets are intrinsically hierarchical:
/// [geographic entities](https://www.census.gov/programs-surveys/geography/guidance/hierarchy.html),
/// such as census blocks, census tracts, counties and states; the command
/// structure of businesses and governments; file systems; software packages.
/// And even non-hierarchical data may be arranged hierarchically as with
/// [*k*-means clustering](https://en.wikipedia.org/wiki/K-means_clustering) or
/// [phylogenetic trees](https://observablehq.com/@d3/tree-of-life). A good
/// hierarchical visualization facilitates rapid multiscale inference:
/// micro-observations of individual elements and macro-observations of large
/// groups.
///
/// This package implements several popular techniques for visualizing
/// hierarchical data:
///
/// **Node-link diagrams** show topology using discrete marks for nodes and
/// links, such as a circle for each node and a line connecting each parent and
/// child. The
/// [“tidy” tree](https://pub.dev/documentation/d4_hierarchy/latest/topics/Tree-topic.html)
/// is delightfully compact, while the
/// [dendrogram](https://pub.dev/documentation/d4_hierarchy/latest/topics/Cluster-topic.html)
/// places leaves at the same level. (These have both polar and Cartesian
/// forms.) [Indented trees](https://observablehq.com/@d3/indented-tree) are
/// useful for interactive browsing.
///
/// **Adjacency diagrams** show topology through the relative placement of
/// nodes. They may also encode a quantitative dimension in the area of each
/// node, for example to show revenue or file size. The
/// [“icicle” diagram](https://pub.dev/documentation/d4_hierarchy/latest/topics/Partition-topic.html)
/// uses rectangles, while the “sunburst” uses annular segments.
///
/// **Enclosure diagrams** also use an area encoding, but show topology through
/// containment. A
/// [treemap](https://pub.dev/documentation/d4_hierarchy/latest/topics/Treemap-topic.html)
/// recursively subdivides area into rectangles.
/// [Circle-packing](https://pub.dev/documentation/d4_hierarchy/latest/topics/Pack-topic.html)
/// tightly nests circles; this is not as space-efficient as a treemap, but
/// perhaps more readily shows topology.
export 'src/d4_hierarchy.dart';
