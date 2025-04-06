import 'package:linphone/src/widgets/tab_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TopNavContact extends StatelessWidget {
  const TopNavContact({
    required TabController tabController,
    required int activeIndex,
  })  : _tabController = tabController,
        _activeIndex = activeIndex;

  final TabController _tabController;
  final int _activeIndex;

  @override
  Widget build(BuildContext context) {
    const String searchAsset = "assets/images/search.svg";
    return Row(
      children: [
        Expanded(
          child: TabBar(
              labelPadding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicatorPadding:
                  EdgeInsets.only(top: 7, bottom: 7, right: -7, left: -7),
              labelColor: Color(0xf7f7f7f7),
              unselectedLabelColor: Color(0xB1B1B1),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.fromARGB(255, 27, 114, 254),
              ),
              controller: _tabController,
              tabs: <Widget>[
                Tab(child: buildTab("A-Z", 10, _activeIndex == 0)),
                Tab(child: buildTab("Z-A", 10, _activeIndex == 1)),
              ]),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () => {}, //TODO
            child: SvgPicture.asset(
              searchAsset,
              colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
        )
      ],
    );
  }
}
