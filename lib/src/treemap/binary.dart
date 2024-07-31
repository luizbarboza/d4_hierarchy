import '../hierarchy/hierarchy.dart';

void main() {
  for (int i = 1; i < 10; ++i) {
    print(i);
  }
}

/// Recursively partitions the specified [node] into an approximately-balanced
/// binary tree, choosing horizontal partitioning for wide rectangles and
/// vertical partitioning for tall rectangles.
///
/// {@category Treemap}
/// {@category Treemap tiling}
void treemapBinary<T>(HierarchyNode<T> node, num x0, num y0, num x1, num y1) {
  var nodes = node.children!;
  int i, n = nodes.length;
  num sum;
  var sums = [];

  sums.add(sum = 0);
  for (i = 0; i < n; ++i) {
    sums.add(sum += nodes[i].value!);
  }

  void partition(int i, int j, num? value, num x0, num y0, num x1, num y1) {
    if (i >= j - 1) {
      var node = nodes[i];
      node.x0 = x0;
      node.y0 = y0;
      node.x1 = x1;
      node.y1 = y1;
      return;
    }

    var valueOffset = sums[i],
        valueTarget = (value! / 2) + valueOffset,
        k = i + 1,
        hi = j - 1;

    while (k < hi) {
      var mid = k + hi >>> 1;
      if (sums[mid] < valueTarget) {
        k = mid + 1;
      } else {
        hi = mid;
      }
    }

    if ((valueTarget - sums[k - 1]) < (sums[k] - valueTarget) && i + 1 < k) --k;

    var valueLeft = sums[k] - valueOffset, valueRight = value - valueLeft;

    if ((x1 - x0) > (y1 - y0)) {
      var xk = value != 0 ? (x0 * valueRight + x1 * valueLeft) / value : x1;
      partition(i, k, valueLeft, x0, y0, xk, y1);
      partition(k, j, valueRight, xk, y0, x1, y1);
    } else {
      var yk = value != 0 ? (y0 * valueRight + y1 * valueLeft) / value : y1;
      partition(i, k, valueLeft, x0, y0, x1, yk);
      partition(k, j, valueRight, x0, yk, x1, y1);
    }
  }

  partition(0, n, node.value, x0, y0, x1, y1);
}
