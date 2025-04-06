import 'package:linphone/src/classes/call_record.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

class ContactListView extends StatelessWidget {
  const ContactListView({
    required TabController tabController,
    required this.messages,
  }) : _tabController = tabController;

  final TabController _tabController;
  final List<CallRecord> messages;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TabBarView(controller: _tabController, children: [
        Tab(child: ContactItemBuilder(messages: messages)),
        Tab(child: ContactItemBuilder(messages: List.empty())),
      ]),
    );
  }
}

class ContactItemBuilder extends StatelessWidget {
  const ContactItemBuilder({
    required this.messages,
  });

  final List<CallRecord> messages;
  final String pinAsset = "assets/images/pin.svg";
  @override
  Widget build(BuildContext context) {
    return GroupedListView(
      elements: messages,
      itemExtent: 58,
      order: GroupedListOrder.DESC,
      groupHeaderBuilder: (CallRecord call) => Text(call.name[0].toUpperCase()),
      groupBy: (CallRecord call) => call.name[0],
      itemBuilder: (context, CallRecord item) => ExpansionTile(
        title: Text(
          item.name,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(children: [
                  Text(item.name),
                  Spacer(),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Row(children: [Text(item.name)]),
                  ]),
                ]),
              ),
            ],
          )
        ],
      ),
    );
  }
}
