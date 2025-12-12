import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_models.dart';

class ApiService {
  // Recuerda: 10.0.2.2 para emulador, tu IP local para móvil físico
  static const String baseUrl = 'http://10.0.2.2:8081/api';

  static Future<Map<String, String>> _getHeaders(
      {bool withToken = true}) async {
    Map<String, String> headers = {"Content-Type": "application/json"};
    if (withToken) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  static Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/signin');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(withToken: false),
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', authResponse.token);
        await prefs.setString('username', authResponse.username);
        return true;
      }
      return false;
    } catch (e) {+
      print("Error Login: $e");
      return false;
    }
  }

  static Future<bool> register(
      String username, String email, String password, String role) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(withToken: false),
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
          "role": [role]
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<List<ServiceModel>> getServices() async {
    final url = Uri.parse('$baseUrl/servicios');
    try {
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error getServices: $e");
    }
    return [];
  }

  static Future<bool> toggleLike(int serviceId) async {
    final url = Uri.parse('$baseUrl/servicios/$serviceId/like');
    try {
      final response = await http.post(url, headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<UserProfile?> getUserProfile(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final url = Uri.parse('$baseUrl/usuarios/buscar?username=$username');

    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return UserProfile.fromJson(data);
      }
    } catch (e) {
      print("Error Perfil: $e");
    }
    return null;
  }

  static Future<bool> updateProfile(
      String username, UserProfile updatedProfile) async {
    final url = Uri.parse('$baseUrl/usuarios/${updatedProfile.id}');

    try {
      final headers = await _getHeaders();

      final body = jsonEncode({
        "email": updatedProfile.email,
        "telefono": updatedProfile.telefono,
        "alergenos": updatedProfile.alergenos,
        "afecciones": updatedProfile.afecciones,
        "fotoBase64": updatedProfile.fotoBase64
      });

      final response = await http.put(url, headers: headers, body: body);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error al actualizar perfil: $e");
      return false;
    }
  }

  static Future<String?> imageToBase64(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }
}
