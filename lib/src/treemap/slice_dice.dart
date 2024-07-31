import '../hierarchy/hierarchy.dart';
import 'dice.dart';
import 'slice.dart';

/// If the specified [node] has odd depth, delegates to [treemapSlice];
/// otherwise delegates to [treemapDice].
///
/// {@category Treemap}
/// {@category Treemap tiling}
void treemapSliceDice<T>(
    HierarchyNode<T> node, num x0, num y0, num x1, num y1) {
  (node.depth.isOdd ? treemapSlice : treemapDice)(node, x0, y0, x1, y1);
}
