// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A column that animates its children to their new positions when their
/// order changes.
///
/// Every child needs a unique key. The children can have any height: they are
/// measured during layout and slid from where they were drawn last to where
/// they belong now, so an item moving up past others glides into place
/// instead of jumping. The column is as tall as its children, so wrap it in a
/// scroll view when they might not fit.
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
  late final _progress = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
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
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.children.every((child) => child.key != null),
      'Every child of AnimatedReorderColumn needs a key.',
    );
    return _ReorderLayout(
      keys: _keys,
      spacing: widget.spacing,
      progress: _progress,
      startY: _startY,
      drawnY: _drawnY,
      children: widget.children,
    );
  }
}

class _ReorderLayout extends MultiChildRenderObjectWidget {
  const _ReorderLayout({
    required this.keys,
    required this.spacing,
    required this.progress,
    required this.startY,
    required this.drawnY,
    required super.children,
  });

  final List<Key> keys;
  final double spacing;
  final Animation<double> progress;
  final Map<Key, double> startY;
  final Map<Key, double> drawnY;

  @override
  _RenderReorderColumn createRenderObject(BuildContext context) =>
      _RenderReorderColumn(
        keys: keys,
        spacing: spacing,
        progress: progress,
        startY: startY,
        drawnY: drawnY,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderReorderColumn renderObject,
  ) {
    renderObject
      ..keys = keys
      ..spacing = spacing
      ..progress = progress
      ..startY = startY
      ..drawnY = drawnY;
  }
}

class _ReorderParentData extends ContainerBoxParentData<RenderBox> {}

/// Lays the children out top to bottom, each drawn between where it was when
/// the order changed and where it belongs, by [progress]. Its own height is
/// that of the final layout.
class _RenderReorderColumn extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ReorderParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ReorderParentData> {
  _RenderReorderColumn({
    required this._keys,
    required this.startY,
    required this.drawnY,
    required this._spacing,
    required this._progress,
  });

  List<Key> _keys;
  set keys(List<Key> value) {
    _keys = value;
    markNeedsLayout();
  }

  double _spacing;
  set spacing(double value) {
    if (value == _spacing) return;
    _spacing = value;
    markNeedsLayout();
  }

  Animation<double> _progress;
  set progress(Animation<double> value) {
    if (identical(value, _progress)) return;
    if (attached) _progress.removeListener(markNeedsLayout);
    _progress = value;
    if (attached) _progress.addListener(markNeedsLayout);
    markNeedsLayout();
  }

  Map<Key, double> startY;
  Map<Key, double> drawnY;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _progress.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _progress.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ReorderParentData) {
      child.parentData = _ReorderParentData();
    }
  }

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    final childConstraints = BoxConstraints.tightFor(width: width);
    var targetY = 0.0;
    var index = 0;
    var child = firstChild;
    drawnY.removeWhere((key, _) => !_keys.contains(key));
    while (child != null) {
      final key = _keys[index];
      child.layout(childConstraints, parentUsesSize: true);
      // New children start where they belong and pop in on their own.
      final fromY = startY[key] ?? targetY;
      final y = fromY + (targetY - fromY) * _progress.value;
      final parentData = child.parentData! as _ReorderParentData;
      parentData.offset = Offset(0, y);
      drawnY[key] = y;
      targetY += child.size.height + _spacing;
      index++;
      child = parentData.nextSibling;
    }
    final height = index == 0 ? 0.0 : targetY - _spacing;
    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
