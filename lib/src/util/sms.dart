import 'dart:io';

import 'package:flutter/material.dart';
import 'package:linphone/src/classes/db.dart';
import 'package:linphone/src/widgets/alert.dart';

class SmsHandler {
  static SmsHandler? _instance;
  static Socket? _socket;
  // Private constructor
  SmsHandler._internal();
  // Singleton accessor
  factory SmsHandler() {
    _instance ??= SmsHandler._internal();
    return _instance!;
  }

  // Connect method called on first instantiation
  static Future<void> connect(BuildContext context) async {
    var acc = await DbService.listAcc();
    try {
      if (_socket == null) {
        _socket = await Socket.connect(acc[0].uri, 5038);
        _socket!.listen(
          (data) => print(String.fromCharCodes(data)),
          onError: (e) => print(e),
          onDone: () => print("Done!"),
        );
        _socket!.write(
            "Action: Login\r\nUsername: apiuser\r\nSecret: apipass\r\n\r\n");
        await _socket!.flush();
      } else {}
    } catch (e) {
      print(e);
      alert(context, "Fail", "Fiailure connecting to server");
    }
  }

  // Methods to be implemented by consumer
  static void send(String data, String dest, int id) async {
    _socket!.write(
        "Action: smscommand\r\ncommand: gsm send sms 2 $dest \"$data\" $id\r\n\r\n");
    await _socket!.flush();
  }
}
