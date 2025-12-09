import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final String screen; // 'home', 'grupos', 'both'
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.screen = 'home',
    required this.createdAt,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'],
      color: data['color'],
      screen: data['screen'] ?? 'home',
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      'screen': screen,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
