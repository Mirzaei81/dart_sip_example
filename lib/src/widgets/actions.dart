import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linphone/src/widgets/bubble.dart';

class NavActions extends StatelessWidget {
  const NavActions({
    super.key,
    required this.missedCount,
    required TextEditingController searchbarTextConteroller,
  }) : _searchbarTextConteroller = searchbarTextConteroller;

  final int missedCount;
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
            label: Text(missedCount.toString()),
            child: SvgPicture.asset(
              bellAsset,
              width: 16,
              height: 16,
            ),
          ),
          shape: ChatBubble(color: Colors.white, alignment: Alignment.topLeft),
          onSelected: (String result) {
            // Handle the selected action
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Action1',
              child: Text('Action 1'),
              textStyle: TextStyle(backgroundColor: Colors.white),
            ),
            const PopupMenuItem<String>(
              value: 'Action2',
              child: Text('Action 2'),
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
          shape: ChatBubble(color: Colors.white, alignment: Alignment.topLeft),
          onSelected: (String result) {
            // Handle the selected action
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'Action1',
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
