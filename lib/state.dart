import 'package:tlfs/tlfs.dart' as tlfs;

class Todo {
  final tlfs.Doc doc;
  final int index;

  Todo(this.doc, this.index);

  List<String> title() {
    final cursor = this.doc.cursor();
    cursor.field("tasks");
    cursor.index(this.index);
    cursor.field("title");
    final iter = cursor.strs();
    final List<String> titles = [];
    for (final title in iter) {
      titles.add(title);
    }
    iter.destroy();
    cursor.destroy();
    return titles;
  }

  bool complete() {
    final cursor = this.doc.cursor();
    cursor.field("tasks");
    cursor.index(this.index);
    cursor.field("complete");
    final completed = cursor.enabled();
    cursor.destroy();
    return completed;
  }

  void setTitle(String title) {
    final cursor = this.doc.cursor();
    cursor.field("tasks");
    cursor.index(this.index);
    cursor.field("title");
    final causal = cursor.assignStr(title);
    this.doc.apply(causal);
    cursor.destroy();
  }

  void setComplete(bool complete) {
    final cursor = this.doc.cursor();
    cursor.field("tasks");
    cursor.index(this.index);
    cursor.field("complete");
    final causal = complete ? cursor.enable() : cursor.disable();
    this.doc.apply(causal);
    cursor.destroy();
  }

  void delete() {
    final cursor = this.doc.cursor();
    cursor.field("tasks");
    cursor.index(this.index);
    final causal = cursor.delete();
    this.doc.apply(causal);
    cursor.destroy();
  }
}

class Todos {
  final tlfs.Doc doc;

  Todos(this.doc);

  String id() {
    return this.doc.id().toString();
  }

  List<String> title() {
    final cursor = this.doc.cursor();
    cursor.field("title");
    final iter = cursor.strs();
    final List<String> titles = [];
    for (final title in iter) {
      titles.add(title);
    }
    iter.destroy();
    cursor.destroy();
    return titles;
  }

  void setTitle(String title) {
    final cursor = this.doc.cursor();
    cursor.field("title");
    final causal = cursor.assignStr(title);
    this.doc.apply(causal);
    cursor.destroy();
  }

  int length() {
    final cursor = this.doc.cursor();
    cursor.field("tasks");
    return cursor.length();
  }

  Todo create(String title) {
    final todo = Todo(this.doc, this.length());
    todo.setTitle(title);
    return todo;
  }

  Todo get(int index) {
    return Todo(this.doc, index);
  }

  void remove(int index) {
    this.get(index).delete();
  }
}
