import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/properties/account.dart';
import 'package:linphone/src/classes/accounts.dart';
import 'package:linphone/src/classes/db.dart';
import 'package:linphone/src/classes/contact.dart';
import 'package:linphone/src/contactsPage/contact_list.dart';
import 'package:linphone/src/contactsPage/top_nav_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linphone/src/widgets/Actions.dart';
import 'package:linphone/src/widgets/bottomTabNavigator.dart';

bool isCurrentDay(DateTime dateTime) {
  final now = DateTime.now();
  return dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day;
}

class ContactPage extends StatefulWidget {
  ContactPage();

  @override
  State<StatefulWidget> createState() => _ContactWidget();
}

class _ContactWidget extends State<ContactPage> with TickerProviderStateMixin {
  final Map<int, String> bottomTabs = {
    0: "/",
    1: "/messages",
    2: "/contacts",
    3: "/settings",
  };
  late final String _name = "";
  late bool fabActive;
  late final TabController _tabController;
  late int _activeIndex;
  late List<Contact> _totContacts = List<Contact>.empty();
  late List<Contact> _contacts = List<Contact>.empty();

  final TextEditingController _searchbarTextConteroller =
      TextEditingController();

  late List<Accounts> _accs = List<Accounts>.empty();
  int missedCount = 0;

  @override
  void initState() {
    _tabController = TabController(
        animationDuration: Duration(microseconds: 30), length: 2, vsync: this);
    DbService.listContacts().then((contacts) {
      setState(() {
        _totContacts = contacts;
        _contacts = contacts;
      });
    });
    DbService.listAcc().then((acc) {
      setState(() {
        _accs = acc;
      });
    });
    fabActive = false;
    _activeIndex = 0;
    if (mounted) {
      _searchbarTextConteroller.addListener(() {
        setState(() {
          _contacts = _totContacts
              .where((c) => c.name
                  .toLowerCase()
                  .contains(_searchbarTextConteroller.text.toLowerCase()))
              .toList();
        });
      });
    }
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
    return fabActive ? newContactPage() : messagesView(_contacts);
  }

  Scaffold messagesView(List<Contact> calls) {
    const String userAsset = "assets/images/user.svg";
    const String addAsset = "assets/images/add_circle.svg";

    return Scaffold(
      // floatingActionButtonAnimator: Fade, TODO
      bottomNavigationBar: BottomNavBar(2),
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
            missedCount: missedCount,
            searchbarTextConteroller: _searchbarTextConteroller,
            onTap: (phone) =>
                Navigator.pushNamed(context, "/outgoing", arguments: phone),
            messages: calls
                .where((c) => isCurrentDay(c.date))
                .map((c) => {
                      c.phoneNumber:
                          "${c.name} Has recently been added ti you're contacts"
                    })
                .toList(),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Text("${_contacts.length.toString()} Contacts",
                    style: TextStyle(
                        color: Colors.white,
                        decorationColor: Colors.white,
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
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
                          ? TopNavContact(
                              searchContactController:
                                  _searchbarTextConteroller,
                              tabController: _tabController,
                              activeIndex: _activeIndex,
                              counts: calls.length)
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
                          : ContactListView(
                              key: ValueKey(calls.length),
                              tabController: _tabController,
                              contacts: calls),
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

  Scaffold newContactPage() {
    const String arrowLeftAsset = "assets/images/arrow_left.svg";
    const String sentAsset = "assets/images/sent.svg";
    const String userAsset = "assets/images/user_no_outline.svg";
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
                  "New Contact",
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
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                  ),
                  Text("Save contact in",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
                  SizedBox(
                    width: 21,
                  ),
                  Expanded(
                    child: DropdownMenu<int>(
                      // controller: _contactController,
                      trailingIcon: Icon(
                        Icons.add,
                        color: Color.fromRGBO(27, 115, 254, 1),
                        size: 18,
                      ),
                      alignmentOffset: Offset(8, 16),
                      menuStyle: MenuStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                        shadowColor: WidgetStatePropertyAll(
                            Color.fromRGBO(0, 0, 0, 0.07)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24))),
                      ),
                      width: double.infinity,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      hintText: "Recipient",
                      inputDecorationTheme: InputDecorationTheme(
                        hintStyle:
                            TextStyle(color: Color.fromRGBO(177, 177, 177, 1)),
                        outlineBorder: BorderSide.none,
                        filled: true,
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 0,
                              color: Colors.transparent,
                              style: BorderStyle.none),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        fillColor: Color.fromRGBO(247, 247, 247, 1),
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 0,
                              color: Colors.transparent,
                              style: BorderStyle.none),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5.0, horizontal: 9),
                      ),
                      onSelected: (int? id) {
                        Navigator.pushNamed(context, "/chat", arguments: id);
                      },
                      dropdownMenuEntries: _accs.map((Accounts item) {
                        return DropdownMenuEntry<int>(
                            value: item.id ?? 0,
                            label: item.username,
                            leadingIcon: Container(
                              width: 32,
                              height: 32,
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(247, 247, 247, 1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      width: 0.2,
                                      color: Color.fromRGBO(177, 177, 177, 1))),
                              child: Center(
                                child: SvgPicture.asset(
                                  userAsset,
                                  colorFilter: ColorFilter.mode(
                                      Color.fromRGBO(27, 115, 254, 0.7),
                                      BlendMode.srcIn),
                                ),
                              ),
                            ),
                            labelWidget: Container(
                              key: ValueKey<int>(1),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [Text(item.username), Divider()],
                                  ),
                                ],
                              ),
                            ));
                      }).toList(),
                    ),
                  ),
                ],
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
