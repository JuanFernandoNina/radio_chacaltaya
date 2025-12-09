import 'package:cloud_firestore/cloud_firestore.dart';

class CarouselItem {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final String? linkUrl;
  final bool isActive;
  final int orderPosition;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CarouselItem({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.linkUrl,
    this.isActive = true,
    this.orderPosition = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory CarouselItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CarouselItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      imageUrl: data['image_url'] ?? '',
      linkUrl: data['link_url'],
      isActive: data['is_active'] ?? true,
      orderPosition: data['order_position'] ?? 0,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'link_url': linkUrl,
      'is_active': isActive,
      'order_position': orderPosition,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
