import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Numpad extends StatefulWidget {
  String peerNumber;
  final Function handlCall;
  Numpad(this.peerNumber, this.handlCall);
  @override
  State<StatefulWidget> createState() => NumpadWidget(peerNumber, handlCall);
}

class NumpadWidget extends State<Numpad> {
  static const String callAsset = "assets/images/call_fill.svg";
  static const String delAsset = "assets/images/del.svg";
  late String peerNumber;
  final Function handlCall;
  String dialNumber = "";

  List<bool> activeDigits =
      List<bool>.generate(12, (i) => false, growable: false);

  NumpadWidget(this.peerNumber, this.handlCall);
  Widget build(BuildContext ctx) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      // margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.3),
          borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  peerNumber,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
                ),
              ),
              Positioned(
                right: 16,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (_) => setState(() {
                    dialNumber = dialNumber.substring(0, dialNumber.length - 1);
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
                handlCall();
              },
              child: Container(
                width: 100,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SvgPicture.asset(callAsset,
                          colorFilter:
                              ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    ]),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
//  numPad(Map<dynamic, dynamic> arguments, String delAsset,
