import 'package:sqflite/sqflite.dart';

late Database db;
Future<void> createDatabase() async {
  db = await openDatabase(
    'images.db',
    version: 1,
    onCreate: (Database database, int version) async {
      await database.execute(
          'CREATE TABLE imageTable (id INTEGER PRIMARY KEY AUTOINCREMENT, imageSrc TEXT)');
    },
  );
}

Future<void> insertImagetoDatabase(String imageSrc) async {
  await db.rawInsert(
    'INSERT INTO imageTable(imageSrc) VALUES(?)',
    [imageSrc],
  );
}

Future<List<Map<String, dynamic>>> getImageFromDatabase() async {
  final value = await db.query('imageTable');
  return value;
}

Future<void> deleteImageFromDatabase(int id) async {
  await db.delete('imageTable', where: 'id =?', whereArgs: [id]);
}
