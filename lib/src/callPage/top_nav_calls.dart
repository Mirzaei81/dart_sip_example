import 'package:linphone/src/classes/call_record.dart';
import 'package:linphone/src/widgets/tab_builder.dart';
import 'package:flutter/material.dart';

List<int> countCalls(List<CallRecord>? records) {
  var counts = List<int>.filled(4, 0, growable: false);
  if (records == null) return counts;
  for (var record in records) {
    counts[0] += 1;
    if (record.incoming) {
      counts[1] += 1;
    } else {
      counts[2] += 1;
    }
    if (record.missed) counts[3] += 1;
  }

  return counts;
}

class TopNavigation extends StatelessWidget {
  const TopNavigation(
      {required TabController tabController,
      required int activeIndex,
      required List<int> counts})
      : _tabController = tabController,
        _counts = counts,
        _activeIndex = activeIndex;

  final List<int> _counts;
  final TabController _tabController;
  final int _activeIndex;

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
          Tab(child: buildTab("All", _counts[0], _activeIndex == 0)),
          Tab(child: buildTab("Income", _counts[1], _activeIndex == 1)),
          Tab(child: buildTab("Outcome", _counts[2], _activeIndex == 2)),
          Tab(child: buildTab("Missed", _counts[3], _activeIndex == 3)),
        ]);
  }
}
