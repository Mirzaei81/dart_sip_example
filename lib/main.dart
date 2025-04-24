import 'package:linphone/src/callPage/incoming.dart';
import 'package:linphone/src/callPage/outgoing.dart';
import 'package:linphone/src/classes/db.dart';
import 'package:linphone/src/contactsPage/contacts.dart';
import 'package:linphone/src/callPage/call_record_page.dart';
import 'package:linphone/src/messagePage/chat_page.dart';
import 'package:linphone/src/messagePage/message_page.dart';
import 'package:linphone/src/router.dart';
import 'package:linphone/src/settingsPage/settings.dart';
import 'package:linphone/src/theme_provider.dart';
import 'package:linphone/src/util/sms.dart';
import 'package:linphone/theme.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart' as Logging;
import 'package:provider/provider.dart';
import 'package:flutter_pjsip/flutter_pjsip.dart';

import 'src/about.dart';
import 'src/registerPage/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logging.Logger.level = Logging.Level.debug;
  await DbService.initdb();

  // await oVpnConnection();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static final FlutterPjsip _helper = FlutterPjsip.instance;
  late final Map<String, PageContentBuilder> routes;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  MyApp() {
    routes = {
      '/': ([Object? arguments]) => HistoryPage(),
      '/messages': ([Object? arguments]) => MessagePage(),
      '/chat': ([Object? arguments]) => ChatPage(arguments as int),
      '/contacts': ([Object? arguments]) => ContactPage(),
      '/settings': ([Object? arguments]) => SettingsPage(),
      '/register': ([Object? arguments]) => RegisterWidget(),
      "/outgoing": ([Object? arguments]) => Outgoing(arguments as String),
      "/incoming": ([Object? arguments]) => Incoming(),
      '/about': ([Object? arguments]) => AboutWidget(),
    };
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final PageContentBuilder? pageContentBuilder = routes[name!];
    if (pageContentBuilder != null) {
      if (settings.arguments != null) {
        final Route route = CustomMaterialRouter<Widget>(
            builder: (context) => pageContentBuilder(settings.arguments));
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
    ThemeData targetTheme =
        brightness == Brightness.light ? theme.light() : theme.dark();

    return MultiProvider(
      providers: [
        Provider<DbService>(create: (context) => DbService()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Flutter Demo',
        theme: targetTheme,
        initialRoute: '/',
        themeAnimationDuration: Duration(milliseconds: 200),
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}

//
//
// Future<void> oVpnConnection() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   print("initilizing");
//   await FlutterOpenvpn.init(
//     localizedDescription: "Linotik",
//     providerBundleIdentifier:
//         "com.topfreelancerdeveloper.flutterOpenvpnExample.RunnerExtension", //this is required only on iOS
//   );
//   var content = await rootBundle.loadString("assets/vpn/OpenVPN.ovpn");

//   await FlutterOpenvpn.lunchVpn(
//     content,
//     (isProfileLoaded) {
//       print('\x1b[1;31misProfileLoaded : $isProfileLoaded');
//     },
//     (vpnActivated) {
//       print('\x1b[1;31mvpnActivated : $vpnActivated');
//     },
//     user: "mirzaei",
//     pass: "1v15nz",
//     onConnectionStatusChanged: (duration, lastPacketRecieve, byteIn, byteOut) =>
//         print(byteIn),
//     expireAt: DateTime.now().add(
//       Duration(
//         seconds: 180,
//       ),
//     ),
//   );
// }
