import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_contacts/diacritics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pjsip/flutter_pjsip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linphone/src/classes/call_record.dart';
import 'package:linphone/src/classes/contact.dart';
import 'package:linphone/src/classes/db.dart';
import 'package:linphone/src/widgets/callSlider.dart';
import 'package:linphone/src/widgets/gradiantText.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class Incoming extends StatefulWidget {
  Incoming(this.phoneNumber);
  String phoneNumber;

  @override
  State<StatefulWidget> createState() => OutgoinCallWidget(phoneNumber);
}

class OutgoinCallWidget extends State<Incoming>
    with SingleTickerProviderStateMixin {
  OutgoinCallWidget(this.phoneNumber);

  bool showNumpad = false;
  late final String serverAddress;
  String phoneNumber;

  final FlutterPjsip pjsip = FlutterPjsip.instance;
  bool answerClicked = false;
  bool rejectClicked = false;
  double answer = 0;
  double reject = 1;

  late String callerNumber = "";
  late String callerName = "";
  late String callerImgPath = "";
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void loadSettings() async {
    FlutterPjsip.instance.onSipStateChanged.listen((map) {
      final state = map['call_state'];
      final remoteUri = map['remote_uri'];
      print(state);
      setState(() {
        callerName = remoteUri;
        callerNumber = remoteUri;
      });
      if (state == "DISCONNECTED") {
        HapticFeedback.mediumImpact();
        SystemNavigator.pop();
      }
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    setState(() {
      callerName = preferences.getString("caller_name") ?? "";
      callerNumber = preferences.getString("caller_number") ?? "";
      callerImgPath = preferences.getString("caller_img_path") ?? "";
      print(callerName + "\t" + callerNumber + "\t" + callerImgPath);
    });
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<Contact?> getContact(String number) async {
    return await DbService.getContact(number);
  }

  @override
  Widget build(BuildContext context) {
    const String userAsset = "assets/images/user_fill.svg";

    return GestureDetector(
      onTap: () => {
        setState(() {
          rejectClicked = false;
          reject = 1;
          answer = 0;
          answerClicked = false;
        })
      },
      child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color.fromRGBO(27, 115, 254, 1), Colors.white])),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: 77),
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(stops: [
                          0.97,
                          1
                        ], colors: [
                          Color.fromRGBO(255, 255, 255, 0),
                          Color.fromRGBO(255, 255, 255, 1),
                        ])),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: [0, 1],
                            colors: [Color(0x441B73FE), Color(0x001B73FE)]),
                      ),
                      child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(stops: [
                                0.9,
                                1
                              ], colors: [
                                Color.fromRGBO(255, 255, 255, 1),
                                Color.fromRGBO(255, 255, 255, 0),
                              ])),
                          child: Container(
                            width: 80,
                            height: 80,
                            padding: EdgeInsets.all(20),
                            child: SvgPicture.asset(
                              userAsset,
                              colorFilter: ColorFilter.mode(
                                  Color.fromRGBO(27, 115, 254, 0.7),
                                  BlendMode.srcIn),
                            ),
                          )),
                    ),
                  ),
                  Text(callerName,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(callerName,
                      style: TextStyle(
                          color: Color.fromRGBO(27, 115, 254, 1),
                          fontSize: 15,
                          fontWeight: FontWeight.w500))
                ],
              ),
              Container(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(children: [
                            answerClicked
                                ? Positioned(
                                    top: 20,
                                    right: 12,
                                    child: GradientText(
                                      "Slide to Answer",
                                      gradient: LinearGradient(colors: [
                                        Colors.white,
                                        Color.fromRGBO(155, 155, 155, 1),
                                        Color.fromRGBO(27, 115, 254, 1)
                                      ], stops: [
                                        0,
                                        0.2,
                                        0.6
                                      ]),
                                    ),
                                  )
                                : SizedBox.shrink(),
                            SliderTheme(
                              data: SliderThemeData(
                                padding: EdgeInsets.only(left: 6),
                                trackHeight: 64,
                                activeTrackColor: answerClicked
                                    ? Colors.white.withAlpha(156)
                                    : Colors.transparent,
                                inactiveTrackColor: answerClicked
                                    ? Colors.white.withAlpha(156)
                                    : Colors.transparent,
                                thumbColor: Color.fromARGB(255, 27, 114, 254),
                                thumbShape: Callslider(
                                  thumbRadius: 21,
                                  iconData: Icons.call,
                                ),
                              ),
                              child: Slider(
                                  value: answer,
                                  onChanged: (value) {
                                    setState(() {
                                      answer = value;
                                    });
                                  },
                                  onChangeStart: (value) => {
                                        setState(() {
                                          answerClicked = true;
                                        })
                                      },
                                  onChangeEnd: (value) {
                                    setState(() {
                                      if (value == 1) {
                                        _flutterLocalNotificationsPlugin
                                            .cancel(0);
                                        Vibration.cancel();
                                        Navigator.pushNamed(
                                            context, "/outgoing",
                                            arguments: phoneNumber);
                                      }
                                      answerClicked = false;
                                      answer = 0;
                                    });
                                  }),
                            ),
                          ]),
                          Stack(
                            children: [
                              rejectClicked
                                  ? Positioned(
                                      top: 20,
                                      left: 12,
                                      child: GradientText(
                                        "Slide to Reject",
                                        gradient: LinearGradient(colors: [
                                          Color.fromARGB(255, 242, 65, 65),
                                          Color.fromRGBO(155, 155, 155, 1),
                                          Colors.white,
                                        ], stops: [
                                          0,
                                          0.4,
                                          1
                                        ]),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              SliderTheme(
                                data: SliderThemeData(
                                  padding: EdgeInsets.only(right: 0),
                                  trackHeight: 64,
                                  activeTrackColor: rejectClicked
                                      ? Colors.white.withAlpha(156)
                                      : Colors.transparent,
                                  inactiveTrackColor: rejectClicked
                                      ? Colors.white.withAlpha(156)
                                      : Colors.transparent,
                                  thumbColor: Color.fromARGB(255, 242, 65, 65),
                                  thumbShape: Callslider(
                                      thumbRadius: 21,
                                      iconData: Icons.call_end),
                                ),
                                child: Slider(
                                    value: reject,
                                    onChanged: (value) {
                                      setState(() {
                                        reject = value;
                                      });
                                    },
                                    onChangeStart: (value) => {
                                          setState(() {
                                            rejectClicked = true;
                                          })
                                        },
                                    onChangeEnd: (value) {
                                      setState(() {
                                        if (value == 0) {
                                          _flutterLocalNotificationsPlugin
                                              .cancel(0);
                                          Vibration.cancel();
                                          Vibration.cancel();
                                          DbService.insertRecords(CallRecord(
                                              id: -1,
                                              name: callerName,
                                              date: DateTime.now(),
                                              incoming: true,
                                              missed: true,
                                              calleNumber: callerNumber,
                                              avatarPath: callerImgPath,
                                              recordPath: ""));
                                          SystemNavigator.pop();
                                        }
                                        rejectClicked = false;
                                        reject = 1;
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          )),
    );
  }
}
