import 'dart:collection';

import '../treemap/squarify.dart';

part 'ancestors.dart';
part 'count.dart';
part 'descendants.dart';
part 'each_after.dart';
part 'each_before.dart';
part 'each.dart';
part 'find.dart';
part 'iterator.dart';
part 'leaves.dart';
part 'links.dart';
part 'path.dart';
part 'sort.dart';
part 'sum.dart';

/// Equivalent to [hierarchyWithDefaults], but requires [data] and [children].
///
/// {@category Hierarchies}
HierarchyNode<T> hierarchy<T>(T data, Iterable<T>? Function(T) children) {
  HierarchyNode<T> root = HierarchyNode(data), node;
  List<HierarchyNode<T>> nodes = [root];
  HierarchyNode<T> child;
  Object? childs;
  int i, n;

  while (nodes.isNotEmpty) {
    node = nodes.removeLast();
    if ((childs = children(node.data)) != null &&
        (n = (childs = List<Object?>.from(childs as Iterable<T>)).length) !=
            0) {
      childs as List<Object?>;
      for (i = n - 1; i >= 0; --i) {
        nodes.add(child = childs[i] = HierarchyNode(childs[i] as T));
        child.parent = node;
        child.depth = node.depth + 1;
      }
      node.children = List.castFrom(childs);
    }
  }

  return root..eachBefore(computeHeight);
}

/// Constructs a root node from the specified hierarchical [data].
///
/// The specified [data] must be an object representing the root node. For
/// example:
///
/// ```dart
/// final data = MapView({
///   "name": "Eve",
///   "children": [
///     {"name": "Cain"},
///     {"name": "Seth", "children": [{"name": "Enos"}, {"name": "Noam"}]},
///     {"name": "Abel"},
///     {"name": "Awan", "children": [{"name": "Enoch"}]},
///     {"name": "Azura"}
///   ]
/// });
/// ```
///
/// To construct a hierarchy:
///
/// ```dart
/// final root = hierarchyWithDefaults(data);
/// ```
///
/// The specified [children] accessor function is invoked for each datum,
/// starting with the root [data], and must return an iterable of data
/// representing the children, if any. If the children accessor is not
/// specified, it defaults to:
///
/// ```dart
/// Iterable? children(d) {
///   return d.children;
/// }
/// ```
///
/// If [data] is a [Map], the children accessor instead defaults to:
/// ```dart
/// Iterable? children(d) {
///   return d["children"];
/// }
/// ```
///
/// If [data] is a [LinkedHashMap], it is implicitly converted to the entry
/// \[undefined, [data]\], and the children accessor instead defaults to:
///
/// ```dart
/// Iterable? children(d) {
///   return d is List
///       ? d[1] is Map
///         ? (d[1] as Map).entries.map((e) => [e.key, e.value])
///         : d[1]
///       : null;
/// }
/// ```
///
/// This allows you to pass the result of
/// [group](https://pub.dev/documentation/d4_array/latest/d4_array/group.html)
/// or
/// [rollup](https://pub.dev/documentation/d4_array/latest/d4_array/rollup.html)
/// to hierarchy.
///
/// The returned root node and each descendant has the following properties:
///
/// * *node*.data - the associated data as passed to
/// [hierarchy](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/hierarchyWithDefaults.html)
/// * *node*.depth - zero for the root, increasing by one for each descendant
/// generation
/// * *node*.height - the greatest distance from any descendant leaf, or zero
/// for leaves
/// * *node*.parent - the parent node, or null for the root node
/// * *node*.children - an array of child nodes, if any, or undefined for leaves
/// * *node*.value - the optional summed value of the node and its
/// [descendants](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/descendants.html)
///
/// {@category Hierarchies}
HierarchyNode<dynamic> hierarchyWithDefaults(
  data, [
  Iterable? Function(dynamic)? children,
]) {
  if (data is LinkedHashMap) {
    data = [null, data];
    children ??= entryChildren;
  } else {
    children ??= data is Map ? mapChildren : objectChildren;
  }
  return hierarchy(data, children);
}

