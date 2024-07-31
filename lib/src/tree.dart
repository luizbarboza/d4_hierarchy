import 'hierarchy/hierarchy.dart';

int defaultSeparation<T>(HierarchyNode<T> a, HierarchyNode<T> b) {
  return a.parent == b.parent ? 1 : 2;
}

// function radialSeparation(a, b) {
//   return (a.parent === b.parent ? 1 : 2) / a.depth;
// }

// This function is used to traverse the left contour of a subtree (or
// subforest). It returns the successor of v on this contour. This successor is
// either given by the leftmost child of v or by the thread of v. The function
// returns null if and only if v is on the highest level of its subtree.
TreeNode<T>? nextLeft<T>(TreeNode<T> v) {
  var children = v.children;
  return children != null ? children[0] : v.t;
}

// This function works analogously to nextLeft.
TreeNode<T>? nextRight<T>(TreeNode<T> v) {
  var children = v.children;
  return children != null ? children[children.length - 1] : v.t;
}

// Shifts the current subtree rooted at w+. This is done by increasing
// prelim(w+) and mod(w+) by shift.
void moveSubtree<T>(TreeNode<T> wm, TreeNode<T> wp, num shift) {
  var change = shift / (wp.i - wm.i);
  wp.c -= change;
  wp.s += shift;
  wm.c += change;
  wp.z += shift;
  wp.m += shift;
}

// All other shifts, applied to the smaller subtrees between w- and w+, are
// performed by this function. To prepare the shifts, we have to adjust
// change(w+), shift(w+), and change(w-).
void executeShifts<T>(TreeNode<T> v) {
  num shift = 0, change = 0;
  var children = v.children, i = children!.length;
  TreeNode<T> w;
  while (--i >= 0) {
    w = children[i];
    w.z += shift;
    w.m += shift;
    shift += w.s + (change += w.c);
  }
}

// If vi-’s ancestor is a sibling of v, returns vi-’s ancestor. Otherwise,
// returns the specified (default) ancestor.
TreeNode<T> nextAncestor<T>(
    TreeNode<T> vim, TreeNode<T> v, TreeNode<T> ancestor) {
  return vim.a.parent == v.parent ? vim.a : ancestor;
}

final class TreeNode<T>
    extends HierarchyNodeBase<HierarchyNode<T>?, TreeNode<T>> {
  TreeNode<T>? A; // default ancestor
  late TreeNode<T> a = this; // ancestor
  num z = 0; // prelim
  num m = 0; // mod
  num c = 0; // change
  num s = 0; // shift
  TreeNode<T>? t; // thread
  int i; // number

  TreeNode(HierarchyNode<T>? node, this.i) : super(node);

  @override
  TreeNode<T> copy() {
    throw UnimplementedError();
  }
}

TreeNode<T> treeRoot<T>(HierarchyNode<T> root) {
  var tree = TreeNode(root, 0), nodes = <TreeNode<T>>[tree];
  TreeNode<T> node;
  TreeNode<T> child;
  List<HierarchyNode<T>>? children;
  int i, n;

  while (nodes.isNotEmpty) {
    node = nodes.removeLast();
    if ((children = node.data?.children) != null) {
      n = children!.length;
      node.children = [];
      for (i = n - 1; i >= 0; --i) {
        node.children!.insert(0, child = TreeNode(children[i], i));
        nodes.add(child);
        child.parent = node;
      }
    }
  }

  (tree.parent = TreeNode(null, 0)).children = [tree];
  return tree;
}

// Node-link tree diagram using the Reingold-Tilford "tidy" algorithm
/// The tree layout produces tidy node-link diagrams of trees using the
/// [Reingold–Tilford “tidy” algorithm](http://reingold.co/tidier-drawings.pdf),
/// improved to run in linear time by
/// [Buchheim *et al.*](http://dirk.jivas.de/papers/buchheim02improving.pdf)
///
/// <img alt="Partition" src="https://raw.githubusercontent.com/d3/d3-hierarchy/main/img/cluster.png">
///
/// Tidy trees are typically more compact than
/// [dendrograms](https://pub.dev/documentation/d4_hierarchy/latest/topics/Cluster-topic.html).
///
/// {@category Tree}
class Tree<T> {
  /// The separation accessor is used to separate neighboring nodes. The
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
  ///
  /// A variation that is more appropriate for radial layouts reduces the
  /// separation gap proportionally to the radius:
  ///
  /// ```dart
  /// int separation<T>(HierarchyNode<T> a, HierarchyNode<T> b) {
  ///   return (a.parent == b.parent ? 1 : 2) / a.depth;
  /// }
  /// ```
  var separation = defaultSeparation<T>, _nodeSize = false;
  num _dx = 1, _dy = 1;

