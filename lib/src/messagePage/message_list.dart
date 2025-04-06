import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:linphone/src/classes/message.dart';

class MessageListView extends StatelessWidget {
  const MessageListView({
    required TabController tabController,
    required this.messages,
  }) : _tabController = tabController;

  final TabController _tabController;
  final (List<MessageDto>, List<MessageDto>, List<MessageDto>) messages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TabBarView(controller: _tabController, children: [
        Tab(child: messageItemBuilder(messages: messages.$1)),
        Tab(child: messageItemBuilder(messages: messages.$2)),
        Tab(child: messageItemBuilder(messages: messages.$3)),
      ]),
    );
  }
}

class messageItemBuilder extends StatelessWidget {
  const messageItemBuilder({
    required this.messages,
  });

  final List<MessageDto> messages;
  final String pinAsset = "assets/images/pin.svg";
  @override
  Widget build(BuildContext context) {
    return GroupedListView(
      elements: messages,
      itemExtent: 40,
      order: GroupedListOrder.DESC,
      groupHeaderBuilder: (MessageDto msg) => Text(
        msg.dateSend.day == DateTime.now().day
            ? "Today"
            : msg.dateSend.day == DateTime.now().subtract(Duration(days: 1)).day
                ? "Yesterday"
                : DateFormat('d, MMM, y').format(msg.dateSend),
        style: TextStyle(
            fontFamily: "inter", fontSize: 8, fontWeight: FontWeight.w400),
      ),
      groupBy: (MessageDto msg) =>
          DateFormat('yyyy-MM-dd').format(msg.dateSend),
      itemBuilder: (context, MessageDto item) => Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            Row(children: [
              Container(
                width: 32,
                height: 32,
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(247, 247, 247, 1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        width: 0.2, color: Color.fromRGBO(177, 177, 177, 1))),
                child: Center(
                  child: Text(item.peer.name[0],
                      style: TextStyle(
                          color: Color.fromRGBO(27, 115, 254, 0.7),
                          fontWeight: FontWeight.w500,
                          fontSize: 13)),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.peer.name),
                  Text(
                    item.content,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Color.fromRGBO(96, 96, 96, 1),
                        fontSize: 8,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
              Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(children: [
                  Text(
                    DateFormat("jm").format(item.dateSend),
                    style: TextStyle(fontSize: 8),
                  )
                ]),
                item.isPinned
                    ? SvgPicture.asset(
                        pinAsset,
                        fit: BoxFit.cover,
                        width: 12,
                        height: 12,
                      )
                    : SizedBox.shrink()
              ]),
            ]),
          ],
        ),
      ),
    );
  }
}
