/// Modelo que representa una operación pendiente de sincronización
class QueueOperationModel {
  final String id;
  final String entity; // 'task'
  final String entityId;
  final String operation; // 'CREATE', 'UPDATE', 'DELETE'
  final String payload; // JSON string
  final int createdAt; // timestamp en milisegundos
  final int attemptCount;
  final String? lastError;

  QueueOperationModel({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    this.attemptCount = 0,
    this.lastError,
  });

  /// Convierte un Map de SQLite a QueueOperationModel
  factory QueueOperationModel.fromMap(Map<String, dynamic> map) {
    return QueueOperationModel(
      id: map['id'] as String,
      entity: map['entity'] as String,
      entityId: map['entity_id'] as String,
      operation: map['op'] as String,
      payload: map['payload'] as String,
      createdAt: map['created_at'] as int,
      attemptCount: map['attempt_count'] as int? ?? 0,
      lastError: map['last_error'] as String?,
    );
  }

  /// Convierte QueueOperationModel a Map para insertar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity': entity,
      'entity_id': entityId,
      'op': operation,
      'payload': payload,
      'created_at': createdAt,
      'attempt_count': attemptCount,
      'last_error': lastError,
    };
  }

  /// Crea una copia con campos actualizados
  QueueOperationModel copyWith({
    String? id,
    String? entity,
    String? entityId,
    String? operation,
    String? payload,
    int? createdAt,
    int? attemptCount,
    String? lastError,
  }) {
    return QueueOperationModel(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
    );
  }
}