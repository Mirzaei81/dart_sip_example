import 'package:flutter/material.dart';
import 'package:sip_ua/sip_ua.dart';

typedef PageContentBuilder = Widget Function(
    [SIPUAHelper? helper, Object? arguments]);

class CustomMaterialRouter<T> extends MaterialPageRoute<T> {
  CustomMaterialRouter({required super.builder});

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.name == "/") {
      return child;
    }
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return FadeTransition(opacity: animation, child: child);
  }
}
