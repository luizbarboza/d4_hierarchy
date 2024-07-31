// ignore_for_file: prefer_void_to_null

import 'dart:collection';
import 'dart:math';

import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

import 'round.dart';

void main() {
  test("treemapResquarify(parent, x0, y0, x1, y1) produces a stable update",
      () {
    final tile = treemapResquarify<Null>;
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
        [(x0: 0, x1: 5, y0: 0, y1: 20), (x0: 5, x1: 10, y0: 0, y1: 20)]);
  });

  test("treemapResquarify.ratio(ratio) observes the specified ratio", () {
    final tile = treemapResquarifyRatio<Null>(1);
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

  test("treemapResquarify.ratio(ratio) is stable if the ratio is unchanged",
      () {
    final root = HierarchyNode(null)
      ..value = 20
      ..children = [
        HierarchyNode(null)..value = 10,
        HierarchyNode(null)..value = 10
      ];
    treemapResquarify(root, 0, 0, 20, 10);
    expect(root.children!.map(round),
        [(x0: 0, x1: 10, y0: 0, y1: 10), (x0: 10, x1: 20, y0: 0, y1: 10)]);
    treemapResquarifyRatio((1 + sqrt(5)) / 2)(root, 0, 0, 10, 20);
    expect(root.children!.map(round),
        [(x0: 0, x1: 5, y0: 0, y1: 20), (x0: 5, x1: 10, y0: 0, y1: 20)]);
  });

  test("treemapResquarify.ratio(ratio) is unstable if the ratio is changed",
      () {
    final root = HierarchyNode(null)
      ..value = 20
      ..children = [
        HierarchyNode(null)..value = 10,
        HierarchyNode(null)..value = 10
      ];
    treemapResquarify(root, 0, 0, 20, 10);
    expect(root.children!.map(round),
        [(x0: 0, x1: 10, y0: 0, y1: 10), (x0: 10, x1: 20, y0: 0, y1: 10)]);
    treemapResquarifyRatio<Null>(1)(root, 0, 0, 10, 20);
    expect(root.children!.map(round),
        [(x0: 0, x1: 10, y0: 0, y1: 10), (x0: 0, x1: 10, y0: 10, y1: 20)]);
  });

  test("treemapResquarify does not break on 0-sized inputs", () {
    //final root = HierarchyNode(null)..children = [HierarchyNode(null)..children = [HierarchyNode(null)..value = 0], HierarchyNode(null)..value = 1];
    final root = hierarchyWithDefaults(HashMap.from({
      "children": [
        {
          "children": [
            {"value": 0}
          ]
        },
        {"value": 1}
      ]
    }));
    final treemapper = Treemap()..tile = treemapResquarify;
    treemapper(root..sum((d) => d!["value"]));
    treemapper(root..sum((d) => d!["sum"]));
    final a = root.leaves().map((d) => [d.x0, d.x1, d.y0, d.y1]);
    expect(a, [
      [0, 1, 0, 0],
      [0, 1, 0, 0]
    ]);
  });
}
