import 'dart:collection';

import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

void main() {
  test("node.find() finds nodes", () {
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
    expect(
        root.find((d, _, __, [___]) => d.data["id"] == "b")!.data["id"], "b");
    expect(root.find((d, i, __, [___]) => i == 0)!.data["id"], "root");
    expect(root.find((d, i, e, [___]) => d != e)!.data["id"], "a");
  });
}
