import '../hierarchy/hierarchy.dart';
import 'dice.dart';
import 'slice.dart';
import 'squarify.dart';

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
void Function(HierarchyNode<T>, num, num, num, num) treemapResquarifyRatio<T>(
    num ratio) {
  return (parent, x0, y0, x1, y1) {
    Squarify<T>? squarify;
    List<SquarifyRow<T>> rows;
    if ((squarify = parent.squarify) != null && (squarify!.ratio == ratio)) {
      rows = squarify.rows;
      var value = parent.value!;
      SquarifyRow<T> row;
      List<HierarchyNode<T>> nodes;
      int i, j = -1, n, m = rows.length;
      HierarchyNode<T> parent0;

      while (++j < m) {
        row = rows[j];
        nodes = row.children;
        row = (value: i = 0, dice: row.dice, children: row.children);
        n = nodes.length;
        for (; i < n; ++i) {
          row = (
            value: row.value + nodes[i].value!,
            dice: row.dice,
            children: row.children
          );
        }
        parent0 = HierarchyNode(parent.data)
          ..value = row.value
          ..children = row.children;
        if (row.dice) {
          treemapDice(parent0, x0, y0, x1,
              value != 0 ? y0 += (y1 - y0) * row.value / value : y1);
        } else {
          treemapSlice(parent0, x0, y0,
              value != 0 ? x0 += (x1 - x0) * row.value / value : x1, y1);
        }
        value -= row.value;
      }
    } else {
      parent.squarify = (
        rows: rows = squarifyRatio(ratio, parent, x0, y0, x1, y1),
        ratio: ratio
      );
    }
  };
}

/// Like [treemapSquarify], except preserves the topology (node adjacencies) of
/// the previous layout computed by treemapResquarify, if there is one and it
/// used the same target aspect ratio. The golden ratio, φ = (1 + sqrt(5)) / 2,
/// per [Kong *et al.*](http://vis.stanford.edu/papers/perception-treemaps) is
/// used.
///
/// This tiling method is good for animating changes to treemaps because it only
/// changes node sizes and not their relative positions, thus avoiding
/// distracting shuffling and occlusion. The downside of a stable update,
/// however, is a suboptimal layout for subsequent updates: only the first
/// layout uses the Bruls *et al.* squarified algorithm.
///
/// {@category Treemap}
/// {@category Treemap tiling}
void treemapResquarify<T>(
        HierarchyNode<T> parent, num x0, num y0, num x1, num y1) =>
    treemapResquarifyRatio<T>(phi)(parent, x0, y0, x1, y1);
