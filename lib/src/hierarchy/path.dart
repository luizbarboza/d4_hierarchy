part of 'hierarchy.dart';

List<Node> _path<T, Node extends HierarchyNodeBase<T, Node>>(
    Node thisArg, Node end) {
  var start = thisArg,
      ancestor = _leastCommonAncestor(start, end),
      nodes = [start];
  while (start != ancestor) {
    start = start.parent!;
    nodes.add(start);
  }
  var k = nodes.length;
  while (end != ancestor) {
    nodes.insert(k, end);
    end = end.parent!;
  }
  return nodes;
}

Node _leastCommonAncestor<T, Node extends HierarchyNodeBase<T, Node>>(
    Node a, Node b) {
  if (a == b) return a;
  var aNodes = a.ancestors(), bNodes = b.ancestors();
  Node? c;
  a = aNodes.removeLast();
  b = bNodes.removeLast();
  while (a == b) {
    c = a;
    a = aNodes.removeLast();
    b = bNodes.removeLast();
  }
  return c!;
}
