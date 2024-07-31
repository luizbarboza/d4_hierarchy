part of 'hierarchy.dart';

void _sort<T, Node extends HierarchyNodeBase<T, Node>>(
    Node thisArg, int Function(Node, Node) compare) {
  return thisArg.eachBefore((node, _, __, [___]) {
    if (node.children != null) {
      node.children!.sort(compare);
    }
  });
}
