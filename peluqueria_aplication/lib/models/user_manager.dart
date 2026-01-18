import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../models/api_service.dart';

class UserManager {
  static ValueNotifier<UserProfile?> profileNotifier = ValueNotifier(null);

  static Future<void> loadProfile(String username) async {
    try {
      UserProfile? profile = await ApiService.getUserProfile(username);
      if (profile != null) {
        profileNotifier.value = profile;
      } else {
        print("⚠️ No se pudo cargar el perfil para $username");
      }
    } catch (e) {
      print("Error en UserManager: $e");
    }
  }

  static void clear() {
    profileNotifier.value = null;
  }
}