HierarchyNode<R> cast<T, R>(HierarchyNode<T> thisArg) {
  var node = HierarchyNode<R>(thisArg.data as R)
    ..id = thisArg.id
    ..parentId = thisArg.parentId
    ..value = thisArg.value
    ..depth = thisArg.depth
    ..height = thisArg.height
    ..children = thisArg.children?.map(cast<T, R>).toList();
  node.children?.forEach((child) => child.parent = node);
  return node;
}

HierarchyNode<T> _copy<T>(HierarchyNode<T> thisArg) {
  return cast<T, T>(thisArg);
}

Iterable? mapChildren(d) {
  return d["children"];
}

Iterable? objectChildren(d) {
  return d.children;
}

Iterable? entryChildren(d) {
  return d is List
      ? d[1] is Map
          ? (d[1] as Map).entries.map((e) => [e.key, e.value])
          : d[1]
      : null;
}

void computeHeight<T, Node extends HierarchyNodeBase<T, Node>>(
    Node? node, _, __,
    [___]) {
  var height = 0;
  do {
    node!.height = height;
  } while ((node = node.parent) != null && (node!.height < ++height));
}

abstract base class HierarchyNodeBase<T,
    Node extends HierarchyNodeBase<T, Node>> extends Iterable<Node> {
  /// Hierarchical data.
  T data;

  /// Zero for the root, increasing by one for each descendant generation.
  int depth = 0;

  /// The greatest distance from any descendant leaf, or zero for leaves.
  int height = 0;

  /// The parent node, or null for the root node.
  Node? parent;

  /// An list of child nodes, if any, or null for leaves.
  List<Node>? children;

  /// The optional summed value of the node and its [descendants].
  num? value;

  String? id;
  String? parentId;

  num? x;
  num? y;

  num? r;

  num? x0;
  num? y0;
  num? x1;
  num? y1;

  Squarify<T>? squarify;

  HierarchyNodeBase(this.data);

  void count() => _count(this as Node);

  void each(
    void Function(
      Node,
      int,
      Node, [
      Object?,
    ]) function, [
    Object? that,
  ]) =>
      _each(this as Node, function, that);

  void eachAfter(
    void Function(
      Node,
      int,
      Node, [
      Object?,
    ]) function, [
    Object? that,
  ]) =>
      _eachAfter(this as Node, function, that);

  void eachBefore(
    void Function(
      Node,
      int,
      Node, [
      Object?,
    ]) function, [
    Object? that,
  ]) =>
      _eachBefore(this as Node, function, that);

  Node? find(
    bool Function(
      Node,
      int,
      Node, [
      Object?,
    ]) filter, [
    Object? that,
  ]) =>
      _find(this as Node, filter, that);

  void sum(num? Function(T) value) => _sum(this as Node, value);

  void sort(
    int Function(Node, Node) compare,
  ) =>
      _sort(this as Node, compare);

  List<Node> path(Node target) => _path(this as Node, target);

  List<Node> ancestors() => _ancestors(this as Node);

  List<Node> descendants() => _descendants(this as Node);

  List<Node> leaves() => _leaves(this as Node);

  List<Map<String, Node>> links() => _links(this as Node);

  Node copy();

  @override
  Iterator<Node> get iterator => _Iterator<T, Node>(this as Node);

  @override
  operator ==(Object other) {
    if (other is! HierarchyNodeBase<T, Node>) return false;
    int i = 0;
    var otherChildren = other.children;
    return data == other.data &&
        depth == other.depth &&
        height == other.height &&
        value == other.value &&
        id == other.id &&
        parentId == other.parentId &&
        x == other.x &&
        y == other.y &&
        r == other.r &&
        x0 == other.x0 &&
        y0 == other.y0 &&
        x1 == other.x1 &&
        y1 == other.y1 &&
        (children != null) == (otherChildren != null) &&
        (children != null
            ? children!.every((child) => child == otherChildren![i++])
            : true);
  }

  @override
  int get hashCode => Object.hash(
      data,
      depth,
      height,
      value,
      id,
      parentId,
      x,
      y,
      r,
      x0,
      y0,
      x1,
      y1,
      children != null ? Object.hashAll(children!) : null);
}

