class CallRecord {
  final String name;
  final String avatarPath;
  final DateTime date;
  final bool incoming;
  final bool missed;
  final String calleNumber;
  final String recordPath;

  CallRecord(
      {required this.name,
      required this.date,
      required this.incoming,
      required this.missed,
      required this.calleNumber,
      required this.avatarPath,
      required this.recordPath});
  Map<String, Object?> toMap() {
    return {
      "name": name,
      "avatarPath": avatarPath,
      "date": date,
      "incoming": incoming,
      "missed": missed,
      "calleNumber": calleNumber,
      "recordPath": recordPath,
    };
  }
}
