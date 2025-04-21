import 'package:flutter/material.dart';

class CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  final Color color;

  const CustomPopupMenuItem({
    Key? key,
    required T value,
    VoidCallback? onTap,
    required double height,
    required bool enabled,
    Widget? child,
    required this.color,
  }) : super(
          key: key,
          value: value,
          onTap: onTap,
          height: height,
          enabled: enabled,
          child: child,
        );

  @override
  _CustomPopupMenuItemState<T> createState() => _CustomPopupMenuItemState<T>();
}

class _CustomPopupMenuItemState<T>
    extends PopupMenuItemState<T, CustomPopupMenuItem<T>> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.color,
      child: super.build(context),
    );
  }
}
