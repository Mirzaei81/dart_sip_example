import 'package:linphone/src/classes/contact.dart';

class Message {
  int id = 0;
  final String content;
  final DateTime dateSend;
  final int recvId;
  final bool isMine;
  bool read;
  bool isPinned;
  Map<String, Object?> toMap() {
    return {
      "content": content,
      "dateSend": dateSend.millisecondsSinceEpoch,
      "peerId": recvId,
      "isPinned": isPinned ? 1 : 0,
      "read": read ? 1 : 0,
      "isMine": isMine ? 1 : 0
    };
  }

  Message(
      {this.id = 0,
      required this.isMine,
      required this.recvId,
      required this.content,
      required this.dateSend,
      required this.isPinned,
      required this.read});
}

class MessageDto {
  final Contact peer;
  String content;
  final DateTime dateSend;
  bool isPinned;
  bool read;
  MessageDto(
      {required this.content,
      required this.read,
      required this.dateSend,
      required this.isPinned,
      required this.peer});
}
