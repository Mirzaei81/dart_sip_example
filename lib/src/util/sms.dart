import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:linphone/src/classes/db.dart';
import 'package:linphone/src/widgets/alert.dart';
import 'dart:convert';

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
        final String address = acc[0].uri;
        final headers = {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Cache-Control': 'max-age=0',
          'Connection': 'keep-alive',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Origin': 'http://$address',
          'Referer': 'http://$address/linotik_cgi/SMSCGI?15000',
          'Sec-GPC': '1',
          'Upgrade-Insecure-Requests': '1',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36',
          'Cookie':
              'language=en; loginname=admin; password=OV%5B2%5CFXo%5CI%5CmOFK4O%7CS%7BQVOzPlHj%5CoHlPIPoPFe%7BQVm%3F; OsVer=51.18.0.50; Series=; Product=TG100; defaultpwd=; current=sms; Backto=; TabIndex=0; TabIndexwithback=0; curUrl=15000',
        };

        final url = Uri.parse('http://$address/linotik_cgi/SMSCGI?15000');
        try {
          var res = await http.get(
            url,
            headers: headers,
          );
          var status = res.statusCode;
          print("$status");
        } catch (except) {
          alert(context, "Connection Failure", "Failed to connect to server");
        }
        _socket = await Socket.connect(acc[0].uri, 5038);
        _socket!.listen(
          (data) => (print(utf8.decode(data))),
          onError: (e) => print(e),
          onDone: () => print("Done!"),
        );
        print("Action: Login\r\nUsername: apiuser\r\nSecret: apipass\r\n\r\n");
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
    print("sending a mesage to $dest ");
    print(
        "Action: smscommand\r\ncommand: gsm send sms 2 $dest \"$data\" $id\r\n\r\n");
    _socket!.write(
        "Action: smscommand\r\ncommand: gsm send sms 2 $dest \"$data\" $id\r\n\r\n");
    await _socket!.flush();
  }
}
