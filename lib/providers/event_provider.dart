import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/firebase_service.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  List<Event> _todayEvents = [];
  List<Event> _reminders = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  // Getters
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

  // Verificar si una fecha tiene eventos
  bool hasEventsOnDate(DateTime date) {
    return _events.any((event) =>
      event.eventDate.year == date.year &&
      event.eventDate.month == date.month &&
      event.eventDate.day == date.day
    );
  }

  // Cargar todos los datos
  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 Cargando todos los eventos...');
      
      _events = await FirebaseService.getActiveEvents();
      _todayEvents = await FirebaseService.getTodayEvents();
      _reminders = await FirebaseService.getUpcomingReminders(days: 7);
      
      print('✅ Cargados: ${_events.length} eventos, ${_todayEvents.length} hoy, ${_reminders.length} recordatorios');
    } catch (e) {
      _error = 'Error al cargar eventos: $e';
      print('❌ Error en loadAll: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refrescar
  Future<void> refresh() async {
    await loadAll();
  }

  // Seleccionar fecha
  void selectDate(DateTime date) {
    _selectedDate = date;
    print('📅 Fecha seleccionada: $date');
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}