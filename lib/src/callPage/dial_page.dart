import 'dart:io';

import 'package:flutter_pjsip/flutter_pjsip.dart';
import 'package:linphone/src/classes/contact.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linphone/src/classes/db.dart';
import 'package:linphone/src/widgets/alert.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DialPage extends StatefulWidget {
  final List<Contact> contacts;
  const DialPage({
    required this.contacts,
  });
  @override
  State<StatefulWidget> createState() => NumPadWidget(contacts: contacts);
}

class NumPadWidget extends State<DialPage> {
  final List<Contact> contacts;
  NumPadWidget({required this.contacts});
  String dialNumber = "";
  late String serverAddress;

  final FlutterPjsip pjsip = FlutterPjsip.instance;

  void _loadSettings() async {
    SharedPreferencesWithCache _preferences =
        await SharedPreferencesWithCache.create(
            cacheOptions: const SharedPreferencesWithCacheOptions());
    var uri = _preferences.getString('sip_uri') ?? '192.168.5.150';
    var password = _preferences.getString('password') ?? '';
    var user = _preferences.getString('auth_user') ?? '';
    try {
      await pjsip.pjsipInit(DbService.dbPath);
      await pjsip.pjsipLogin(
          ip: uri, password: password, username: user, port: "5060");
    } catch (error) {
      alert(context, "error while initing", error.toString());
    }
    setState(() {
      serverAddress = uri;
    });
    pjsip.onSipStateChanged.listen((map) {
      final state = map['call_state'];
      final remoteUri = map['remote_uri'];
      switch (state) {
        case "CALLING":
          {
            Navigator.pushNamed(context, "/outgoing",
                arguments: {"peerNumber": remoteUri});
            break;
          }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  List<bool> activeDigits =
      List<bool>.generate(12, (i) => false, growable: false);

  Future<Widget?> _handleCall(BuildContext context) async {
    final dest = dialNumber;
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await Permission.microphone.request();
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.phone.request();
    }
    if (dest.isEmpty) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Target is empty.'),
            content: Text('Please enter a SIP URI or username!'),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return null;
    }
    // dialNumber =
    //     dialNumber.startsWith("0") ? dialNumber.substring(1) : dialNumber;
    print(dialNumber + "\t" + serverAddress);
    pjsip.pjsipCall(username: dialNumber, ip: serverAddress, port: "5060");
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const String callAsset = "assets/images/call_fill.svg";
    const String delAsset = "assets/images/del.svg";

    return Container(
        child: Stack(
      children: [
        Positioned.fill(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: contacts.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 60,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(children: [
                        contacts[index].imgPath.isNotEmpty
                            ? Image.file(File(contacts[index].imgPath))
                            : Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 0.2,
                                  ),
                                ),
                                child: Center(
                                    child: Text(
                                  contacts[index].name[0].toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 27, 114, 254)),
                                )),
                              ),
                        Expanded(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      contacts[index].name,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(contacts[index].phoneNumber,
                                        style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                Color.fromRGBO(37, 37, 37, 1))),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                                child: SvgPicture.asset(
                                  callAsset,
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.cover,
                                ),
                              )
                            ],
                          ),
                        ),
                      ]),
                    ),
                    Divider(
                      height: 1,
                    )
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 150,
          left: 28,
          width: 343,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            // margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.circular(24)),
            child: Column(
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        dialNumber,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 24),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapDown: (_) => setState(() {
                          dialNumber =
                              dialNumber.substring(0, dialNumber.length - 1);
                        }),
                        onLongPress: () => setState(() {
                          dialNumber = "";
                        }),
                        child: SvgPicture.asset(
                          delAsset,
                          fit: BoxFit.cover,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    )
                  ],
                ),
                Divider(
                  color: Colors.transparent,
                ),
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTapDown: (_) => setState(() {
                            activeDigits[0] = true;
                          }),
                          onTapUp: (_) => setState(() {
                            activeDigits[0] = false;
                            dialNumber += "1";
                          }),
                          child: Container(
                              width: 98,
                              height: 48,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  color: activeDigits[0]
                                      ? Color.fromRGBO(200, 200, 200, 1)
                                      : Color.fromRGBO(240, 240, 240, 1)),
                              child: Column(
                                children: [
                                  Text("1",
                                      style: TextStyle(
                                          color: Color.fromRGBO(32, 32, 32, 1),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700)),
                                  Text("MNO",
                                      style: TextStyle(
                                          color: Color.fromRGBO(37, 37, 37, 1),
                                          fontSize: 8,
                                          fontWeight: FontWeight.w400))
                                ],
                              )),
                        ),
                        GestureDetector(
                          onTapDown: (_) => setState(() {
                            activeDigits[1] = true;
                          }),
                          onTapUp: (_) => setState(() {
                            dialNumber += "2";
                            activeDigits[1] = false;
                          }),
                          child: Container(
                            width: 98,
                            height: 48,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: activeDigits[1]
                                    ? Color.fromRGBO(200, 200, 200, 1)
                                    : Color.fromRGBO(240, 240, 240, 1)),
                            child: Column(
                              children: [
                                Text("2",
                                    style: TextStyle(
                                        color: Color.fromRGBO(32, 32, 32, 1),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                Text("ABC",
                                    style: TextStyle(
                                        color: Color.fromRGBO(37, 37, 37, 1),
                                        fontSize: 8,
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (_) => setState(() {
                            activeDigits[2] = true;
                          }),
                          onTapUp: (_) => setState(() {
                            dialNumber += "3";
                            activeDigits[2] = false;
                          }),
                          child: Container(
                            width: 98,
                            height: 48,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: activeDigits[2]
                                    ? Color.fromRGBO(200, 200, 200, 1)
                                    : Color.fromRGBO(240, 240, 240, 1)),
                            child: Column(
                              children: [
                                Text("3",
                                    style: TextStyle(
                                        color: Color.fromRGBO(32, 32, 32, 1),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                Text("DEF",
                                    style: TextStyle(
                                        color: Color.fromRGBO(37, 37, 37, 1),
                                        fontSize: 8,
                                        fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ]),
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTapDown: (_) => setState(() {
                            activeDigits[3] = true;
                          }),
                          onTapUp: (_) => setState(() {
                            dialNumber += "4";
                            activeDigits[3] = false;
                          }),
                          child: Container(
                            width: 98,
                            height: 48,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: activeDigits[3]
                                    ? Color.fromRGBO(200, 200, 200, 1)
                                    : Color.fromRGBO(240, 240, 240, 1)),
                            child: Column(
                              children: [
                                Text("4",
                                    style: TextStyle(
                                        color: Color.fromRGBO(32, 32, 32, 1),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                Text("GHI",
                                    style: TextStyle(
                                        color: Color.fromRGBO(37, 37, 37, 1),
                                        fontSize: 8,
                                        fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (_) => setState(() {
                            activeDigits[4] = true;
                          }),
                          onTapUp: (_) => setState(() {
                            dialNumber += "5";
                            activeDigits[4] = false;
                          }),
                          child: Container(
                            width: 98,
                            height: 48,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: activeDigits[4]
                                    ? Color.fromRGBO(200, 200, 200, 1)
                                    : Color.fromRGBO(240, 240, 240, 1)),
                            child: Column(
                              children: [
                                Text("5",
                                    style: TextStyle(
                                        color: Color.fromRGBO(32, 32, 32, 1),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                Text("JKL",
                                    style: TextStyle(
                                        color: Color.fromRGBO(37, 37, 37, 1),
                                        fontSize: 8,
                                        fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (_) => setState(() {
                            activeDigits[5] = true;
                          }),
                          onTapUp: (_) => setState(() {
                            dialNumber += "6";
                            activeDigits[5] = false;
                          }),
                          child: Container(
                            width: 98,
                            height: 48,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: activeDigits[5]
                                    ? Color.fromRGBO(200, 200, 200, 1)
                                    : Color.fromRGBO(240, 240, 240, 1)),
                            child: Column(
                              children: [
                                Text("6",
                                    style: TextStyle(
                                        color: Color.fromRGBO(32, 32, 32, 1),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                Text("MNO",
                                    style: TextStyle(
                                        color: Color.fromRGBO(37, 37, 37, 1),
                                        fontSize: 8,
                                        fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ]),
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTapDown: (_) => setState(() {
                            activeDigits[6] = true;
                          }),
                          onTapUp: (_) => setState(() {
                            dialNumber += "7";
                            activeDigits[6] = false;
                          }),
                          child: Container(
                            width: 98,
                            height: 48,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: activeDigits[6]
                                    ? Color.fromRGBO(200, 200, 200, 1)
                                    : Color.fromRGBO(240, 240, 240, 1)),
                            child: Column(
                              children: [
                                Text("7",
                                    style: TextStyle(
                                        color: Color.fromRGBO(32, 32, 32, 1),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                Text("PQRS",
                                    style: TextStyle(
                                        color: Color.fromRGBO(37, 37, 37, 1),
                                        fontSize: 8,
                                        fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (_) => setState(() {
                            activeDigits[7] = true;
                          }),
                          onTapUp: (_) => setState(() {
                            dialNumber += "8";
                            activeDigits[7] = false;
                          }),
                          child: Container(
                            width: 98,
                            height: 48,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: activeDigits[7]
                                    ? Color.fromRGBO(200, 200, 200, 1)
                                    : Color.fromRGBO(240, 240, 240, 1)),
                            child: Column(
                              children: [
                                Text("8",
                                    style: TextStyle(
                                        color: Color.fromRGBO(32, 32, 32, 1),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                Text("TUV",
                                    style: TextStyle(
                                        color: Color.fromRGBO(37, 37, 37, 1),
                                        fontSize: 8,
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (_) => setState(() {
                            activeDigits[8] = true;
                          }),
                          onTapUp: (_) => setState(() {
                            dialNumber += "9";
                            activeDigits[8] = false;
                          }),
                          child: Container(
                            width: 98,
                            height: 48,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: activeDigits[8]
                                    ? Color.fromRGBO(200, 200, 200, 1)
                                    : Color.fromRGBO(240, 240, 240, 1)),
                            child: Column(
                              children: [
                                Text("9",
                                    style: TextStyle(
                                        color: Color.fromRGBO(32, 32, 32, 1),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                Text("WXYZ",
                                    style: TextStyle(
                                        color: Color.fromRGBO(37, 37, 37, 1),
                                        fontSize: 8,
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ]),
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTapDown: (_) => setState(() {
                            activeDigits[9] = true;
                          }),
                          onTapUp: (_) => setState(() {
                            dialNumber += "#";
                            activeDigits[9] = false;
                          }),
                          child: Container(
                            width: 98,
                            height: 48,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: activeDigits[9]
                                    ? Color.fromRGBO(200, 200, 200, 1)
                                    : Color.fromRGBO(240, 240, 240, 1)),
                            child: Center(
                              child: Text("#",
                                  style: TextStyle(
                                      color: Color.fromRGBO(32, 32, 32, 1),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (_) => setState(() {
                            activeDigits[10] = true;
                          }),
                          onTapUp: (_) => setState(() {
                            dialNumber += "0";
                            activeDigits[10] = false;
                          }),
                          child: Container(
                            width: 98,
                            height: 48,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: activeDigits[10]
                                    ? Color.fromRGBO(200, 200, 200, 1)
                                    : Color.fromRGBO(240, 240, 240, 1)),
                            child: Column(
                              children: [
                                Text("0",
                                    style: TextStyle(
                                        color: Color.fromRGBO(32, 32, 32, 1),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                Text("+",
                                    style: TextStyle(
                                        color: Color.fromRGBO(37, 37, 37, 1),
                                        fontSize: 8,
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (_) => setState(() {
                            activeDigits[11] = true;
                          }),
                          onTapUp: (_) => setState(() {
                            dialNumber += "*";
                            activeDigits[11] = false;
                          }),
                          child: Container(
                            width: 98,
                            height: 48,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: activeDigits[11]
                                    ? Color.fromRGBO(200, 200, 200, 1)
                                    : Color.fromRGBO(240, 240, 240, 1)),
                            child: Center(
                              child: Text("*",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromRGBO(32, 32, 32, 1),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ]),
                Divider(color: Colors.transparent),
                Column(children: [
                  GestureDetector(
                    onTap: () {
                      _handleCall(context);
                    },
                    child: Container(
                      width: 100,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 27, 114, 254),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SvgPicture.asset(callAsset,
                                colorFilter: ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn)),
                          ]),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        )
      ],
    ));
  }
}
