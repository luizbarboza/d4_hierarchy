import 'dart:collection';

import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

void main() {
  test("d3.hierarchy(data, children) supports iterable children", () {
    final root = hierarchyWithDefaults(HashMap.from({
      "id": "root",
      "children": {
        {"id": "a"},
        {
          "id": "b",
          "children": {
            {"id": "ba"}
          }
        }
      }
    }));
    final a = root.children![0];
    final b = root.children![1];
    final ba = root.children![1].children![0];
    expect(root.links(), [
      {"source": root, "target": a},
      {"source": root, "target": b},
      {"source": b, "target": ba}
    ]);
  });

  /*test("d3.hierarchy(data, children) ignores non-iterable children", () {
    final root = hierarchyWithDefaults(HashMap.from({
      "id": "root",
      "children": [
        {"id": "a", "children": null},
        {"id": "b", "children": 42}
      ]
    }));
    final a = root.children![0];
    final b = root.children![1];
    expect(root.links(), [
      {"source": root, "target": a},
      {"source": root, "target": b}
    ]);
  });*/
}
