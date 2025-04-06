import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ftpconnect/ftpConnect.dart';
import 'package:http/http.dart' as http;
import 'package:linphone/src/callPage/dial_page.dart';
import 'package:linphone/src/callPage/call_record_list.dart';
import 'package:linphone/src/callPage/top_nav_calls.dart';
import 'package:linphone/src/classes/contact.dart';
import 'package:linphone/src/classes/call_record.dart';
import 'package:linphone/src/classes/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linphone/src/widgets/alert.dart';
import 'package:loader_overlay/loader_overlay.dart';
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

  final Map<int, String> bottomTabs = {
    0: "/",
    1: "/messages",
    2: "/contacts",
    3: "/settings",
  };
  String _name = "";
  bool fabActive = false;
  late final TabController _tabController;
  late final TabController _bottomTabController;
  late int _activeIndex = 0;
  late Future<List<CallRecord>> callRecords = Future(List.empty);
  late final Future<List<Contact>> contacts;
  bool loading = false;

  Future<void> _loadName() async {
    final perf = await _prefs;
    setState(() {
      _name = perf.getString("display_name") ?? "";
    });
  }

  Future<void> loadDb() async {
    bool fetched = (await _prefs).getBool("fetched") ?? false;
    if (fetched) {
      String address = (await _prefs).getString("sip_uri") ?? '192.168.10.110';
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
          }
          await ftpClient.disconnect();
          context.loaderOverlay.hide();
          (await _prefs).setBool("fetched", true);
        } else {
          alert(context, "Connection Failure", "Failed to connect to server");
        }
      } catch (e) {
        setState(() {
          loading = false;
        });
        alert(context, "Connection Failure", "Failed to connect to server");
        context.loaderOverlay.hide();
      }
    }
    context.loaderOverlay.hide();
    await _loadName();
    callRecords = DbService.listRecords(); // future builder will resolve this
    contacts = DbService.listContacts();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Permission.storage.request().then(print);
      Permission.notification.request().then((PermissionStatus perm) {
        print(perm.toString());
      });
      DbService.listAcc().then((accounts) {
        accounts.isEmpty
            ? Navigator.pushNamed(context, "/register")
            : {
                loadDb(),
                _prefs.then((p) {
                  var token = p.getString("token");
                  if (token == null) {
                    registerToken(accounts[0].uri.trim(), context, p);
                  }
                })
              };
      });
    });

    _tabController = TabController(
        animationDuration: Duration(microseconds: 30), length: 4, vsync: this);

    _bottomTabController = TabController(
        animationDuration: Duration(microseconds: 30), length: 4, vsync: this);
    _bottomTabController.addListener(() {
      Navigator.pushNamed(
          context, bottomTabs[_bottomTabController.index] ?? "/");
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
    _bottomTabController.dispose();
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
    const String bellAsset = "assets/images/Bellsvg.svg";
    const String searchAsset = "assets/images/search.svg";
    const String keypadAsset = "assets/images/keypad.svg";

    const String callFillAsset = "assets/images/call_fill.svg";
    const String bubbleFillAsset = "assets/images/bubble_fill.svg";
    const String contactFillAsset = "assets/images/contact_fill.svg";
    const String settingsFillAsset = "assets/images/settings_fill.svg";

    const String callOutlineAsset = "assets/images/call_outline.svg";
    const String bubbleOutlineAsset = "assets/images/bubble_outline.svg";
    const String contactOutlineAsset = "assets/images/contact_outline.svg";
    const String settingsOutlineAsset = "assets/images/settings_outline.svg";

    return Scaffold(
      bottomNavigationBar: Container(
        color: Color(0xf7f7f7f7),
        child: Container(
          width: 343,
          height: 64,
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.only(bottom: 6, right: 16, left: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(18),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 7),
                ),
              ],
              borderRadius: BorderRadius.circular(24)),
          child: TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8)),
                border: Border(
                    top: BorderSide(
                  color: Color.fromARGB(255, 27, 114, 254),
                  width: 3.0,
                )),
              ),
              controller: _bottomTabController,
              tabs: [
                Tab(
                  icon: SvgPicture.asset(
                    _bottomTabController.index == 0
                        ? callFillAsset
                        : callOutlineAsset,
                  ),
                  text: 'call',
                ),
                Tab(
                  icon: SvgPicture.asset(
                    _bottomTabController.index == 1
                        ? bubbleFillAsset
                        : bubbleOutlineAsset,
                  ),
                  text: "Message",
                ),
                Tab(
                  icon: SvgPicture.asset(_bottomTabController.index == 2
                      ? contactFillAsset
                      : contactOutlineAsset),
                  text: "Contacts",
                ),
                Tab(
                  icon: SvgPicture.asset(_bottomTabController.index == 3
                      ? settingsFillAsset
                      : settingsOutlineAsset),
                  text: "Settings",
                )
              ]),
        ),
      ),
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
          Row(
            children: [
              SvgPicture.asset(
                bellAsset,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
              SizedBox(
                width: 10,
              ),
              SvgPicture.asset(
                searchAsset,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              )
            ],
          )
        ],
      ),
      body: FutureBuilder<List<CallRecord>>(
          future: callRecords,
          builder: (context, snapshot) =>
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                snapshot.hasData
                    ? Padding(
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
                                "${snapshot.data!.where((data) => data.missed).length.toString()} Missed Calls",
                                style: TextStyle(
                                    color: Colors.white,
                                    decorationColor: Colors.white,
                                    decoration: TextDecoration.underline,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500))
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xf7f7f7f7),
                      borderRadius: BorderRadiusDirectional.only(
                          topEnd: Radius.circular(24),
                          topStart: Radius.circular(24)),
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
                                    counts: countCalls(snapshot.data),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Text(
                                      "Results",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 96, 96, 96),
                                          fontSize: 8),
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: fabActive
                                ? FutureBuilder<List<Contact>>(
                                    future: contacts,
                                    builder: (context, snapshot) => loading
                                        ? CircularProgressIndicator()
                                        : DialPage(
                                            contacts:
                                                snapshot.data ?? List.empty()))
                                : HistoryListView(
                                    tabController: _tabController,
                                    calls: snapshot.data ?? List.empty()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ])),
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

void registerToken(String address, BuildContext context,
    SharedPreferencesWithCache perf) async {
  await Firebase.initializeApp();
  String? token = await FirebaseMessaging.instance.getToken();
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
    'Referer': 'http://$address/linphone_cgi/TokenCGI?15000',
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

  final url = Uri.parse('http://$address/linphone_cgi/TokenCGI?15000');
  try {
    var res = await http.post(url, headers: headers, body: data);
    var status = res.statusCode;
    if (status != 200) {
      alert(context, "Connection Failure", "Failed to connect to server");
    }
    print(res.body);
    perf.setString("token", token);
  } catch (except) {
    alert(context, "Connection Failure", "Failed to connect to server");
  }
}
