import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/api_models.dart';

class AuthProvider extends ChangeNotifier {
  final String baseUrl = 'http://192.168.1.144:8080/api'; 
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  String? _token;
  String? _username;

  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get username => _username;
  int? _userId;
  int? get userId => _userId;

  Future<bool> checkSession() async {
    _token = await _storage.read(key: 'jwt_token');
    _username = await _storage.read(key: 'username');
    final idStr = await _storage.read(key: 'user_id');
    _userId = idStr != null ? int.tryParse(idStr) : null;

    if (_token != null && _username != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseUrl/auth/signin');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['accessToken'];
        _username = data['username'];
        _userId = data['id'];

        await _storage.write(key: 'jwt_token', value: _token);
        await _storage.write(key: 'username', value: _username);
        await _storage.write(key: 'user_id', value: _userId.toString());
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Error Login: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final url = Uri.parse('$baseUrl/auth/signup');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": name,
          "email": email,
          "password": password,
          "role": ["cliente"]
        }),
      );
      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _username = null;
    _userId = null;
    await _storage.deleteAll();
    notifyListeners();
  }
  
  Future<Map<String, String>> getAuthHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }
}