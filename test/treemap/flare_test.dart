import 'dart:convert';
import 'dart:io';

import 'package:d4_dsv/d4_dsv.dart';
import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

void main() {
  test(
      "treemap(flare) produces the expected result with a squarified ratio of φ",
      _test(
          "test/data/flare.csv", "test/data/flare_phi.json", treemapSquarify));

  test(
      "treemap(flare) produces the expected result with a squarified ratio of 1",
      _test("test/data/flare.csv", "test/data/flare_one.json",
          treemapSquarifyRatio(1)));
}

_test(String inputFile, String expectedFile,
    void Function(HierarchyNode, num, num, num, num) tile) {
  return () {
    final inputText = File(inputFile).readAsStringSync();
    final expectedText = File(expectedFile).readAsStringSync();

    final stratifier = Stratify.withDefaults()
      ..parentId = (d, _, __) {
        final i = d["id"]!.lastIndexOf(".");
        return i >= 0 ? d["id"]!.substring(0, i) : null;
      };

    final treemaper = Treemap()
      ..tile = tile
      ..size = [960, 500];

    final data = csvParse(inputText);
    var expected = jsonDecode(expectedText);

    var actual = treemaper(stratifier(data.$1)
      ..sum((d) => d!["value"] != null ? num.tryParse(d["value"]!) : null)
      ..sort((a, b) {
        final diff = b.value! - a.value!;
        return diff != 0
            ? (diff > 0 ? 1 : -1)
            : a.data!["id"]!.compareTo(b.data!["id"]!);
      }));

    HierarchyNode<String> visit(HierarchyNode node) {
      return HierarchyNode((node.data["id"] as String)
          .substring((node.data["id"] as String).lastIndexOf(".") + 1))
        ..x0 = round(node.x0!)
        ..y0 = round(node.y0!)
        ..x1 = round(node.x1!)
        ..y1 = round(node.y1!)
        ..children = node.children?.map(visit).toList();
    }

    actual = visit(actual);

    HierarchyNode<String> visit0(node) {
      return HierarchyNode(node["name"] as String)
        ..x0 = round(node["x"])
        ..y0 = round(node["y"])
        ..x1 = round(node["x"] + node["dx"])
        ..y1 = round(node["y"] + node["dy"])
        ..children = (node["children"] as List?)
            ?.map(visit0)
            .toList()
            .reversed // D3 3.x bug
            .toList();
    }

    expected = visit0(expected);

    expect(actual, expected);
  };
}

num round(num x) {
  return (x * 100).round() / 100;
}
