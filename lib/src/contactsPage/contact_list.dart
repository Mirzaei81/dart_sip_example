import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:linphone/src/classes/contact.dart';

class ContactListView extends StatefulWidget {
  const ContactListView({
    key,
    required this.tabController,
    required this.contacts,
  }) : super(key: key);

  final TabController tabController;
  final List<Contact> contacts;

  @override
  _ContactListViewState createState() => _ContactListViewState();
}

class _ContactListViewState extends State<ContactListView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TabBarView(controller: widget.tabController, children: [
        Tab(
            child:
                ContactItemBuilder(messages: widget.contacts, reverse: false)),
        Tab(
            child:
                ContactItemBuilder(messages: widget.contacts, reverse: true)),
      ]),
    );
  }
}

class ContactItemBuilder extends StatefulWidget {
  ContactItemBuilder({
    required this.messages,
    required this.reverse,
  });

  final bool reverse;
  final List<Contact> messages;
  @override
  State<StatefulWidget> createState() =>
      ContactItemState(reverse: reverse, messages: messages);
}

class ContactItemState extends State<ContactItemBuilder> {
  ContactItemState({
    required this.messages,
    required this.reverse,
  });
  final bool reverse;
  final List<Contact> messages;
  final String pinAsset = "assets/images/pin.svg";
  late Map<int, bool> itemActive;
  @override
  void initState() {
    super.initState();
    Map<int, bool> tmpMap = Map();
    for (var m in messages) {
      tmpMap[m.id ?? 0] = false;
    }
    if (messages.isNotEmpty) {
      itemActive = tmpMap;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String callAsset = "assets/images/call_fill.svg";
    final String infoAsset = "assets/images/info.svg";
    const String messageAsset = "assets/images/bubble_fill.svg";
    return GroupedListView(
        elements: messages,
        order: reverse ? GroupedListOrder.DESC : GroupedListOrder.ASC,
        groupHeaderBuilder: (Contact call) => Text(call.name[0].toUpperCase()),
        groupBy: (Contact call) => call.name[0].toLowerCase(),
        itemBuilder: (context, Contact item) => GestureDetector(
              onTap: () => setState(() {
                itemActive[item.id ?? 0] = !(itemActive[item.id ?? 0] ?? true);
              }),
              child: Container(
                padding: EdgeInsets.only(bottom: 16, top: 16),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(16)),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: itemActive.isNotEmpty &&
                          (itemActive[item.id ?? 1] ?? false)
                      ? Container(
                          key: ValueKey<int>(0),
                          padding: EdgeInsets.all(8),
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(children: [
                                    Column(children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 0.2,
                                          ),
                                        ),
                                        child: Center(
                                            child: Text(
                                          item.name[0].toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 27, 114, 254)),
                                        )),
                                      )
                                    ]),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Text(item.name),
                                    Spacer(),
                                    item.name == item.phoneNumber
                                        ? SizedBox.shrink()
                                        : Text(item.phoneNumber),
                                  ])),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                        context, "/outgoing",
                                        arguments: item.phoneNumber),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Color.fromARGB(
                                              255, 27, 114, 254)),
                                      child: SvgPicture.asset(callAsset,
                                          width: 16,
                                          height: 16,
                                          colorFilter: ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                        context, "/chat",
                                        arguments: item.id),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Color.fromARGB(
                                              255, 27, 114, 254)),
                                      child: SvgPicture.asset(messageAsset,
                                          width: 16,
                                          height: 16,
                                          colorFilter: ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                        context, "/contact",
                                        arguments: item.id),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Color.fromARGB(
                                              255, 27, 114, 254)),
                                      child: SvgPicture.asset(
                                        infoAsset,
                                        width: 16,
                                        height: 16,
                                        colorFilter: ColorFilter.mode(
                                            Colors.white, BlendMode.srcIn),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      : Container(
                          key: ValueKey<int>(1),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(247, 247, 247, 1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        width: 0.2,
                                        color:
                                            Color.fromRGBO(177, 177, 177, 1))),
                                child: Center(
                                  child: Text(item.name[0],
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(27, 115, 254, 0.7),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13)),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name),
                                  Wrap(
                                    direction: Axis.vertical,
                                    spacing: 8.0,
                                    runSpacing: 6.0,
                                    children: [],
                                  )
                                ],
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                ),
              ),
            ));
  }
}
