import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactPage extends StatefulWidget {
  ContactPage({super.key});
  @override
  State<StatefulWidget> createState() => _ContactWidget();
}

class _ContactWidget extends State<ContactPage> with TickerProviderStateMixin {
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
        animationDuration: Duration(microseconds: 30), length: 3, vsync: this);

    _bottomTabController = TabController(
        animationDuration: Duration(microseconds: 30), length: 4, vsync: this);
    _bottomTabController.index = 1;
    _bottomTabController.addListener(() {
      print(bottomTabs[_bottomTabController.index]);
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
    final List<Map<String, dynamic>> calls = [
      {'name': 'xdd', "pinned": false, 'date': DateTime.now(), "is_last": true},
      {
        'name': 'xdd',
        'date': DateTime.now().subtract(Duration(days: 1)),
        "lastmessage": "test",
        "pinned": false,
        "is_last": true
      },
      {
        'name': 'xddddd',
        "lastmessage": "test",
        "pinned": true,
        'date': DateTime.now().subtract(Duration(days: 1)),
        "is_last": false
      },
      {
        'name': 'Grocery xddddd',
        "lastmessage": "test",
        "pinned": false,
        'date': DateTime.now().subtract(Duration(days: 2)),
        "is_last": true
      },
      {
        'name': 'Workout xddddd',
        "lastmessage": "test",
        'date': DateTime.now().subtract(Duration(days: 3)),
        "pinned": true,
        "is_last": true
      },
    ];

    return fabActive ? NewContactPage() : messagesView(calls);
  }

  Scaffold messagesView(List<Map<String, dynamic>> calls) {
    const String userAsset = "assets/images/user.svg";
    const String bellAsset = "assets/images/Bellsvg.svg";
    const String searchAsset = "assets/images/search.svg";
    const String addAsset = "assets/images/add_circle.svg";

    const String bubbleFillAsset = "assets/images/bubble_fill.svg";

    const String callOutlineAsset = "assets/images/call_outline.svg";
    const String contactOutlineAsset = "assets/images/contact_outline.svg";
    const String settingsOutlineAsset = "assets/images/settings_outline.svg";
    return Scaffold(
      // floatingActionButtonAnimator: Fade, TODO
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
                    callOutlineAsset,
                  ),
                  text: 'call',
                ),
                Tab(
                  icon: SvgPicture.asset(bubbleFillAsset),
                  text: "Contact",
                ),
                Tab(
                  icon: SvgPicture.asset(contactOutlineAsset),
                  text: "Contacts",
                ),
                Tab(
                  icon: SvgPicture.asset(settingsOutlineAsset),
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
                          ? TopNavContact(
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
                          ? ContactPage()
                          : ContactListView(
                              tabController: _tabController, messages: calls),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: fabActive ? null : fabMethod(addAsset),
    );
  }


  Scaffold NewContactPage() {
    const String arrowLeftAsset = "assets/images/arrow_left.svg";
    const String sentAsset = "assets/images/sent.svg";
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        bottomSheet: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: TextField(
                      cursorHeight: 16,
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintStyle: TextStyle(
                              fontSize: 13,
                              color: Color.fromRGBO(177, 177, 177, 1)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32)),
                          hintText: 'Enter message',
                          filled: true,
                          fillColor: Color.fromRGBO(247, 247, 247, 1))),
                ),
              ),
              SvgPicture.asset(sentAsset, width: 20, height: 20),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: 24,
          leading: GestureDetector(
            onTap: () => setState(() {
              fabActive = !fabActive;
            }),
            child: SvgPicture.asset(
              arrowLeftAsset,
              width: 24,
              height: 24,
            ),
          ),
          title: Row(children: [
            Row(
              children: [
                Text(
                  "New Conversation",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                )
              ],
            ),
            // TextField()
          ]),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: DropdownButton<int>(
                items: [
                  DropdownMenuItem(child: Row(children: [Text("Hello World")]))
                ],
                onChanged: (int? value) {},
              )),
        ));
  }

  Column fabMethod(String addAsset) {
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
              width: 172,
              height: 44,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 27, 114, 254),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  spacing: 10,
                  children: [
                    SvgPicture.asset(addAsset, width: 18, height: 18),
                    Text(
                      "New Contact",
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
