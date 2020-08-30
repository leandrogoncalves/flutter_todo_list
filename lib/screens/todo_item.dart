import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/models/Todo.dart';

class TodoItem extends StatefulWidget {
  final Todo todo;
  final int index;

  TodoItem({Key key, @required this.todo, @required this.index})
      : super(key: key);

  @override
  _TodoItemState createState() => _TodoItemState(todo, index);
}

class _TodoItemState extends State<TodoItem> {
  Todo _todo;
  int _index;

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  final key = GlobalKey<ScaffoldState>();

  _TodoItemState(Todo todo, int index) {
    debugPrint(todo.toString());
    debugPrint(index.toString());
    this._todo = todo;
    this._index = index;

    if (_todo != null) {
      _tituloController.text = todo.titulo;
      _descricaoController.text = todo.descricao;
    }
  }

  _saveItem() async {
    if (_tituloController.text.isEmpty || _descricaoController.text.isEmpty) {
      key.currentState.showSnackBar(
          SnackBar(content: Text('Titulo e descrição são obrigatórios')));
      return false;
    }

    List<Todo> list = [];

    //Pega a lista do storage do disposivitivo
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('list');
    if (data != null) {
      var objs = jsonDecode(data) as List;
      list = objs.map((obj) => Todo.fromJson(obj)).toList();
    }

    //Adiciona um novo item na lista
    Todo todo = Todo.fromTituloDescricao(
      _tituloController.text,
      _descricaoController.text,
    );

    //Cria ou atualiza item da lista
    if (_index != -1) {
      list[_index] = todo;
    } else {
      list.add(todo);
    }

    //Salva a nova lista
    prefs.setString('list', jsonEncode(list));

    _tituloController.clear();
    _descricaoController.clear();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Item da Lista'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                hintText: 'Titulo',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _descricaoController,
              decoration: InputDecoration(
                hintText: 'Descricao',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonTheme(
              minWidth: double.infinity,
              child: RaisedButton(
                  color: Colors.lightGreen,
                  textColor: Colors.white,
                  child: Text(
                    'Salvar',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () => _saveItem()),
            ),
          )
        ],
      ),
    );
  }
}
