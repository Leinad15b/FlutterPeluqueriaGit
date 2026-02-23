import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/api_models.dart';

class ApiService {
  // Ajusta tu IP: 10.0.2.2 (emulador) o IP local (móvil físico)
  static const String baseUrl = 'http://192.168.1.144:8080/api';
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
    // Read stored userId - the backend has no buscar endpoint, uses /{id}
    final idStr = await _storage.read(key: 'user_id');
    if (idStr == null || idStr == 'null') {
      print("⚠️ No hay user_id almacenado, no se puede cargar el perfil");
      return null;
    }
    final url = Uri.parse('$baseUrl/usuarios/$idStr');
    try {
      final headers = await _getHeaders();
      print("📡 GET perfil: $url");
      final response = await http.get(url, headers: headers);
      print("📡 Status: ${response.statusCode} body: ${response.body.substring(0, response.body.length.clamp(0, 300))}");
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
      final file = File(path);
      if (!await file.exists()) {
        print("Archivo no encontrado: $path");
        return null;
      }
      final bytes = await file.readAsBytes();
      print("imagen cargada: ${bytes.length} bytes");
      return base64Encode(bytes);
    } catch (e) {
      print("Error convirtiendo imagen: $e");
      return null;
    }
  }

  // Convierte un XFile directamente (más fiable en Android)
  static Future<String?> xFileToBase64(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      print("imagen desde XFile: ${bytes.length} bytes");
      return base64Encode(bytes);
    } catch (e) {
      print("Error xFileToBase64: $e");
      return null;
    }
  }

  static Future<Valoracion?> getValoracionPorCita(int citaId) async {
    final url = Uri.parse('$baseUrl/valoraciones/cita/$citaId');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return Valoracion.fromJson(data);
      }
    } catch (e) {
      print("Excepción getValoracionPorCita: $e");
    }
    return null;
  }

  static Future<bool> crearValoracion(ValoracionRequest request) async {
    final url = Uri.parse('$baseUrl/valoraciones');
    try {
      final body = jsonEncode(request.toJson());
      print("📤 POST valoracion body: $body");
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: body,
      );
      print("📥 crearValoracion status: ${response.statusCode} body: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
    } catch (e) {
      print("Error crearValoracion: $e");
      return false;
    }
  }

  static Future<bool> actualizarValoracion(int valoracionId, ValoracionRequest request) async {
    final url = Uri.parse('$baseUrl/valoraciones/$valoracionId');
    try {
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(request.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error actualizarValoracion: $e");
      return false;
    }
  }

  static Future<bool> eliminarValoracion(int valoracionId) async {
    final url = Uri.parse('$baseUrl/valoraciones/$valoracionId');
    try {
      final response = await http.delete(url, headers: await _getHeaders());
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error eliminarValoracion: $e");
      return false;
    }
  }
}