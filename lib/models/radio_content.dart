import 'package:cloud_firestore/cloud_firestore.dart';

class RadioContent {
  final String id;
  final String title;
  final String? description;
  final String? videoUrl;
  final String? audioUrl;
  final String? thumbnailUrl;
  final bool isActive;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RadioContent({
    required this.id,
    required this.title,
    this.description,
    this.videoUrl,
    this.audioUrl,
    this.thumbnailUrl,
    this.isActive = true,
    this.categoryId,
    required this.createdAt,
    this.updatedAt,
  });

  factory RadioContent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RadioContent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      videoUrl: data['video_url'],
      audioUrl: data['audio_url'],
      thumbnailUrl: data['thumbnail_url'],
      isActive: data['is_active'] ?? true,
      categoryId: data['category_id'],
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
      'video_url': videoUrl,
      'audio_url': audioUrl,
      'thumbnail_url': thumbnailUrl,
      'is_active': isActive,
      'category_id': categoryId,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
