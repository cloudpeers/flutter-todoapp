import 'package:flutter/material.dart';
import 'package:tlfs/sdk.dart';
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
                return MaterialPageRoute(builder: (context) {
                  final sdk = Sdk.of(context).sdk;
                  final docs = Docs.load(sdk, "todoapp");
                  return DocsView(docs: docs);
                });
              case '/todos':
                final todos = settings.arguments! as Todos;
                return MaterialPageRoute(builder: (context) {
                  return TodosView(todos: todos);
                });
              default:
                return null;
            }
          }),
    ),
  );
}

class DocsView extends StatelessWidget {
  const DocsView({
    Key? key,
    required this.docs,
  }) : super(key: key);

  final Docs docs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: ListView.builder(
        itemCount: docs.length(),
        itemBuilder: (context, i) {
          return DocTile(todos: Todos(docs.get(i)));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final doc = docs.create();
          Todos(doc).setTitle('a new document');
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
      body: StreamBuilder(
        stream: todos.subscribe(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          return ListView.builder(
            itemCount: todos.length(),
            itemBuilder: (context, i) {
              return TodoTile(todo: todos.get(i));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          todos.create('a new todo');
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
        title: Title(values: todos.title()),
        subtitle: Text(todos.id()),
        onTap: () {
          Navigator.pushNamed(context, '/todos', arguments: todos);
        },
        onLongPress: () {
          final sdk = Sdk.of(context).sdk;
          sdk.removeDoc(todos.doc.id()); // safety
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
          title: Title(values: todo.title()),
          trailing: Checkbox(
            value: todo.complete(),
            onChanged: (value) {
              if (value != null) {
                todo.setComplete(value);
              }
            },
          ),
          onTap: () {
            // edit title and delete
          }),
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
    if (values.isNotEmpty) {
      children.add(Text(values[0]));
    }
    if (values.length > 1) {
      children.add(const Icon(Icons.warning));
    }
    return Row(children: children);
  }
}
