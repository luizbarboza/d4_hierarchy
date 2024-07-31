import 'dart:math';

import '../lcg.dart';
import 'enclose.dart';
import 'pack.dart';

void _place<T>(PackCircle b, PackCircle a, PackCircle c) {
  num dx = b.x - a.x, x, a2, dy = b.y - a.y, y, b2, d2 = dx * dx + dy * dy;
  if (d2 != 0) {
    a2 = a.r + c.r;
    a2 *= a2;
    b2 = b.r + c.r;
    b2 *= b2;
    if (a2 > b2) {
      x = (d2 + b2 - a2) / (2 * d2);
      y = sqrt(max(0, b2 / d2 - x * x));
      c.x = b.x - x * dx - y * dy;
      c.y = b.y - x * dy + y * dx;
    } else {
      x = (d2 + a2 - b2) / (2 * d2);
      y = sqrt(max(0, a2 / d2 - x * x));
      c.x = a.x + x * dx - y * dy;
      c.y = a.y + x * dy + y * dx;
    }
  } else {
    c.x = a.x + c.r;
    c.y = a.y;
  }
}

bool _intersects<T>(PackCircle a, PackCircle b) {
  var dr = a.r + b.r - 1e-6, dx = b.x - a.x, dy = b.y - a.y;
  return dr > 0 && dr * dr > dx * dx + dy * dy;
}

num _score<T>(_Node node) {
  var a = node._,
      b = node.next!._,
      ab = a.r + b.r,
      dx = (a.x * b.r + b.x * a.r) / ab,
      dy = (a.y * b.r + b.y * a.r) / ab;
  return dx * dx + dy * dy;
}

class _Node {
  final PackCircle _;
  _Node? next, previous;

  _Node(PackCircle circle) : _ = circle;
}

num packSiblingsRandom(Iterable<PackCircle> circles, num Function() random) {
  int n;
  List<PackCircle> circles0;
  if ((n = (circles0 = circles.toList()).length) == 0) return 0;

  PackCircle a, b, c;
  num aa, ca;
  int i;
  _Node? j, k;
  num sj, sk;

  // Place the first circle.
  a = circles0[0];
  a.x = 0;
  a.y = 0;
  if (!(n > 1)) return a.r;

  // Place the second circle.
  b = circles0[1];
  a.x = -b.r;
  b.x = a.r;
  b.y = 0;
  if (!(n > 2)) return a.r + b.r;

  // Place the third circle.
  _place(b, a, c = circles0[2]);

  // Initialize the front-chain using the first three circles a, b and c.
  var a0 = _Node(a), b0 = _Node(b), c0 = _Node(c);
  a0.next = c0.previous = b0;
  b0.next = a0.previous = c0;
  c0.next = b0.previous = a0;

  // Attempt to place each remaining circle…
  pack:
  for (i = 3; i < n; ++i) {
    _place(a0._, b0._, c = circles0[i]);
    c0 = _Node(c);

    // Find the closest intersecting circle on the front-chain, if any.
    // “Closeness” is determined by linear distance along the front-chain.
    // “Ahead” or “behind” is likewise determined by linear distance.
    j = b0.next;
    k = a0.previous;
    sj = b0._.r;
    sk = a0._.r;
    do {
      if (sj <= sk) {
        if (_intersects(j!._, c0._)) {
          b0 = j;
          a0.next = b0;
          b0.previous = a0;
          --i;
          continue pack;
        }
        sj += j._.r;
        j = j.next;
      } else {
        if (_intersects(k!._, c0._)) {
          a0 = k;
          a0.next = b0;
          b0.previous = a0;
          --i;
          continue pack;
        }
        sk += k._.r;
        k = k.previous;
      }
    } while (j != k!.next);

    // Success! Insert the new circle c between a and b.
    c0.previous = a0;
    c0.next = b0;
    a0.next = b0.previous = b0 = c0;

    // Compute the new closest circle pair to the centroid.
    aa = _score(a0);
    while ((c0 = c0.next!) != b0) {
      if ((ca = _score(c0)) < aa) {
        a0 = c0;
        aa = ca;
      }
    }
    b0 = a0.next!;
  }

  // Compute the enclosing circle of the front chain.
  List<PackCircle> a1;
  a1 = [b0._];
  c0 = b0;
  while ((c0 = c0.next!) != b0) {
    a1.add(c0._);
  }
  PackCircle c5 = packEncloseRandom(a1, random);

  // Translate the circles to put the enclosing circle around the origin.
  for (i = 0; i < n; ++i) {
    a = circles0[i];
    a.x = a.x - c5.x;
    a.y = a.y - c5.y;
  }

  return c5.r;
}

/// Packs the specified iterable of [circles], each of which must have a
/// *circle*.r property specifying the circle’s radius.
///
/// Assigns the following properties to each circle:
///
/// * *circle*.x - the *x*-coordinate of the circle’s center
/// * *circle*.y - the y coordinate of the circle’s center
///
/// The circles are positioned according to the front-chain packing algorithm by
/// [Wang *et al.*](https://dl.acm.org/citation.cfm?id=1124851)
///
/// {@category Pack}
Iterable<PackCircle> packSiblings(Iterable<PackCircle> circles) {
  packSiblingsRandom(circles = circles.toList(), lcg());
  return circles;
}
