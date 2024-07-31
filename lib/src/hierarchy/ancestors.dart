part of 'hierarchy.dart';

List<Node> _ancestors<T, Node extends HierarchyNodeBase<T, Node>>(
    Node thisArg) {
  Node? node = thisArg;
  List<Node> nodes = [node];
  while ((node = node!.parent) != null) {
    nodes.add(node!);
  }
  return nodes;
}
