import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:linphone/src/callPage/call_record_page.dart';
import 'package:linphone/src/classes/call_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:linphone/src/classes/db.dart';
import 'package:linphone/src/widgets/alert.dart';
import 'package:linphone/src/widgets/sliderThumb.dart';

class HistoryListView extends StatefulWidget {
  final List<CallRecord> calls;
  final TabController tabController;
  HistoryListView({key, required this.calls, required this.tabController})
      : super(key: key);

  @override
  State<HistoryListView> createState() =>
      HistoryListState(calls: calls, tabController: tabController);
}

class HistoryListState extends State<HistoryListView> {
  HistoryListState({
    required this.tabController,
    required this.calls,
  });

  final TabController tabController;
  final List<CallRecord> calls;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TabBarView(controller: tabController, children: [
        RecordBuilder(calls: calls),
        RecordBuilder(calls: calls.where((i) => i.incoming).toList()),
        RecordBuilder(calls: calls.where((i) => !i.incoming).toList()),
        RecordBuilder(calls: calls.where((i) => i.missed).toList()),
      ]),
    );
  }
}

class RecordBuilder extends StatefulWidget {
  final List<CallRecord> calls;
  RecordBuilder({required this.calls});
  @override
  State<RecordBuilder> createState() =>
      RecordState(calls, calls.isNotEmpty ? calls.last.id : 0);
}

class RecordState extends State<RecordBuilder> {
  final String micAsset = "assets/images/mic.svg";
  final String outgoingAsset = "assets/images/incoming.svg";
  final String incomingAsset = "assets/images/outgoing.svg";
  final String callAsset = "assets/images/call_fill.svg";
  final String infoAsset = "assets/images/info.svg";
  final String trashAsset = "assets/images/trash.svg";
  final String playAsset = "assets/images/play.svg";
  final String pauseAsset = "assets/images/pause.svg";

  late AudioPlayer player = AudioPlayer();

  final List<CallRecord> calls;
  final List<bool> selected;
  RecordState(this.calls, count) : selected = List.filled(count, false);

  Duration? _duration;
  Duration? _position;

  late PlayerState _playerState;

