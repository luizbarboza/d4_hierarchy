part of 'hierarchy.dart';

List<Map<String, Node>> _links<T, Node extends HierarchyNodeBase<T, Node>>(
    Node thisArg) {
  var root = thisArg, links = <Map<String, Node>>[];
  root.each((node, _, __, [___]) {
    if (node != root) {
      // Don’t include the root’s parent, if any.
      links.add({"source": node.parent!, "target": node});
    }
  });
  return links;
}
