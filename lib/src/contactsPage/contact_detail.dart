import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linphone/src/classes/contact.dart';
import 'package:linphone/src/classes/db.dart';
import 'package:share_plus/share_plus.dart';

class ContactDetailPage extends StatefulWidget {
  const ContactDetailPage(
    this.id,
  );

  final int id;
  @override
  _ContactListViewState createState() => _ContactListViewState(id);
}

class _ContactListViewState extends State<ContactDetailPage> {
  Contact? contact;
  int id;
  _ContactListViewState(this.id);
  @override
  void initState() {
    DbService.getContactById(id).then((c) => {
          print(c),
          setState(() {
            contact = c;
          })
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const String userAsset = "assets/images/user.svg";
    final String callAsset = "assets/images/call_fill.svg";
    final String bubbleAsset = "assets/images/bubble_fill.svg";
    final String trashAsset = "assets/images/trash.svg";
    final String editAsset = "assets/images/edit.svg";

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 27, 114, 254),
      appBar: AppBar(
        actionsPadding: EdgeInsets.all(20),
        toolbarHeight: 80,
        leadingWidth: 161,
        automaticallyImplyLeading: true,
        backgroundColor: Color.fromARGB(255, 27, 114, 254),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  size: 24,
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Contact Deatil",
                style: TextStyle(color: Colors.white, fontSize: 16),
              )
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xf7f7f7f7),
                borderRadius: BorderRadiusDirectional.only(
                    topEnd: Radius.circular(24), topStart: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child:
                              (contact != null && contact!.imgPath.isNotEmpty)
                                  ? Image.file(File(contact!.imgPath))
                                  : SvgPicture.asset(
                                      userAsset,
                                      width: 64,
                                      height: 64,
                                      colorFilter: ColorFilter.mode(
                                          Color.fromRGBO(27, 115, 254, 1),
                                          BlendMode.srcIn),
                                    ),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        contact != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    contact!.name,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        contact!.phoneNumber,
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      ),
                                      SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(
                                              text: contact!.phoneNumber));
                                        },
                                        child: Icon(
                                          Icons.content_copy,
                                          size: 16,
                                          color:
                                              Color.fromRGBO(27, 115, 254, 1),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            : SizedBox.shrink(),
                        Spacer(),
                        GestureDetector(
                          onTap: () => SharePlus.instance
                              .share(ShareParams(text: contact!.phoneNumber)),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.share,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, "/outgoing",
                              arguments: contact!.phoneNumber),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color.fromRGBO(27, 115, 254, 1)),
                            child: SvgPicture.asset(
                              callAsset,
                              colorFilter: ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, "/chat",
                              arguments: contact!.id),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color.fromRGBO(27, 115, 254, 1)),
                            child: SvgPicture.asset(
                              bubbleAsset,
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                            ),
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/",
                                arguments: contact!.id);
                          },
                          child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white),
                              child: SvgPicture.asset(editAsset,
                                  width: 16,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                      Color.fromRGBO(27, 115, 254, 1),
                                      BlendMode.srcIn))),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            DbService.removeContact(id);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            child: SvgPicture.asset(
                              trashAsset,
                              width: 16,
                              height: 16,
                              colorFilter:
                                  ColorFilter.mode(Colors.red, BlendMode.srcIn),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Mobile",
                              style: TextStyle(
                                  fontSize: 8, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Text(
                                  contact!.phoneNumber,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                        text: contact!.phoneNumber));
                                  },
                                  child: Icon(
                                    Icons.content_copy,
                                    size: 16,
                                    color: Color.fromRGBO(27, 115, 254, 1),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, "/outgoing",
                              arguments: contact!.phoneNumber),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            child: SvgPicture.asset(
                              callAsset,
                              colorFilter: ColorFilter.mode(
                                  Color.fromRGBO(27, 115, 254, 1),
                                  BlendMode.srcIn),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/chat",
                                arguments: contact!.id);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            child: SvgPicture.asset(
                              bubbleAsset,
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                  Color.fromRGBO(27, 115, 254, 1),
                                  BlendMode.srcIn),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}
