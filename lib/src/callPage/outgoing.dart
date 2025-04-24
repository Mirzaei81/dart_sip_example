import 'package:flutter_pjsip/flutter_pjsip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linphone/src/classes/contact.dart';
import 'package:linphone/src/classes/db.dart';
import 'package:linphone/src/widgets/funcPad.dart';
import 'package:linphone/src/widgets/numpad.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

class Outgoing extends StatefulWidget {
  final String peerId;
  Outgoing(this.peerId);

  @override
  State<StatefulWidget> createState() => OutgoinCallWidget(peerId);
}

class OutgoinCallWidget extends State<Outgoing> {
  OutgoinCallWidget(this.peerNumber);
  bool showNumpad = false;
  late final String serverAddress;
  final String peerNumber;
  late Contact calle;

  final FlutterPjsip pjsip = FlutterPjsip.instance;

  Future<void> _addCall(String number) async {
    await pjsip.pjsipCall(username: number, ip: serverAddress, port: "5060");
  }

  Future<void> _endCall() async {
    await pjsip.pjsipRefuse();
    await Navigator.pushNamed(context, "/");
  }

  Future<void> _bluetooth() async {
    await Permission.bluetooth.request();
    return null;
  }

  Future<void> _hold() async {
    await pjsip.pjsipHold();
    return null;
  }

  Future<void> _unHold() async {
    await pjsip.pjsipReinvite();
    return null;
  }

  Future<void> _speaker() async {
    await pjsip.pjsipHandsFree();
  }

  Future<void> _mute() async {
    await pjsip.pjsipMute();
  }

  void _loadSettings() async {
    var accounts = await DbService.listAcc();
    if (accounts.isNotEmpty) {
      setState(() {
        serverAddress = accounts[0].uri;
      });
    }
  }

  Future<Contact?> getContact(String number) async {
    return await DbService.getContact(number);
  }

  @override
  void initState() {
    super.initState();
    Vibration.cancel();
    DbService.getContact(peerNumber).then((c) {
      if (c != null) {
        setState(() {
          calle = c;
        });
      }
    });
    FlutterPjsip.instance.pjsipReceive();

    _loadSettings();
  }

  void displayNumpad() {
    setState(() {
      showNumpad = !showNumpad;
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    const String userAsset = "assets/images/user_no_outline.svg";
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color.fromRGBO(27, 115, 254, 1), Colors.white])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 77),
            FutureBuilder(
              future: getContact(arguments["peerNumber"] ?? ""),
              builder: (ctx, AsyncSnapshot<Contact?> snap) => Column(
                children: [
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
                              (snap.connectionState == ConnectionState.active &&
                                      snap.data != null &&
                                      snap.data!.imgPath.isEmpty)
                                  ? snap.data!.imgPath
                                  : userAsset,
                              colorFilter: ColorFilter.mode(
                                  Color.fromRGBO(27, 115, 254, 0.7),
                                  BlendMode.srcIn),
                            ),
                          )),
                    ),
                  ),
                  Text((snap.connectionState == ConnectionState.active &&
                          snap.data != null &&
                          snap.data!.name.isEmpty)
                      ? snap.data!.name
                      : ""),
                  Text(arguments["peerNumber"] ?? "")
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: showNumpad
                  ? Numpad(
                      (arguments["peerNumber"] ?? "")
                          .split("@")[0]
                          .substring("sip:".length),
                      (number) => _addCall(number))
                  : funcPad(_endCall, (number) => _addCall(number), _hold,
                      _bluetooth, _speaker, _mute, displayNumpad),
            ),
          ],
        ));
  }
}
