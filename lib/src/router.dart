import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

typedef PageContentBuilder = Widget Function([Object? arguments]);

class CustomMaterialRouter<T> extends MaterialPageRoute<T> {
  CustomMaterialRouter(
      {required RouteSettings settings, required WidgetBuilder builder})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.name == "/" ||
        settings.name == "/register" ||
        settings.name == "/incoming" ||
        settings.name == "/outgoing") {
      return LoaderOverlay(child: child);
    }
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return FadeTransition(
        opacity: animation, child: LoaderOverlay(child: child));
  }
}
