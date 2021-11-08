import 'package:flutter/material.dart';
import 'package:flutter_tlfs/flutter_tlfs.dart';
import './state.dart';

void main() {
  runApp(
    Sdk(
      appname: 'todoapp',
      child: MaterialApp(
        initialRoute: '/docs',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/docs':
              return MaterialPageRoute(
                builder: (context) {
                  return DocsView();
                }
              );
            case '/todos':
              final todos = settings.arguments! as Todos;
              return MaterialPageRoute(
                builder: (context) {
                  return TodosView(todos: todos);
                }
              );
            default:
              return null;
          }
        }
      ),
    ),
  );
}

class DocsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Docs(
      schema: 'todoapp',
      child: Builder(
        builder: (context) {
          final docs = Docs.of(context);
          return Scaffold(
            appBar: AppBar(title: Text('Documents')),
            body: ListView.builder(
              itemCount: docs.length(),
              itemBuilder: (context, i) {
                return DocTile(todos: Todos(docs.get(i)));
              },
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                final doc = docs.create();
                Todos(doc).setTitle('a new document');
              },
            ),
          );
        },
      ),
    );
  }
}

class TodosView extends StatelessWidget {
  const TodosView({
    Key? key,
    required this.todos,
  }) : super(key: key);

  final Todos todos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Title(values: todos.title())),
      body: ListView.builder(
        itemCount: todos.length(),
        itemBuilder: (context, i) {
          return TodoTile(todo: this.todos.get(i));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          this.todos.create('a new todo');
        },
      ),
    );
  }
}

class DocTile extends StatelessWidget {
  const DocTile({
    Key? key,
    required this.todos,
  }) : super(key: key);

  final Todos todos;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Title(values: this.todos.title()),
        subtitle: Text(this.todos.id()),
        onTap: () {
          Navigator.pushNamed(context, '/todos', arguments: this.todos);
        },
        onLongPress: () {
          final sdk = Sdk.of(context).sdk;
          sdk.removeDoc(this.todos.doc.id()); // safety
        },
      ),
    );
  }
}

class TodoTile extends StatelessWidget {
  const TodoTile({
    Key? key,
    required this.todo,
  }) : super(key: key);

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Title(values: this.todo.title()),
        trailing: Checkbox(
          value: this.todo.complete(),
          onChanged: (value) {
            if (value != null) {
              this.todo.setComplete(value);
            }
          },
        ),
        onTap: () {
          // edit title and delete
        }
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title({
    Key? key,
    required this.values,
  }) : super(key: key);

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    print(this.values);
    if (this.values.length > 0) {
      children.add(Text(this.values[0]));
    }
    if (this.values.length > 1) {
      children.add(Icon(Icons.warning));
    }
    return Row(children: children);
  }
}
