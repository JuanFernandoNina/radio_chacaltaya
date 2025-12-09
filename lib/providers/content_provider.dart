import 'package:flutter/material.dart';
import '../models/radio_content.dart';
import '../services/firebase_service.dart'; // 🔥 Cambio aquí

class ContentProvider extends ChangeNotifier {
  List<RadioContent> _contents = [];
  bool _isLoading = false;
  String? _error;

  List<RadioContent> get contents => _contents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar contenido activo (para usuarios)
  Future<void> loadActiveContent() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contents = await FirebaseService.getActiveContent(); // 🔥 Cambio aquí
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar todo el contenido (para admin)
  Future<void> loadAllContent() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contents = await FirebaseService.getAllContent(); // 🔥 Cambio aquí
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear contenido
  Future<bool> createContent(RadioContent content) async {
    try {
      final newContent = await FirebaseService.createContent(content); // 🔥 Cambio aquí
      _contents.insert(0, newContent);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Actualizar contenido
  Future<bool> updateContent(String id, RadioContent content) async {
    try {
      final updatedContent = await FirebaseService.updateContent(id, content); // 🔥 Cambio aquí
      final index = _contents.indexWhere((c) => c.id == id);
      if (index != -1) {
        _contents[index] = updatedContent;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Eliminar contenido
  Future<bool> deleteContent(String id) async {
    try {
      await FirebaseService.deleteContent(id); // 🔥 Cambio aquí
      _contents.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}