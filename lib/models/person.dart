class Person {
  final String id;
  final String name;
  final String createdAt;

  Person({required this.id, required this.name, required this.createdAt});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'created_at': createdAt,
      };

  factory Person.fromMap(Map<String, dynamic> map) => Person(
        id: map['id'] as String,
        name: map['name'] as String,
        createdAt: map['created_at'] as String,
      );

  Person copyWith({String? name}) => Person(
        id: id,
        name: name ?? this.name,
        createdAt: createdAt,
      );
}
