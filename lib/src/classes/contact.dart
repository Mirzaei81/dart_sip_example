class Contact {
  final int? id;
  final String name;
  final String imgPath;
  final String phoneNumber;
  final DateTime date;
  Map<String, Object?> toMap() {
    return {
      "name": name,
      "img_path": imgPath,
      "phone_number": phoneNumber,
      "date": date
    };
  }

  Contact(
      {this.id,
      required this.name,
      required this.phoneNumber,
      required this.imgPath,
      required this.date});
}
