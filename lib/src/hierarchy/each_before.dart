part of 'hierarchy.dart';

void _eachBefore<T, Node extends HierarchyNodeBase<T, Node>>(
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
  List<Node> nodes = [node];
  List<Node>? children;
  int i, index = -1;
  while (nodes.isNotEmpty) {
    node = nodes.removeLast();
    callback(node, ++index, thisArg, that);
    if ((children = node.children) != null) {
      for (i = children!.length - 1; i >= 0; --i) {
        nodes.add(children[i]);
      }
    }
  }
}
