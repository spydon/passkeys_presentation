// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

/// A column that animates its children to their new positions when their
/// order changes.
///
/// Every child needs a unique key. The children can have any height: they are
/// measured during layout and slid from where they were drawn last to where
/// they belong now, so an item moving up past others glides into place
/// instead of jumping. Children that do not fit are clipped, so give the column
/// bounded height.
class AnimatedReorderColumn extends StatefulWidget {
  const AnimatedReorderColumn({
    required this.children,
    this.spacing = 16,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOutCubic,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedReorderColumn> createState() => _AnimatedReorderColumnState();
}

class _AnimatedReorderColumnState extends State<AnimatedReorderColumn>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );

  /// Where each child was drawn in the last layout.
  final _drawnY = <Key, double>{};

  /// Where each child started when the current animation began.
  var _startY = <Key, double>{};

  List<Key> get _keys => [for (final child in widget.children) child.key!];

  @override
  void didUpdateWidget(AnimatedReorderColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldKeys = [for (final child in oldWidget.children) child.key!];
    if (!_sameOrder(oldKeys, _keys)) {
      _startY = Map.of(_drawnY);
      _controller.forward(from: 0);
    }
  }

  static bool _sameOrder(List<Key> a, List<Key> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.children.every((child) => child.key != null),
      'Every child of AnimatedReorderColumn needs a key.',
    );
    return ClipRect(
      child: CustomMultiChildLayout(
        delegate: _ReorderLayoutDelegate(
          keys: _keys,
          spacing: widget.spacing,
          progress: CurvedAnimation(parent: _controller, curve: widget.curve),
          startY: _startY,
          drawnY: _drawnY,
        ),
        children: [
          for (final child in widget.children)
            LayoutId(id: child.key!, child: child),
        ],
      ),
    );
  }
}

class _ReorderLayoutDelegate extends MultiChildLayoutDelegate {
  _ReorderLayoutDelegate({
    required this.keys,
    required this.spacing,
    required this.progress,
    required this.startY,
    required this.drawnY,
  }) : super(relayout: progress);

  final List<Key> keys;
  final double spacing;
  final Animation<double> progress;
  final Map<Key, double> startY;
  final Map<Key, double> drawnY;

  @override
  void performLayout(Size size) {
    final constraints = BoxConstraints(maxWidth: size.width);
    var targetY = 0.0;
    drawnY.removeWhere((key, _) => !keys.contains(key));
    for (final key in keys) {
      final childSize = layoutChild(key, constraints);
      // New children start where they belong and pop in on their own.
      final fromY = startY[key] ?? targetY;
      final y = fromY + (targetY - fromY) * progress.value;
      positionChild(key, Offset(0, y));
      drawnY[key] = y;
      targetY += childSize.height + spacing;
    }
  }

  @override
  bool shouldRelayout(_ReorderLayoutDelegate oldDelegate) =>
      !identical(keys, oldDelegate.keys) || spacing != oldDelegate.spacing;
}
