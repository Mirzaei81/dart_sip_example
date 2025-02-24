class CallRecord {
  final String name;
  final String avatarPath;
  final DateTime date;
  final bool incoming;
  final String calleNumber;
  final String recordPath;

  CallRecord(
      {required this.name,
      required this.date,
      required this.incoming,
      required this.calleNumber,
      required this.avatarPath,
      required this.recordPath});
}
