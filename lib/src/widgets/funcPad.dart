import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class funcPad extends StatefulWidget {
  funcPad(
    this.endCall,
    this.addCall,
    this.holdCall,
    this.bluetoothCallback,
    this.speakerCallBack,
    this.muteCallback,
    this.keyPad,
  );
  Function endCall;

  Function speakerCallBack;

  Function muteCallback;

  Function keyPad;
  Function addCall;

  Function holdCall;

  Function bluetoothCallback;

  @override
  State<StatefulWidget> createState() => funcPadWidget(
        endCall,
        addCall,
        holdCall,
        bluetoothCallback,
        speakerCallBack,
        muteCallback,
        keyPad,
      );
}

class funcPadWidget extends State<funcPad> {
  static const String mute = "assets/images/mute.svg";
  static const String speaker = "assets/images/speaker.svg";
  static const String bluetooth = "assets/images/bluetooth.svg";
  static const String callHold = "assets/images/call_hold.svg";
  static const String callAdd = "assets/images/call_add.svg";
  static const String keypad = "assets/images/keypad.svg";
  static const String callFill = "assets/images/call_fill.svg";
  bool endCallActive = false;
  bool addCallActive = false;
  bool holdCallActive = false;
  bool bluetoothCallbackActive = false;
  bool speakerCallBackActive = false;
  bool muteCallbackActive = false;
  bool keyPadActive = false;
  int counter = 0;

  late Function endCall;
  late Function addCall;
  late Function holdCall;
  late Function bluetoothCallback;
  late Function speakerCallBack;
  late Function muteCallback;
  late Function keyPad;
  late Timer timeCounter;
  funcPadWidget(
    this.endCall,
    this.addCall,
    this.holdCall,
    this.bluetoothCallback,
    this.speakerCallBack,
    this.muteCallback,
    this.keyPad,
  );
  @override
  void initState() {
    super.initState();
    timeCounter = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        counter += 1;
      });
    });
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.5),
          borderRadius: BorderRadius.circular(24)),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 16,
          ),
          Center(
            child: Text(
              "${(counter / 60).toInt().toString().padLeft(2, "0")}:${(counter % 60).toString().padLeft(2, "0")}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => {
                  setState(() {
                    addCallActive = !addCallActive;
                  }),
                  addCall()
                },
                child: Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: addCallActive
                          ? Color.fromRGBO(27, 115, 254, 1)
                          : Color.fromRGBO(255, 255, 255, 0.2),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        callAdd,
                        width: 32,
                        height: 32,
                        colorFilter: ColorFilter.mode(
                            addCallActive ? Colors.white : Colors.black,
                            BlendMode.srcIn),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Add Call",
                        style: TextStyle(
                          color: addCallActive ? Colors.white : Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => {
                  holdCall(),
                  setState(() => holdCallActive = !holdCallActive)
                },
                child: Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: holdCallActive
                          ? Color.fromRGBO(27, 115, 254, 1)
                          : Color.fromRGBO(255, 255, 255, 0.2),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        callHold,
                        width: 32,
                        height: 32,
                        colorFilter: ColorFilter.mode(
                            holdCallActive ? Colors.white : Colors.black,
                            BlendMode.srcIn),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Hold Call",
                        style: TextStyle(
                          color: holdCallActive ? Colors.white : Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => {
                  setState(
                      () => bluetoothCallbackActive = !bluetoothCallbackActive),
                  bluetoothCallback()
                },
                child: Container(
                  width: 80,
                  height: 80,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: bluetoothCallbackActive
                          ? Color.fromRGBO(27, 115, 254, 1)
                          : Color.fromRGBO(255, 255, 255, 0.2),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        bluetooth,
                        width: 32,
                        height: 32,
                        colorFilter: ColorFilter.mode(
                            bluetoothCallbackActive
                                ? Colors.white
                                : Colors.black,
                            BlendMode.srcIn),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Bluetooth",
                        style: TextStyle(
                          color: bluetoothCallbackActive
                              ? Colors.white
                              : Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => {
                  speakerCallBack(),
                  setState(() {
                    speakerCallBackActive = !speakerCallBackActive;
                  })
                },
                child: Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: speakerCallBackActive
                          ? Color.fromRGBO(27, 115, 254, 1)
                          : Color.fromRGBO(255, 255, 255, 0.2),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      SvgPicture.asset(speaker,
                          colorFilter: ColorFilter.mode(
                              speakerCallBackActive
                                  ? Colors.white
                                  : Colors.black,
                              BlendMode.srcIn),
                          width: 32,
                          height: 32),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Speaker",
                        style: TextStyle(
                          color: speakerCallBackActive
                              ? Colors.white
                              : Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => {
                  setState(() {
                    muteCallbackActive = !muteCallbackActive;
                  }),
                  muteCallback()
                },
                child: Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: muteCallbackActive
                          ? Color.fromRGBO(27, 115, 254, 1)
                          : Color.fromRGBO(255, 255, 255, 0.2),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      SvgPicture.asset(mute,
                          width: 32,
                          height: 32,
                          colorFilter: ColorFilter.mode(
                              muteCallbackActive ? Colors.white : Colors.black,
                              BlendMode.srcIn)),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Mute",
                        style: TextStyle(
                          color:
                              muteCallbackActive ? Colors.white : Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    keyPadActive = !keyPadActive;
                    keyPad();
                  });
                },
                child: Container(
                  width: 80,
                  height: 80,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: keyPadActive
                          ? Color.fromRGBO(27, 115, 254, 1)
                          : Color.fromRGBO(255, 255, 255, 0.2),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      SvgPicture.asset(keypad,
                          colorFilter: ColorFilter.mode(
                              keyPadActive ? Colors.white : Colors.black,
                              BlendMode.srcIn),
                          width: 32,
                          height: 32),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Keypad",
                        style: TextStyle(
                          color: keyPadActive ? Colors.white : Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: GestureDetector(
                onTap: () => {timeCounter.cancel(), endCall()},
                child: Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(255, 255, 255, 0.6)),
                    child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(255, 255, 255, 1)),
                        child: Transform.rotate(
                          angle: math.pi * 3 / 4,
                          child: SvgPicture.asset(
                            callFill,
                            width: 21,
                            height: 21,
                            colorFilter: ColorFilter.mode(
                                Color.fromRGBO(242, 65, 65, 1),
                                BlendMode.srcIn),
                          ),
                        )))),
          )
        ],
      ),
    );
  }
}
