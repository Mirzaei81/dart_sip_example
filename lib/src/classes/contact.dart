class Contact {
  final String name;
  final String imgPath;
  final String phoneNumber;
  Map<String, Object?> toMap() {
    return {"name": name, "imgPath": imgPath, "phoneNumber": phoneNumber};
  }

  Contact(
      {required this.name, required this.phoneNumber, required this.imgPath});
}
