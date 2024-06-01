import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Book {
  final String name;
  final String id;

  Book({required this.name, required this.id});

  // JSONからBookオブジェクトを生成するファクトリコンストラクタ
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      name: json['name'],
      id: json['id'],
    );
  }

  // BookオブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }
}

class DatabaseHelper {
  static Future<Database> getDatabase() async {
    // アプリケーションのドキュメントディレクトリ内のデータベースファイルのパスを取得
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, "aozora.db");

    // データベースファイルがドキュメントディレクトリに存在するかチェックし、存在しない場合はコピーする
    copyDatabaseToDocumentsDir();
    // コピーされたデータベースファイルを開く
    return await openDatabase(path);
  }

  static Future<List<String>> getAuthors() async {
    final db = await getDatabase(); // getDatabaseメソッドは、データベースに接続するためのメソッドです
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT DISTINCT 姓名 FROM aozora_books');

    return List.generate(maps.length, (i) {
      return maps[i]['姓名'];
    });
  }

  static Future<List<Book>> getBooksByAuthor(String author) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('aozora_books', where: '姓名 = ?', whereArgs: [author]);

    return List.generate(maps.length, (i) {
      return Book(
        name: maps[i]['作品名'] as String,
        id: maps[i]['作品ID'].toString(), // 仮にカラム名が '作品ID' だとします
      );
    });
  }
}

Future<void> copyDatabaseToDocumentsDir() async {
  final dbPath =
      join((await getApplicationDocumentsDirectory()).path, "aozora.db");

  // データベースファイルが既に存在するかチェック
  // if (await File(dbPath).exists()) {
  //   return;
  // }

  // アセットからデータを読み込む
  final data = await rootBundle.load("assets/database/aozora.db");
  final bytes = data.buffer.asUint8List();

  // ファイルを書き込む
  await File(dbPath).writeAsBytes(bytes);
}

class HistoryHelper {
  static const String _historyKey = 'history';

  // 履歴を保存する
  static Future<void> saveHistory(List<Book> history) async {
    final prefs = await SharedPreferences.getInstance();
    // BookオブジェクトのリストをJSON配列に変換
    final String encodedData =
        jsonEncode(history.map((book) => book.toJson()).toList());
    await prefs.setString(_historyKey, encodedData);
  }

  // 履歴を読み込む
  static Future<List<Book>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_historyKey);
    if (encodedData != null) {
      // JSON配列をBookオブジェクトのリストに変換
      Iterable l = jsonDecode(encodedData);
      List<Book> history =
          List<Book>.from(l.map((model) => Book.fromJson(model)));
      return history;
    } else {
      return [];
    }
  }
}
