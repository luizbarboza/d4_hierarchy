part of 'hierarchy.dart';

List<Node> _descendants<T, Node extends HierarchyNodeBase<T, Node>>(
    Node thisArg) {
  return thisArg.toList();
}
