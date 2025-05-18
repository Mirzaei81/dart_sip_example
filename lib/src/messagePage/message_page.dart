import 'package:linphone/src/classes/contact.dart';
import 'package:linphone/src/classes/message.dart';
import 'package:linphone/src/classes/db.dart';
import 'package:linphone/src/messagePage/message_list.dart';
import 'package:linphone/src/messagePage/top_nav_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linphone/src/widgets/Actions.dart';
import 'package:linphone/src/widgets/bottomTabNavigator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagePage extends StatefulWidget {
  MessagePage();

  @override
  State<StatefulWidget> createState() => _MessageWidget();
}

class _MessageWidget extends State<MessagePage> with TickerProviderStateMixin {
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
  int _activeIndex = 0;

  final TextEditingController _searchbarTextConteroller =
      TextEditingController();

  List<MessageDto> totalMessages = List.empty();
  List<MessageDto> messages = List.empty();
  int unread = 0;
  int isPinned = 0;

  late List<Contact> totalContacts;
  late List<Contact> contacts;

  late TextEditingController _contactController;

  int total = 0;
  Future<void> _loadName() async {
    final perf = await _prefs;
    setState(() {
      _name = perf.getString("display_name") ?? "";
    });
  }

  void onTap(MessageDto item) => {
        setState(() => messages
            .where((m) => m.peer.id == (item.peer.id ?? 1))
            .forEach((m) => m.read = true)),
        DbService.seenMessage(item.peer.id ?? 0).then((_) {
          Navigator.pushNamed(context, "/chat", arguments: item.peer.id);
        }),
      };

  @override
  void initState() {
    _contactController = TextEditingController();
    _contactController.addListener(() {
      setState(() {
        contacts = totalContacts
            .where((c) =>
                c.name
                    .toLowerCase()
                    .contains(_contactController.text.toLowerCase()) ||
                c.phoneNumber
                    .toLowerCase()
                    .toString()
                    .contains(_contactController.text.toLowerCase()))
            .take(10)
            .toList();
      });
    });
    DbService.listContacts().then((c) => {
          setState(() {
            totalContacts = c;
            contacts = c.take(10).toList();
          })
        });
    DbService.listMessages().then((msg) {
      setState(() {
        messages = msg.$1;
        totalMessages = msg.$1;
        total = msg.$2;
        unread = msg.$3;
        isPinned = msg.$4;
      });
    });
    _tabController = TabController(
        animationDuration: Duration(microseconds: 30), length: 3, vsync: this);
    _loadName();
    _tabController.animation!.addListener(() {
      setState(() {
        _activeIndex = _tabController.index;
      });
    });
    _searchbarTextConteroller.addListener(() {
      var newMesages = totalMessages
          .where((m) => m.peer.name.contains(_searchbarTextConteroller.text))
          .toList();
      setState(() {
        messages = newMesages;
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
    return fabActive ? newMessagePage() : messagesView(messages);
  }

  Scaffold messagesView(List<MessageDto> messages) {
    const String userAsset = "assets/images/user.svg";
    const String addAsset = "assets/images/add_circle.svg";

    return Scaffold(
      bottomNavigationBar: BottomNavBar(1),
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
            onTap: (result) async => {
              await DbService.seenMessage(int.tryParse(result) ?? 0),
              Navigator.pushNamed(context, "/chat",
                  arguments:
                      int.tryParse(result.replaceAll(RegExp(r"\(|\)"), "")))
            },
            messages: messages
                .where((m) => !m.read)
                .map((m) =>
                    {m.peer.id.toString(): "  ${m.peer.name}:${m.content}"})
                .toList(),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("You Have",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                Text("$unread Unread Messages",
                    style: TextStyle(
                      shadows: [
                        Shadow(color: Colors.white, offset: Offset(0, -3))
                      ],
                      color: Colors.transparent,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      decorationThickness: 1,
                    )),
                SizedBox(
                  height: 23,
                )
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
                          ? TopNavMessage(
                              _tabController,
                              _activeIndex,
                              messages.length,
                              messages.where((m) => !m.read).length,
                              messages.where((m) => m.isPinned).length)
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
                          ? Placeholder()
                          : MessageListView(
                              tabController: _tabController,
                              messages: messages,
                              onTap: onTap,
                            ),
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

  Scaffold newMessagePage() {
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
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownMenu<int>(
          controller: _contactController,
          trailingIcon: Icon(
            Icons.add,
            color: Color.fromRGBO(27, 115, 254, 1),
            size: 18,
          ),
          alignmentOffset: Offset(8, 16),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            shadowColor: WidgetStatePropertyAll(Color.fromRGBO(0, 0, 0, 0.07)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24))),
          ),
          width: double.infinity,
          enableFilter: true,
          requestFocusOnTap: true,
          hintText: "Recipient",
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(color: Color.fromRGBO(177, 177, 177, 1)),
            outlineBorder: BorderSide.none,
            filled: true,
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 0, color: Colors.transparent, style: BorderStyle.none),
              borderRadius: BorderRadius.circular(32),
            ),
            fillColor: Color.fromRGBO(247, 247, 247, 1),
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 0, color: Colors.transparent, style: BorderStyle.none),
              borderRadius: BorderRadius.circular(32),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 9),
          ),
          onSelected: (int? id) {
            Navigator.pushNamed(context, "/chat", arguments: id);
          },
          dropdownMenuEntries: contacts.map((Contact item) {
            return DropdownMenuEntry<int>(
                value: item.id ?? 0,
                label: item.name,
                leadingIcon: Container(
                  width: 32,
                  height: 32,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(247, 247, 247, 1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          width: 0.2, color: Color.fromRGBO(177, 177, 177, 1))),
                  child: Center(
                    child: Text(item.name[0],
                        style: TextStyle(
                            color: Color.fromRGBO(27, 115, 254, 0.7),
                            fontWeight: FontWeight.w500,
                            fontSize: 13)),
                  ),
                ),
                labelWidget: Container(
                  key: ValueKey<int>(1),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name),
                          item.phoneNumber != item.name
                              ? Text(
                                  "Mobile: ${item.phoneNumber}",
                                  style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(96, 96, 96, 1)),
                                )
                              : SizedBox.shrink(),
                          Divider()
                        ],
                      ),
                    ],
                  ),
                ));
          }).toList(),
        ),
      ),
    );
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
                      "New Message",
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
