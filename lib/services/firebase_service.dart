import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/radio_content.dart';
import '../models/category.dart';
import '../models/carousel_item.dart';
import '../models/event.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================
  // AUTHENTICATION
  // ============================================

  static Future<UserCredential> signInWithEmail(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  static Future<bool> isAdmin() async {
    if (currentUser == null) return false;

    try {
      final doc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // CATEGORIES
  // ============================================

  static Future<List<Category>> getCategories() async {
    final snapshot = await _firestore
        .collection('categories')
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Category(
        id: doc.id,
        name: data['name'] ?? '',
        icon: data['icon'],
        color: data['color'],
        screen: data['screen'] ?? 'home',
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  static Future<List<Category>> getCategoriesByScreen(String screen) async {
    final snapshot = await _firestore
        .collection('categories')
        .where('screen', whereIn: [screen, 'both'])
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Category(
        id: doc.id,
        name: data['name'] ?? '',
        icon: data['icon'],
        color: data['color'],
        screen: data['screen'] ?? 'home',
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  static Future<Category> createCategory(Category category) async {
    final docRef = await _firestore.collection('categories').add({
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
      'screen': category.screen,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final doc = await docRef.get();
    final data = doc.data()!;

    return Category(
      id: doc.id,
      name: data['name'],
      icon: data['icon'],
      color: data['color'],
      screen: data['screen'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  static Future<Category> updateCategory(String id, Category category) async {
    await _firestore.collection('categories').doc(id).update({
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
      'screen': category.screen,
    });

    final doc = await _firestore.collection('categories').doc(id).get();
    final data = doc.data()!;

    return Category(
      id: doc.id,
      name: data['name'],
      icon: data['icon'],
      color: data['color'],
      screen: data['screen'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  static Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();
  }

  // ============================================
  // RADIO CONTENT
  // ============================================

  static Future<List<RadioContent>> getActiveContent() async {
    final snapshot = await _firestore
        .collection('radio_content')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return _contentFromSnapshot(snapshot);
  }

  static Future<List<RadioContent>> getAllContent() async {
    final snapshot = await _firestore
        .collection('radio_content')
        .orderBy('createdAt', descending: true)
        .get();

    return _contentFromSnapshot(snapshot);
  }

  static Future<List<RadioContent>> getContentByCategory(
      String categoryId) async {
    final snapshot = await _firestore
        .collection('radio_content')
        .where('categoryId', isEqualTo: categoryId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return _contentFromSnapshot(snapshot);
  }

  static List<RadioContent> _contentFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return RadioContent(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'],
        videoUrl: data['videoUrl'],
        audioUrl: data['audioUrl'],
        thumbnailUrl: data['thumbnailUrl'],
        isActive: data['isActive'] ?? true,
        categoryId: data['categoryId'],
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  static Future<RadioContent> createContent(RadioContent content) async {
    final docRef = await _firestore.collection('radio_content').add({
      'title': content.title,
      'description': content.description,
      'videoUrl': content.videoUrl,
      'audioUrl': content.audioUrl,
      'thumbnailUrl': content.thumbnailUrl,
      'isActive': content.isActive,
      'categoryId': content.categoryId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final doc = await docRef.get();
    final data = doc.data()!;

    return RadioContent(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      videoUrl: data['videoUrl'],
      audioUrl: data['audioUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      isActive: data['isActive'],
      categoryId: data['categoryId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static Future<RadioContent> updateContent(
      String id, RadioContent content) async {
    await _firestore.collection('radio_content').doc(id).update({
      'title': content.title,
      'description': content.description,
      'videoUrl': content.videoUrl,
      'audioUrl': content.audioUrl,
      'thumbnailUrl': content.thumbnailUrl,
      'isActive': content.isActive,
      'categoryId': content.categoryId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final doc = await _firestore.collection('radio_content').doc(id).get();
    final data = doc.data()!;

    return RadioContent(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      videoUrl: data['videoUrl'],
      audioUrl: data['audioUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      isActive: data['isActive'],
      categoryId: data['categoryId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static Future<void> deleteContent(String id) async {
    await _firestore.collection('radio_content').doc(id).delete();
  }

  // ============================================
  // CAROUSEL
  // ============================================

  static Future<List<CarouselItem>> getActiveCarousel() async {
    final snapshot = await _firestore
        .collection('carousel')
        .where('isActive', isEqualTo: true)
        .orderBy('orderPosition', descending: false)
        .get();

    return _carouselFromSnapshot(snapshot);
  }

  static Future<List<CarouselItem>> getAllCarousel() async {
    final snapshot = await _firestore
        .collection('carousel')
        .orderBy('orderPosition', descending: false)
        .get();

    return _carouselFromSnapshot(snapshot);
  }

  static List<CarouselItem> _carouselFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return CarouselItem(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'],
        imageUrl: data['imageUrl'] ?? '',
        linkUrl: data['linkUrl'],
        isActive: data['isActive'] ?? true,
        orderPosition: data['orderPosition'] ?? 0,
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  static Future<CarouselItem> createCarousel(CarouselItem item) async {
    final docRef = await _firestore.collection('carousel').add({
      'title': item.title,
      'description': item.description,
      'imageUrl': item.imageUrl,
      'linkUrl': item.linkUrl,
      'isActive': item.isActive,
      'orderPosition': item.orderPosition,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final doc = await docRef.get();
    final data = doc.data()!;

    return CarouselItem(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      linkUrl: data['linkUrl'],
      isActive: data['isActive'],
      orderPosition: data['orderPosition'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static Future<CarouselItem> updateCarousel(
      String id, CarouselItem item) async {
    await _firestore.collection('carousel').doc(id).update({
      'title': item.title,
      'description': item.description,
      'imageUrl': item.imageUrl,
      'linkUrl': item.linkUrl,
      'isActive': item.isActive,
      'orderPosition': item.orderPosition,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final doc = await _firestore.collection('carousel').doc(id).get();
    final data = doc.data()!;

    return CarouselItem(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      linkUrl: data['linkUrl'],
      isActive: data['isActive'],
      orderPosition: data['orderPosition'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static Future<void> deleteCarousel(String id) async {
    await _firestore.collection('carousel').doc(id).delete();
  }

  // ============================================
  // EVENTS
  // ============================================

// ============================================
// EVENTS
// ============================================

  /// Obtener todos los eventos activos ordenados por fecha
  static Future<List<Event>> getActiveEvents() async {
    try {
      print('🔍 FirebaseService.getActiveEvents iniciando...');

      final snapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .orderBy('eventDate', descending: false)
          .get();

      print('✅ Query exitoso. Documentos: ${snapshot.docs.length}');

      // Mostrar datos crudos
      for (var doc in snapshot.docs) {
        print('   📄 Documento ${doc.id}:');
        print('      Data: ${doc.data()}');
      }

      final events = _eventsFromSnapshot(snapshot);
      print('✅ Eventos parseados: ${events.length}');

      return events;
    } catch (e, stackTrace) {
      print('❌ Error en getActiveEvents:');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Obtener TODOS los eventos (incluye inactivos - para admin)
  static Future<List<Event>> getAllEvents() async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .orderBy('eventDate', descending: false)
          .get();

      return _eventsFromSnapshot(snapshot);
    } catch (e) {
      print('❌ Error en getAllEvents: $e');
      rethrow;
    }
  }

  /// Obtener eventos por rango de fechas
  static Future<List<Event>> getEventsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .where('eventDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('eventDate', descending: false)
          .get();

      return _eventsFromSnapshot(snapshot);
    } catch (e) {
      print('❌ Error en getEventsByDateRange: $e');
      rethrow;
    }
  }

  /// Obtener eventos de hoy
  static Future<List<Event>> getTodayEvents() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      return await getEventsByDateRange(
        startDate: startOfDay,
        endDate: endOfDay,
      );
    } catch (e) {
      print('❌ Error en getTodayEvents: $e');
      rethrow;
    }
  }

  /// Obtener recordatorios próximos (eventos con isReminder=true)
  static Future<List<Event>> getUpcomingReminders({int days = 7}) async {
    try {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: days));

      final snapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .where('isReminder', isEqualTo: true)
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('eventDate', descending: false)
          .get();

      return _eventsFromSnapshot(snapshot);
    } catch (e) {
      print('❌ Error en getUpcomingReminders: $e');
      rethrow;
    }
  }

  /// Convertir QuerySnapshot a lista de Events
  static List<Event> _eventsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return Event.fromFirestore(doc);
      } catch (e) {
        print('❌ Error parseando evento ${doc.id}: $e');
        rethrow;
      }
    }).toList();
  }

  /// Crear un nuevo evento
  static Future<Event> createEvent(Event event) async {
    try {
      final docRef = await _firestore.collection('events').add({
        'title': event.title,
        'description': event.description,
        'eventDate': Timestamp.fromDate(event.eventDate),
        'startTime': event.startTime,
        'endTime': event.endTime,
        'imageUrl': event.imageUrl,
        'isReminder': event.isReminder,
        'isActive': event.isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await docRef.get();
      return Event.fromFirestore(doc);
    } catch (e) {
      print('❌ Error en createEvent: $e');
      rethrow;
    }
  }

  /// Actualizar un evento existente
  static Future<Event> updateEvent(String id, Event event) async {
    try {
      await _firestore.collection('events').doc(id).update({
        'title': event.title,
        'description': event.description,
        'eventDate': Timestamp.fromDate(event.eventDate),
        'startTime': event.startTime,
        'endTime': event.endTime,
        'imageUrl': event.imageUrl,
        'isReminder': event.isReminder,
        'isActive': event.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await _firestore.collection('events').doc(id).get();
      return Event.fromFirestore(doc);
    } catch (e) {
      print('❌ Error en updateEvent: $e');
      rethrow;
    }
  }

  /// Eliminar un evento
  static Future<void> deleteEvent(String id) async {
    try {
      await _firestore.collection('events').doc(id).delete();
    } catch (e) {
      print('❌ Error en deleteEvent: $e');
      rethrow;
    }
  }

  /// Alternar estado activo/inactivo de un evento
  static Future<void> toggleEventActive(String id, bool isActive) async {
    try {
      await _firestore.collection('events').doc(id).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error en toggleEventActive: $e');
      rethrow;
    }
  }

  /// Alternar recordatorio de un evento
  static Future<void> toggleEventReminder(String id, bool isReminder) async {
    try {
      await _firestore.collection('events').doc(id).update({
        'isReminder': isReminder,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error en toggleEventReminder: $e');
      rethrow;
    }
  }
}
