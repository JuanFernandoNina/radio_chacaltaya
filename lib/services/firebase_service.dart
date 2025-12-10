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

  static Future<List<Event>> getActiveEvents() async {
    try {
      print('🔍 Cargando eventos activos...');
      
      final snapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .get();

      print('✅ Eventos encontrados: ${snapshot.docs.length}');
      
      final events = snapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .toList();
      
      // Ordenar por fecha en memoria
      events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      
      return events;
    } catch (e) {
      print('❌ Error en getActiveEvents: $e');
      rethrow;
    }
  }

  static Future<List<Event>> getTodayEvents() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Error en getTodayEvents: $e');
      return [];
    }
  }

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
          .get();

      final events = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
      events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      
      return events;
    } catch (e) {
      print('❌ Error en getUpcomingReminders: $e');
      return [];
    }
  }

  static Future<Event> createEvent(Event event) async {
    final docRef = await _firestore.collection('events').add(event.toFirestore());
    final doc = await docRef.get();
    return Event.fromFirestore(doc);
  }

  static Future<void> deleteEvent(String id) async {
    await _firestore.collection('events').doc(id).delete();
  }
  static Future<Event> updateEvent(String id, Event event) async {
    await _firestore.collection('events').doc(id).update(event.toFirestore());
    final doc = await _firestore.collection('events').doc(id).get();
    return Event.fromFirestore(doc);
  } 
}