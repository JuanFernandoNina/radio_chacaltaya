import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? startTime;
  final String? endTime;
  final String? imageUrl;
  final bool isReminder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    this.startTime,
    this.endTime,
    this.imageUrl,
    this.isReminder = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  // Desde Firestore
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Event(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String?,
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      startTime: data['startTime'] as String?,
      endTime: data['endTime'] as String?,
      imageUrl: data['imageUrl'] as String?,
      isReminder: data['isReminder'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // A Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'startTime': startTime,
      'endTime': endTime,
      'imageUrl': imageUrl,
      'isReminder': isReminder,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Helpers
  String get timeRange {
    if (startTime != null && endTime != null) {
      return '$startTime - $endTime';
    } else if (startTime != null) {
      return startTime!;
    }
    return '';
  }

  bool get isToday {
    final now = DateTime.now();
    return eventDate.year == now.year &&
           eventDate.month == now.month &&
           eventDate.day == now.day;
  }

  @override
  String toString() => 'Event(id: $id, title: $title, date: $eventDate)';
}