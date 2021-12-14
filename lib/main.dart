import 'package:flip/flip.dart';
import 'package:flutter/material.dart';
import 'package:tlfs/sdk.dart';
import 'package:tlfs/tlfs.dart' as tlfs;
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
                  return DocsView(sdk: sdk, schema: "todoapp");
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
    required this.sdk,
    required this.schema,
  }) : super(key: key);

  final tlfs.Sdk sdk;
  final String schema;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: StreamBuilder(
        stream: sdk.subscribeDocs(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          final docs = sdk.docs(schema).toList();
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final todos = Todos(sdk.openDoc(docs[i]));
              return StreamBuilder(
                stream: todos.subscribeTitle(),
                builder: (context, snapshot) => DocTile(todos: todos),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final doc = await sdk.createDoc(schema);
          Todos(doc).setTitle('a new document');
        },
      ),
    );
  }
}

class DocTile extends StatefulWidget {
  const DocTile({
    Key? key,
    required this.todos,
  }) : super(key: key);

  final Todos todos;

  @override
  State<DocTile> createState() => _DocTileState();
}

class _DocTileState extends State<DocTile> {
  late TextEditingController _titleController;
  late FlipController _flipController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todos.title()[0]);
    _flipController = FlipController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: GlobalKey(),
        child: Flip(
          controller: _flipController,
          flipDirection: Axis.vertical,
          firstChild: Card(
            child: ListTile(
              title: Title(values: widget.todos.title()),
              subtitle: Text(widget.todos.id()),
              onTap: () {
                Navigator.pushNamed(context, '/todos', arguments: widget.todos);
              },
              onLongPress: () {
                _flipController.flip();
              },
            ),
          ),
          secondChild: GestureDetector(
            onLongPress: () {
              _flipController.flip();
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0)
                    .add(const EdgeInsets.only(bottom: 3.0)),
                child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                    controller: _titleController,
                    onSubmitted: (String value) {
                      widget.todos.setTitle(value);
                      _flipController.flip();
                    }),
              ),
            ),
          ),
        ),
        background: Container(color: Colors.red),
        onDismissed: (direction) {
          final sdk = Sdk.of(context).sdk;
          final title = widget.todos.title()[0];
          sdk.removeDoc(widget.todos.id());
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('removed document `$title`')));
        });
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
    final sdk = Sdk.of(context).sdk;
    return Scaffold(
      appBar: AppBar(title: Title(values: todos.title())),
      body: StreamBuilder(
        stream: todos.subscribe(),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: todos.length(),
            itemBuilder: (context, i) {
              return TodoTile(todo: todos.get(i));
            },
          );
        },
      ),
      drawer: Drawer(
        child: StreamBuilder(
          stream: LocalPeers(sdk).subscribeLocalPeers(),
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final localPeers = snapshot.data!;
            return ListView.builder(
              itemCount: localPeers.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(localPeers[i]),
                );
              },
            );
          },
        ),
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

class TodoTile extends StatefulWidget {
  const TodoTile({
    Key? key,
    required this.todo,
  }) : super(key: key);

  final Todo todo;

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  late TextEditingController _titleController;
  late FlipController _flipController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title()[0]);
    _flipController = FlipController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: GlobalKey(),
        child: Flip(
          controller: _flipController,
          flipDirection: Axis.vertical,
          flipDuration: const Duration(milliseconds: 300),
          firstChild: Card(
            child: ListTile(
              title: Title(values: widget.todo.title()),
              trailing: Checkbox(
                value: widget.todo.complete(),
                onChanged: (value) {
                  if (value != null) {
                    widget.todo.setComplete(value);
                  }
                },
              ),
              onLongPress: () {
                _flipController.flip();
              },
            ),
          ),
          secondChild: GestureDetector(
            onLongPress: () {
              _flipController.flip();
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0)
                    .add(const EdgeInsets.only(bottom: 3.0)),
                child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                    controller: _titleController,
                    onSubmitted: (String value) {
                      widget.todo.setTitle(value);
                      _flipController.flip();
                    }),
              ),
            ),
          ),
        ),
        background: Container(color: Colors.red),
        onDismissed: (direction) {
          final title = widget.todo.title()[0];
          widget.todo.delete();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('removed todo `$title`')));
        });
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
