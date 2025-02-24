import 'package:flutter/material.dart';

class DialPage extends StatefulWidget {
  final List<Map<String, dynamic>> contacts;
  const DialPage({
    super.key,
    required this.contacts,
  });
  @override
  State<StatefulWidget> createState() => NumPadWidget(contacts: contacts);
}

class NumPadWidget extends State<DialPage> {
  final List<Map<String, dynamic>> contacts;

  NumPadWidget({required this.contacts});
  String dialNumber = "";

  List<bool> activeDigits =
      List<bool>.generate(12, (i) => false, growable: false);
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
