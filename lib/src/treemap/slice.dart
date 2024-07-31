import '../hierarchy/hierarchy.dart';

/// Divides the rectangular area specified by [x0], [y0], [x1], [y1] vertically
/// according the value of each of the specified [node]’s children.
///
/// The children are positioned in order, starting with the top edge ([y0]) of
/// the given rectangle. If the sum of the children’s values is less than the
/// specified [node]’s value (*i.e.*, if the specified [node] has a non-zero
/// internal value), the remaining empty space will be positioned on the bottom
/// edge ([y1]) of the given rectangle.
///
/// {@category Treemap}
/// {@category Treemap tiling}
void treemapSlice<T>(HierarchyNode<T> node, num x0, num y0, num x1, num y1) {
  var nodes = node.children!,
      i = -1,
      n = nodes.length,
      k = node.value != 0 ? (y1 - y0) / node.value! : 0;
  HierarchyNode<T> _node;

  while (++i < n) {
    _node = nodes[i];
    _node.x0 = x0;
    _node.x1 = x1;
    _node.y0 = y0;
    _node.y1 = y0 += _node.value! * k;
  }
}
