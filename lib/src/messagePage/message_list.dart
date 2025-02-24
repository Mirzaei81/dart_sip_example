import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class MessageListView extends StatelessWidget {
  const MessageListView({
    super.key,
    required TabController tabController,
    required this.messages,
  }) : _tabController = tabController;

  final TabController _tabController;
  final List<Map<String, dynamic>> messages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TabBarView(controller: _tabController, children: [
        Tab(child: messageItemBuilder(messages: messages)),
        Tab(child: messageItemBuilder(messages: messages)),
        Tab(child: messageItemBuilder(messages: messages)),
      ]),
    );
  }
}

class messageItemBuilder extends StatelessWidget {
  const messageItemBuilder({
    super.key,
    required this.messages,
  });

  final List<Map<String, dynamic>> messages;
  final String pinAsset = "assets/images/pin.svg";
  @override
  Widget build(BuildContext context) {
    return GroupedListView(
      elements: messages,
      itemExtent: 37,
      order: GroupedListOrder.DESC,
      groupHeaderBuilder: (Map<String, dynamic> call) => Text(
        call['date'].day == DateTime.now().day
            ? "Today"
            : call['date'].day == DateTime.now().subtract(Duration(days: 1)).day
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
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(children: [
                  Text(
                    DateFormat("jm").format(item["date"]),
                    style: TextStyle(fontSize: 8),
                  )
                ]),
                SvgPicture.asset(
                  pinAsset,
                  fit: BoxFit.cover,
                  width: 12,
                  height: 12,
                ),
              ]),
            ]),
          ),
          if (!item["is_last"])
            Divider(
              height: 1,
            ),
        ],
      ),
    );
  }
}