  /// Creates a new tree layout with default settings.
  Tree();

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
  HierarchyNode<T> call(HierarchyNode<T> root) {
    var t = treeRoot(root);

    // Compute the layout using Buchheim et al.’s algorithm.
    t.eachAfter(_firstWalk);
    t.parent!.m = -t.z;
    t.eachBefore(_secondWalk);

    // If a fixed node size is specified, scale x and y.
    if (_nodeSize) {
      root.eachBefore(_sizeNode);

      // If a fixed tree size is specified, scale x and y based on the extent.
      // Compute the left-most, right-most, and depth-most nodes for extents.
    } else {
      var left = root, right = root, bottom = root;
      root.eachBefore((node, _, __, [___]) {
        if (node.x! < left.x!) left = node;
        if (node.x! > right.x!) right = node;
        if (node.depth > bottom.depth) bottom = node;
      });
      var s = left == right ? 1 : separation(left, right) / 2,
          tx = s - left.x!,
          kx = _dx / (right.x! + s + tx),
          ky = _dy / (bottom.depth == 0 ? 1 : bottom.depth);
      root.eachBefore((node, _, __, [___]) {
        node.x = (node.x! + tx) * kx;
        node.y = node.depth * ky;
      });
    }

    return root;
  }

  // Computes a preliminary x-coordinate for v. Before that, FIRST WALK is
  // applied recursively to the children of v, as well as the function
  // APPORTION. After spacing out the children by calling EXECUTE SHIFTS, the
  // node v is placed to the midpoint of its outermost children.
  void _firstWalk(TreeNode<T> v, _, __, [___]) {
    var children = v.children,
        siblings = v.parent!.children!,
        w = v.i != 0 ? siblings[v.i - 1] : null;
    if (children != null) {
      executeShifts(v);
      var midpoint = (children[0].z + children[children.length - 1].z) / 2;
      if (w != null) {
        v.z = w.z + separation(v.data!, w.data!);
        v.m = v.z - midpoint;
      } else {
        v.z = midpoint;
      }
    } else if (w != null) {
      v.z = w.z + separation(v.data!, w.data!);
    }
    v.parent!.A = _apportion(v, w, v.parent!.A ?? siblings[0]);
  }

  // Computes all real x-coordinates by summing up the modifiers recursively.
  void _secondWalk(TreeNode<T> v, _, __, [___]) {
    v.data!.x = v.z + v.parent!.m;
    v.m += v.parent!.m;
  }

  // The core of the algorithm. Here, a new subtree is combined with the
  // previous subtrees. Threads are used to traverse the inside and outside
  // contours of the left and right subtree up to the highest common level. The
  // vertices used for the traversals are vi+, vi-, vo-, and vo+, where the
  // superscript o means outside and i means inside, the subscript - means left
  // subtree and + means right subtree. For summing up the modifiers along the
  // contour, we use respective variables si+, si-, so-, and so+. Whenever two
  // nodes of the inside contours conflict, we compute the left one of the
  // greatest uncommon ancestors using the function ANCESTOR and call MOVE
  // SUBTREE to shift the subtree and prepare the shifts of smaller subtrees.
  // Finally, we add a new thread (if necessary).
  TreeNode<T> _apportion(TreeNode<T> v, TreeNode<T>? w, TreeNode<T> ancestor) {
    if (w != null) {
      TreeNode<T>? vip = v, vop = v, vim = w, vom = vip.parent!.children![0];
      num sip = vip.m, sop = vop.m, sim = vim.m, som = vom.m, shift;
      vim = nextRight(vim);
      vip = nextLeft(vip);
      while (vim != null && vip != null) {
        vom = nextLeft(vom!);
        vop = nextRight(vop!);
        vop!.a = v;
        shift = vim.z + sim - vip.z - sip + separation(vim.data!, vip.data!);
        if (shift > 0) {
          moveSubtree(nextAncestor(vim, v, ancestor), v, shift);
          sip += shift;
          sop += shift;
        }
        sim += vim.m;
        sip += vip.m;
        som += vom!.m;
        sop += vop.m;
      }
      if (vim != null && nextRight(vop!) == null) {
        vop.t = vim;
        vop.m += sim - sop;
      }
      if (vip != null && nextLeft(vom!) == null) {
        vom.t = vip;
        vom.m += sip - som;
        ancestor = v;
      }
    }
    return ancestor;
  }

  void _sizeNode(HierarchyNode<T> node, _, __, [___]) {
    node.x = node.x! * _dx;
    node.y = node.depth * _dy;
  }

  /// The tree layout size specified as a two-element list of numbers \[*width*,
  /// *height*\]. The default is \[1, 1\].
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

  /// The tree layout node size specified as a two-element list of numbers
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
