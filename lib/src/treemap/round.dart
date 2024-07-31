import '../hierarchy/hierarchy.dart';

void roundNode<T>(
  HierarchyNode<T> node,
  int _,
  HierarchyNode<T> __, [
  Object? ___,
]) {
  node.x0 = node.x0!.round();
  node.y0 = node.y0!.round();
  node.x1 = node.x1!.round();
  node.y1 = node.y1!.round();
}
