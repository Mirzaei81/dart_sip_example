import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class HistoryListView extends StatelessWidget {
  const HistoryListView({
    super.key,
    required TabController tabController,
    required this.calls,
  }) : _tabController = tabController;

  final TabController _tabController;
  final List<Map<String, dynamic>> calls;

  @override
  Widget build(BuildContext context) {
    const String micAsset =      "assets/images/mic.svg";
    const String incomingAsset = "assets/images/incoming.svg";
    const String outgoingAsset = "assets/images/outgoing.svg";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TabBarView(controller: _tabController, children: [
        GroupedListView(
          elements: calls,
          itemExtent: 37,
          order: GroupedListOrder.DESC,
          groupHeaderBuilder: (Map<String, dynamic> call) => Text(
            call['date'].day == DateTime.now().day
                ? "Today"
                : call['date'].day ==
                        DateTime.now().subtract(Duration(days: 1)).day
                    ? "Yesterday"
                    : DateFormat('d, MMM, y').format(call['date']),
            style: TextStyle(fontFamily: "inter", fontSize: 8),
          ),
          groupBy: (Map<String, dynamic> call) =>
              DateFormat('yyyy-MM-dd').format(call["date"]),
          itemBuilder: (context, Map<String, dynamic> item) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(children: [
                  Text(item["name"]),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                    SvgPicture.asset(
                      micAsset,
                      fit: BoxFit.cover,
                      width: 12,
                      height: 12,
                    ),
                    Row(children: [
                    item["incoming"]?
                      SvgPicture.asset(
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
                        Text(DateFormat("jm").format(item["date"]),style: TextStyle(fontSize: 8),)
                    ],)
                  ]),
                ]),
              ),
              if (!item["is_last"])
                Divider(
                  height: 1,
                ),
            ],
          ),
        ),
        const Text("Hello"),
        const Text("Hello"),
        const Text("Hello"),
      ]),
    );
  }
}
