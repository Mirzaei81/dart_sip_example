import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

Widget buildTab(String label, int count, bool isSelected) {
  return Tab(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: isSelected? [
    Text(
      label,
      style: TextStyle(
        color: Color(0xf7f7f7f7),
        fontWeight: FontWeight.bold,
      ),
    ),
    Spacer(),
    Padding(
      padding: const EdgeInsets.only(left: 5),
      child: badges.Badge(
        badgeContent: Text(
          count.toString(),
          style: TextStyle(color: Colors.black, fontSize: 10),
        ),
        badgeStyle: badges.BadgeStyle(
          badgeColor: Color(0xf7f7f7f7),
          padding: EdgeInsets.all(6),
        ),
      ),
    ),
  ]: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
