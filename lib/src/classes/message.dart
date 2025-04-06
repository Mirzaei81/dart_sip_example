import 'package:linphone/src/classes/contact.dart';

class Message {
  final String content;
  final DateTime dateSend;
  final int recvId;
  final bool read;
  final bool isPinned;
  Map<String, Object?> toMap() {
    return {
      "content": content,
      "dateSend": dateSend,
      "peerId": recvId,
      "isPinned": isPinned,
      "read": read
    };
  }

  Message(
      {required this.recvId,
      required this.content,
      required this.dateSend,
      required this.isPinned,
      required this.read});
}

class MessageDto {
  final Contact peer;
  final String content;
  final DateTime dateSend;
  final bool isPinned;
  final bool read;
  MessageDto(
      {required this.content,
      required this.read,
      required this.dateSend,
      required this.isPinned,
      required this.peer});
}
