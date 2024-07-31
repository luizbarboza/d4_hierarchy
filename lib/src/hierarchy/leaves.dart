part of 'hierarchy.dart';

List<Node> _leaves<T, Node extends HierarchyNodeBase<T, Node>>(Node thisArg) {
  var leaves = <Node>[];
  thisArg.eachBefore((node, _, __, [___]) {
    if (node.children == null) {
      leaves.add(node);
    }
  });
  return leaves;
}
