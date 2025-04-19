import 'dart:io';

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

  static Future<Contact?> getContact(String phone) async {
    List<Map> map = await _db
        .query("person", where: "phone_number = ?", whereArgs: [phone]);
    if (map.isEmpty) {
      return null;
    }
    Contact c = Contact(
        name: map[0]["name"] ?? "",
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
            name: record["name"] as String,
            phoneNumber: record["phone_number"] as String,
            imgPath: record["img_path"] as String)
    ];

    return contacts;
  }

  static Future<int> insertContacts(Contact values) async {
    int id = await _db.insert('person', values.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return id;
  }

  static Future<(List<MessageDto>, List<MessageDto>, List<MessageDto>)>
      listMessages() async {
    final List<Map<String, Object?>> messagesMaps =
        await _db.rawQuery("""SELECT *
      FROM person
      JOIN messages
      ON person.id = messages.peerId;
    """);
    List<MessageDto> allMessages = [];
    List<MessageDto> readMessages = [];
    List<MessageDto> pinnedMessages = [];
    for (var record in messagesMaps) {
      bool isPinned = (record["isPinned"] as int) == 1;
      bool isRead = (record["read"] as int) == 1;
      MessageDto msg = MessageDto(
          peer: Contact(
            name: record["name"] as String,
            phoneNumber: record["phone_number"] as String,
            imgPath: record["img_path"] as String,
          ),
          content: record["content"] as String,
          dateSend: DateTime.parse(record["dateSend"] as String),
          isPinned: isPinned,
          read: isRead);
      allMessages.add(msg);
      isPinned ? pinnedMessages.add(msg) : null;
      isRead ? null : readMessages.add(msg);
    }

    return (allMessages, readMessages, pinnedMessages);
  }

  static Future<int> insertMessages(Message values) async {
    int id = await _db.insert('messages', values.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON; PRAGMA integrity_check = ON;');
  }

  static Future<Message> parseSmsString(String smsData) async {
    final lines = smsData.split('\n');
    final map = <String, String>{};

    for (final line in lines) {
      final parts = line.split(': ');
      if (parts.length == 2) {
        map[parts[0].trim()] = parts[1].trim();
      }
    }
    Message msg = Message(
      content: map['Content'] ?? '',
      isPinned: false,
      read: false,
      dateSend: DateTime.parse(map['Recvtime'] ?? DateTime.now().toString()),
      recvId: await _getConvId(map['Sender'] ?? ''),
    );
    insertMessages(msg);

    return msg;
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
          contactId = await _db.rawInsert('''
        INSERT INTO person (name, img_path, phone_number)
        VALUES (?, ?, ?)
      ''', [row['sender'], '', row['sender']]);
        } else {
          contactId = contact[0]["id"] as int;
        }
        await _db.rawInsert('''
          INSERT INTO messages (content, dateSend, peerId , isPinned)
          VALUES (?, ?, ?, ?)
        ''', [row['content'], row['recvtime'], contactId, '0']);
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
    img_path VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20)  NOT NULL UNIQUE
  );
  ''');
    await database.execute('''
    insert into person(id,name,img_path,phone_number) VALUES(1,'unknown','','')
  ''');
    return await database.execute('''
  CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL,
    dateSend DATETIME NOT NULL, 
    isPinned INTEGER Not NULL DEFAULT 0,
    read INTEGER Not NULL DEFAULT 0,
    peerId int NOT NULL,
    FOREIGN KEY(peerId) REFERENCES person(id)
  );
  ''');
  }
}
