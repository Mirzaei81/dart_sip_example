import 'package:dart_sip_ua_example/src/classes/Contact.dart';

class conversation_history {
  final Contact recv;
  final List<message> messages;
  final bool isPinned;

  conversation_history(
      {required this.recv, required this.messages, required this.isPinned});
}

class message {
  final String content;
  final DateTime dateSend;
  final bool status;

  message({required this.content, required this.dateSend,required this.status});
}
