part of 'hierarchy.dart';

void _count0<T, Node extends HierarchyNodeBase<T, Node>>(Node node, _, __,
    [___]) {
  num sum = 0;
  var children = node.children;
  int i = children?.length ?? 0;
  if (i == 0) {
    sum = 1;
  } else {
    while (--i >= 0) {
      sum += children?[i].value ?? 0;
    }
  }
  node.value = sum;
}

void _count<T, Node extends HierarchyNodeBase<T, Node>>(Node thisArg) {
  return thisArg.eachAfter(_count0, null);
}
