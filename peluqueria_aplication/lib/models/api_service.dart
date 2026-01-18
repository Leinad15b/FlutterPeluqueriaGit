import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/api_models.dart';

class ApiService {
  // Ajusta tu IP: 10.0.2.2 (emulador) o IP local (móvil físico)
  static const String baseUrl = 'http://192.168.1.144:8081/api';
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, String>> _getHeaders({bool withToken = true}) async {
    Map<String, String> headers = {"Content-Type": "application/json"};
    if (withToken) {
      final token = await _storage.read(key: 'jwt_token');
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      } else {
        print("⚠️ ALERTA: No se encontró token en SecureStorage");
      }
    }
    return headers;
  }

  
  static Future<List<ServiceModel>> getServices() async {
    final url = Uri.parse('$baseUrl/servicios');
    try {
     
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        print("Error GetServices: ${response.statusCode}");
      }
    } catch (e) {
      print("Excepción getServices: $e");
    }
    return [];
  }


  static Future<bool> toggleLike(int serviceId) async {
    final url = Uri.parse('$baseUrl/servicios/$serviceId/like');
    try {
      final response = await http.post(url, headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) {
      print("Error toggleLike: $e");
      return false;
    }
  }


  static Future<UserProfile?> getUserProfile(String username) async {
    final url = Uri.parse('$baseUrl/usuarios/buscar?username=$username');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return UserProfile.fromJson(data);
      } else {
        print("Error GetProfile: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Excepción getUserProfile: $e");
    }
    return null;
  }


  static Future<bool> updateProfile(String username, UserProfile updatedProfile) async {
   
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
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print("Error UpdateProfile: ${response.statusCode} -> ${response.body}");
        return false;
      }
    } catch (e) {
      print("Excepción updateProfile: $e");
      return false;
    }
  }

  static Future<String?> imageToBase64(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print("Error convirtiendo imagen: $e");
      return null;
    }
  }
}