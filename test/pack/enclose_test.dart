import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

void main() {
  // https://github.com/d3/d3-hierarchy/issues/188
  test("packEnclose(circles) handles a tricky case", () {
    expect(
        packEnclose([
          PackCircle.map({"x": 14.5, "y": 48.5, "r": 7.585}),
          PackCircle.map({"x": 9.5, "y": 79.5, "r": 2.585}),
          PackCircle.map({"x": 15.5, "y": 73.5, "r": 8.585})
        ]),
        PackCircle.map({
          "r": 20.790781637717107,
          "x": 12.80193548387092,
          "y": 61.59615384615385
        }));
  });
}