  @override
  void initState() {
    player = AudioPlayer();
    _playerState = player.state;
    player.setReleaseMode(ReleaseMode.stop);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GroupedListView(
      elements: calls,
      order: GroupedListOrder.DESC,
      groupHeaderBuilder: (CallRecord call) => Text(
        call.date.day == DateTime.now().day
            ? "Today"
            : call.date.day == DateTime.now().subtract(Duration(days: 1)).day
                ? "Yesterday"
                : DateFormat('d, MMM, y').format(call.date),
        style: TextStyle(fontFamily: "inter", fontSize: 8),
      ),
      groupBy: (CallRecord call) => DateFormat('yyyy-MM-dd').format(call.date),
      itemBuilder: (context, CallRecord item) => GestureDetector(
        onTap: () {
          File(item.recordPath).exists().then(
              (e) => {player.setSource(DeviceFileSource(item.recordPath))});
          setState(() {
            _playerState = PlayerState.paused;
            selected[item.id - 1] = !selected[item.id - 1];
          });
        },
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: AnimatedSwitcher(
            duration: Duration(seconds: 1),
            child: selected.isNotEmpty && selected[item.id - 1]
                ? Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(children: [
                              Column(children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 0.2,
                                    ),
                                  ),
                                  child: Center(
                                      child: Text(
                                    item.name[0].toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 27, 114, 254)),
                                  )),
                                )
                              ]),
                              Text(item.name),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Color.fromARGB(255, 27, 114, 254)),
                                child: SvgPicture.asset(
                                  infoAsset,
                                  width: 16,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                      Colors.white, BlendMode.srcIn),
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Color.fromARGB(255, 27, 114, 254)),
                                child: SvgPicture.asset(callAsset,
                                    width: 16,
                                    height: 16,
                                    colorFilter: ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn)),
                              ),
                            ])),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  item.incoming
                                      ? SvgPicture.asset(
                                          outgoingAsset,
                                          fit: BoxFit.cover,
                                          width: 14,
                                          height: 14,
                                        )
                                      : SvgPicture.asset(
                                          incomingAsset,
                                          fit: BoxFit.cover,
                                          width: 14,
                                          height: 14,
                                        ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.incoming ? "Outcome" : "Incoming",
                                        style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        (item.date.day == DateTime.now().day
                                                ? "Today  "
                                                : item.date.day ==
                                                        DateTime.now()
                                                            .subtract(Duration(
                                                                days: 1))
                                                            .day
                                                    ? "Yesterday  "
                                                    : DateFormat('d, MMM, y')
                                                        .format(item.date)) +
                                            DateFormat("jm").format(item.date),
                                        style: TextStyle(fontSize: 8),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Text(
                                    item.calleNumber,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              )
                            ]),
                        item.recordPath.isNotEmpty
                            ? FutureBuilder(
                                future: File(item.recordPath).exists(),
                                builder: (context, snapshot) => (snapshot
                                            .data ??
                                        false)
                                    ? Row(
                                        children: [
                                          _playerState == PlayerState.playing
                                              ? GestureDetector(
                                                  onTap: () => {
                                                        player.pause(),
                                                        setState(() {
                                                          _playerState =
                                                              PlayerState
                                                                  .paused;
                                                        })
                                                      },
                                                  child: SvgPicture.asset(
                                                    pauseAsset,
                                                    width: 24,
                                                    height: 24,
                                                  ))
                                              : GestureDetector(
                                                  onTap: () {
                                                    try {
                                                      player.resume();

                                                      setState(() {
                                                        _playerState =
                                                            PlayerState.playing;
                                                      });
                                                    } catch (e) {
                                                      alert(
                                                          context,
                                                          "Audio failure",
                                                          "Audio file is probebly corrupted");
                                                    }
                                                  },
                                                  child: Container(
                                                      margin:
                                                          EdgeInsets.all(16),
                                                      child: SvgPicture.asset(
                                                          playAsset))),
                                          Expanded(
                                            child: SliderTheme(
                                              data: SliderTheme.of(context)
                                                  .copyWith(
                                                activeTrackColor: Colors.grey,
                                                inactiveTrackColor:
                                                    Colors.grey[100],
                                                trackShape:
                                                    RoundedRectSliderTrackShape(),
                                                trackHeight: 4.0,
                                                thumbShape:
                                                    RRectSliderThumbShape(
                                                        enabledThumbRadius:
                                                            12.0,
                                                        disabledThumbRadius: 4),
                                                thumbColor: Color.fromARGB(
                                                    255, 27, 114, 254),
                                                overlayShape:
                                                    RoundSliderOverlayShape(
                                                        overlayRadius: 28.0),
                                                tickMarkShape:
                                                    RoundSliderTickMarkShape(),
                                                valueIndicatorShape:
                                                    PaddleSliderValueIndicatorShape(),
                                              ),
                                              child: Slider(
                                                value: (_position != null &&
                                                        _duration != null &&
                                                        _position!
                                                                .inMilliseconds >
                                                            0 &&
                                                        _position!
                                                                .inMilliseconds <
                                                            _duration!
                                                                .inMilliseconds)
                                                    ? _position!
                                                            .inMilliseconds /
                                                        _duration!
                                                            .inMilliseconds
                                                    : 0.0,
                                                min: 0,
                                                max: 100,
                                                onChanged: (value) {
                                                  setState(
                                                    () {
                                                      final duration =
                                                          _duration;
                                                      if (duration == null) {
                                                        return;
                                                      }
                                                      final position = value *
                                                          duration
                                                              .inMilliseconds;
                                                      player.seek(Duration(
                                                          milliseconds: position
                                                              .round()));
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                              onTap: () {
                                                DbService.removeCallRecord(
                                                    item.id);
                                                setState(() {
                                                  calls.remove(item);
                                                });
                                              },
                                              child:
                                                  SvgPicture.asset(trashAsset))
                                        ],
                                      )
                                    : SizedBox.shrink(),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(children: [
                            Text(item.name),
                            Spacer(),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SvgPicture.asset(
                                    micAsset,
                                    fit: BoxFit.cover,
                                    width: 12,
                                    height: 12,
                                  ),
                                  Row(
                                    children: [
                                      item.incoming
                                          ? SvgPicture.asset(
                                              incomingAsset,
                                              fit: BoxFit.cover,
                                              width: 14,
                                              height: 14,
                                            )
                                          : SvgPicture.asset(
                                              outgoingAsset,
                                              fit: BoxFit.cover,
                                              width: 14,
                                              height: 14,
                                            ),
                                      Text(
                                        DateFormat("jm").format(item.date),
                                        style: TextStyle(fontSize: 8),
                                      )
                                    ],
                                  ),
                                ]),
                          ]),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
