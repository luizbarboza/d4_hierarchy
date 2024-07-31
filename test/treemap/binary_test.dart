import 'dart:collection';

import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

import 'round.dart';

void main() {
  test(
      "treemapBinary(parent, x0, y0, x1, y1) generates a binary treemap layout",
      () {
    const tile = treemapBinary;
    final root = HierarchyNode(null)
      ..value = 24
      ..children = [
        HierarchyNode(null)..value = 6,
        HierarchyNode(null)..value = 6,
        HierarchyNode(null)..value = 4,
        HierarchyNode(null)..value = 3,
        HierarchyNode(null)..value = 2,
        HierarchyNode(null)..value = 2,
        HierarchyNode(null)..value = 1
      ];
    tile(root, 0, 0, 6, 4);
    expect(root.children!.map(round), [
      (x0: 0.00, x1: 3.00, y0: 0.00, y1: 2.00),
      (x0: 0.00, x1: 3.00, y0: 2.00, y1: 4.00),
      (x0: 3.00, x1: 4.71, y0: 0.00, y1: 2.33),
      (x0: 4.71, x1: 6.00, y0: 0.00, y1: 2.33),
      (x0: 3.00, x1: 4.20, y0: 2.33, y1: 4.00),
      (x0: 4.20, x1: 5.40, y0: 2.33, y1: 4.00),
      (x0: 5.40, x1: 6.00, y0: 2.33, y1: 4.00)
    ]);
  });

  test("treemapBinary does not break on 0-sized inputs", () {
    final data = HashMap.from({
      "children": [
        {"value": 0},
        {"value": 0},
        {"value": 1}
      ]
    });
    final root = hierarchyWithDefaults(data)..sum((d) => d["value"]);
    final treemapper = Treemap()..tile = treemapBinary;
    treemapper(root);
    final a = root.leaves().map((d) => [d.x0, d.x1, d.y0, d.y1]);
    expect(a, [
      [0, 1, 0, 0],
      [1, 1, 0, 0],
      [0, 1, 0, 1]
    ]);
  });
}
