import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_pjsip/flutter_pjsip.dart';
import 'package:ftpconnect/ftpConnect.dart';
import 'package:http/http.dart' as http;
import 'package:linphone/src/callPage/dial_page.dart';
import 'package:linphone/src/callPage/call_record_list.dart';
import 'package:linphone/src/callPage/top_nav_calls.dart';
import 'package:linphone/src/classes/call_record.dart';
import 'package:linphone/src/classes/contact.dart' as DbContact;
import 'package:linphone/src/classes/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linphone/src/util/sms.dart';
import 'package:linphone/src/widgets/Actions.dart';
import 'package:linphone/src/widgets/alert.dart';
import 'package:linphone/src/widgets/bottomTabNavigator.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path/path.dart' as pathLib;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage();

  @override
  State<HistoryPage> createState() => _HistoryWidget();
}

enum Item { string, dateTime }

class _HistoryWidget extends State<HistoryPage> with TickerProviderStateMixin {
  final Future<SharedPreferencesWithCache> _prefs =
      SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions());

  String _name = "";
  bool fabActive = false;
  late final TabController _tabController;
  late int _activeIndex = 0;
  List<CallRecord> TOTcallRecords = List<CallRecord>.empty();
  List<CallRecord> callRecords = List.empty();
  List<DbContact.Contact> contacts = List<DbContact.Contact>.empty();
  bool loading = false;

  bool showNotifs = false;

  bool showSearchbar = true;
  final TextEditingController _searchbarTextConteroller =
      TextEditingController();

  int missedCount = 0;

  Future<void> _initContacts() async {
    final String dirPath = (await getApplicationDocumentsDirectory()).path;
    final perf = await _prefs;
    bool getC = perf.getBool("contacat") ?? false;
    if (!getC) {
      var contacts = await FlutterContacts.getContacts(
          withPhoto: true,
          withGroups: true,
          withAccounts: true,
          withProperties: true);
      for (var c in contacts) {
        if (c.phones.isEmpty) continue;
        var path = "";
        if (c.photo != null && c.photo!.isNotEmpty) {
          path = dirPath + pathLib.separator + c.id.toString();
          var f = File(path);
          f.writeAsString(base64Encode(c.photo as List<int>));
        }
        try {
          DbService.insertContacts(DbContact.Contact(
              name: c.displayName,
              phoneNumber: c.phones[0].normalizedNumber.replaceAll(" ", ""),
              imgPath: path,
              date: DateTime.now()));
        } catch (e) {
          print(e.toString());
        }
      }
    }
    await perf.setBool("contacat", true);
    setState(() {
      _name = perf.getString("display_name") ?? "";
    });
  }

  Future<void> _initDisplayName() async {
    final perf = await _prefs;
    setState(() {
      _name = perf.getString("display_name") ?? "";
    });
  }

  Future<void> _initDb(SharedPreferencesWithCache p, String address) async {
    int fetched = (await DbService.getPerfrence<int>("fetched")) ?? 0;
    if (fetched == 0) {
      context.loaderOverlay.show();
      FTPConnect ftpClient =
          FTPConnect(address, user: 'root', pass: 'ys123456', timeout: 10);
      try {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        File srcFile = File("$appDocPath/pbxFile.sqlite");
        bool connected = await ftpClient.connect();
        if (connected) {
          await ftpClient.sendCustomCommand("TYPE I");
          bool success = await ftpClient.downloadFileWithRetry(
              "/persistent/var/lib/asterisk/db/MyPBX.sqlite", srcFile,
              pRetryCount: 5);
          if (success) {
            await DbService.bulkInsert(srcFile.path);
            setState(() {
              loading = false;
            });

            await DbService.setPerfrence("fetched", true);
            context.loaderOverlay.hide();
            await ftpClient.disconnect();
          } else {
            print(success);
            alert(context, "Connection Failure", "Failed to connect to server");
          }
        } else {
          alert(context, "Connection Failure", "Failed to connect to server");
        }
      } catch (e) {
        print(e.toString());
        setState(() {
          loading = false;
        });
        alert(context, "Connection Failure", "Failed to connect to server");
        context.loaderOverlay.hide();
      }
    }
    context.loaderOverlay.hide();
    await _initDisplayName();
  }

  void initHandler() async {
    var accounts = await DbService.listAcc();
    if (accounts.isEmpty) {
      Navigator.pushNamed(context, "/register");
      return;
    }

    var p = await _prefs;
    var token = p.getString("token");
    if (token == null) {
      await registerToken(accounts[0].uri.trim(), context, p);
    }
    const platform = MethodChannel('com.linotik.app/main');
    try {
      final result = (await platform.invokeMethod<bool>(
              'request_permissions', {"database": DbService.dbPath})) ??
          false;
      if (result) {
        await _initDb(p, accounts[0].uri.trim());
        await _initContacts();
      } else {
        openAppSettings();
      }
    } catch (e) {
      print(e);
    }
    FlutterPjsip instence = FlutterPjsip.instance;
    await instence.pjsipInit(DbService.dbPath);
    await instence.pjsipLogin(
        username: accounts[0].username,
        password: accounts[0].password,
        ip: accounts[0].uri,
        port: "5060");
    await SmsHandler.connect(context);

    var fetchedContacts = await DbService.listContacts();
    var fetchedTOTcallRecords = await DbService.listRecords();

    setState(() {
      contacts = fetchedContacts;
      TOTcallRecords = fetchedTOTcallRecords;
      callRecords = fetchedTOTcallRecords;
      missedCount = callRecords.where((cr) => cr.missed).length;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initHandler();
    });

    _tabController = TabController(
        animationDuration: Duration(microseconds: 30), length: 4, vsync: this);

    _searchbarTextConteroller.addListener(() {
      setState(() => callRecords = TOTcallRecords.where(
          (c) => c.name.contains(_searchbarTextConteroller.text)).toList());
    });
    _tabController.animation!.addListener(() {
      setState(() {
        loading = true;
        _activeIndex = _tabController.index;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void onPopInvoke(bool poped, dynamic t) {
    if (!poped) {
      if (fabActive) {
        setState(() {
          fabActive = false;
        });
      } else {
        DbService.dispose();
        SystemNavigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String userAsset = "assets/images/user.svg";
    const String keypadAsset = "assets/images/keypad.svg";

    return Scaffold(
      bottomNavigationBar: BottomNavBar(0),
      backgroundColor: Color.fromARGB(255, 27, 114, 254),
      appBar: AppBar(
        actionsPadding: EdgeInsets.all(20),
        automaticallyImplyLeading: true,
        leadingWidth: 90,
        toolbarHeight: 90,
        backgroundColor: Color.fromARGB(255, 27, 114, 254),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16),
          child: Container(
            height: 260,
            width: 260,
            alignment: Alignment.center, // <---- The magic
            child: SvgPicture.asset(
              userAsset,
              fit: BoxFit.cover,
              width: 150,
              height: 150,
            ),
          ),
        ),
        title: Builder(builder: (context) {
          return Column(
            children: [
              Text('Hello $_name',
                  style: TextStyle(color: Color(0xf7f7f7f7), fontSize: 16)),
            ],
          );
        }),
        actions: [
          NavActions(
            searchbarTextConteroller: _searchbarTextConteroller,
            onTap: (value) =>
                Navigator.pushNamed(context, "/outgoing", arguments: value),
            messages: callRecords
                .where((c) => c.missed)
                .map((c) => {c.calleNumber: "Missed call : ${c.calleNumber}"})
                .toList(),
          )
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: 6, bottom: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("You Have",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 8)),
              Text(
                  "${callRecords.where((data) => data.missed).length.toString()} Missed Calls",
                  style: TextStyle(
                      color: Colors.white,
                      decorationColor: Colors.white,
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                      fontWeight: FontWeight.w500))
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xf7f7f7f7),
              borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(24), topStart: Radius.circular(24)),
            ),
            child: PopScope<Object?>(
              canPop: false,
              onPopInvokedWithResult: onPopInvoke,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: !fabActive
                        ? TopNavigation(
                            tabController: _tabController,
                            activeIndex: _activeIndex,
                            counts: countCalls(callRecords),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              "Results",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 96, 96, 96),
                                  fontSize: 8),
                            ),
                          ),
                  ),
                  Expanded(
                      child: fabActive
                          ? DialPage(contacts: contacts)
                          : HistoryListView(
                              key: Key(callRecords.length.toString()),
                              tabController: _tabController,
                              calls: callRecords)),
                ],
              ),
            ),
          ),
        ),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: fabActive ? null : fabMethod(keypadAsset),
    );
  }

  Column fabMethod(String keypadAsset) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: GestureDetector(
            onTap: () => {
              setState(() {
                fabActive = !fabActive;
              })
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              width: 126,
              height: 44,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 27, 114, 254),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  spacing: 10,
                  children: [
                    SvgPicture.asset(keypadAsset, width: 18, height: 18),
                    Text(
                      "Keypad",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ]),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> registerToken(String address, BuildContext context,
    SharedPreferencesWithCache perf) async {
  await Firebase.initializeApp();
  String? token = await FirebaseMessaging.instance.getToken();
  FirebaseMessaging.instance.onTokenRefresh.listen(
    (token) => sendToken(address, token, context, perf),
  );
  print(token);
  if (token != null) {
    sendToken(address, token, context, perf);
  }
}

void sendToken(address, token, context, SharedPreferencesWithCache perf) async {
  final headers = {
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
    'Cache-Control': 'max-age=0',
    'Connection': 'keep-alive',
    'Content-Type': 'application/x-www-form-urlencoded',
    'Origin': 'http://$address',
    'Referer': 'http://$address/linotik_cgi/TokenCGI?15000',
    'Sec-GPC': '1',
    'Upgrade-Insecure-Requests': '1',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36',
    'Cookie':
        'language=en; loginname=admin; password=OV%5B2%5CFXo%5CI%5CmOFK4O%7CS%7BQVOzPlHj%5CoHlPIPoPFe%7BQVm%3F; OsVer=51.18.0.50; Series=; Product=TG100; defaultpwd=; current=sms; Backto=; TabIndex=0; TabIndexwithback=0; curUrl=15000',
  };

  final data = {
    'token': token,
  };

  final url = Uri.parse('http://$address/linotik_cgi/TokenCGI?15000');
  try {
    var res = await http.post(url, headers: headers, body: data);
    var status = res.statusCode;
    if (status != 200) {
      alert(context, "Connection Failure", "Failed to connect to server");
      return;
    }
    perf.setString("token", token);
  } catch (except) {
    alert(context, "Connection Failure", "Failed to connect to server");
  }
}
