import 'package:linphone/src/widgets/tab_builder.dart';
import 'package:flutter/material.dart';

class TopNavMessage extends StatelessWidget {
  TopNavMessage(
    this._tabController,
    this._activeIndex,
    this.all,
    this.unread,
    this.pinned,
  );
  late final TabController _tabController;
  late final int _activeIndex;
  late final int all;
  late final int pinned;
  late final int unread;

  @override
  Widget build(BuildContext context) {
    return TabBar(
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
          Tab(child: buildTab("All", all, _activeIndex == 0)),
          Tab(child: buildTab("Unread", unread, _activeIndex == 1)),
          Tab(child: buildTab("Pinned", pinned, _activeIndex == 2)),
        ]);
  }
}