/// A hierarchy node holds data, it can be linked to a parent if it is not a
/// root, as well as to children if it is not a leaf.
///
/// {@category Hierarchies}
final class HierarchyNode<T> extends HierarchyNodeBase<T, HierarchyNode<T>> {
  HierarchyNode(super.data);

  /// Return a deep copy of the subtree starting at this *node*. (The returned
  /// deep copy shares the same data, however.)
  ///
  /// The returned node is the root of a new tree; the returned node’s parent is
  /// always null and its depth is always zero.
  @override
  HierarchyNode<T> copy() => _copy(this);

  /// Returns the list of ancestors nodes, starting with this node, then
  /// followed by each parent up to the root.
  @override
  ancestors();

  /// Returns the list of descendant nodes, starting with this node, then
  /// followed by each child in topological order.
  @override
  descendants();

  /// Returns the list of leaf nodes in traversal order. A leaf is a node with
  /// no children.
  @override
  leaves();

  /// Returns the first node in the hierarchy from this *node* for which the
  /// specified [filter] returns a truthy value. Returns null if no such node is
  /// found.
  @override
  find(filter, [that]);

  /// Returns the shortest path through the hierarchy from this *node* to the
  /// specified *target* node.
  ///
  /// The path starts at this *node*, ascends to the least common ancestor of
  /// this *node* and the *target* node, and then descends to the *target* node.
  /// This is useful for hierarchical edge bundling.
  @override
  path(target);

  /// Returns an list of links for this *node* and its descendants, where each
  /// *link* is an map that defines source and target properties. The source of
  /// each link is the parent node, and the target is a child node.
  @override
  links();

  /// Evaluates the specified [value] function for this *node* and each
  /// descendant in
  /// [post-order traversal](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/eachAfter.html).
  ///
  /// The *node*.value property of each node is set to the numeric value
  /// returned by the specified function plus the combined value of all
  /// children. The function is passed the node’s data, and must return a
  /// non-negative number. The [value] accessor is evaluated for *node* and
  /// every descendant, including internal nodes; if you only want leaf nodes to
  /// have internal value, then return zero for any node with children.
  /// [For example](https://observablehq.com/@d3/treemap-by-count), as an
  /// alternative to
  /// [*node*.count](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/count.html):
  ///
  /// ```dart
  /// root.sum((d) => d.value ? 1 : 0);
  /// ```
  ///
  /// You must call *node*.sum or
  /// [*node*.count](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/count.html)
  /// before invoking a hierarchical layout that requires *node*.value, such as
  /// [treemap](https://pub.dev/documentation/d4_hierarchy/latest/topics/Treemap-topic.html).
  /// For example:
  ///
  /// ```dart
  /// // Construct the treemap layout.
  /// final treemap = Treemap();
  /// treemap.size([width, height]);
  /// treemap.padding(2);
  ///
  /// // Sum and sort the data.
  /// root.sum((d) => d.value);
  /// root.sort((a, b) {
  ///   var heightDiff = b.height - a.height;
  ///   return (heightDiff != 0 ? heightDiff : b.value! - a.value!).sign.toInt();
  /// });
  ///
  /// // Compute the treemap layout.
  /// treemap(root);
  ///
  /// // Retrieve all descendant nodes.
  /// final nodes = root.descendants();
  /// ```
  ///
  /// Since the API supports
  /// [method chaining](https://en.wikipedia.org/wiki/Method_chaining), you can
  /// also say:
  ///
  /// ```dart
  /// (Treemap()
  ///       ..size = [width, height]
  ///       ..constPadding(2))(root
  ///       ..sum((d) => d.value)
  ///       ..sort((a, b) {
  ///         var heightDiff = b.height - a.height;
  ///         return (heightDiff != 0 ? heightDiff : b.value! - a.value!)
  ///             .sign
  ///             .toInt();
  ///       }))
  ///     .descendants();
  ///
  /// This example assumes that the node data has a value property.
  /// ```
  @override
  sum(value);

  /// Computes the number of leaves under this *node* and assigns it to
  /// *node*.value, and similarly for every descendant of *node*.
  ///
  /// If this *node* is a leaf, its count is one. See also
  /// [*node*.sum](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/sum.html).
  @override
  count();

