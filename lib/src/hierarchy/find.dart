part of 'hierarchy.dart';

Node? _find<T, Node extends HierarchyNodeBase<T, Node>>(
  Node thisArg,
  bool Function(
    Node,
    int,
    Node, [
    Object?,
  ]) callback, [
  Object? that,
]) {
  var index = -1;
  for (final node in thisArg) {
    if (callback(node, ++index, thisArg, that)) {
      return node;
    }
  }
  return null;
}
