import 'package:linphone/src/classes/accounts.dart';
import 'package:linphone/src/classes/db.dart';
import 'package:flutter/material.dart';
import 'package:linphone/src/widgets/bottomTabNavigator.dart';
import 'package:sqflite/sqflite.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage();

  @override
  State<StatefulWidget> createState() => SettingsWidget();
}

class SettingsWidget extends State<SettingsPage> {
  List<Accounts> _accounts = List<Accounts>.empty();
  @override
  void initState() {
    DbService.listAcc().then((acc) {
      setState(() {
        _accounts = acc;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      bottomNavigationBar: BottomNavBar(3),
      backgroundColor: Color.fromARGB(255, 27, 114, 254),
      appBar: AppBar(
        actionsPadding: EdgeInsets.all(20),
        automaticallyImplyLeading: true,
        toolbarHeight: 69,
        backgroundColor: Color.fromARGB(255, 27, 114, 254),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 260,
            width: 260,
            alignment: Alignment.center, // <---- The magic
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        title: Builder(builder: (context) {
          return Column(
            children: [
              Text('Accounts',
                  style: TextStyle(color: Color(0xf7f7f7f7), fontSize: 16)),
            ],
          );
        }),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, "/register"),
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xf7f7f7f7),
          borderRadius: BorderRadiusDirectional.only(
              topEnd: Radius.circular(24), topStart: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ListView.builder(
              itemExtent: 50,
              itemCount: _accounts.length,
              itemBuilder: (context, idx) {
                Accounts item = _accounts[idx];
                return Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    (Row(children: [
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
                          child: Text(item.username[0],
                              style: TextStyle(
                                  color: Color.fromRGBO(27, 115, 254, 0.7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13)),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.username),
                            Text(
                              item.password,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: Color.fromRGBO(96, 96, 96, 1),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: 52,
                        height: 10,
                        child: Switch(
                            trackColor: WidgetStatePropertyAll(Colors.white),
                            thumbColor: WidgetStateColor.resolveWith((state) =>
                                state.contains(WidgetState.selected)
                                    ? Color.fromRGBO(27, 115, 254, 0.7)
                                    : Colors.blueGrey),
                            value: item.active,
                            onChanged: (a) => {
                                  print(a),
                                  setState(
                                    () {
                                      _accounts
                                          .where((acc) => acc.id == item.id)
                                          .forEach((acc) => acc.active = a);
                                    },
                                  ),
                                  DbService.activeAcc(item.id, a),
                                }),
                      ),
                    ])),
                    SizedBox(
                      height: 7,
                    ),
                    idx != _accounts.length - 1
                        ? Divider(
                            height: 1,
                            color: Colors.grey,
                          )
                        : SizedBox.shrink()
                  ],
                );
              }),
        ),
      ),
    ));
  }
}
