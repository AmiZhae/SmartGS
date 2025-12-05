import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.getOrderHistory(token);

      _orders = (data['orders'] as List)
          .map((order) => Order.fromJson(order))
          .toList();
    } catch (e, stackTrace) {
      _error = e.toString();
      log(
        'Error loading orders: $e',
        name: 'OrderProvider',
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
