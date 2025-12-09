import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/firebase_service.dart'; // 🔥 Cambio aquí

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await FirebaseService.getCategories(); // 🔥 Cambio aquí
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory(Category category) async {
    try {
      final newCategory = await FirebaseService.createCategory(category); // 🔥 Cambio aquí
      _categories.add(newCategory);
      _categories.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await FirebaseService.deleteCategory(id); // 🔥 Cambio aquí
      _categories.removeWhere((c) => c.id == id);
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