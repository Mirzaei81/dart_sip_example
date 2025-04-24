import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:linphone/src/classes/contact.dart';
import 'package:linphone/src/classes/db.dart';
import 'package:linphone/src/classes/message.dart';
import 'package:linphone/src/util/sms.dart';

class ChatPage extends StatefulWidget {
  final int peerId;
  ChatPage(this.peerId);
  @override
  State<StatefulWidget> createState() {
    return ChatState(peerId);
  }
}

class ChatState extends State<ChatPage> {
  final int peerId;
  ChatState(this.peerId);
  List<Message> msgs = List.empty();
  Contact? peer;

  late TextEditingController _massagesControler;

  final ScrollController _controller = ScrollController();

  bool isScrooling = true;
  final String pinAsset = "assets/images/pin.svg";

  void fetchData() async {
    var messages = await DbService.getMessagefromPeer(peerId);
    var peerC = await DbService.getContactById(peerId);
    setState(() {
      msgs = messages;
      peer = peerC;
    });
  }

  @override
  void initState() {
    super.initState();
    _massagesControler = TextEditingController();
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels != 0) {
          setState(() {
            isScrooling = false;
          });
        }
      } else {
        setState(() {
          isScrooling = true;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  void sendSMS() async {
    Message message = Message(
        isMine: true,
        recvId: peerId,
        content: _massagesControler.text,
        dateSend: DateTime.now(),
        isPinned: false,
        read: true);
    await DbService.insertMessages(message);
    msgs.add(message);
    _controller.jumpTo(_controller.position.maxScrollExtent);
    if (peer != null) {
      SmsHandler.send(_massagesControler.text, peer!.phoneNumber, message.id);
      setState(() {
        _massagesControler.text = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const String sendAsset = "assets/images/sent.svg";
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          actions: [
            PopupMenuButton(
              itemBuilder: (ctx) => [
                PopupMenuItem(
                    onTap: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text(
                              'Delete all contact messages',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            content: const Text(
                                'Are you sure you want to remove all this messages this'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => {
                                  DbService.removeMessages(peerId),
                                  Navigator.pop(context, 'Cancel'),
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 242, 65, 65),
                        ),
                        Text("Remove chat history")
                      ],
                    )),
                PopupMenuItem(
                    onTap: () => DbService.pinMessages(peerId),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          pinAsset,
                          width: 24,
                          height: 24,
                          //   colorFilter: ColorFilter.mode(
                          //       Colors.gray, BlendMode.srcIn),
                        ),
                        Text("Pin message")
                      ],
                    ))
              ],
              child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5)),
                  child: Icon(Icons.more_vert)),
            )
          ],
          title: peer != null
              ? Row(
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
                                color: Color.fromRGBO(177, 177, 177, 1))),
                        child: Center(
                          child: Text(peer!.name[0],
                              style: TextStyle(
                                  color: Color.fromRGBO(27, 115, 254, 0.7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13)),
                        )),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          peer!.name,
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        peer!.phoneNumber != peer!.name
                            ? Text(
                                "Mobile: ${peer!.phoneNumber}",
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(96, 96, 96, 1)),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    msgs.where((m) => m.isPinned == true).length == msgs.length
                        ? SvgPicture.asset(
                            pinAsset,
                            height: 16,
                            width: 16,
                          )
                        : SizedBox.shrink()
                  ],
                )
              : SizedBox.shrink()),
      floatingActionButton: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        reverseDuration: Duration(milliseconds: 300),
        child: isScrooling
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                      onTap: _scrollDown,
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color.fromRGBO(27, 115, 254, 1),
                          ),
                          margin: EdgeInsets.only(bottom: 48),
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                          )))
                ],
              )
            : SizedBox.shrink(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      body: Container(
        margin: EdgeInsets.only(bottom: 64),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(8),
          itemCount: msgs.length,
          controller: _controller,
          itemBuilder: (context, index) {
            Message message = msgs[index];
            return Container(
              width: double.infinity,
              child: Column(
                children: [
                  index == 0
                      ? Center(child: Text(_formatDate(message.dateSend)))
                      : msgs[index - 1].dateSend.day != message.dateSend.day
                          ? Center(child: Text(_formatDate(message.dateSend)))
                          : SizedBox.shrink(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: message.isMine
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: message.isMine
                        ? getMessageItem(message).reversed.toList()
                        : getMessageItem(message),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _massagesControler,
                keyboardType: TextInputType.text,
                autocorrect: false,
                autofocus: true,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintStyle: TextStyle(
                        fontSize: 13, color: Color.fromRGBO(177, 177, 177, 1)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(32)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                    hintText: 'Enter message',
                    filled: true,
                    fillColor: Color.fromRGBO(247, 247, 247, 1)),
              ),
            ),
            GestureDetector(
              onTap: () => sendSMS(),
              child: SvgPicture.asset(
                sendAsset,
                colorFilter: ColorFilter.mode(
                    Color.fromARGB(255, 27, 114, 254), BlendMode.srcIn),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour % 12}:${date.minute.toString().padLeft(2, '0')} '
        '${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _formatDate(DateTime date) {
    DateTime today = DateTime.now();
    return date.day == today.day
        ? "Today"
        : date.day == today.subtract(Duration(days: 1)).day
            ? "Yesterday"
            : date.month == today.month
                ? DateFormat('d, MMM').format(date)
                : DateFormat('d, MMM, y').format(date);
  }

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  List<Widget> getMessageItem(Message message) => [
        GestureDetector(
          onTap: () => {},
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isMine ? Colors.blue[500] : Colors.grey[300],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
                topLeft:
                    message.isMine ? Radius.circular(16) : Radius.circular(4),
                topRight:
                    message.isMine ? Radius.circular(4) : Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  softWrap: true,
                  maxLines: 10,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: message.isMine ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(
          _formatTime(message.dateSend),
          style: TextStyle(
            color: message.isMine ? Colors.white70 : Colors.black54,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        message.isPinned
            ? SvgPicture.asset(
                pinAsset,
                width: 12,
                height: 12,
              )
            : SizedBox.shrink()
      ];
}
