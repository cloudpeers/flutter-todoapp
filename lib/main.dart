import 'package:flip/flip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tlfs/sdk.dart';
import 'package:tlfs/tlfs.dart' as tlfs;
import './localization.dart';
import './state.dart';

const List<Locale> SUPPORTED_LOCALES = [
  const Locale('en'),
  const Locale('de'),
  //const Locale('pt'),
];

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
        },
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FluentLocalizationsDelegate(SUPPORTED_LOCALES),
        ],
        supportedLocales: SUPPORTED_LOCALES,
        onGenerateTitle: (BuildContext context) => i18n(context, 'title-app'),
      ),
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
      appBar: AppBar(title: Text(i18n(context, 'title-docs'))),
      body: Column(children: [
        const InviteBanner(),
        Expanded(
          child: StreamBuilder(
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
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final doc = await sdk.createDoc(schema);
          Todos(doc).setTitle(i18n(context, 'new-document-title'));
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
    final title = widget.todos.title();
    String? text;
    if (title.isNotEmpty) {
      text = title[0];
    }
    _titleController = TextEditingController(text: text);
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
                    decoration: InputDecoration(
                      labelText: i18n(context, 'label-doc-title'),
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(i18n(
                  context, 'snackbar-removed-document', {'title': title}))));
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
      body: Column(
        children: [
          const InviteBanner(),
          Expanded(
              child: StreamBuilder(
            stream: todos.subscribe(),
            builder: (context, snapshot) {
              return ListView.builder(
                itemCount: todos.length(),
                itemBuilder: (context, i) {
                  return TodoTile(todo: todos.get(i));
                },
              );
            },
          )),
        ],
      ),
      drawer: Drawer(
        child: StreamRebuilder(
          streamBuilder: () => LocalPeers(sdk).subscribeLocalPeers(),
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final localPeers = snapshot.data!;
            return ListView.builder(
              itemCount: localPeers.length,
              itemBuilder: (context, i) {
                return PeerTile(
                  id: localPeers[i],
                  isConnected: false,
                  isLocal: true,
                  permission: 0,
                  onTap: () {
                    todos.addPeer(localPeers[i]);
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          todos.create(i18n(context, 'new-todo-title'));
        },
      ),
    );
  }
}

class InviteBanner extends StatefulWidget {
  const InviteBanner({Key? key}) : super(key: key);

  @override
  State<InviteBanner> createState() => _InviteBannerState();
}

class _InviteBannerState extends State<InviteBanner> {
  List<String> invites = [];

  @override
  Widget build(BuildContext context) {
    final sdk = Sdk.of(context).sdk;
    return StreamBuilder(
        stream: Invites(sdk).subscribeInvites(),
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.data != null) {
            invites = snapshot.data!;
          }
          final List<Widget> children = [];
          for (int i = 0; i < invites.length; i++) {
            children.add(MaterialBanner(
              padding: const EdgeInsets.all(20),
              content: Text(i18n(
                  context, 'invite-banner-content', {'invite': invites[i]})),
              backgroundColor: const Color(0xFFE0E0E0),
              actions: [
                TextButton(
                  child: Text(i18n(context, 'invite-banner-accept')),
                  onPressed: () {
                    sdk.addDoc(invites[i], "todoapp");
                    setState(() => invites.removeAt(i));
                  },
                ),
                TextButton(
                  child: Text(i18n(context, 'invite-banner-dismiss')),
                  onPressed: () {
                    setState(() => invites.removeAt(i));
                  },
                ),
              ],
            ));
          }
          return Column(
            children: children,
            mainAxisSize: MainAxisSize.min,
          );
        });
  }
}

class PeerTile extends StatelessWidget {
  const PeerTile({
    Key? key,
    required this.id,
    required this.isConnected,
    required this.isLocal,
    required this.permission,
    this.onTap,
  }) : super(key: key);

  final String id;
  final bool isConnected;
  final bool isLocal;
  final int permission;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icon(isConnected ? Icons.link : Icons.link_off),
      Icon(isLocal ? Icons.wifi : Icons.network_cell),
      Icon(permission > 0 ? Icons.visibility : Icons.visibility_off),
      Icon(permission > 1 ? Icons.edit : Icons.edit_off),
    ];
    if (permission > 2) {
      icons.add(const Icon(Icons.share));
    }
    return Card(
      child: ListTile(
        title: Text(id),
        trailing: Row(
          children: icons,
          mainAxisSize: MainAxisSize.min,
        ),
        onTap: onTap,
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
                    decoration: InputDecoration(
                      labelText: i18n(context, 'label-todo-title'),
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  i18n(context, 'snackbar-remove-todo', {'title': title}))));
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

class StreamRebuilder<T> extends StatefulWidget {
  const StreamRebuilder({
    Key? key,
    required this.streamBuilder,
    required this.builder,
  }) : super(key: key);

  final Stream<T> Function() streamBuilder;
  final AsyncWidgetBuilder<T> builder;

  @override
  State<StreamRebuilder<T>> createState() => _StreamRebuilderState<T>();
}

class _StreamRebuilderState<T> extends State<StreamRebuilder<T>> {
  Stream<T>? stream;

  @override
  void initState() {
    super.initState();
    stream = widget.streamBuilder();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream!,
      builder: widget.builder,
    );
  }
}
