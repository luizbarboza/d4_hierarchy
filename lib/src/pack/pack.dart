import 'dart:math';

import '../constant.dart';
import '../hierarchy/hierarchy.dart';
import '../lcg.dart';
import 'siblings.dart';

num _defaultRadius<T>(HierarchyNode<T> d) {
  return sqrt(d.value ?? double.nan);
}

/// The pack layout produces circle-packing diagrams, where the area of each
/// leaf circle is proportional its value.
///
/// [<img alt="Circle-Packing" src="https://raw.githubusercontent.com/d3/d3-hierarchy/main/img/pack.png">](https://observablehq.com/@d3/circle-packing)
///
/// The enclosing circles show the approximate cumulative size of each subtree,
/// but due to wasted space there is some distortion; only the leaf nodes can be
/// compared accurately. Although
/// [circle packing](http://en.wikipedia.org/wiki/Circle_packing) does not use
/// space as efficiently as a
/// [treemap](https://pub.dev/documentation/d4_hierarchy/latest/topics/Treemap-topic.html),
/// the “wasted” space more prominently reveals the hierarchical structure.
///
/// {@category Pack}
class Pack<T> {
  /// Specifies the radius of each leaf circle.
  ///
  /// The default is null, wich means that the radius of each leaf circle is
  /// derived from the leaf *node*.value (computed by
  /// [*node*.sum](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/sum.html));
  /// the radii are then scaled proportionally to fit the layout [size].
  num Function(HierarchyNode<T>)? radius;

  /// The padding is used to separate tangent siblings. Defaults to
  /// zero.
  ///
  /// When siblings are packed, tangent siblings will be separated by
  /// approximately the specified padding; the enclosing parent circle will also
  /// be separated from its children by approximately the specified padding. If
  /// an explicit [radius] is not specified, the padding is approximate because
  /// a two-pass algorithm is needed to fit within the layout [size]\: the
  /// circles are first packed without padding; a scaling factor is computed and
  /// applied to the specified padding; and lastly the circles are re-packed
  /// with padding.
  num Function(HierarchyNode<T>) padding = constantZero;
  num _dx = 1, _dy = 1;

  /// Creates a new pack layout with the default settings.
  Pack();

  /// Lays out the specified *root*
  /// [hierarchy](https://pub.dev/documentation/d4_hierarchy/latest/topics/Hierarchies-topic.html).
  ///
  /// Assigns the following properties on *root* and its descendants:
  ///
  /// * *node*.x - the *x*-coordinate of the circle’s center
  /// * *node*.y - the y coordinate of the circle’s center
  /// * *node*.r - the radius of the circle
  ///
  /// You must call
  /// [*root*.sum](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/sum.html)
  /// before passing the hierarchy to the pack layout. You probably also want to
  /// call
  /// [*root*.sort](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/sort.html)
  /// to order the hierarchy before computing the layout.
  HierarchyNode<T> call(HierarchyNode<T> root) {
    final random = lcg();
    root.x = _dx / 2;
    root.y = _dy / 2;
    if (radius != null) {
      root
        ..eachBefore(_radiusLeaf(radius!))
        ..eachAfter(_packChildrenRandom(padding, 0.5, random))
        ..eachBefore(_translateChild(1));
    } else {
      root
        ..eachBefore(_radiusLeaf(_defaultRadius))
        ..eachAfter(_packChildrenRandom(constantZero, 1, random))
        ..eachAfter(
            _packChildrenRandom(padding, root.r! / min(_dx, _dy), random))
        ..eachBefore(_translateChild(min(_dx, _dy) / (2 * root.r!)));
    }
    return root;
  }

  /// The pack layout size specified as a two-element list of numbers
  /// \[*width*, *height*\]. The default is \[1, 1\].
  List<num> get size => [_dx, _dy];
  set size(List<num> size) {
    _dx = size[0];
    _dy = size[1];
  }

  void constPadding(num padding) => this.padding = constant(padding);
}

void Function(
  HierarchyNode<T>,
  int,
  HierarchyNode<T>, [
  Object?,
]) _radiusLeaf<T>(num Function(HierarchyNode<T>) radius) {
  return (node, _, __, [___]) {
    if (node.children == null) {
      node.r = max(0, radius(node));
    }
  };
}

void Function(
  HierarchyNode<T>,
  int,
  HierarchyNode<T>, [
  Object?,
]) _packChildrenRandom<T>(
    num Function(HierarchyNode<T>) padding, num k, num Function() random) {
  return (node, _, __, [___]) {
    List<HierarchyNode<T>>? children;
    if ((children = node.children) != null) {
      int i, n = children!.length;
      num r = padding(node) * k, e;

      if (r != 0) {
        for (i = 0; i < n; ++i) {
          children[i].r = children[i].r! + r;
        }
      }
      e = packSiblingsRandom(children.cast(), random);
      if (r != 0) {
        for (i = 0; i < n; ++i) {
          children[i].r = children[i].r! - r;
        }
      }
      node.r = e + r;
    }
  };
}

void Function(
  HierarchyNode<T>,
  int,
  HierarchyNode<T>, [
  Object?,
]) _translateChild<T>(num k) {
  return (node, _, __, [___]) {
    var parent = node.parent;
    node.r = node.r! * k;
    if (parent != null) {
      node.x = parent.x! + k * node.x!;
      node.y = parent.y! + k * node.y!;
    }
  };
}

/// "Wraps" any object or map, assuming it has the properties or keys
/// [x], [y] and [r].
///
/// {@category Pack}
extension type PackCircle._(Object? _) {
  PackCircle.map(Map map) : _ = map;
  PackCircle.object(Object node) : _ = node;

  num get x => _ is Map ? _["x"] : (_ as HierarchyNode).x;
  set x(num x) => _ is Map ? _["x"] = x : (_ as HierarchyNode).x = x;

  num get y => _ is Map ? _["y"] : (_ as HierarchyNode).y;
  set y(num y) => _ is Map ? _["y"] = y : (_ as HierarchyNode).y = y;

  num get r => _ is Map ? _["r"] : (_ as HierarchyNode).r;
  set r(num r) => _ is Map ? _["r"] = r : (_ as HierarchyNode).r = r;
}
