import 'dart:collection';

import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

final tree = HashMap.from({
  "id": "root",
  "children": [
    {
      "id": "a",
      "children": [
        {"id": "ab"}
      ]
    },
    {
      "id": "b",
      "children": [
        {"id": "ba"}
      ]
    }
  ]
});

void main() {
  test("node.each() traverses a hierarchy in breadth-first order", () {
    final root = hierarchyWithDefaults(tree);
    final a = [];
    root.each((d, _, __, [___]) => a.add(d.data["id"]));
    expect(a, ["root", "a", "b", "ab", "ba"]);
  });

  test("node.eachBefore() traverses a hierarchy in pre-order traversal", () {
    final root = hierarchyWithDefaults(tree);
    final a = [];
    root.eachBefore((d, _, __, [___]) => a.add(d.data["id"]));
    expect(a, ["root", "a", "ab", "b", "ba"]);
  });

  test("node.eachAfter() traverses a hierarchy in post-order traversal", () {
    final root = hierarchyWithDefaults(tree);
    final a = [];
    root.eachAfter((d, _, __, [___]) => a.add(d.data["id"]));
    expect(a, ["ab", "a", "ba", "b", "root"]);
  });

  test("a hierarchy is an iterable equivalent to *node*.each()", () {
    final root = hierarchyWithDefaults(tree);
    final a = root.map((d) => d.data["id"]).toList();
    expect(a, ["root", "a", "b", "ab", "ba"]);
  });
}
