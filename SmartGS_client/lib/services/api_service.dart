import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<Map<String, dynamic>> signup(
    String username,
    String email,
    String password,
    String phone,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Signup failed');
    }
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
    String token, {
    String? email,
    String? phone,
  }) async {
    final Map<String, dynamic> body = {};
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;

    final response = await http.put(
      Uri.parse('$baseUrl/profile/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['detail'] ?? 'Failed to update profile',
      );
    }
  }

  static Future<Map<String, dynamic>> changePassword(
    String token, {
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['detail'] ?? 'Failed to change password',
      );
    }
  }

  static Future<List<dynamic>> getAllProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['products'];
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<dynamic>> getProductsByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$category'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['products'];
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<Map<String, dynamic>> addToCart(
    String token,
    int productId,
    int quantity,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['detail'] ?? 'Failed to add to cart',
      );
    }
  }

  static Future<List<dynamic>> getCart(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['cart'];
    } else {
      throw Exception('Failed to load cart');
    }
  }

  static Future<Map<String, dynamic>> updateCart(
    String token,
    int productId,
    int quantity,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cart/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update cart');
    }
  }

  static Future<Map<String, dynamic>> deleteFromCart(
    String token,
    int productId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/delete/$productId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete from cart');
    }
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
    String token,
    double amount,
    List<Map<String, dynamic>> items,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payment/create-payment-intent'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'amount': amount, 'items': items}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['detail'] ??
            'Failed to create payment intent',
      );
    }
  }

  static Future<Map<String, dynamic>> checkout(
    String token,
    List<Map<String, dynamic>> items,
    String paymentIntentId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/order/checkout?payment_intent_id=$paymentIntentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'items': items}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['detail'] ?? 'Failed to checkout',
      );
    }
  }

  static Future<Map<String, dynamic>> getOrderHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/order/history'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load order history');
    }
  }
}
