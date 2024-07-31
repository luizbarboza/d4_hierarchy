import 'hierarchy/hierarchy.dart';

var preroot = HierarchyNode(null)..depth = -1,
    ambiguous = HierarchyNode("__ambiguous__"),
    imputed = {};

defaultId(Map d, _, __) {
  return d["id"];
}

defaultParentId(Map d, _, __) {
  return d["parentId"];
}

/// Transforms a tree from link representation to hierarchy.
///
/// {@category Stratify}
class Stratify<T> {
  /// The id accessor is invoked for each element in the input data passed to
  /// the stratify operator ([Stratify.call]), being passed the current datum
  /// (*d*) and the current index (*i*). The returned string is then used to
  /// identify the node’s relationships in conjunction with the [parentId].
  ///
  /// For leaf nodes, the id may be undefined; otherwise, the id must be unique.
  /// (Null and the empty string are equivalent to undefined.)
  Function(T, int, Iterable<T>)? id;

  /// The parent id accessor is invoked for each element in the input data
  /// passed to the stratify operator ([Stratify.call]), being passed the
  /// current datum (*d*) and the current index (*i*). The returned string is
  /// then used to identify the node’s relationships in conjunction with the
  /// [id].
  ///
  /// For the root node, the parent id should be undefined. (Null and the empty
  /// string are equivalent to undefined.) There must be exactly one root node
  /// in the input data, and no circular relationships.
  Function(T, int, Iterable<T>)? parentId;

  /// If a path accessor is set, the [id] and [parentId] accessors are ignored,
  /// and a unix-like hierarchy is computed on the slash-delimited strings
  /// returned by the path accessor, imputing parent nodes and ids as necessary.
  ///
  /// For example, given the output of the UNIX find command in the local
  /// directory:
  ///
  /// ```dart
  /// final paths = [
  ///   "axes.js",
  ///   "channel.js",
  ///   "context.js",
  ///   "legends.js",
  ///   "legends/ramp.js",
  ///   "marks/density.js",
  ///   "marks/dot.js",
  ///   "marks/frame.js",
  ///   "scales/diverging.js",
  ///   "scales/index.js",
  ///   "scales/ordinal.js",
  ///   "stats.js",
  ///   "style.js",
  ///   "transforms/basic.js",
  ///   "transforms/bin.js",
  ///   "transforms/centroid.js",
  ///   "warnings.js",
  /// ];
  /// ```
  ///
  /// You can say:
  ///
  /// ```dart
  /// final root = (Stratify()..path = (d, i, data) => d)(paths);
  /// ```
  String Function(T, int, Iterable<T>)? path;

  /// Constructs a new stratify operator.
  ///
  /// ```dart
  /// final stratify = Stratify<Map>(
  ///   id: (d, i, data) => d["name"],
  ///   parentId: (d, i, data) => d["parent"],
  /// );
  /// ```
  Stratify({this.id, this.parentId});

  /// Generates a new hierarchy from the specified tabular [data].
  ///
  /// ```dart
  /// final root = stratify(data);
  /// ```
  HierarchyNode<T?> call(Iterable<T> data) {
    var data0 = <Object?>[...data],
        nodes = <HierarchyNode<Object?>>[],
        nodeByKey = <String, HierarchyNode<Object?>>{};
    Function? currentId = id, currentParentId = parentId;
    int i, n;
    Object? d;
    HierarchyNode<Object?>? root;
    HierarchyNode<Object?>? parent;
    HierarchyNode<Object?> node;
    Object? nodeId;
    String nodeKey;

    if (path != null) {
      i = 0;
      final I = data.map((d) => normalize(path!(d, i++, data))).toList();
      final P = I.map(parentof).toList();
      final S = I.toSet()..add("");
      i = 0;
      String pi;
      while (i < P.length) {
        pi = P[i];
        if (!S.contains(pi)) {
          S.add(pi);
          I.add(pi);
          P.add(parentof(pi));
          data0.add(imputed);
        }
        i++;
      }
      currentId = (_, i, __) => I[i];
      currentParentId = (_, i, __) => P[i];
    }

    i = 0;
    n = data0.length;
    for (; i < n; ++i) {
      d = data0[i];
      nodes.add(node = HierarchyNode(d));
      //if (d == imputed) continue;
      if ((nodeId = currentId?.call(d, i, data)?.toString()) != null &&
          (nodeId as String).isNotEmpty) {
        nodeKey = node.id = nodeId;
        nodeByKey[nodeKey] = nodeByKey.containsKey(nodeKey) ? ambiguous : node;
      }
      if ((nodeId = currentParentId?.call(d, i, data)?.toString()) != null &&
          (nodeId as String).isNotEmpty) {
        node.parentId = nodeId;
      }
    }

    for (i = 0; i < n; ++i) {
      node = nodes[i];
      if ((nodeId = node.parentId) != null) {
        parent = nodeByKey[nodeId];
        if (parent == null) throw ArgumentError("missing: $nodeId");
        if (parent == ambiguous) throw ArgumentError("ambiguous: $nodeId");
        if (parent.children != null) {
          parent.children!.add(node);
        } else {
          parent.children = [node];
        }
        node.parent = parent;
      } else {
        if (root != null) throw ArgumentError("multiple roots");
        root = node;
      }
    }

    if (root == null) throw ArgumentError("no root");

    // When imputing internal nodes, only introduce roots if needed.
    // Then replace the imputed marker data with null.
    if (path != null) {
      while (root!.data == imputed && root.children!.length == 1) {
        root = root.children![0];
        --n;
      }
      for (var i = nodes.length - 1; i >= 0; --i) {
        node = nodes[i];
        if (node.data != imputed) break;
        node.data = null;
      }
    }

    root.parent = preroot;
    (root
          ..eachBefore((node, _, __, [___]) {
            node.depth = node.parent!.depth + 1;
            --n;
          }))
        .eachBefore(computeHeight);
    root.parent = null;
    if (n > 0) throw ArgumentError("cycle");

    return cast<Object?, T?>(root);
  }

  static Stratify<T> withDefaults<T extends Map>(
          {Function(Map, int, Iterable<Map>)? id = defaultId,
          Function(Map, int, Iterable<Map>)? parentId = defaultParentId}) =>
      Stratify<T>(id: id, parentId: parentId);
}

// To normalize a path, we coerce to a string, strip the trailing slash if any
// (as long as the trailing slash is not immediately preceded by another slash),
// and add leading slash if missing.
String normalize<T>(T path) {
  var path0 = path.toString();
  var i = path0.length;
  if (slash(path0, i - 1) && !slash(path0, i - 2)) {
    path0 = path0.substring(0, path0.length - 1);
  }
  return path0.isNotEmpty && path0[0] == "/" ? path0 : "/$path0";
}

// Walk backwards to find the first slash that is not the leading slash, e.g.:
// "/foo/bar" ⇥ "/foo", "/foo" ⇥ "/", "/" ↦ "". (The root is special-cased
// because the id of the root must be a truthy value.)
String parentof(String path) {
  var i = path.length;
  if (i < 2) return "";
  while (--i > 1) {
    if (slash(path, i)) break;
  }
  return path.substring(0, i);
}

// Slashes can be escaped; to determine whether a slash is a path delimiter, we
// count the number of preceding backslashes escaping the forward slash: an odd
// number indicates an escaped forward slash.
bool slash(String path, int i) {
  if (i >= 0 && path[i] == "/") {
    var k = 0;
    while (i > 0 && path[--i] == "\\") {
      ++k;
    }
    if ((k & 1) == 0) return true;
  }
  return false;
}
