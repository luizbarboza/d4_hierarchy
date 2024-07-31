import 'dart:math';

import '../array.dart';
import '../lcg.dart';
import 'pack.dart';

/// Computes the
/// [smallest circle](https://en.wikipedia.org/wiki/Smallest-circle_problem)
/// that encloses the specified iterable of [circles], each of which must have a
/// *circle*.r property specifying the circle’s radius, and *circle*.x and
/// *circle*.y properties specifying the circle’s center.
///
/// The enclosing circle is computed using the
/// [Matoušek-Sharir-Welzl algorithm](http://www.inf.ethz.ch/personal/emo/PublFiles/SubexLinProg_ALG16_96.pdf).
/// (See also [Apollonius’ Problem](https://observablehq.com/@d3/apollonius-problem).)
///
/// {@category Pack}
PackCircle packEnclose<T>(Iterable<PackCircle> circles) {
  return packEncloseRandom(circles, lcg());
}

PackCircle packEncloseRandom(
    Iterable<PackCircle> circles, num Function() random) {
  var i = 0,
      n = (circles = shuffle(circles.toList(), random)).length,
      B = <PackCircle>[];
  PackCircle p;
  PackCircle? e;

  while (i < n) {
    p = (circles as List)[i];
    if (e != null && _enclosesWeak(e, p)) {
      ++i;
    } else {
      e = _encloseBasis(B = _extendBasis(B, p));
      i = 0;
    }
  }

  return e!;
}

List<PackCircle> _extendBasis<T>(List<PackCircle> B, PackCircle p) {
  int i, j;

  if (_enclosesWeakAll(p, B)) return [p];

  // If we get here then B must have at least one element.
  for (i = 0; i < B.length; ++i) {
    if (_enclosesNot(p, B[i]) && _enclosesWeakAll(_encloseBasis2(B[i], p), B)) {
      return [B[i], p];
    }
  }

  // If we get here then B must have at least two elements.
  for (i = 0; i < B.length - 1; ++i) {
    for (j = i + 1; j < B.length; ++j) {
      if (_enclosesNot(_encloseBasis2(B[i], B[j]), p) &&
          _enclosesNot(_encloseBasis2(B[i], p), B[j]) &&
          _enclosesNot(_encloseBasis2(B[j], p), B[i]) &&
          _enclosesWeakAll(_encloseBasis3(B[i], B[j], p), B)) {
        return [B[i], B[j], p];
      }
    }
  }

  // If we get here then something is very wrong.
  throw Error();
}

bool _enclosesNot(PackCircle a, PackCircle b) {
  var dr = a.r - b.r, dx = b.x - a.x, dy = b.y - a.y;
  return dr < 0 || dr * dr < dx * dx + dy * dy;
}

bool _enclosesWeak(PackCircle a, PackCircle b) {
  var dr = a.r - b.r + max(a.r, max(b.r, 1)) * 1e-9,
      dx = b.x - a.x,
      dy = b.y - a.y;
  return dr > 0 && dr * dr > dx * dx + dy * dy;
}

bool _enclosesWeakAll(PackCircle a, List<PackCircle> B) {
  for (var i = 0; i < B.length; ++i) {
    if (!_enclosesWeak(a, B[i])) {
      return false;
    }
  }
  return true;
}

PackCircle? _encloseBasis<T>(List<PackCircle> B) {
  switch (B.length) {
    case 1:
      return _encloseBasis1(B[0]);
    case 2:
      return _encloseBasis2(B[0], B[1]);
    case 3:
      return _encloseBasis3(B[0], B[1], B[2]);
    default:
      return null;
  }
}

PackCircle _encloseBasis1<T>(PackCircle a) {
  return PackCircle.map({"x": a.x, "y": a.y, "r": a.r});
}

PackCircle _encloseBasis2<T>(PackCircle a, PackCircle b) {
  var x1 = a.x,
      y1 = a.y,
      r1 = a.r,
      x2 = b.x,
      y2 = b.y,
      r2 = b.r,
      x21 = x2 - x1,
      y21 = y2 - y1,
      r21 = r2 - r1,
      l = sqrt(x21 * x21 + y21 * y21);
  return PackCircle.map({
    "x": (x1 + x2 + x21 / l * r21) / 2,
    "y": (y1 + y2 + y21 / l * r21) / 2,
    "r": (l + r1 + r2) / 2
  });
}

PackCircle _encloseBasis3<T>(PackCircle a, PackCircle b, PackCircle c) {
  var x1 = a.x,
      y1 = a.y,
      r1 = a.r,
      x2 = b.x,
      y2 = b.y,
      r2 = b.r,
      x3 = c.x,
      y3 = c.y,
      r3 = c.r,
      a2 = x1 - x2,
      a3 = x1 - x3,
      b2 = y1 - y2,
      b3 = y1 - y3,
      c2 = r2 - r1,
      c3 = r3 - r1,
      d1 = x1 * x1 + y1 * y1 - r1 * r1,
      d2 = d1 - x2 * x2 - y2 * y2 + r2 * r2,
      d3 = d1 - x3 * x3 - y3 * y3 + r3 * r3,
      ab = a3 * b2 - a2 * b3,
      xa = (b2 * d3 - b3 * d2) / (ab * 2) - x1,
      xb = (b3 * c2 - b2 * c3) / ab,
      ya = (a3 * d2 - a2 * d3) / (ab * 2) - y1,
      yb = (a2 * c3 - a3 * c2) / ab,
      A = xb * xb + yb * yb - 1,
      B = 2 * (r1 + xa * xb + ya * yb),
      C = xa * xa + ya * ya - r1 * r1,
      r = -(A.abs() > 1e-6 ? (B + sqrt(B * B - 4 * A * C)) / (2 * A) : C / B);
  return PackCircle.map({"x": x1 + xa + xb * r, "y": y1 + ya + yb * r, "r": r});
}
