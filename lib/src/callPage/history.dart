import 'package:dart_sip_ua_example/src/callPage/dial_page.dart';
import 'package:dart_sip_ua_example/src/callPage/history_list.dart';
import 'package:dart_sip_ua_example/src/callPage/top_nav_calls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryWidget();
}

enum Item { string, dateTime }

class _HistoryWidget extends State<HistoryPage>
    with TickerProviderStateMixin {
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

  Future<void> _loadName() async {
    final perf = await _prefs;
    setState(() {
      _name = perf.getString("display_name") ?? "";
    });
  }

  @override
  void initState() {
    _tabController = TabController(
        animationDuration: Duration(microseconds: 30), length: 4, vsync: this);

    _bottomTabController = TabController(
        animationDuration: Duration(microseconds: 30), length: 4, vsync: this);
    _bottomTabController.addListener(() {
      Navigator.pushNamed(
          context, bottomTabs[_bottomTabController.index] ?? "/");
    });
    _loadName();
    _tabController.animation!.addListener(() {
      setState(() {
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
    print("$fabActive,$poped");
    if (!poped) {
      if (fabActive) {
        setState(() {
          fabActive = false;
        });
      } else {
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

    final List<Map<String, dynamic>> calls = [
      {
        'name': 'Call John',
        "incoming": false,
        'date': DateTime.now(),
        "is_last": true
      },
      {
        'name': 'Meeting with team',
        'date': DateTime.now().subtract(Duration(days: 1)),
        "incoming": false,
        "is_last": true
      },
      {
        'name': 'Doctor appointment',
        "incoming": true,
        'date': DateTime.now().subtract(Duration(days: 1)),
        "is_last": false
      },
      {
        'name': 'Grocery shopping',
        "incoming": false,
        'date': DateTime.now().subtract(Duration(days: 2)),
        "is_last": true
      },
      {
        'name': 'Workout',
        'date': DateTime.now().subtract(Duration(days: 3)),
        "incoming": true,
        "is_last": true
      },
    ];
    final List<Map<String, dynamic>> contacts = [
      {"img": null, "name": "AbcXyzPq", "number": "989374615820"},
      {"img": null, "name": "LmNoPrSt", "number": "987456321098"},
      {"img": null, "name": "QrStUvWx", "number": "989012345678"}
    ];

    return Scaffold(
      bottomNavigationBar: Container(
        color: Color(0xf7f7f7f7),
        child: Container(
          width: 343,
          height: 64,
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.only(bottom: 6, right: 16, left: 16),
          decoration: BoxDecoration(
            color:Colors.white,
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
                        color: Color.fromARGB(255, 27, 114, 254), width: 3.0,)),
              ),
            
            controller: _bottomTabController, tabs: [
            Tab(
              icon: SvgPicture.asset(_bottomTabController.index==0 ?callFillAsset:callOutlineAsset,),
              text: 'call',          
            ),                       
            Tab(                     
              icon: SvgPicture.asset(_bottomTabController.index==1?bubbleFillAsset:bubbleOutlineAsset,),
              text: "Message",       
            ),                       
            Tab(                     
              icon: SvgPicture.asset(_bottomTabController.index==2?contactFillAsset:contactOutlineAsset),
              text: "Contacts",      
            ),                       
            Tab(                     
              icon: SvgPicture.asset(_bottomTabController.index==3?settingsFillAsset:settingsOutlineAsset),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "world",
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
                          ? topNavigation(
                              tabController: _tabController,
                              activeIndex: _activeIndex)
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
                              tabController: _tabController, calls: calls),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
