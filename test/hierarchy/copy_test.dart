import 'dart:collection';

import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

void main() {
  test("node.copy() copies values", () {
    final root = hierarchyWithDefaults(HashMap.from({
      "id": "root",
      "children": [
        {"id": "a"},
        {
          "id": "b",
          "children": [
            {"id": "ba"}
          ]
        }
      ]
    }))
      ..count();
    expect(root.copy().value, 2);
  });
}
