import 'package:linphone/src/classes/call_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class HistoryListView extends StatelessWidget {
  const HistoryListView({
    required TabController tabController,
    required this.calls,
  }) : _tabController = tabController;

  final TabController _tabController;
  final List<CallRecord> calls;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TabBarView(controller: _tabController, children: [
        RecordBuilder(calls: calls),
        RecordBuilder(calls: calls.where((i) => i.incoming).toList()),
        RecordBuilder(calls: calls.where((i) => !i.incoming).toList()),
        RecordBuilder(calls: calls.where((i) => i.missed).toList()),
      ]),
    );
  }
}

class RecordBuilder extends StatelessWidget {
  final String micAsset = "assets/images/mic.svg";
  final String incomingAsset = "assets/images/incoming.svg";
  final String outgoingAsset = "assets/images/outgoing.svg";

  const RecordBuilder({
    required this.calls,
  });

  final List<CallRecord> calls;

  @override
  Widget build(BuildContext context) {
    return GroupedListView(
      elements: calls,
      itemExtent: 37,
      order: GroupedListOrder.DESC,
      groupHeaderBuilder: (CallRecord call) => Text(
        call.date.day == DateTime.now().day
            ? "Today"
            : call.date.day == DateTime.now().subtract(Duration(days: 1)).day
                ? "Yesterday"
                : DateFormat('d, MMM, y').format(call.date),
        style: TextStyle(fontFamily: "inter", fontSize: 8),
      ),
      groupBy: (CallRecord call) => DateFormat('yyyy-MM-dd').format(call.date),
      itemBuilder: (context, CallRecord item) => Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(children: [
                Text(item.name),
                Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  SvgPicture.asset(
                    micAsset,
                    fit: BoxFit.cover,
                    width: 12,
                    height: 12,
                  ),
                  Row(
                    children: [
                      item.incoming
                          ? SvgPicture.asset(
                              incomingAsset,
                              fit: BoxFit.cover,
                              width: 14,
                              height: 14,
                            )
                          : SvgPicture.asset(
                              outgoingAsset,
                              fit: BoxFit.cover,
                              width: 14,
                              height: 14,
                            ),
                      Text(
                        DateFormat("jm").format(item.date),
                        style: TextStyle(fontSize: 8),
                      )
                    ],
                  )
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
