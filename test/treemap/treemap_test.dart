import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

import 'round.dart';

final simple =
    HashMap.from(jsonDecode(File("test/data/simple2.json").readAsStringSync()));

void main() {
  test("treemap() has the expected defaults", () {
    final t = Treemap<dynamic>();
    expect(t.tile, treemapSquarify<dynamic>);
    expect(t.size, [1, 1]);
    expect(t.round, false);
  });

  test("treemap.round(round) observes the specified rounding", () {
    final t = Treemap()
      ..size = [600, 400]
      ..round = true;
    final root = hierarchyWithDefaults(simple)
      ..sum(defaultValue)
      ..sort(descendingValue);
    t(root);
    final nodes = root.descendants().map(round);
    expect(t.round, true);
    expect(nodes, [
      (x0: 0, x1: 600, y0: 0, y1: 400),
      (x0: 0, x1: 300, y0: 0, y1: 200),
      (x0: 0, x1: 300, y0: 200, y1: 400),
      (x0: 300, x1: 471, y0: 0, y1: 233),
      (x0: 471, x1: 600, y0: 0, y1: 233),
      (x0: 300, x1: 540, y0: 233, y1: 317),
      (x0: 300, x1: 540, y0: 317, y1: 400),
      (x0: 540, x1: 600, y0: 233, y1: 400)
    ]);
  });

  test(
      "treemap.padding(padding) sets the inner and outer padding to the specified value",
      () {
    final t = Treemap()..constPadding(42);
    expect(t.padding(HierarchyNode(null)), 42);
    expect(t.paddingInner(HierarchyNode(null)), 42);
    expect(t.paddingOuter(HierarchyNode(null)), 42);
    expect(t.paddingTop(HierarchyNode(null)), 42);
    expect(t.paddingRight(HierarchyNode(null)), 42);
    expect(t.paddingBottom(HierarchyNode(null)), 42);
    expect(t.paddingLeft(HierarchyNode(null)), 42);
  });

  test("treemap.paddingInner(padding) observes the specified padding", () {
    final t = Treemap()
      ..size = [6, 4]
      ..constPaddingInner(0.5);
    final root = hierarchyWithDefaults(simple)
      ..sum(defaultValue)
      ..sort(descendingValue);
    t(root);
    final nodes = root.descendants().map(round);
    expect(t.paddingInner(HierarchyNode(null)), 0.5);
    expect(t.size, [6, 4]);
    expect(nodes, [
      (x0: 0.00, x1: 6.00, y0: 0.00, y1: 4.00),
      (x0: 0.00, x1: 2.75, y0: 0.00, y1: 1.75),
      (x0: 0.00, x1: 2.75, y0: 2.25, y1: 4.00),
      (x0: 3.25, x1: 4.61, y0: 0.00, y1: 2.13),
      (x0: 5.11, x1: 6.00, y0: 0.00, y1: 2.13),
      (x0: 3.25, x1: 5.35, y0: 2.63, y1: 3.06),
      (x0: 3.25, x1: 5.35, y0: 3.56, y1: 4.00),
      (x0: 5.85, x1: 6.00, y0: 2.63, y1: 4.00)
    ]);
  });

  test("treemap.paddingOuter(padding) observes the specified padding", () {
    final t = Treemap()
      ..size = [6, 4]
      ..constPaddingOuter(0.5);
    final root = hierarchyWithDefaults(simple)
      ..sum(defaultValue)
      ..sort(descendingValue);
    t(root);
    final nodes = root.descendants().map(round);
    expect(t.paddingOuter(HierarchyNode(null)), 0.5);
    expect(t.paddingTop(HierarchyNode(null)), 0.5);
    expect(t.paddingRight(HierarchyNode(null)), 0.5);
    expect(t.paddingBottom(HierarchyNode(null)), 0.5);
    expect(t.paddingLeft(HierarchyNode(null)), 0.5);
    expect(t.size, [6, 4]);
    expect(nodes, [
      (x0: 0.00, x1: 6.00, y0: 0.00, y1: 4.00),
      (x0: 0.50, x1: 3.00, y0: 0.50, y1: 2.00),
      (x0: 0.50, x1: 3.00, y0: 2.00, y1: 3.50),
      (x0: 3.00, x1: 4.43, y0: 0.50, y1: 2.25),
      (x0: 4.43, x1: 5.50, y0: 0.50, y1: 2.25),
      (x0: 3.00, x1: 5.00, y0: 2.25, y1: 2.88),
      (x0: 3.00, x1: 5.00, y0: 2.88, y1: 3.50),
      (x0: 5.00, x1: 5.50, y0: 2.25, y1: 3.50)
    ]);
  });

  test("treemap.size(size) observes the specified size", () {
    final t = Treemap()..size = [6, 4];
    final root = hierarchyWithDefaults(simple)
      ..sum(defaultValue)
      ..sort(descendingValue);
    t(root);
    final nodes = root.descendants().map(round);
    expect(t.size, [6, 4]);
    expect(nodes, [
      (x0: 0.00, x1: 6.00, y0: 0.00, y1: 4.00),
      (x0: 0.00, x1: 3.00, y0: 0.00, y1: 2.00),
      (x0: 0.00, x1: 3.00, y0: 2.00, y1: 4.00),
      (x0: 3.00, x1: 4.71, y0: 0.00, y1: 2.33),
      (x0: 4.71, x1: 6.00, y0: 0.00, y1: 2.33),
      (x0: 3.00, x1: 5.40, y0: 2.33, y1: 3.17),
      (x0: 3.00, x1: 5.40, y0: 3.17, y1: 4.00),
      (x0: 5.40, x1: 6.00, y0: 2.33, y1: 4.00)
    ]);
  });

  test("treemap.size(size) makes defensive copies", () {
    final size = [6, 4];
    final t = Treemap()..size = size;
    size[1] = 100;
    final root = hierarchyWithDefaults(simple)
      ..sum(defaultValue)
      ..sort(descendingValue);
    t(root);
    final nodes = root.descendants().map(round);
    expect(t.size, [6, 4]);
    t.size[1] = 100;
    expect(t.size, [6, 4]);
    expect(nodes, [
      (x0: 0.00, x1: 6.00, y0: 0.00, y1: 4.00),
      (x0: 0.00, x1: 3.00, y0: 0.00, y1: 2.00),
      (x0: 0.00, x1: 3.00, y0: 2.00, y1: 4.00),
      (x0: 3.00, x1: 4.71, y0: 0.00, y1: 2.33),
      (x0: 4.71, x1: 6.00, y0: 0.00, y1: 2.33),
      (x0: 3.00, x1: 5.40, y0: 2.33, y1: 3.17),
      (x0: 3.00, x1: 5.40, y0: 3.17, y1: 4.00),
      (x0: 5.40, x1: 6.00, y0: 2.33, y1: 4.00)
    ]);
  });

  test("treemap.tile(tile) observes the specified tile function", () {
    final t = Treemap<dynamic>()
      ..size = [6, 4]
      ..tile = treemapSlice;
    final root = hierarchyWithDefaults(simple)
      ..sum(defaultValue)
      ..sort(descendingValue);
    t(root);
    final nodes = root.descendants().map(round);
    expect(t.tile, treemapSlice<dynamic>);
    expect(nodes, [
      (x0: 0.00, x1: 6.00, y0: 0.00, y1: 4.00),
      (x0: 0.00, x1: 6.00, y0: 0.00, y1: 1.00),
      (x0: 0.00, x1: 6.00, y0: 1.00, y1: 2.00),
      (x0: 0.00, x1: 6.00, y0: 2.00, y1: 2.67),
      (x0: 0.00, x1: 6.00, y0: 2.67, y1: 3.17),
      (x0: 0.00, x1: 6.00, y0: 3.17, y1: 3.50),
      (x0: 0.00, x1: 6.00, y0: 3.50, y1: 3.83),
      (x0: 0.00, x1: 6.00, y0: 3.83, y1: 4.00)
    ]);
  });

  test("treemap(data) observes the specified values", () {
    foo(d) => d["foo"] as num?;
    final t = Treemap()..size = [6, 4];
    final root = hierarchyWithDefaults(HashMap.from(
        jsonDecode(File("test/data/simple3.json").readAsStringSync())))
      ..sum(foo)
      ..sort(descendingValue);
    t(root);
    final nodes = root.descendants().map(round);
    expect(t.size, [6, 4]);
    expect(nodes, [
      (x0: 0.00, x1: 6.00, y0: 0.00, y1: 4.00),
      (x0: 0.00, x1: 3.00, y0: 0.00, y1: 2.00),
      (x0: 0.00, x1: 3.00, y0: 2.00, y1: 4.00),
      (x0: 3.00, x1: 4.71, y0: 0.00, y1: 2.33),
      (x0: 4.71, x1: 6.00, y0: 0.00, y1: 2.33),
      (x0: 3.00, x1: 5.40, y0: 2.33, y1: 3.17),
      (x0: 3.00, x1: 5.40, y0: 3.17, y1: 4.00),
      (x0: 5.40, x1: 6.00, y0: 2.33, y1: 4.00)
    ]);
  });

  test("treemap(data) observes the specified sibling order", () {
    final t = Treemap();
    final root = hierarchyWithDefaults(simple)
      ..sum(defaultValue)
      ..sort(ascendingValue);
    t(root);
    expect(root.descendants().map((d) => d.value), [24, 1, 2, 2, 3, 4, 6, 6]);
  });
}

num? defaultValue(d) {
  return d is Map ? d["value"] : null;
}

int ascendingValue(HierarchyNode a, HierarchyNode b) {
  return (a.value! - b.value!).sign.toInt();
}

int descendingValue(HierarchyNode a, HierarchyNode b) {
  return (b.value! - a.value!).sign as int;
}
