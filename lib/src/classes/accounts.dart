import 'dart:core';

class Accounts {
  final int id;
  final String username;
  final String uri;
  final String password;
  bool active;

  Accounts(
      {required this.id,
      required this.username,
      required this.uri,
      required this.active,
      required this.password});
  Map<String, Object?> toMap() {
    return {
      "username": username,
      "uri": uri,
      "password": password,
      "active": active ? 1 : 0
    };
  }

  static List<Accounts> fromMaps(List<Map<String, Object?>> accObjects) {
    List<Accounts> accountsList = List<Accounts>.empty().toList();
    for (var acc in accObjects) {
      accountsList.add(Accounts(
          id: acc["id"] as int,
          username: acc["username"] as String,
          password: acc["password"] as String,
          active: acc["active"] as int == 1,
          uri: acc["uri"] as String));
    }
    return accountsList;
  }
}
