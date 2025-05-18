import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linphone/src/widgets/bubble.dart';

class NavActions extends StatelessWidget {
  const NavActions(
      {super.key,
      required TextEditingController searchbarTextConteroller,
      required this.messages,
      required this.onTap})
      : _searchbarTextConteroller = searchbarTextConteroller;
  final PopupMenuItemSelected<String> onTap;
  final List<Map<String, String>> messages;
  final String bellAsset = "assets/images/Bellsvg.svg";
  final String searchAsset = "assets/images/search.svg";
  final TextEditingController _searchbarTextConteroller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PopupMenuButton<String>(
          offset: Offset(32, 32),
          color: Colors.white,
          surfaceTintColor: Colors.white,
          icon: Badge(
            offset: Offset(7, -7),
            label: Text(messages.length.toString()),
            child: SvgPicture.asset(
              bellAsset,
              width: 16,
              height: 16,
            ),
          ),
          shape: ChatBubble(
              color: Colors.white, alignment: Alignment.topLeft, pos: 0.6),
          onSelected: onTap,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            for (var iter in messages)
              PopupMenuItem<String>(
                value: iter.keys.toString(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        iter.values
                            .toString()
                            .replaceAllMapped(RegExp(r"\(|\)"), (m) => ""),
                        style: TextStyle(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                    Divider(
                      color: Color.fromRGBO(27, 115, 254, 1),
                      thickness: 1,
                    )
                  ],
                ),
                textStyle:
                    TextStyle(backgroundColor: Colors.white, fontSize: 6),
              ),
          ],
        ),
        SizedBox(
          width: 10,
        ),
        PopupMenuButton<String>(
          offset: Offset(32, 32),
          color: Colors.white,
          icon: SvgPicture.asset(
            searchAsset,
            width: 16,
            height: 16,
          ),
          shape: ChatBubble(
              color: Colors.white, alignment: Alignment.topLeft, pos: 0.8),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'Action1',
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: TextField(
                controller: _searchbarTextConteroller,
                keyboardType: TextInputType.text,
                autocorrect: false,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    filled: false,
                    isCollapsed: true,
                    hintText: "Search ...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 10,
                    )),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
