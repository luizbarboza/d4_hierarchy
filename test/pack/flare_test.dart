import 'dart:convert';
import 'dart:io';

import 'package:d4_dsv/d4_dsv.dart';
import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

void main() {
  test("pack(flare) produces the expected result",
      _test("test/data/flare.csv", "test/data/flare_pack.json"));
}

_test(String inputFile, String expectedFile) {
  return () {
    final inputText = File(inputFile).readAsStringSync();
    final expectedText = File(expectedFile).readAsStringSync();

    final stratifier = Stratify.withDefaults()
      ..parentId = (d, _, __) {
        final i = d["id"]!.lastIndexOf(".");
        return i >= 0 ? d["id"]!.substring(0, i) : null;
      };

    final packer = Pack()..size = [960, 960];

    final data = csvParse(inputText);
    var expected = jsonDecode(expectedText);

    var actual = packer(stratifier(data.$1)
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
        ..x = round(node.x!)
        ..y = round(node.y!)
        ..r = round(node.r!)
        ..children = node.children?.map(visit).toList();
    }

    actual = visit(actual);

    HierarchyNode<String> visit0(node) {
      return HierarchyNode(node["name"] as String)
        ..x = round(node["x"])
        ..y = round(node["y"])
        ..r = round(node["r"])
        ..children = (node["children"] as List?)?.map(visit0).toList();
    }

    expected = visit0(expected);

    expect(actual, expected);
  };
}

num round(num x) {
  return (x * 100).round() / 100;
}
