import 'dart:io';

import 'package:flutter_pjsip/flutter_pjsip.dart';
import 'package:linphone/src/classes/accounts.dart';
import 'package:linphone/src/classes/db.dart';
import 'package:linphone/src/classes/contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart' as flutter_contact;
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:flutter_svg/svg.dart';
import 'package:linphone/src/widgets/alert.dart';
import 'package:linphone/src/widgets/loading_overlay.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class RegisterWidget extends StatefulWidget {
  RegisterWidget();

  @override
  State<RegisterWidget> createState() => _MyRegisterWidget();
}

class _MyRegisterWidget extends State<RegisterWidget> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sipUriController = TextEditingController();
  final TextEditingController _authorizationUserController =
      TextEditingController();

  late SharedPreferencesWithCache _preferences;

  final FlutterPjsip pjsip = FlutterPjsip.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SharedPreferencesWithCache.create(
              cacheOptions: SharedPreferencesWithCacheOptions())
          .then((perf) {
        _preferences = perf;
      });
      _loadSettings();
    });
  }

  void importContacts() async {
    if (await flutter_contacts.FlutterContacts.requestPermission()) {
      List<flutter_contact.Contact> contacts =
          await flutter_contacts.FlutterContacts.getContacts();

      for (var contact in contacts) {
        File? f;
        var photo = contact.photo;
        if (photo != null) {
          f = await File(
                  "${contact.displayName}-${DateTime.now().toString()}.png")
              .writeAsBytes(photo);
        }
        DbService.insertContacts(Contact(
            name: contact.displayName,
            phoneNumber: contact.phones[0].number,
            imgPath: f != null ? f.path : ""));
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _sipUriController.dispose();
    _authorizationUserController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    _saveSettings();
  }

  void _loadSettings() async {
    List<Accounts> accounts = await DbService.listAcc();
    _sipUriController.text = accounts[0].uri;
    _passwordController.text = accounts[0].password;
    _authorizationUserController.text = accounts[0].username;
  }

  Future<void> _saveSettings() async {
    await _preferences.setString(
        'display_name', _authorizationUserController.text);
    await DbService.insertAcc(Accounts(
        id: 0,
        uri: _sipUriController.text,
        username: _authorizationUserController.text,
        password: _passwordController.text));
    return;
  }

  void registrationStateChanged(bool State) {
    context.loaderOverlay.hide();
    if (State) {
      Navigator.pushNamed(context, "/");
    } else {
      alert(context, "Somthing went wrong on register",
          "Couldn't register to server contact support");
    }
  }

  void _register(BuildContext context) {
    context.loaderOverlay.show(
        widgetBuilder: (progress) =>
            ConnectingOverlay(progress ?? "", "Connecting..."));
    _saveSettings().then((_) {
      pjsip.pjsipInit(DbService.dbPath).then((v) => {
            if (!v && kDebugMode)
              {
                alert(context, "Internal Error",
                    "Somthing went wrong while trying to initlize sdk")
              }
          });
      pjsip
          .pjsipLogin(
              username: _authorizationUserController.text,
              password: _passwordController.text,
              ip: _sipUriController.text,
              port: "5060")
          .then(registrationStateChanged);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color? textFieldFill =
        Theme.of(context).buttonTheme.colorScheme?.surfaceContainerLowest;

    OutlineInputBorder border = OutlineInputBorder(
      borderSide:
          const BorderSide(color: Color.fromRGBO(204, 204, 204, 1), width: 1),
      borderRadius: BorderRadius.circular(12),
    );
    const String logo = "assets/images/logo.png";
    const String topRight = "assets/images/topRight.svg";
    const String botLeft = "assets/images/bottomLeft.svg";
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text("LINOTIK V1.0",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ),
          SvgPicture.asset(
            topRight,
            alignment: Alignment.topCenter,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SvgPicture.asset(
              botLeft,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(logo),
                  Text("Sip Register",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  Text(
                    "Please fill in the below feilds",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 52,
                  ),
                  Material(
                    shadowColor: Color.fromRGBO(0, 0, 0, 0.07),
                    elevation: 10,
                    child: TextFormField(
                      controller: _sipUriController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: textFieldFill,
                        hintText: "Server address",
                        border: border,
                        enabledBorder: border,
                        focusedBorder: border,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Material(
                    shadowColor: Color.fromRGBO(0, 0, 0, 0.07),
                    elevation: 10,
                    child: TextFormField(
                      controller: _authorizationUserController,
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: textFieldFill,
                          border: border,
                          enabledBorder: border,
                          focusedBorder: border,
                          hintText: "Username"),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Material(
                    elevation: 10,
                    shadowColor: Color.fromRGBO(0, 0, 0, 0.07),
                    child: TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: textFieldFill,
                        border: border,
                        enabledBorder: border,
                        focusedBorder: border,
                        hintText: "Password",
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      print("registering");
                      _register(context);
                    },
                    child: Text(
                      "Register",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: WidgetStateColor.resolveWith(
                            (states) => Color.fromRGBO(27, 115, 254, 1))),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
