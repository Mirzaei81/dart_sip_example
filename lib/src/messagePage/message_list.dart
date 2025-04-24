import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:linphone/src/classes/message.dart';

class MessageListView extends StatelessWidget {
  const MessageListView({
    required TabController tabController,
    required this.messages,
    required this.onTap,
  }) : _tabController = tabController;

  final TabController _tabController;
  final List<MessageDto> messages;
  final void Function(MessageDto item) onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TabBarView(controller: _tabController, children: [
        Tab(child: MessageItemBuilder(messages: messages, onTap: onTap)),
        Tab(
            child: MessageItemBuilder(
                messages: messages.where((m) => !m.read).toList(),
                onTap: onTap)),
        Tab(
            child: MessageItemBuilder(
                messages: messages.where((m) => m.isPinned).toList(),
                onTap: onTap)),
      ]),
    );
  }
}

class MessageItemBuilder extends StatelessWidget {
  const MessageItemBuilder({
    required this.messages,
    required this.onTap,
  });
  final void Function(MessageDto item) onTap;
  final List<MessageDto> messages;
  final String pinAsset = "assets/images/pin.svg";
  @override
  Widget build(BuildContext context) {
    return GroupedListView(
      elements: messages,
      order: GroupedListOrder.DESC,
      groupHeaderBuilder: (MessageDto msg) => Text(
        msg.dateSend.day == DateTime.now().day
            ? "Today"
            : msg.dateSend.day == DateTime.now().subtract(Duration(days: 1)).day
                ? "Yesterday"
                : DateFormat('d, MMM, yyyy').format(msg.dateSend),
        style: TextStyle(
            fontFamily: "inter", fontSize: 8, fontWeight: FontWeight.w400),
      ),
      groupBy: (MessageDto msg) =>
          DateFormat('yyyy-MM-dd').format(msg.dateSend),
      itemBuilder: (context, MessageDto item) => GestureDetector(
        onTap: () => onTap(item),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.transparent)),
          width: double.infinity,
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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.peer.name),
                      Text(
                        item.content,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            color: Color.fromRGBO(96, 96, 96, 1),
                            fontSize: 8,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
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
      ),
    );
  }
}
