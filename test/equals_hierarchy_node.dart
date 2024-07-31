import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

class EqualsHierarchyNode<T> extends CustomMatcher {
  EqualsHierarchyNode(Map<String, dynamic> node)
      : super(
          """Hierarchy node which when represented as {id: node.id, depth: 
          node.depth, height: node.height, children: node.children} is equal 
          to""",
          "a representation",
          node,
        );

  @override
  Object? featureValueOf(actual) {
    return {
      if ((actual as HierarchyNode).id != null) "id": (actual).id,
      "depth": actual.depth,
      "height": actual.height,
      "data": actual.data,
      if (actual.children != null)
        "children":
            actual.children!.map((node) => featureValueOf(node)).toList(),
    };
  }
}
