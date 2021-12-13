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
    final List<String> titles = [];
    for (final title in cursor.regStrs()) {
      titles.add(title);
    }
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
    final List<String> titles = [];
    for (final title in cursor.regStrs()) {
      titles.add(title);
    }
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

class Docs {
  final tlfs.Sdk sdk;
  final String schema;
  final List<String> docs;

  Docs._(this.sdk, this.schema, this.docs);

  static Docs load(tlfs.Sdk sdk, String schema) {
    final List<String> docs = [];
    for (final doc in sdk.docs(schema)) {
      docs.add(doc);
    }
    return Docs._(sdk, schema, docs);
  }

  Future<tlfs.Doc> create() async {
    return await sdk.createDoc(schema);
  }

  tlfs.Doc get(int index) {
    return sdk.openDoc(docs[index]);
  }

  int length() {
    return docs.length;
  }
}
