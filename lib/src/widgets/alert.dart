import 'package:flutter/material.dart';

void alert(BuildContext context, String title, String body) {
  showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
        );
      });
}
