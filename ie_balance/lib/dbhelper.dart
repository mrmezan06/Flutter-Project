import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'balance.dart';
import 'source.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'balance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE trasum(
            id INTEGER PRIMARY KEY,
            amount INTEGER,
            type TEXT,
            category TEXT,
            ctime TEXT
        )
''');
  }

  /* Get All Data of incomesrc table */
  Future<List<Balance>> getAllTransaction() async {
    Database db = await instance.database;
    var incomesrcs = await db.query('trasum', orderBy: 'category');
    List<Balance> incomesrcList = incomesrcs.isNotEmpty
        ? incomesrcs.map((c) => Balance.fromMap(c)).toList()
        : [];
    return incomesrcList;
  }

/* Get all data filtered by income */
  Future<List<Balance>> getIncomeTransaction() async {
    Database db = await instance.database;
    var incomesrcs =
        await db.query('trasum', where: 'type = ?', whereArgs: ['Income']);
    List<Balance> expensesrcList = incomesrcs.isNotEmpty
        ? incomesrcs.map((c) => Balance.fromMap(c)).toList()
        : [];
    return expensesrcList;
  }

/* Get All Data filtered by expense */
  Future<int> getExpenseSum() async {
    Database db = await instance.database;
    var incomesrcs =
        await db.query('trasum', where: 'type = ?', whereArgs: ['Expense']);
    List<Balance> expensesrcList = incomesrcs.isNotEmpty
        ? incomesrcs.map((c) => Balance.fromMap(c)).toList()
        : [];
    int x = 0;
    for (var e in expensesrcList) {
      x = x + e.amount;
    }
    print('Expense: $x');
    return x;
  }

/* Add to the incomesrc Table */
  Future<int> addTransactions(Balance incomesrc) async {
    Database db = await instance.database;
    return await db.insert('trasum', incomesrc.toMap());
  }

/* Remove data */
  Future<int> removeTransactions(int id) async {
    Database db = await instance.database;
    return await db.delete('trasum', where: 'id = ?', whereArgs: [id]);
  }

/* Update data */
  Future<int> update(Balance incomesrc) async {
    Database db = await instance.database;
    return await db.update('trasum', incomesrc.toMap(),
        where: "id = ?", whereArgs: [incomesrc.id]);
  }
}
