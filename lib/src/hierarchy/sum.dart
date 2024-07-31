part of 'hierarchy.dart';

void _sum<T, Node extends HierarchyNodeBase<T, Node>>(
    Node thisArg, num? Function(T) value) {
  thisArg.eachAfter((node, _, __, [___]) {
    var sum = value(node.data) ?? 0,
        children = node.children,
        i = children != null ? children.length : 0;
    if (sum.isNaN) sum = 0;
    while (--i >= 0) {
      sum += children![i].value ?? 0;
    }
    node.value = sum;
  });
}
