
import 'package:dart_sip_ua_example/src/widgets/tab_builder.dart';
import 'package:flutter/material.dart';

class topNavigation extends StatelessWidget {
  const topNavigation({
    super.key,
    required TabController tabController,
    required int activeIndex,
  }) : _tabController = tabController, _activeIndex = activeIndex;

  final TabController _tabController;
  final int _activeIndex;

  @override
  Widget build(BuildContext context) {
    return TabBar(
        labelPadding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicatorPadding: EdgeInsets.only(
            top: 7, bottom: 7, right: -7, left: -7),
        labelColor: Color(0xf7f7f7f7),
        unselectedLabelColor: Color(0xB1B1B1),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color.fromARGB(255, 27, 114, 254),
        ),
        controller: _tabController,
        tabs: <Widget>[
          Tab(child: buildTab("All", 10, _activeIndex == 0)),
          Tab(child: buildTab("Income", 10, _activeIndex == 1)),
          Tab(child: buildTab("Outcome", 5, _activeIndex == 2)),
          Tab(child: buildTab("Missed", 2, _activeIndex == 3)),
        ]);
  }
}