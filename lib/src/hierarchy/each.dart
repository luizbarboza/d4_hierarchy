part of 'hierarchy.dart';

void _each<T, Node extends HierarchyNodeBase<T, Node>>(
  Node thisArg,
  void Function(
    Node,
    int,
    Node, [
    Object?,
  ]) callback, [
  Object? that,
]) {
  var index = -1;
  for (final node in thisArg) {
    callback(node, ++index, thisArg, that);
  }
}
