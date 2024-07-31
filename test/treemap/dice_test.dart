import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

import 'round.dart';

void main() {
  test("treemapDice(parent, x0, y0, x1, y1) generates a diced layout", () {
    const tile = treemapDice;
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
    tile(root, 0, 0, 4, 6);
    expect(root.children!.map(round), [
      (x0: 0.00, x1: 1.00, y0: 0.00, y1: 6.00),
      (x0: 1.00, x1: 2.00, y0: 0.00, y1: 6.00),
      (x0: 2.00, x1: 2.67, y0: 0.00, y1: 6.00),
      (x0: 2.67, x1: 3.17, y0: 0.00, y1: 6.00),
      (x0: 3.17, x1: 3.50, y0: 0.00, y1: 6.00),
      (x0: 3.50, x1: 3.83, y0: 0.00, y1: 6.00),
      (x0: 3.83, x1: 4.00, y0: 0.00, y1: 6.00)
    ]);
  });

  test("treemapDice(parent, x0, y0, x1, y1) handles a degenerate empty parent",
      () {
    const tile = treemapDice;
    final root = HierarchyNode(null)
      ..value = 0
      ..children = [
        HierarchyNode(null)..value = 0,
        HierarchyNode(null)..value = 0
      ];
    tile(root, 0, 0, 0, 4);
    expect(root.children!.map(round), [
      (x0: 0.00, x1: 0.00, y0: 0.00, y1: 4.00),
      (x0: 0.00, x1: 0.00, y0: 0.00, y1: 4.00)
    ]);
  });
}
