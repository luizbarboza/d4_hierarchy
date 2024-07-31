import 'hierarchy/hierarchy.dart';
import 'treemap/dice.dart';
import 'treemap/round.dart';

/// The partition layout produces adjacency diagrams: a space-filling variant of
/// a
/// [node-link tree diagram](https://pub.dev/documentation/d4_hierarchy/latest/topics/Tree-topic.html).
///
/// [<img alt="Partition" src="https://raw.githubusercontent.com/d3/d3-hierarchy/main/img/partition.png">](https://observablehq.com/@d3/icicle/2?intent=fork)
///
/// Rather than drawing a link between parent and child in the hierarchy, nodes
/// are drawn as solid areas (either arcs or rectangles), and their placement
/// relative to other nodes reveals their position in the hierarchy. The size of
/// the nodes encodes a quantitative dimension that would be difficult to show
/// in a node-link diagram.
///
/// {@category Partition}
class Partition<T> {
  num _dx = 1, _dy = 1;

  /// The padding is used to separate a node’s adjacent children. Defaults to
  /// zero.
  num padding = 0;

  /// Whether or not to round. Defaults to false.
  var round = false;

  /// Creates a new partition layout with the default settings.
  Partition();

  /// Lays out the specified *root*
  /// [hierarchy](https://pub.dev/documentation/d4_hierarchy/latest/topics/Hierarchies-topic.html).
  ///
  /// Assigns the following properties on *root* and its descendants:
  ///
  /// * *node*.x0 - the left edge of the rectangle
  /// * *node*.y0 - the top edge of the rectangle
  /// * *node*.x1 - the right edge of the rectangle
  /// * *node*.y1 - the bottom edge of the rectangle
  ///
  /// You must call
  /// [*root*.sum](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/sum.html)
  /// before passing the hierarchy to the partition layout. You probably also
  /// want to call
  /// [*root*.sort](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/sort.html)
  /// to order the hierarchy before computing the layout.
  HierarchyNode<T> call(HierarchyNode<T> root) {
    var n = root.height + 1;
    root.x0 = root.y0 = padding;
    root.x1 = _dx;
    root.y1 = _dy / n;
    root.eachBefore(_positionNode(_dy, n));
    if (round) root.eachBefore(roundNode);
    return root;
  }

  void Function(HierarchyNode<T>, int, HierarchyNode<T>, [Object?])
      _positionNode(num dy, num n) {
    return (node, _, __, [___]) {
      if (node.children != null) {
        treemapDice(node, node.x0!, dy * (node.depth + 1) / n, node.x1!,
            dy * (node.depth + 2) / n);
      }
      var x0 = node.x0!,
          y0 = node.y0!,
          x1 = node.x1! - padding,
          y1 = node.y1! - padding;
      if (x1 < x0) x0 = x1 = (x0 + x1) / 2;
      if (y1 < y0) y0 = y1 = (y0 + y1) / 2;
      node.x0 = x0;
      node.y0 = y0;
      node.x1 = x1;
      node.y1 = y1;
    };
  }

  /// The partition layout size specified as a two-element list of numbers
  /// \[*width*, *height*\]. The default is \[1, 1\].
  List<num> get size => [_dx, _dy];
  set size(List<num> size) {
    _dx = size[0];
    _dy = size[1];
  }
}
