import 'package:dart_sip_ua_example/src/contactsPage/contacts.dart';
import 'package:dart_sip_ua_example/src/callPage/history.dart';
import 'package:dart_sip_ua_example/src/messagePage/message_page.dart';
import 'package:dart_sip_ua_example/src/router.dart';
import 'package:dart_sip_ua_example/src/settingsPage/settings.dart';
import 'package:dart_sip_ua_example/src/theme_provider.dart';
import 'package:dart_sip_ua_example/src/user_state/sip_user_cubit.dart';
import 'package:dart_sip_ua_example/theme.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:sip_ua/sip_ua.dart';

import 'src/about.dart';
import 'src/callscreen.dart';
import 'src/callPage/dialpad.dart';
import 'src/register.dart';

void main() {
  Logger.level = Level.debug;
  if (WebRTC.platformIsDesktop) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: MyApp(),
    ),
  );
}


// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  final SIPUAHelper _helper = SIPUAHelper();
  Map<String, PageContentBuilder> routes = {
    '/': ([SIPUAHelper? helper, Object? arguments]) => HistoryPage(),
    '/messages': ([SIPUAHelper? helper, Object? arguments]) => MessagePage(),
    '/contacts': ([SIPUAHelper? helper, Object? arguments]) => ContactsPage(),
    '/settings': ([SIPUAHelper? helper, Object? arguments]) => SettingsPage(),
    '/dial': ([SIPUAHelper? helper, Object? arguments]) =>
        DialPadWidget(helper),
    '/register': ([SIPUAHelper? helper, Object? arguments]) =>
        RegisterWidget(helper),
    '/callscreen': ([SIPUAHelper? helper, Object? arguments]) =>
        CallScreenWidget(helper, arguments as Call?),
    '/about': ([SIPUAHelper? helper, Object? arguments]) => AboutWidget(),
  };

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final PageContentBuilder? pageContentBuilder = routes[name!];
    if (pageContentBuilder != null) {
      if (settings.arguments != null) {
        final Route route = CustomMaterialRouter<Widget>(
            builder: (context) =>
                pageContentBuilder(_helper, settings.arguments));
        return route;
      } else {
        final Route route = CustomMaterialRouter<Widget>(
            builder: (context) => pageContentBuilder(_helper));
        return route;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme = TextTheme();
    MaterialTheme theme = MaterialTheme(textTheme);
    ThemeData targetTheme = brightness == Brightness.light ? theme.light() : theme.dark();

    return MultiProvider(
      providers: [
        Provider<SIPUAHelper>.value(value: _helper),
        Provider<SipUserCubit>(
            create: (context) => SipUserCubit(sipHelper: _helper)),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: targetTheme,
        initialRoute: '/',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}


