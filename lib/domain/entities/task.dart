class Task {
  final String id;
  final String title;
  final bool completed;
  final DateTime updatedAt;
  final bool deleted;

  Task({
    required this.id,
    required this.title,
    required this.completed,
    required this.updatedAt,
    this.deleted = false,
  });

  /// Crea una copia de la tarea con los campos actualizados
  Task copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? updatedAt,
    bool? deleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, completed: $completed, updatedAt: $updatedAt, deleted: $deleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.completed == completed &&
        other.updatedAt == updatedAt &&
        other.deleted == deleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        completed.hashCode ^
        updatedAt.hashCode ^
        deleted.hashCode;
  }
}