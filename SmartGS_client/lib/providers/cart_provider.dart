import 'dart:developer';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  Future<void> loadCart(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.getCart(token);
      _cartItems = data.map((json) => CartItem.fromJson(json)).toList();
    } catch (e, stackTrace) {
      _error = e.toString();
      log(
        'Error loading cart: $e',
        name: 'CartProvider',
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(String token, int productId, int quantity) async {
    try {
      await ApiService.addToCart(token, productId, quantity);
      await loadCart(token);
    } catch (e, stackTrace) {
      _error = e.toString();
      log(
        'Error adding to cart: $e',
        name: 'CartProvider',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> updateQuantity(String token, int productId, int quantity) async {
    try {
      await ApiService.updateCart(token, productId, quantity);
      await loadCart(token);
    } catch (e, stackTrace) {
      _error = e.toString();
      log(
        'Error updating cart quantity: $e',
        name: 'CartProvider',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> removeFromCart(String token, int productId) async {
    try {
      await ApiService.deleteFromCart(token, productId);
      await loadCart(token);
    } catch (e, stackTrace) {
      _error = e.toString();
      log(
        'Error removing from cart: $e',
        name: 'CartProvider',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void clearCart() {
    _cartItems = [];
    notifyListeners();
  }

  Future<Map<String, dynamic>> checkout(
    String token,
    List<Map<String, dynamic>> items, {
    required String paymentIntentId,
  }) async {
    if (_cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    try {
      final response = await ApiService.checkout(token, items, paymentIntentId);
      clearCart();
      return response;
    } catch (e, stackTrace) {
      _error = e.toString();
      log('Checkout failed: $e', name: 'CartProvider', stackTrace: stackTrace);
      rethrow;
    }
  }
}
