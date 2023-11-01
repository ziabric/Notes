import 'package:flutter/material.dart';
import 'Helper.dart';

void main() => runApp(MyApp());

// Обертка для нормальной работы Scaffold
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

// класс, который реализует окно в нем запускается отрисока состояния
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// класс, который описывает состояние ( вся магия в нем )
class _MyHomePageState extends State<MyHomePage> {
  // список заметок
  final List<String> notes = [];

  // апи для работы с базой
  final DatabaseManager dbManager = DatabaseManager();

  // перегрузка метода инициализации окна
  @override
  void initState() {
    super.initState();
    dbManager.openDb();
    loadNotesFromDb();
  }

  // функция заполнения списка заметок
  void loadNotesFromDb() {
    var loadedNotes = dbManager.fetchAllNotes();
    setState(() {
      notes.clear();
      notes.addAll(loadedNotes);
    });
  }

  // перегрузка конструктора
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(notes[index]),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    dbManager.delete(notes[index]);
                    loadNotesFromDb();
                  });
                },
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNote();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // метод, который выводит маленькое окошко с текстовым полем и двумя кнопками
  void _addNote() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text("Add Note"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Add"),
              onPressed: () {
                dbManager.insert(controller.text);
                loadNotesFromDb();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  // перегрузка деструктора
  @override
  void dispose() {
    dbManager.close();
    super.dispose();
  }
}
