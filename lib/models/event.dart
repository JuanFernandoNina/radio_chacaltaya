import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? startTime; // Formato "HH:mm"
  final String? endTime;   // Formato "HH:mm"
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

  // 🔥 Desde Firestore (Firebase)
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

  // 🔥 A Firestore (para crear/actualizar)
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

  // ⚠️ DEPRECATED: Mantener para compatibilidad con código antiguo
  // TODO: Eliminar cuando todo use Firebase
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      imageUrl: json['image_url'] as String?,
      isReminder: json['is_reminder'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  // ⚠️ DEPRECATED: Mantener para compatibilidad
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'image_url': imageUrl,
      'is_reminder': isReminder,
      'is_active': isActive,
    };
  }

  // ============================================
  // HELPERS ÚTILES
  // ============================================
  
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

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return eventDate.year == tomorrow.year &&
           eventDate.month == tomorrow.month &&
           eventDate.day == tomorrow.day;
  }

  bool get isPast {
    final now = DateTime.now();
    final eventDateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      startTime != null ? int.parse(startTime!.split(':')[0]) : 0,
      startTime != null ? int.parse(startTime!.split(':')[1]) : 0,
    );
    return eventDateTime.isBefore(now);
  }

  int get daysUntilEvent {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    return eventDay.difference(today).inDays;
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? eventDate,
    String? startTime,
    String? endTime,
    String? imageUrl,
    bool? isReminder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      imageUrl: imageUrl ?? this.imageUrl,
      isReminder: isReminder ?? this.isReminder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, date: $eventDate, time: $timeRange)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}