  /// Sorts the children of this *node*, if any, and each of this *node*’s
  /// descendants’ children, in
  /// [pre-order traversal](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/eachBefore.html)
  /// using the specified [compare] function.
  ///
  /// The specified function is passed two nodes *a* and *b* to compare. If *a*
  /// should be before *b*, the function must return a value less than zero; if
  /// *b* should be before *a*, the function must return a value greater than
  /// zero; otherwise, the relative order of *a* and *b* are not specified. See
  /// [*array*.sort](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort)
  /// for more.
  ///
  /// Unlike
  /// [*node*.sum](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/sum.html),
  /// the [compare] function is passed two
  /// [nodes](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode-class.html)
  /// rather than two nodes’ data. For example, if the data has a value prop
  ///
  /// ```dart
  /// root
  ///   ..sum((d) => d.value)
  ///   ..sort((a, b) => (b.value! - a.value!).sign.toInt());
  /// ```
  ///
  /// Similarly, to sort nodes by descending height (greatest distance from any
  /// descendant leaf) and then descending value, as is recommended for
  /// [treemaps](https://pub.dev/documentation/d4_hierarchy/latest/topics/Tree-topic.html)
  /// and
  /// [icicles](https://pub.dev/documentation/d4_hierarchy/latest/topics/Partition-topic.html):
  ///
  /// ```dart
  /// root
  ///   ..sum((d) => d.value)
  ///   ..sort((a, b) {
  ///     var heightDiff = b.height - a.height;
  ///     return (heightDiff != 0 ? heightDiff : b.value! - a.value!).sign.toInt();
  ///   });
  /// ```
  ///
  /// To sort nodes by descending height and then ascending id, as is
  /// recommended for
  /// [trees](https://pub.dev/documentation/d4_hierarchy/latest/topics/Tree-topic.html)
  /// and
  /// [dendrograms](https://pub.dev/documentation/d4_hierarchy/latest/topics/Cluster-topic.html):
  ///
  /// ```dart
  /// root
  ///   ..sum((d) => d.value)
  ///   ..sort((a, b) {
  ///     var heightDiff = b.height - a.height;
  ///     return (heightDiff != 0 ? heightDiff : ascending(a.id, b.id)).sign.toInt();
  ///   });
  /// ```
  ///
  /// You must call *node*.sort before invoking a hierarchical layout if you
  /// want the new sort order to affect the layout; see
  /// [*node*.sum](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/HierarchyNode/sum.html)
  /// for an example.
  @override
  sort(compare);

  /// A new iterator over the *node*’s descendants in breadth-first order.
  ///
  /// For example:
  ///
  /// ```dart
  /// for (final descendant in node) {
  ///   print(descendant);
  /// }
  /// ```
  @override
  get iterator;

  /// Invokes the specified [function] for *node* and each descendant in
  /// [breadth-first order](https://en.wikipedia.org/wiki/Breadth-first_search),
  /// such that a given *node* is only visited if all nodes of lesser depth have
  /// already been visited, as well as all preceding nodes of the same depth.
  ///
  /// The specified function is passed the current *descendant*, the zero-based
  /// traversal *index*, and this *node*. If [that] is specified, it is the this
  /// context of the callback.
  @override
  each(function, [that]);

  /// Invokes the specified [function] for *node* and each descendant in
  /// [post-order traversal](https://en.wikipedia.org/wiki/Tree_traversal#Post-order),
  /// such that a given *node* is only visited after all of its descendants have
  /// already been visited.
  ///
  /// The specified function is passed the current *descendant*, the zero-based
  /// traversal *index*, and this *node*. If [that] is specified, it is the this
  /// context of the callback.
  @override
  eachAfter(function, [that]);

  /// Invokes the specified [function] for *node* and each descendant in
  /// [pre-order traversal](https://en.wikipedia.org/wiki/Tree_traversal#Pre-order),
  /// such that a given *node* is only visited after all of its ancestors have
  /// already been visited.
  ///
  /// The specified function is passed the current *descendant*, the zero-based
  /// traversal *index*, and this *node*. If [that] is specified, it is the this
  /// context of the callback.
  @override
  eachBefore(function, [that]);
}
