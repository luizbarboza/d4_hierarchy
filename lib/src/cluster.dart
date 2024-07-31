import 'dart:math';

import 'hierarchy/hierarchy.dart';

int defaultSeparation<T>(HierarchyNode<T> a, HierarchyNode<T> b) {
  return a.parent == b.parent ? 1 : 2;
}

num meanX<T>(List<HierarchyNode<T>> children) {
  return children.fold(0, meanXReduce<T>) / children.length;
}

num meanXReduce<T>(num x, HierarchyNode<T> c) {
  return x + c.x!;
}

num maxY<T>(List<HierarchyNode<T>> children) {
  return 1 + children.fold(0, maxYReduce);
}

num maxYReduce<T>(num y, HierarchyNode<T> c) {
  return max(y, c.y!);
}

HierarchyNode<T> leafLeft<T>(HierarchyNode<T> node) {
  List<HierarchyNode<T>>? children;
  while ((children = node.children) != null) {
    node = children![0];
  }
  return node;
}

HierarchyNode<T> leafRight<T>(HierarchyNode<T> node) {
  List<HierarchyNode<T>>? children;
  while ((children = node.children) != null) {
    node = children![children.length - 1];
  }
  return node;
}

/// The cluster layout produces
/// [dendrograms](http://en.wikipedia.org/wiki/Dendrogram): node-link diagrams
/// that place leaf nodes of the tree at the same depth.
///
/// <img alt="Partition" src="https://raw.githubusercontent.com/d3/d3-hierarchy/main/img/cluster.png">
///
/// Dendrograms are typically less compact than
/// [tidy trees](https://pub.dev/documentation/d4_hierarchy/latest/topics/Tree-topic.html),
/// but are useful when all the leaves should be at the same level, such as for
/// hierarchical clustering or
/// [phylogenetic tree diagrams](https://observablehq.com/@d3/tree-of-life).
///
/// {@category Cluster}
class Cluster<T> {
  /// The separation accessor is used to separate neighboring leaves. The
  /// separation function is passed two nodes *a* and *b*, and must return the
  /// desired separation.
  ///
  /// The nodes are typically siblings, though the nodes may be more distantly
  /// related if the layout decides to place such nodes adjacent.
  ///
  /// Defaults to:
  ///
  /// ```dart
  /// int separation<T>(HierarchyNode<T> a, HierarchyNode<T> b) {
  ///   return a.parent == b.parent ? 1 : 2;
  /// }
  /// ```
  var separation = defaultSeparation<T>, _nodeSize = false;
  num _dx = 1, _dy = 1;

  /// Creates a new cluster layout with default settings.
  Cluster();

  /// Lays out the specified [root]
  /// [hierarchy](https://pub.dev/documentation/d4_hierarchy/latest/topics/Hierarchies-topic.html).
  ///
  /// Assigns the following properties on [root] and its descendants:
  ///
  /// * *node*.x - the *x*-coordinate of the node
  /// * *node*.y - the y coordinate of the node
  ///
  /// The coordinates *x* and *y* represent an arbitrary coordinate system; for
  /// example, you can treat *x* as an angle and *y* as a radius to produce a
  /// [radial layout](https://observablehq.com/@d3/radial-tidy-tree). You may
  /// want to call
  /// [*root*.sort](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/sort.html)
  /// before passing the hierarchy to the tree layout.
  void call(HierarchyNode<T> root) {
    HierarchyNode<T>? previousNode;
    var x = 0;

    // First walk, computing the initial x & y values.
    root.eachAfter((node, _, __, [___]) {
      var children = node.children;
      if (children != null) {
        (node).x = meanX(children);
        node.y = maxY(children);
      } else {
        node.x =
            previousNode != null ? x += separation(node, previousNode!) : 0;
        node.y = 0;
        previousNode = node;
      }
    });

    var left = leafLeft(root),
        right = leafRight(root),
        x0 = left.x! - separation(left, right) / 2,
        x1 = right.x! + separation(right, left) / 2;

    // Second walk, normalizing x & y to the desired size.
    root.eachAfter(_nodeSize
        ? (node, _, __, [___]) {
            node.x = (node.x! - root.x!) * _dx;
            node.y = (root.y! - node.y!) * _dy;
          }
        : (node, _, __, [___]) {
            node.x = (node.x! - x0) / (x1 - x0) * _dx;
            node.y =
                (1 - (root.y != null && root.y != 0 ? node.y! / root.y! : 1)) *
                    _dy;
          });
  }

  /// The cluster layout size specified as a two-element list of numbers
  /// \[*width*, *height*\]. The default is \[1, 1\].
  ///
  /// A layout size of null indicates that a [nodeSize] will be used instead.
  /// The coordinates *x* and *y* represent an arbitrary coordinate system; for
  /// example, to produce a
  /// [radial layout](https://observablehq.com/@d3/radial-tidy-tree), a size of
  /// \[360, *radius*\] corresponds to a breadth of 360° and a depth of
  /// *radius*.
  List<num>? get size => _nodeSize ? null : [_dx, _dy];
  set size(List<num>? size) {
    if (size != null) {
      _dx = size[0];
      _dy = size[1];
      _nodeSize = false;
    } else {
      _nodeSize = true;
    }
  }

  /// The cluster layout node size specified as a two-element list of numbers
  /// \[*width*, *height*\]. The default is null.
  ///
  /// A node size of null indicates that a layout [size] will be used instead.
  /// When a node size is specified, the root node is always positioned at
  /// ⟨0, 0⟩.
  List<num>? get nodeSize => _nodeSize ? [_dx, _dy] : null;
  set nodeSize(List<num>? nodeSize) {
    if (nodeSize != null) {
      _dx = nodeSize[0];
      _dy = nodeSize[1];
      _nodeSize = true;
    } else {
      _nodeSize = false;
    }
  }
}
