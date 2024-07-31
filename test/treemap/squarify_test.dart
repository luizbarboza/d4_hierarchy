import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

import 'round.dart';

void main() {
  test("treemapSquarify(parent, x0, y0, x1, y1) generates a squarified layout",
      () {
    const tile = treemapSquarify;
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
      (x0: 3.00, x1: 5.40, y0: 2.33, y1: 3.17),
      (x0: 3.00, x1: 5.40, y0: 3.17, y1: 4.00),
      (x0: 5.40, x1: 6.00, y0: 2.33, y1: 4.00)
    ]);
  });

  test(
      "treemapSquarify(parent, x0, y0, x1, y1) does not produce a stable update",
      () {
    const tile = treemapSquarify;
    final root = HierarchyNode(null)
      ..value = 20
      ..children = [
        HierarchyNode(null)..value = 10,
        HierarchyNode(null)..value = 10
      ];
    tile(root, 0, 0, 20, 10);
    expect(root.children!.map(round),
        [(x0: 0, x1: 10, y0: 0, y1: 10), (x0: 10, x1: 20, y0: 0, y1: 10)]);
    tile(root, 0, 0, 10, 20);
    expect(root.children!.map(round),
        [(x0: 0, x1: 10, y0: 0, y1: 10), (x0: 0, x1: 10, y0: 10, y1: 20)]);
  });

  test("treemapSquarify.ratio(ratio) observes the specified ratio", () {
    final tile = treemapSquarifyRatio(1);
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

  test(
      "treemapSquarify(parent, x0, y0, x1, y1) handles a degenerate tall empty parent",
      () {
    const tile = treemapSquarify;
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

  test(
      "treemapSquarify(parent, x0, y0, x1, y1) handles a degenerate wide empty parent",
      () {
    const tile = treemapSquarify;
    final root = HierarchyNode(null)
      ..value = 0
      ..children = [
        HierarchyNode(null)..value = 0,
        HierarchyNode(null)..value = 0
      ];
    tile(root, 0, 0, 4, 0);
    expect(root.children!.map(round), [
      (x0: 0.00, x1: 4.00, y0: 0.00, y1: 0.00),
      (x0: 0.00, x1: 4.00, y0: 0.00, y1: 0.00)
    ]);
  });

  test("treemapSquarify(parent, x0, y0, x1, y1) handles a leading zero value",
      () {
    const tile = treemapSquarify;
    final root = HierarchyNode(null)
      ..value = 24
      ..children = [
        HierarchyNode(null)..value = 0,
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
      (x0: 0.00, x1: 3.00, y0: 0.00, y1: 0.00),
      (x0: 0.00, x1: 3.00, y0: 0.00, y1: 2.00),
      (x0: 0.00, x1: 3.00, y0: 2.00, y1: 4.00),
      (x0: 3.00, x1: 4.71, y0: 0.00, y1: 2.33),
      (x0: 4.71, x1: 6.00, y0: 0.00, y1: 2.33),
      (x0: 3.00, x1: 5.40, y0: 2.33, y1: 3.17),
      (x0: 3.00, x1: 5.40, y0: 3.17, y1: 4.00),
      (x0: 5.40, x1: 6.00, y0: 2.33, y1: 4.00)
    ]);
  });
}
