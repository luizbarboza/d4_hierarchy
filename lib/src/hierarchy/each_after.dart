part of 'hierarchy.dart';

void _eachAfter<T, Node extends HierarchyNodeBase<T, Node>>(
  Node thisArg,
  void Function(
    Node,
    int,
    Node, [
    Object?,
  ]) callback, [
  Object? that,
]) {
  Node? node = thisArg;
  List<Node> nodes = [node], next = [];
  List<Node>? children;
  int i, n, index = -1;
  while (nodes.isNotEmpty) {
    node = nodes.removeLast();
    next.add(node);
    if ((children = node.children) != null) {
      i = 0;
      n = children!.length;
      for (; i < n; ++i) {
        nodes.add(children[i]);
      }
    }
  }
  while (next.isNotEmpty) {
    node = next.removeLast();
    callback(node, ++index, thisArg, that);
  }
}
