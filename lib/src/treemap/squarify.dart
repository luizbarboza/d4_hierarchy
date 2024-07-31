import 'dart:math';

import '../hierarchy/hierarchy.dart';
import 'dice.dart';
import 'slice.dart';

final phi = (1 + sqrt(5)) / 2;

List<SquarifyRow<T>> squarifyRatio<T>(
    num ratio, HierarchyNode<T> parent, num x0, num y0, num x1, num y1) {
  var rows = <SquarifyRow<T>>[],
      nodes = parent.children!,
      i0 = 0,
      i1 = 0,
      n = nodes.length,
      value = parent.value!;
  SquarifyRow<T> row;
  num nodeValue, dx, dy, minValue, maxValue, newRatio, minRatio, alpha, beta;
  num? sumValue;
  HierarchyNode<T> parent0;

  while (i0 < n) {
    dx = x1 - x0;
    dy = y1 - y0;

    // Find the next non-empty node.
    do {
      sumValue = nodes[i1++].value;
    } while (sumValue == 0 && i1 < n);
    minValue = maxValue = sumValue!;
    alpha = max(dy / dx, dx / dy) / (value * ratio);
    beta = sumValue * sumValue * alpha;
    minRatio = max(maxValue / beta, beta / minValue);

    // Keep adding nodes while the aspect ratio maintains or improves.
    for (; i1 < n; ++i1) {
      sumValue = sumValue! + (nodeValue = nodes[i1].value!);
      if (nodeValue < minValue) minValue = nodeValue;
      if (nodeValue > maxValue) maxValue = nodeValue;
      beta = sumValue * sumValue * alpha;
      newRatio = max(maxValue / beta, beta / minValue);
      if (newRatio > minRatio) {
        sumValue -= nodeValue;
        break;
      }
      minRatio = newRatio;
    }

    // Position and record the row orientation.
    rows.add(row =
        (value: sumValue!, dice: dx < dy, children: nodes.sublist(i0, i1)));
    parent0 = HierarchyNode(parent.data)
      ..value = row.value
      ..children = row.children;
    if (row.dice) {
      treemapDice(
          parent0, x0, y0, x1, value != 0 ? y0 += dy * sumValue / value : y1);
    } else {
      treemapSlice(
          parent0, x0, y0, value != 0 ? x0 += dx * sumValue / value : x1, y1);
    }
    value = value - sumValue;
    i0 = i1;
  }

  return rows;
}

/// Specifies the desired aspect ratio of the generated rectangles. The [ratio]
/// must be specified as a number greater than or equal to one.
///
/// Note that the orientation of the generated rectangles (tall or wide) is not
/// implied by the ratio; for example, a ratio of two will attempt to produce a
/// mixture of rectangles whose *width*:*height* ratio is either 2:1 or 1:2.
/// (However, you can approximately achieve this result by generating a square
/// treemap at different dimensions, and then
/// [stretching the treemap](https://observablehq.com/@d3/stretched-treemap) to
/// the desired aspect ratio.) Furthermore, the specified [ratio] is merely a
/// hint to the tiling algorithm; the rectangles are not guaranteed to have the
/// specified aspect ratio.
///
/// {@category Treemap}
/// {@category Treemap tiling}
void Function(HierarchyNode<T>, num, num, num, num) treemapSquarifyRatio<T>(
    num ratio) {
  return (parent, x0, y0, x1, y1) {
    squarifyRatio(ratio, parent, x0, y0, x1, y1);
  };
}

/// Implements the [squarified treemap](https://www.win.tue.nl/~vanwijk/stm.pdf)
/// algorithm by Bruls *et al.*, which seeks to produce rectangles of a given
/// aspect ratio. The golden ratio, φ = (1 + sqrt(5)) / 2, per
/// [Kong *et al.*](http://vis.stanford.edu/papers/perception-treemaps) is used.
///
/// {@category Treemap}
/// {@category Treemap tiling}
void treemapSquarify<T>(
        HierarchyNode<T> parent, num x0, num y0, num x1, num y1) =>
    treemapSquarifyRatio<T>(phi)(parent, x0, y0, x1, y1);

typedef SquarifyRow<T> = ({
  num value,
  bool dice,
  List<HierarchyNode<T>> children,
});

typedef Squarify<T> = ({List<SquarifyRow<T>> rows, num ratio});
