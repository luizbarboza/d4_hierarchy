import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

void main() {
  test("pack is deterministic", () {
    int i = -1;
    final data = (Stratify()
      ..path = (d, __, ___) => d)([41, 41, 11, 11, 4, 4].expand((n) {
      i++;
      return List.generate(n, (j) => (i: i, j: j));
    }).map((e) => "/${e.i}/${e.i}-${e.j}"));
    final packer = Pack()
      ..size = [100, 100]
      ..constPadding(0);
    final pack1 = packer(hierarchyWithDefaults(data)..count());
    for (var i = 0; i < 40; ++i) {
      expect(packer(hierarchyWithDefaults(data)..count()), pack1);
    }
  });
}
