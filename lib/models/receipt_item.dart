/// Un ítem de la boleta (o un "consumo adicional" agregado manualmente).
class ReceiptItem {
  final String id;
  final String eventId;
  final String name;
  final double quantity;
  final int unitPrice; // pesos, sin decimales
  final int totalPrice; // pesos, sin decimales
  final bool isExtra; // true = agregado manualmente después del OCR
  final int sortOrder;

  /// IDs de las personas que comparten este ítem (se llena aparte,
  /// mediante la tabla item_shares, pero se mantiene aquí en memoria
  /// mientras se arma la asignación en la UI).
  final List<String> sharedByPersonIds;

  ReceiptItem({
    required this.id,
    required this.eventId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.isExtra = false,
    this.sortOrder = 0,
    List<String>? sharedByPersonIds,
  }) : sharedByPersonIds = sharedByPersonIds ?? [];

  ReceiptItem copyWith({
    String? name,
    double? quantity,
    int? unitPrice,
    int? totalPrice,
    bool? isExtra,
    int? sortOrder,
    List<String>? sharedByPersonIds,
  }) {
    return ReceiptItem(
      id: id,
      eventId: eventId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      isExtra: isExtra ?? this.isExtra,
      sortOrder: sortOrder ?? this.sortOrder,
      sharedByPersonIds: sharedByPersonIds ?? List.of(this.sharedByPersonIds),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'event_id': eventId,
        'name': name,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': totalPrice,
        'is_extra': isExtra ? 1 : 0,
        'sort_order': sortOrder,
      };

  factory ReceiptItem.fromMap(Map<String, dynamic> map) => ReceiptItem(
        id: map['id'] as String,
        eventId: map['event_id'] as String,
        name: map['name'] as String,
        quantity: (map['quantity'] as num).toDouble(),
        unitPrice: (map['unit_price'] as num).toInt(),
        totalPrice: (map['total_price'] as num).toInt(),
        isExtra: (map['is_extra'] as int) == 1,
        sortOrder: (map['sort_order'] as int?) ?? 0,
      );
}
