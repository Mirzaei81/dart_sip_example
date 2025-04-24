import 'dart:io';

import 'package:intl/intl.dart';
import 'package:linphone/src/classes/accounts.dart';
import 'package:linphone/src/classes/call_record.dart';
import 'package:linphone/src/classes/contact.dart';
import 'package:linphone/src/classes/message.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  static late Database _db;

  factory DbService() {
    return _instance;
  }
  static String get dbPath {
    return _db.path;
  }

  DbService._internal();

  @override
  static String sToString() {
    return "DB:${_db.path}";
  }

  static Future<void> dispose() async {
    await _db.close();
  }

  static Future<void> pinMessage(int id) async {
    try {
      await _db.update("messages", {"isPinned": true},
          where: "id = ?",
          whereArgs: [id],
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> pinMessages(int id) async {
    try {
      await _db.update("messages", {"isPinned": true},
          where: "peerId = ?",
          whereArgs: [id],
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> seenMessage(int id) async {
    print("updating message with id : $id");
    try {
      await _db.update("messages", {"read": true},
          where: "peerId = ?",
          whereArgs: [id],
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> initdb() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isAndroid || Platform.isIOS) {
      final databasePath = await getDatabasesPath();
      final path = "$databasePath/linotik.db";
      _db = await openDatabase(path,
          version: 1, onCreate: _createDatabase, onConfigure: _onConfigure);
    }
  }

  static Future<List<Accounts>> listAcc() async {
    var query = await _db.query("accounts");
    return Accounts.fromMaps(query);
  }

  static Future<int> insertAcc(Accounts acc) async {
    return _db.insert("accounts", acc.toMap());
  }

  static Future<List<Map<String, Object?>>> listNames() async {
    return _db.rawQuery("SELECT name FROM sqlite_master WHERE type = 'table';");
  }

  static Future<Contact?> getContactById(int id) async {
    List<Map> map = await _db.query("person", where: "id= ?", whereArgs: [id]);
    if (map.isEmpty) {
      return null;
    }
    Contact c = Contact(
        id: map[0]["id"] ?? 0,
        name: map[0]["name"] ?? "",
        date: DateTime.fromMillisecondsSinceEpoch(
            map[0]["data"] ?? DateTime.now().millisecondsSinceEpoch),
        phoneNumber: map[0]["phone_number"],
        imgPath: map[0]["img_path"] ?? "");
    return c;
  }

  static Future<Contact?> getContact(String phone) async {
    List<Map> map = await _db
        .query("person", where: "phone_number = ?", whereArgs: [phone]);
    if (map.isEmpty) {
      return null;
    }
    Contact c = Contact(
        id: map[0]["id"] ?? 0,
        name: map[0]["name"] ?? "",
        date: DateTime.fromMillisecondsSinceEpoch(map[0]["data"]),
        phoneNumber: map[0]["phone_number"] ?? phone,
        imgPath: map[0]["img_path"] ?? "");
    return c;
  }

  static Future<List<CallRecord>> listRecords() async {
    final List<Map<String, Object?>> recordMaps = await _db.rawQuery('''
      select call_records.id,person.name,person.img_path,person.phone_number,call_records.date,call_records.incoming,call_records.record_path,call_records.missed
      from call_records 
      join person  on call_records.personId = person.id 
      ''');
    List<CallRecord> recordList = List<CallRecord>.empty(growable: true);
    for (var record in recordMaps) {
      recordList.add(CallRecord(
        id: record["id"] as int,
        name: record["name"] as String,
        avatarPath: (record["img_path"] ?? "") as String,
        date: DateTime.parse(record["date"] as String),
        incoming: record["incoming"] == 1,
        missed: record["missed"] == 1,
        calleNumber: record["phone_number"] as String,
        recordPath: record["record_path"] as String,
      ));
    }
    ;
    return recordList;
  }

  static Future<void> removeCallRecord(int id) async {
    await _db.delete("call_records", where: "id = ?", whereArgs: [id]);
  }

  static Future<int> insertRecords(CallRecord values) async {
    int id = await _db.insert('call_records', values.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return id;
  }

  static Future<List<Contact>> listContacts() async {
    final List<Map<String, Object?>> contactsMaps = await _db.query("person");
    List<Contact> contacts = [
      for (var record in contactsMaps)
        Contact(
            id: record["id"] as int,
            name: record["name"] as String,
            phoneNumber: record["phone_number"] as String,
            date: (DateTime.fromMillisecondsSinceEpoch(record["date"] as int)),
            imgPath: record["img_path"] as String)
    ];

    return contacts;
  }

  static Future<int> insertContacts(Contact values) async {
    int id = await _db.insert('person', values.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return id;
  }

  static Future<void> removeMessage(int id) async {
    await _db.delete('messages', where: "id = ?", whereArgs: [id]);
  }

  static Future<void> removeMessages(int id) async {
    await _db.delete('messages', where: "peerId= ?", whereArgs: [id]);
  }

  static Future<List<Message>> getMessagefromPeer(int id) async {
    final List<Map<String, Object?>> messagesMaps =
        await _db.rawQuery("""SELECT *
      FROM person
      JOIN messages
      ON person.id = messages.peerId
      where person.id = ?;
    """, [id]);
    return [
      for (var msg in messagesMaps)
        Message(
          recvId: (msg["recvId"] ?? 0) as int,
          content: (msg["content"] ?? '') as String,
          isMine: (msg["isMine"] ?? 0) == 1,
          dateSend: DateTime.fromMillisecondsSinceEpoch(msg["dateSend"] as int),
          isPinned: (msg["isPinned"] as int? ?? 0) == 1,
          read: (msg["read"] as int? ?? 0) == 1,
        )
    ];
  }

  static Future<(List<MessageDto>, int, int, int)> listMessages() async {
    final List<Map<String, Object?>> messagesMaps = await _db.rawQuery("""
          WITH summary AS (
              SELECT p.id, 
                    p.peerId, 
                    p.content, 
                    p.read,
                    p.isPinned,
                    p.dateSend,
                    ROW_NUMBER() OVER(PARTITION BY p.peerId 
                                          ORDER BY p.dateSend DESC) AS rank
                FROM messages p)
          SELECT *
            FROM summary JOIN person on summary.peerId = person.id
          WHERE rank = 1
    """);
    List<Map<String, Object?>> stats = await _db.rawQuery("""
select 
      COUNT(*) AS total,
      COUNT(*) Filter(WHERE messages.read = 0 ) AS unread,
      COUNT(*) Filter(WHERE messages.isPinned = 1) AS isPinned
  from messages""", []);
    List<MessageDto> allMessages = [];
    for (var record in messagesMaps) {
      bool isPinned = (record["isPinned"] as int) == 1;
      bool isRead = (record["read"] as int) == 1;
      MessageDto msg = MessageDto(
          peer: Contact(
            id: record["id"] as int,
            name: record["name"] as String,
            phoneNumber: record["phone_number"] as String,
            imgPath: record["img_path"] as String,
            date: (DateTime.fromMillisecondsSinceEpoch(
              (record["date"] ?? DateTime.now().microsecondsSinceEpoch) as int,
            )),
          ),
          content: record["content"] as String,
          dateSend:
              DateTime.fromMillisecondsSinceEpoch(record["dateSend"] as int),
          isPinned: isPinned,
          read: isRead);
      allMessages.add(msg);
    }
    return (
      allMessages,
      stats[0]["total"] as int,
      stats[0]["unread"] as int,
      stats[0]["isPinned"] as int,
    );
  }

  static Future<int> insertMessages(Message values) async {
    int id = await _db.insert('messages', values.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON; PRAGMA integrity_check = ON;');
  }

  static Future<int> _getConvId(String senderPhone) async {
    const getConvIdSql = '''
    SELECT c.id 
    FROM person c
    WHERE c.phone_number = ?
    LIMIT 1;
  ''';
    int? row =
        Sqflite.firstIntValue(await _db.rawQuery(getConvIdSql, [senderPhone]));

    return row ?? 1;
  }

  static Future<void> bulkInsert(String sourceDbPath) async {
    bool exists = await File(sourceDbPath).exists();
    if (exists && _db.isOpen) {
      var targetdb =
          await openDatabase(sourceDbPath, onConfigure: _onConfigure);

      for (var row in await targetdb
          .rawQuery("select sender, content, recvtime from smsrecv")) {
        var contact = await _db.query("person",
            distinct: true,
            where: "phone_number = ?",
            whereArgs: [row["sender"]]);
        int contactId = 0;
        if (contact.isEmpty) {
          contactId = await _db.insert(
              "person",
              {
                "name": row['sender'],
                "img_path": "",
                "phone_number": row['sender'],
                "date": DateTime.parse(row["recvtime"] as String)
                    .millisecondsSinceEpoch,
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        } else {
          contactId = contact[0]["id"] as int;
        }
        await _db.rawInsert('''
          INSERT INTO messages (content, dateSend, peerId , isPinned,isMine)
          VALUES (?, ?, ?, ?, ?)
        ''', [
          row['content'],
          DateTime.parse(row['recvtime'] as String).millisecondsSinceEpoch,
          contactId,
          '0',
          '0'
        ]);
      }
      await targetdb.close();
    }
  }

  static Future<void> _createDatabase(Database database, int version) async {
    await database.execute('''
  CREATE TABLE IF NOT EXISTS call_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    personId VARCHAR(255) NOT NULL,
    date DATETIME NOT NULL,
    incoming BOOLEAN NOT NULL,
    missed BOOLEAN NOT NULL,
    record_path VARCHAR(255) NOT NULL,
    FOREIGN KEY(personId) REFERENCES person(id)
  );
  ''');

    await database.execute('''
  CREATE TABLE IF NOT EXISTS accounts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username VARCHAR(255) NOT NULL,
      uri VARCHAR(255) NOT NULL,
      password VARCHAR(255) NOT NULL
  )''');
    await database.execute('''
  CREATE TABLE IF NOT EXISTS person (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL,
    img_path VARCHAR(255),
    date int NOT NULL,
    phone_number VARCHAR(20)  NOT NULL UNIQUE
  );
  ''');
    return await database.execute('''
    CREATE TABLE IF NOT EXISTS messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      content TEXT NOT NULL,
      dateSend DATETIME NOT NULL, 
      isPinned INTEGER Not NULL DEFAULT 0,
      read INTEGER Not NULL DEFAULT 0,
      peerId int NOT NULL,
      isMine int Not NULL DEFAULT 0,
      FOREIGN KEY(peerId) REFERENCES person(id)
    );
  ''');
  }
}
