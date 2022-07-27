import 'dart:async';
import 'package:flutter/material.dart';

// TODO
/// Work in progress
class ExpandableRow {}

// TODO
/// Work in progress
class ExpandableListView {}

class ExpandableColumnEvent {
  ExpandableColumnEvent({
    required this.contentContainerId,
    this.expansionIndex,
  });
  final int contentContainerId;
  final int? expansionIndex;
}

class ExpandableColumnController {
  final _controller = StreamController<ExpandableColumnEvent>.broadcast();
  Stream<ExpandableColumnEvent> get stream => _controller.stream;
  expansionToggle(int? contentCotnainerId, int index) {
    if (contentCotnainerId == null) return;
    _controller.add(ExpandableColumnEvent(
        contentContainerId: contentCotnainerId, expansionIndex: index));
  }
}

/// A column that allows targetting specific children and animating the
/// expansion of the target child.
///
/// For targetting, this project currently uses an ordered `List` and indexes to target specific
/// `ExpandableColumn`'s and a specific child that belongs to them.
///
/// The ability to perform equality matching on the `List` may be added in the future.
class ExpandableColumn extends StatefulWidget {
  /// A column that allows targetting specific children and animating the
  /// expansion of the target child.
  ///
  /// For targetting, this project currently uses an ordered `List` and indexes to target specific
  /// `ExpandableColumn`'s and a specific child that belongs to them.
  ///
  /// The ability to perform equality matching on the `List` may be added in the future.
  const ExpandableColumn({
    Key? key,
    this.id,
    this.controller,
    this.autoExpandChildren = const [],
    this.expansionAlignment = Alignment.center,
    this.duration = 800,
    this.curve = Curves.fastOutSlowIn,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.children = const [],
  }) : super(key: key);

  /// A unique identifier that is used by an `ExpandabeColumnController`.
  /// This is particularly useful when using multiple `ExpandableColumn`'s where
  /// the controller can toggle the expansion of a specific child belonging to a
  /// specific `ExpandableColumn`.
  final int? id;

  /// The `ExpandableColumnController` that this `ExpandableColumn` will listen to.
  final ExpandableColumnController? controller;

  /// A list of indexes that correspond to the children of this `ExpandableColumn`.
  /// Each child for the given index will be automatically expanded once this widget
  /// is built. Inversely, providing an `id` and `controller` allows fine-grained
  /// control over toggling the expansion of specific children in specific `ExpandableColumn`'s.
  final List<int> autoExpandChildren;

  /// The animation duration in millseconds.
  final int duration;

  /// The animation curve.
  final Curve curve;

  /// The alignment of the child widget that is expandable.
  final AlignmentGeometry expansionAlignment;

  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final List<Widget> children;

  @override
  State<ExpandableColumn> createState() => _ExpandableColumnState();
}

class _ExpandableColumnState extends State<ExpandableColumn> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var e in widget.autoExpandChildren) {
        widget.controller?.expansionToggle(widget.id, e);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: widget.key,
      mainAxisAlignment: widget.mainAxisAlignment,
      mainAxisSize: widget.mainAxisSize,
      crossAxisAlignment: widget.crossAxisAlignment,
      textDirection: widget.textDirection,
      verticalDirection: widget.verticalDirection,
      textBaseline: widget.textBaseline,
      children: widget.children
          .map((e) => ColumnChildExpander(
                expansionAlignment: widget.expansionAlignment,
                index: widget.children.indexOf(e),
                contentCotnainerId: widget.id,
                controller: widget.controller,
                duration: widget.duration,
                curve: widget.curve,
                child: e,
              ))
          .toList(),
    );
  }
}

class ColumnChildExpander extends StatefulWidget {
  const ColumnChildExpander({
    Key? key,
    required this.index,
    required this.contentCotnainerId,
    required this.controller,
    required this.child,
    this.duration = 800,
    this.curve = Curves.fastOutSlowIn,
    this.expansionAlignment = Alignment.center,
  }) : super(key: key);
  final int index;
  final int? contentCotnainerId;
  final ExpandableColumnController? controller;
  final Widget child;
  final int duration;
  final Curve curve;
  final AlignmentGeometry expansionAlignment;

  @override
  ColumnChildExpanderState createState() => ColumnChildExpanderState();
}

class ColumnChildExpanderState extends State<ColumnChildExpander>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration), vsync: this);

  late final Animation<double> _animation =
      CurvedAnimation(parent: _controller, curve: widget.curve);

  @override
  void initState() {
    widget.controller?.stream.listen((event) {
      if (event.expansionIndex == widget.index &&
          event.contentContainerId == widget.contentCotnainerId) {
        if (_animation.isDismissed) {
          _controller.forward();
        }
        if (_animation.isCompleted) {
          _controller.reverse();
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      alignment: widget.expansionAlignment,
      duration: Duration(seconds: widget.duration),
      curve: widget.curve,
      child: SizeTransition(
        sizeFactor: _animation,
        child: Container(child: widget.child),
      ),
    );
  }
}
