import 'package:tlfs/tlfs.dart' as tlfs;

class Todo {
  final tlfs.Doc doc;
  final int index;

  Todo(this.doc, this.index);

  List<String> title() {
    final cursor = doc.createCursor();
    cursor.structField("tasks");
    cursor.arrayIndex(index);
    cursor.structField("title");
    final titles = cursor.regStrs().toList();
    cursor.drop();
    return titles;
  }

  bool complete() {
    final cursor = doc.createCursor();
    cursor.structField("tasks");
    cursor.arrayIndex(index);
    cursor.structField("complete");
    final completed = cursor.flagEnabled();
    cursor.drop();
    return completed;
  }

  void setTitle(String title) {
    final cursor = doc.createCursor();
    cursor.structField("tasks");
    cursor.arrayIndex(index);
    cursor.structField("title");
    final causal = cursor.regAssignStr(title);
    doc.applyCausal(causal);
    cursor.drop();
  }

  void setComplete(bool complete) {
    final cursor = doc.createCursor();
    cursor.structField("tasks");
    cursor.arrayIndex(index);
    cursor.structField("complete");
    final causal = complete ? cursor.flagEnable() : cursor.flagDisable();
    doc.applyCausal(causal);
    cursor.drop();
  }

  void delete() {
    final cursor = doc.createCursor();
    cursor.structField("tasks");
    cursor.arrayIndex(index);
    final causal = cursor.arrayRemove();
    doc.applyCausal(causal);
    cursor.drop();
  }
}

class Todos {
  final tlfs.Doc doc;

  Todos(this.doc);

  String id() {
    return doc.id().toString();
  }

  Stream<void> subscribe() {
    final cursor = doc.createCursor();
    final stream = cursor.subscribe();
    cursor.drop();
    return stream;
  }

  List<String> title() {
    final cursor = doc.createCursor();
    cursor.structField("title");
    final titles = cursor.regStrs().toList();
    cursor.drop();
    return titles;
  }

  void setTitle(String title) {
    final cursor = doc.createCursor();
    cursor.structField("title");
    final causal = cursor.regAssignStr(title);
    doc.applyCausal(causal);
    cursor.drop();
  }

  Stream<void> subscribeTitle() {
    final cursor = doc.createCursor();
    cursor.structField("title");
    final stream = cursor.subscribe();
    cursor.drop();
    return stream;
  }

  int length() {
    final cursor = doc.createCursor();
    cursor.structField("tasks");
    final length = cursor.arrayLength();
    cursor.drop();
    return length;
  }

  Todo create(String title) {
    final todo = Todo(doc, length());
    todo.setTitle(title);
    return todo;
  }

  Todo get(int index) {
    return Todo(doc, index);
  }

  void remove(int index) {
    get(index).delete();
  }
}

class LocalPeers {
  final tlfs.Sdk sdk;

  LocalPeers(this.sdk);

  Stream<List<String>> subscribeLocalPeers() async* {
    final sub = sdk.subscribeLocalPeers();
    yield (await sdk.localPeers()).toList();
    await for (final _ in sub) {
      yield (await sdk.localPeers()).toList();
    }
  }
}
