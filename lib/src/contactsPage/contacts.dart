import 'dart:io';

import 'package:image_picker/image_picker.dart';
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
import 'package:vibration/vibration.dart';

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality, int? limit);
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

  List<XFile>? _mediaFileList;
  final ImagePicker _picker = ImagePicker();

  TextEditingController _accController = TextEditingController();

  TextEditingController _namePreConteroller = TextEditingController();
  TextEditingController _firstnameConteroller = TextEditingController();
  TextEditingController _lastnameConteroller = TextEditingController();
  TextEditingController _nameSuffConteroller = TextEditingController();

  TextEditingController _mobileConteroller = TextEditingController();
  TextEditingController _telephoneConteroller = TextEditingController();
  TextEditingController _workConteroller = TextEditingController();
  TextEditingController _homeConteroller = TextEditingController();

  late String imgSrc = "";

  int _account = 0;

  bool DropDownError = false;

  bool submitGlow = false;

  bool cancelGlow = false;

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

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
  }) async {
    if (context.mounted) {
      try {
        final XFile? media = await _picker.pickMedia();
        setState(() {
          if (media != null) {
            imgSrc = media.path;
          }
        });
      } catch (e) {
        print(e);
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
            searchbarTextConteroller: _searchbarTextConteroller,
            onTap: (phone) =>
                Navigator.pushNamed(context, "/outgoing", arguments: phone),
            messages: calls
                .where((c) => isCurrentDay(c.date))
                .map((c) => {
                      c.phoneNumber:
                          "${c.name} Has recently been added to you're contacts"
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
    const String userAsset = "assets/images/user_no_outline.svg";
    const String callAsset = "assets/images/call_outline.svg";
    const String mailAsset = "assets/images/mail_fill.svg";

    void onClicked() async {
      if (_account == 0) {
        setState(() {
          DropDownError = true;
        });
        Vibration.vibrate(duration: 300);
        return;
      }
      int i = await DbService.insertContacts(Contact(
          name:
              "${_namePreConteroller.text}${_firstnameConteroller.text} ${_lastnameConteroller.text}${_nameSuffConteroller.text}",
          phoneNumber: _telephoneConteroller.text,
          imgPath: imgSrc,
          date: DateTime.now()));
      Navigator.pushNamed(context, "/", arguments: i);
    }

    void OnCancel() {
      Navigator.pop(context);
    }

    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  height: 10,
                  thickness: 1,
                  color: Color.fromRGBO(177, 177, 177, 1),
                ),
                GestureDetector(
                    onTap: () => _onImageButtonPressed(
                          ImageSource.gallery,
                          context: context,
                        ),
                    child: imgSrc.isEmpty
                        ? Container(
                            margin: EdgeInsets.only(top: 12),
                            alignment: Alignment.center,
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(247, 247, 247, 1),
                              border: Border.all(
                                  color: Color.fromRGBO(177, 177, 177, 1)),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.photo_camera,
                              color: Color.fromRGBO(177, 177, 177, 1),
                              size: 20,
                            ),
                          )
                        : Container(
                            width: 64,
                            height: 64,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Image.file(
                              File(imgSrc),
                              width: 64,
                              height: 64,
                              fit: BoxFit.fill,
                            ),
                          )),
                Form(
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 12),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Color.fromRGBO(247, 247, 247, 1),
                        ),
                        child: Theme(
                          data: ThemeData(
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            shape: LinearBorder.none,
                            tilePadding: EdgeInsets.all(0),
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  userAsset,
                                  colorFilter: ColorFilter.mode(
                                      Color.fromRGBO(96, 96, 96, 1),
                                      BlendMode.srcIn),
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: TextFormField(
                                    controller: _namePreConteroller,
                                    decoration: InputDecoration(
                                        hintText: "Name Prefix",
                                        hintStyle: TextStyle(
                                            color: Color.fromRGBO(
                                                177, 177, 177, 1))),
                                  ),
                                )
                              ],
                            ),
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: TextFormField(
                                      controller: _firstnameConteroller,
                                      validator: (v) => (v != null && v.isEmpty)
                                          ? "FirstName can't be empty"
                                          : null,
                                      decoration: InputDecoration(
                                          hintText: "First Name",
                                          hintStyle: TextStyle(
                                              color: Color.fromRGBO(
                                                  177, 177, 177, 1))),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: TextFormField(
                                      controller: _lastnameConteroller,
                                      validator: (v) => (v != null && v.isEmpty)
                                          ? "LastName can't be empty"
                                          : null,
                                      decoration: InputDecoration(
                                          hintText: "Last Name",
                                          hintStyle: TextStyle(
                                              color: Color.fromRGBO(
                                                  177, 177, 177, 1))),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: TextFormField(
                                      controller: _nameSuffConteroller,
                                      decoration: InputDecoration(
                                          hintText: "Name suffix",
                                          hintStyle: TextStyle(
                                              color: Color.fromRGBO(
                                                  177, 177, 177, 1))),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 12),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Color.fromRGBO(247, 247, 247, 1),
                        ),
                        child: Theme(
                          data: ThemeData(
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            shape: LinearBorder.none,
                            tilePadding: EdgeInsets.all(0),
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  callAsset,
                                  colorFilter: ColorFilter.mode(
                                      Color.fromRGBO(96, 96, 96, 1),
                                      BlendMode.srcIn),
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: TextFormField(
                                    controller: _mobileConteroller,
                                    validator: (v) => (v != null && v.isEmpty)
                                        ? "Mobile can't be empty"
                                        : null,
                                    decoration: InputDecoration(
                                        hintText: "Mobile",
                                        isDense: true,
                                        hintStyle: TextStyle(
                                            color: Color.fromRGBO(
                                                177, 177, 177, 1))),
                                  ),
                                )
                              ],
                            ),
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: TextFormField(
                                      controller: _telephoneConteroller,
                                      validator: (v) => (v != null && v.isEmpty)
                                          ? "Telephone can't be empty"
                                          : null,
                                      decoration: InputDecoration(
                                          hintText: "Telephone",
                                          hintStyle: TextStyle(
                                              color: Color.fromRGBO(
                                                  177, 177, 177, 1))),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: TextFormField(
                                      controller: _homeConteroller,
                                      validator: (v) => (v != null && v.isEmpty)
                                          ? "Home can't be empty"
                                          : null,
                                      decoration: InputDecoration(
                                          hintText: "Home",
                                          hintStyle: TextStyle(
                                              color: Color.fromRGBO(
                                                  177, 177, 177, 1))),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: TextFormField(
                                      controller: _workConteroller,
                                      validator: (v) => (v != null && v.isEmpty)
                                          ? "Work can't be empty"
                                          : null,
                                      decoration: InputDecoration(
                                          hintText: "Work",
                                          hintStyle: TextStyle(
                                              color: Color.fromRGBO(
                                                  177, 177, 177, 1))),
                                    ),
                                  ),
                                  Flexible(
                                      fit: FlexFit.loose,
                                      child: Text(
                                        "+ Add Phone Number",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(27, 115, 254, 1),
                                            fontSize: 10),
                                      )),
                                  SizedBox(
                                    height: 16,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          GestureDetector(
                              onTapDown: (e) => setState(
                                    () {
                                      submitGlow = true;
                                    },
                                  ),
                              onTapUp: (e) => {
                                    onClicked(),
                                    setState(() {
                                      submitGlow = false;
                                    })
                                  },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 64),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(27, 115, 254, 1),
                                    boxShadow: submitGlow
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF0000BB)
                                                  .withAlpha(60),
                                              blurRadius: 16.0,
                                              spreadRadius: 3.0,
                                              offset: const Offset(
                                                0.0,
                                                3.0,
                                              ),
                                            ),
                                          ]
                                        : null,
                                    borderRadius: BorderRadius.circular(32)),
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              )),
                          SizedBox(
                            height: 14,
                          ),
                          GestureDetector(
                              onTapDown: (e) => setState(() {
                                    cancelGlow = true;
                                  }),
                              onTapUp: (e) => {
                                    OnCancel(),
                                    setState(
                                      () {
                                        cancelGlow = false;
                                      },
                                    )
                                  },
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    shadows: cancelGlow
                                        ? [
                                            Shadow(
                                              color: Colors.redAccent
                                                  .withAlpha(255),
                                              blurRadius: 24.0,
                                              offset: const Offset(
                                                0.0,
                                                3.0,
                                              ),
                                            )
                                          ]
                                        : null),
                              ))
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
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
                      controller: _accController,
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
                      onSelected: (item) => setState(() {
                        DropDownError = false;
                        _account = item ?? 0;
                      }),
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
                  DropDownError
                      ? Text(
                          "Please Select valid Account",
                          style:
                              TextStyle(color: Colors.redAccent, fontSize: 12),
                        )
                      : SizedBox.shrink(),
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
