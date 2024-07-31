part of 'hierarchy.dart';

class _Iterator<T, Node extends HierarchyNodeBase<T, Node>>
    implements Iterator<Node> {
  List<Node>? _current;
  List<Node> _next;

  late Node _current0;

  _Iterator(Node thisArg) : _next = [thisArg];

  @override
  Node get current => _current0;

  @override
  bool moveNext() {
    if (_current == null) {
      _current = _next.reversed.toList();
      _next = [];
    }

    if (_current!.isNotEmpty) {
      Node node = _current0 = _current!.removeLast();
      List<Node>? children;
      if ((children = node.children) != null) {
        _next.addAll(children!);
      }
      return true;
    }

    if (_next.isNotEmpty) {
      _current = null;
      return moveNext();
    }

    return false;
  }
}
