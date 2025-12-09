import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/firebase_service.dart';

class EventProvider with ChangeNotifier {
  // ============================================
  // ESTADO
  // ============================================

  List<Event> _events = [];
  List<Event> _todayEvents = [];
  List<Event> _reminders = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  // ============================================
  // GETTERS
  // ============================================

  List<Event> get events => _events;
  List<Event> get todayEvents => _todayEvents;
  List<Event> get reminders => _reminders;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Eventos para la fecha seleccionada
  List<Event> get eventsForSelectedDate {
    return _events.where((event) {
      return event.eventDate.year == _selectedDate.year &&
          event.eventDate.month == _selectedDate.month &&
          event.eventDate.day == _selectedDate.day;
    }).toList();
  }

  // Eventos próximos (próximos 7 días)
  List<Event> get upcomingEvents {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return _events.where((event) {
      return event.eventDate.isAfter(now) &&
          event.eventDate.isBefore(nextWeek) &&
          event.isActive;
    }).toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
  }

  // Verificar si una fecha tiene eventos
  bool hasEventsOnDate(DateTime date) {
    return _events.any((event) =>
        event.eventDate.year == date.year &&
        event.eventDate.month == date.month &&
        event.eventDate.day == date.day &&
        event.isActive);
  }

  // ============================================
  // ACCIONES - CARGAR DATOS
  // ============================================

  // Cargar todos los eventos
  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cargar eventos activos
      _events = await FirebaseService.getActiveEvents();

      // Filtrar eventos de hoy
      _todayEvents = await FirebaseService.getTodayEvents();

      // Cargar recordatorios (próximos 7 días)
      _reminders = await FirebaseService.getUpcomingReminders(days: 7);
    } catch (e) {
      _error = 'Error al cargar eventos: ${e.toString()}';
      debugPrint('❌ Error en EventProvider.loadAll: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar solo eventos activos
  Future<void> loadActiveEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await FirebaseService.getActiveEvents();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error en loadActiveEvents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar todos los eventos (incluye inactivos - para admin)
  Future<void> loadAllEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await FirebaseService.getAllEvents();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error en loadAllEvents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar eventos por rango de fechas
  Future<void> loadEventsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await FirebaseService.getEventsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error en loadEventsByDateRange: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar eventos de hoy
  Future<void> loadTodayEvents() async {
    try {
      _todayEvents = await FirebaseService.getTodayEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error en loadTodayEvents: $e');
    }
  }

  // Cargar recordatorios
  Future<void> loadReminders({int days = 7}) async {
    try {
      _reminders = await FirebaseService.getUpcomingReminders(days: days);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error en loadReminders: $e');
    }
  }

  // Refrescar todo
  Future<void> refresh() async {
    await loadAll();
  }

  // ============================================
  // ACCIONES - CRUD
  // ============================================

  // Crear evento
  Future<bool> createEvent(Event event) async {
    try {
      final newEvent = await FirebaseService.createEvent(event);
      _events.insert(0, newEvent);

      // Actualizar listas específicas si aplica
      if (newEvent.isToday) {
        _todayEvents.add(newEvent);
      }
      if (newEvent.isReminder && newEvent.daysUntilEvent <= 7) {
        _reminders.add(newEvent);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al crear evento: ${e.toString()}';
      debugPrint('❌ Error en createEvent: $e');
      notifyListeners();
      return false;
    }
  }

  // Actualizar evento
  Future<bool> updateEvent(String id, Event event) async {
    try {
      final updatedEvent = await FirebaseService.updateEvent(id, event);

      // Actualizar en la lista principal
      final index = _events.indexWhere((e) => e.id == id);
      if (index != -1) {
        _events[index] = updatedEvent;
      }

      // Actualizar en eventos de hoy si aplica
      final todayIndex = _todayEvents.indexWhere((e) => e.id == id);
      if (todayIndex != -1) {
        if (updatedEvent.isToday) {
          _todayEvents[todayIndex] = updatedEvent;
        } else {
          _todayEvents.removeAt(todayIndex);
        }
      } else if (updatedEvent.isToday) {
        _todayEvents.add(updatedEvent);
      }

      // Actualizar en recordatorios si aplica
      final reminderIndex = _reminders.indexWhere((e) => e.id == id);
      if (reminderIndex != -1) {
        if (updatedEvent.isReminder && updatedEvent.daysUntilEvent <= 7) {
          _reminders[reminderIndex] = updatedEvent;
        } else {
          _reminders.removeAt(reminderIndex);
        }
      } else if (updatedEvent.isReminder && updatedEvent.daysUntilEvent <= 7) {
        _reminders.add(updatedEvent);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar evento: ${e.toString()}';
      debugPrint('❌ Error en updateEvent: $e');
      notifyListeners();
      return false;
    }
  }

  // Eliminar evento
  Future<bool> deleteEvent(String id) async {
    try {
      await FirebaseService.deleteEvent(id);

      _events.removeWhere((e) => e.id == id);
      _todayEvents.removeWhere((e) => e.id == id);
      _reminders.removeWhere((e) => e.id == id);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar evento: ${e.toString()}';
      debugPrint('❌ Error en deleteEvent: $e');
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // ACCIONES - NAVEGACIÓN
  // ============================================

  // Seleccionar fecha
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Ir a hoy
  void goToToday() {
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============================================
  // UTILIDADES
  // ============================================

  // Obtener eventos por mes
  List<Event> getEventsForMonth(int year, int month) {
    return _events
        .where((event) =>
            event.eventDate.year == year &&
            event.eventDate.month == month &&
            event.isActive)
        .toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
  }

  // Obtener estadísticas
  Map<String, int> getStatistics() {
    return {
      'total': _events.where((e) => e.isActive).length,
      'today': _todayEvents.length,
      'upcoming': upcomingEvents.length,
      'reminders': _reminders.length,
      'past': _events.where((e) => e.isPast && e.isActive).length,
    };
  }
}
