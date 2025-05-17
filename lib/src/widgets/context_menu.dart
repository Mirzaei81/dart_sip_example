import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef ContextMenuBuilder = Widget Function(
    BuildContext context, Offset offset);

/// Shows and hides the context menu based on user gestures.
///
/// By default, shows the menu on right clicks and long presses.
class ContextMenuRegion extends StatefulWidget {
  /// Creates an instance of [ContextMenuRegion].
  const ContextMenuRegion({
    super.key,
    required this.child,
    required this.contextMenuBuilder,
    required this.controller,
  });

  /// Builds the context menu.
  final ContextMenuBuilder contextMenuBuilder;
  final ContextMenuController controller;

  /// The child widget that will be listened to for gestures.
  final Widget child;

  @override
  State<ContextMenuRegion> createState() => _ContextMenuRegionState(controller);
}

class _ContextMenuRegionState extends State<ContextMenuRegion> {
  final ContextMenuController _contextMenuController;
  void _onTap(TapDownDetails event) {
    _show(event.globalPosition);
  }

  _ContextMenuRegionState(this._contextMenuController);
  void _onTapOut() {
    if (!_contextMenuController.isShown) {
      return;
    }
    _hide();
  }

  void _show(Offset position) {
    _contextMenuController.show(
      context: context,
      contextMenuBuilder: (context) {
        return widget.contextMenuBuilder(context, position);
      },
    );
  }

  void _hide() {
    _contextMenuController.remove();
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTap,
      onDoubleTap: _onTapOut,
      child: widget.child,
    );
  }
}
