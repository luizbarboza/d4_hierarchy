import '../constant.dart';
import '../hierarchy/hierarchy.dart';
import 'round.dart';
import 'squarify.dart';

/// A **treemap** recursively subdivides area into rectangles according to each
/// node’s associated value.
///
/// [<img alt="Treemap" src="https://raw.githubusercontent.com/d3/d3-hierarchy/main/img/treemap.png">](https://observablehq.com/@d3/treemap/2?intent=fork)
///
/// D4’s treemap implementation supports an extensible
/// [tiling method](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/Treemap/tile.html):
/// the default
/// [squarified](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/treemapSquarify.html)
/// method seeks to generate rectangles with a
/// [golden](https://en.wikipedia.org/wiki/Golden_ratio) aspect ratio; this
/// offers better readability and size estimation than
/// [slice-and-dice](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/treemapSliceDice.html),
/// which simply alternates between horizontal and vertical subdivision by
/// depth.
///
/// {@category Treemap}
class Treemap<T> {
  /// The
  /// [tiling method](https://pub.dev/documentation/d4_hierarchy/latest/topics/Treemap%20tiling-topic.html),
  /// which defaults to
  /// [treemapSquarify](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/treemapSquarify.html)
  /// with the golden ratio.
  var tile = treemapSquarify<T>;

  /// Whether or not to round. Defaults to false.
  var round = false;

  late List<num?> _paddingStack;

  /// The inner padding is used to separate a node’s adjacent children and is
  /// invoked for each node with children, being passed the current node.
  num Function(HierarchyNode<T>) paddingInner = constantZero;

  /// The top padding is used to separate the top edge of a node from its
  /// children. Defaults to zero.
  num Function(HierarchyNode<T>) paddingTop = constantZero;

  /// The right padding is used to separate the right edge of a node from its
  /// children. Defaults to zero.
  num Function(HierarchyNode<T>) paddingRight = constantZero;

  /// The bottom padding is used to separate the bottom edge of a node from its
  /// children. Defaults to zero.
  num Function(HierarchyNode<T>) paddingBottom = constantZero;

  /// The left padding is used to separate the left edge of a node from its
  /// children. Defaults to zero.
  num Function(HierarchyNode<T>) paddingLeft = constantZero;

  num _dx = 1, _dy = 1;

  /// Creates a new treemap layout with default settings.
  Treemap();

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
  /// before passing the hierarchy to the treemap layout. You probably also want
  /// to call
  /// [*root*.sort](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/sort.html)
  /// to order the hierarchy before computing the layout.
  HierarchyNode<T> call(HierarchyNode<T> root) {
    root.x0 = root.y0 = 0;
    root.x1 = _dx;
    root.y1 = _dy;
    _paddingStack = List.filled(root.height + 1, null);
    _paddingStack[0] = 0;
    root.eachBefore(_positionNode);
    _paddingStack = [];
    if (round) root.eachBefore(roundNode);
    return root;
  }

  void _positionNode(
    HierarchyNode<T> node,
    int _,
    HierarchyNode<T> __, [
    Object? ___,
  ]) {
    var p = _paddingStack[node.depth]!,
        x0 = node.x0! + p,
        y0 = node.y0! + p,
        x1 = node.x1! - p,
        y1 = node.y1! - p;
    if (x1 < x0) x0 = x1 = (x0 + x1) / 2;
    if (y1 < y0) y0 = y1 = (y0 + y1) / 2;
    node.x0 = x0;
    node.y0 = y0;
    node.x1 = x1;
    node.y1 = y1;
    if (node.children != null) {
      p = _paddingStack[node.depth + 1] = paddingInner(node) / 2;
      x0 += paddingLeft(node) - p;
      y0 += paddingTop(node) - p;
      x1 -= paddingRight(node) - p;
      y1 -= paddingBottom(node) - p;
      if (x1 < x0) x0 = x1 = (x0 + x1) / 2;
      if (y1 < y0) y0 = y1 = (y0 + y1) / 2;
      tile(node, x0, y0, x1, y1);
    }
  }

  /// The treemap layout size specified as a two-element list of numbers
  /// \[*width*, *height*\]. The default is \[1, 1\].
  List<num> get size => [_dx, _dy];
  set size(List<num> size) {
    _dx = size[0];
    _dy = size[1];
  }

  /// An alias for [paddingInner], but defines [paddingInner] and
  /// [paddingOuter].
  num Function(HierarchyNode<T>) get padding => paddingInner;
  set padding(num Function(HierarchyNode<T>) padding) =>
      paddingInner = paddingOuter = padding;

  /// An alias for [paddingLeft], but defines [paddingTop], [paddingRight],
  /// [paddingBottom] and [paddingLeft].
  num Function(HierarchyNode<T>) get paddingOuter => paddingTop;
  set paddingOuter(num Function(HierarchyNode<T>) paddingOuter) =>
      paddingTop = paddingRight = paddingBottom = paddingLeft = paddingOuter;

  void constPadding(num padding) => this.padding = constant(padding);

  void constPaddingInner(num paddingInner) =>
      this.paddingInner = constant(paddingInner);

  void constPaddingOuter(num paddingOuter) =>
      this.paddingOuter = constant(paddingOuter);
}
