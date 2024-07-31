import 'package:d4_hierarchy/d4_hierarchy.dart';

({num x0, num y0, num x1, num y1}) round<T>(HierarchyNode<T> d) {
  return (x0: r(d.x0!), y0: r(d.y0!), x1: r(d.x1!), y1: r(d.y1!));
}

num r(num x) {
  return (x * 100).round() / 100;
}
