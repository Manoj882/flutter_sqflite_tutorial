import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHeler {
  /// singleton
  DBHeler._();

  static final DBHeler getInstance = DBHeler._();

  /// Table - note

  static const String TABLE_NOTE = 'note';
  static const String COLUMN_NOTE_SNO = 's_no';
  static const String COLUMN_NOTE_TITLE = 'title';
  static const String COLUMN_NOTE_DESC = 'desc';

  Database? db;

  /// db Open (path -> if exists then open else create db)

  Future<Database> getDB() async {
    db ??= await openDB();
    return db!;

    // if(db != null){
    //   return db!;
    // } else {
    //   db = await openDB();
    //   return db!;
    // }
  }

  Future<Database?> openDB() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();

      String dbPath = join(appDir.path, 'noteDB.db');

      final database =
          await openDatabase(dbPath, onCreate: (db, version) async {
        /// create all your tables here

        await db.execute(
            'create table $TABLE_NOTE ($COLUMN_NOTE_SNO integer primary key autoincrement, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text)');
      }, version: 1);

      return database;
    } catch (e) {
      return null;
    }
  }

  /// all queries

  /// Insertion

  Future<bool> addNote({required String title, required String desc}) async {
    final db = await getDB();

    int rowsEffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: title,
      COLUMN_NOTE_DESC: desc,
    });

    print('add note: $rowsEffected');

    return rowsEffected > 0;
  }

  /// reading all data

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await getDB();

    /// select * from note

    List<Map<String, dynamic>> data = await db.query(TABLE_NOTE);
    return data;
  }

/// update data

  Future<bool> updateNote({
    required String title,
    required String desc,
    required int sno,
  }) async {
    final db = await getDB();

    int rowsEffected = await db.update(
      TABLE_NOTE,
      {
        COLUMN_NOTE_TITLE: title,
        COLUMN_NOTE_DESC: desc,
      },
      where: '$COLUMN_NOTE_SNO = $sno',
    );

    return rowsEffected > 0;
  }

  /// delete data
  
  Future<bool> deleteNote({required int sno}) async {
    final db = await getDB();

     int rowsEffected = await db.delete(TABLE_NOTE, where: '$COLUMN_NOTE_SNO = ?', whereArgs: ['$sno']);

     return rowsEffected > 0;
  }

}
