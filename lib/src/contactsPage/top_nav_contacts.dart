import 'package:linphone/src/widgets/tab_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TopNavContact extends StatefulWidget {
  const TopNavContact(
      {required this.tabController,
      required this.activeIndex,
      required this.counts,
      required this.searchContactController});

  final TabController tabController;
  final int activeIndex;
  final int counts;

  final TextEditingController searchContactController;

  @override
  _TopNavContactState createState() =>
      _TopNavContactState(searchContactController);
}

class _TopNavContactState extends State<TopNavContact> {
  bool searchClicked = false;
  _TopNavContactState(this._searchContactController);
  final _searchContactController;
  @override
  Widget build(BuildContext context) {
    const String searchAsset = "assets/images/search.svg";
    return Row(
      children: [
        Expanded(
          child: TabBar(
              labelPadding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicatorPadding:
                  EdgeInsets.only(top: 7, bottom: 7, right: -7, left: -7),
              labelColor: Color(0xf7f7f7f7),
              unselectedLabelColor: Color(0xB1B1B1),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.fromARGB(255, 27, 114, 254),
              ),
              controller: widget.tabController,
              tabs: <Widget>[
                Tab(
                    child: buildTab(
                        "A-Z", widget.counts, widget.activeIndex == 0)),
                Tab(
                    child: buildTab(
                        "Z-A", widget.counts, widget.activeIndex == 1)),
              ]),
        ),
        Spacer(),
        searchClicked
            ? Container(
                width: 80,
                height: 15,
                child: TextField(
                  controller: _searchContactController,
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      filled: false,
                      isCollapsed: true,
                      hintText: "Search ...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        fontSize: 14,
                      )),
                ),
              )
            : SizedBox.shrink(),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: TapRegion(
            onTapOutside: (_) => {
              setState(() {
                searchClicked = false;
              })
            },
            onTapInside: (_) => {
              setState(() {
                searchClicked = true;
              })
            },
            child: SvgPicture.asset(
              searchAsset,
              colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
        )
      ],
    );
  }
}
