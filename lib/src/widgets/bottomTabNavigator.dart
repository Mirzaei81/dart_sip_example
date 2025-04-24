import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linphone/src/widgets/tabIndicator.dart';

class BottomNavBar extends StatefulWidget {
  final int index;
  BottomNavBar(this.index);
  @override
  State<StatefulWidget> createState() {
    return BottomNavigationBarState(index: index);
  }
}

class BottomNavigationBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  final String callFillAsset = "assets/images/call_fill.svg";
  final String bubbleFillAsset = "assets/images/bubble_fill.svg";
  final String contactFillAsset = "assets/images/contact_fill.svg";
  final String settingsFillAsset = "assets/images/settings_fill.svg";

  final String callOutlineAsset = "assets/images/call_outline.svg";
  final String bubbleOutlineAsset = "assets/images/bubble_outline.svg";
  final String contactOutlineAsset = "assets/images/contact_outline.svg";
  final String settingsOutlineAsset = "assets/images/settings_outline.svg";
  late final TabController _bottomTabController;

  final Map<int, String> bottomTabs = {
    0: "/",
    1: "/messages",
    2: "/contacts",
    3: "/settings",
  };
  final int index;
  BottomNavigationBarState({required this.index});

  @override
  void initState() {
    super.initState();
    _bottomTabController = TabController(
        animationDuration: Duration(microseconds: 30), length: 4, vsync: this);
    _bottomTabController.index = index;
    _bottomTabController.addListener(() {
      Navigator.pushNamed(
          context, bottomTabs[_bottomTabController.index] ?? "/");
    });
    print(_bottomTabController.index);
  }

  @override
  void dispose() {
    _bottomTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            indicator: BottomRoundedIndicator(
                color: Color.fromARGB(255, 27, 114, 254)),
            controller: _bottomTabController,
            tabs: [
              Tab(
                icon: SvgPicture.asset(
                  _bottomTabController.index == 0
                      ? callFillAsset
                      : callOutlineAsset,
                ),
                text: 'call',
              ),
              Tab(
                icon: SvgPicture.asset(
                  _bottomTabController.index == 1
                      ? bubbleFillAsset
                      : bubbleOutlineAsset,
                ),
                text: "Message",
              ),
              Tab(
                icon: SvgPicture.asset(_bottomTabController.index == 2
                    ? contactFillAsset
                    : contactOutlineAsset),
                text: "Contacts",
              ),
              Tab(
                icon: SvgPicture.asset(_bottomTabController.index == 3
                    ? settingsFillAsset
                    : settingsOutlineAsset),
                text: "Settings",
              )
            ]),
      ),
    );
  }
}
