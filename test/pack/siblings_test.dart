import 'dart:math';

import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

void main() {
  test("packSiblings(circles) produces a non-overlapping layout of circles",
      () {
    permute([100, 200, 500, 70, 3].map(circleValue).toList(), (p) {
      if (intersectsAny(packSiblings(p).toList())) {
        fail(p.map((c) => c.r).toList().toString());
      }
    });
    permute([3, 30, 50, 400, 600].map(circleValue).toList(), (p) {
      if (intersectsAny(packSiblings(p).toList())) {
        fail(p.map((c) => c.r).toList().toString());
      }
    });
    permute([1, 1, 3, 30, 50, 400, 600].map(circleValue).toList(), (p) {
      if (intersectsAny(packSiblings(p).toList())) {
        fail(p.map((c) => c.r).toList().toString());
      }
    });
    expect(
        intersectsAny(packSiblings([
          0.24155803737254639,
          0.06349736576607135,
          0.4721808601742349,
          0.7469141449305542,
          1.6399276349079663
        ].map(circleRadius))
            .toList()),
        false);
    expect(
        intersectsAny(packSiblings([
          2,
          9071,
          79,
          51,
          325,
          867,
          546,
          19773,
          371,
          16,
          165781,
          10474,
          6928,
          40201,
          31062,
          14213,
          8626,
          12,
          299,
          1075,
          98918,
          4738,
          664,
          2694,
          2619,
          51237,
          21431,
          99,
          5920,
          1117,
          321,
          519162,
          33559,
          234,
          4207
        ].map(circleValue))
            .toList()),
        false);
    expect(
        intersectsAny(packSiblings([
          0.3371386860049076,
          58.65337373332081,
          2.118883785686244,
          1.7024669121097333,
          5.834919697833051,
          8.949453403094978,
          6.792586534702093,
          105.30490014617664,
          6.058936212213754,
          0.9535722042975694,
          313.7636051642043
        ].map(circleRadius))
            .toList()),
        false);
    expect(
        intersectsAny(packSiblings([
          6.26551789195159,
          1.707773433636342,
          9.43220282933871,
          9.298909705475646,
          5.753163715613753,
          8.882383159012575,
          0.5819319661882536,
          2.0234859171687747,
          2.096171518434433,
          9.762727931304937
        ].map(circleRadius))
            .toList()),
        false);
    expect(
        intersectsAny(packSiblings([
          9.153035316963035,
          9.86048622524424,
          8.3974499571329,
          7.8338007571397865,
          8.78260490259886,
          6.165829618300345,
          7.134819943097564,
          7.803701771392344,
          5.056638985134191,
          7.424601077645588,
          8.538658023474753,
          2.4616388562274896,
          0.5444633747829343,
          9.005740508584667
        ].map(circleRadius))
            .toList()),
        false);
    expect(
        intersectsAny(packSiblings([
          2.23606797749979,
          52.07088264296293,
          5.196152422706632,
          20.09975124224178,
          357.11557267679996,
          4.898979485566356,
          14.7648230602334,
          17.334875731491763
        ].map(circleRadius))
            .toList()),
        false);
  });

  test(
      "packSiblings(circles) can successfully pack a circle with a tiny radius",
      () {
    expect(
        intersectsAny(packSiblings([
          0.5672035864083508,
          0.6363498687452267,
          0.5628456216244132,
          1.5619458670239148,
          1.5658933259424268,
          0.9195955097595698,
          0.4747083763630309,
          0.38341282734497434,
          1.3475593361729394,
          0.7492342961633259,
          1.0716990115071823,
          0.31686823341701664,
          2.8766442376551415e-7
        ].map(circleRadius))
            .toList()),
        false);
  });

  test("packSiblings accepts large circles", () {
    expect(
        packSiblings([
          PackCircle.map({"r": 1e+11}),
          PackCircle.map({"r": 1}),
          PackCircle.map({"r": 1})
        ]),
        [
          PackCircle.map({"r": 1e+11, "x": 0, "y": 0}),
          PackCircle.map({"r": 1, "x": 1e+11 + 1, "y": 0}),
          PackCircle.map({"r": 1, "x": 1e+11 + 1, "y": 2})
        ]);
    expect(
        packSiblings([
          PackCircle.map({"r": 1e+16}),
          PackCircle.map({"r": 1}),
          PackCircle.map({"r": 1})
        ]),
        [
          PackCircle.map({"r": 1e+16, "x": 0, "y": 0}),
          PackCircle.map({"r": 1, "x": 1e+16 + 1, "y": 0}),
          PackCircle.map({"r": 1, "x": 1e+16 + 1, "y": 2})
        ]);
  });
}

void swap(List array, int i, int j) {
  final t = array[i];
  array[i] = array[j];
  array[j] = t;
}

void permute<T>(List<T> array, void Function(List<T>) f, [int? n]) {
  n ??= array.length;
  if (n == 1) {
    f(array);
    return;
  }
  for (var i = 0; i < n - 1; ++i) {
    permute(array, f, n - 1);
    swap(array, n.isOdd ? 0 : i, n - 1);
  }
  permute(array, f, n - 1);
}

PackCircle circleValue(num value) {
  return PackCircle.map({"r": sqrt(value)});
}

PackCircle circleRadius(num radius) {
  return PackCircle.map({"r": radius});
}

bool intersectsAny(List<PackCircle> circles) {
  for (var i = 0, n = circles.length; i < n; ++i) {
    for (var j = i + 1, ci = circles[i]; j < n; ++j) {
      if (intersects(ci, circles[j])) {
        return true;
      }
    }
  }
  return false;
}

bool intersects(PackCircle a, PackCircle b) {
  final dr = a.r + b.r - 1e-6, dx = b.x - a.x, dy = b.y - a.y;
  return dr > 0 && dr * dr > dx * dx + dy * dy;
}
