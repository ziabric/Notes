import 'dart:ffi';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart';

// апи для работы с sqlite3
class DatabaseManager {
  // хэндлер базы
  var _database;

  // инициализация + создание таблицы при необходимости
  void openDb() {
    open.overrideFor(OperatingSystem.android, _openOnAndroid);
    _database = sqlite3.openInMemory();
    _database.execute('CREATE TABLE notes(id INTEGER, text TEXT(300));');
  }

  Database get database => _database;

  // удаление из таблицы заметки + заполнение списка заново
  void delete(String text) {
    String tmp = "DELETE FROM notes WHERE text='${text}';";
    _database.execute(tmp);
  }

  // добавление заметки в таблицу
  void insert(String text) {
    _database.execute("INSERT INTO notes(text) VALUES ('${text}');");
  }

  // возвращаем список заметок из базы
  List<String> fetchAllNotes() {
    var result = _database.select('SELECT * FROM notes');
    List<String> notes = [];
    for (var row in result) {
      var text = row['text'] as String;
      notes.add(text);
    }
    return notes;
  }

  // закрываем соединение
  void close() {
    _database.close();
  }

  // т к используем андроид подгружаем динамическую библиотеку для работы с sqlite3
  DynamicLibrary _openOnAndroid() {
    final libraryNextToDartLibrary = DynamicLibrary.open('libsqlite3.so');
    return libraryNextToDartLibrary;
  }
}
