import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../models/api_service.dart';

class UserManager {
  static ValueNotifier<UserProfile?> profileNotifier = ValueNotifier(null);

  static Future<void> loadProfile(String username) async {
    UserProfile? profile = await ApiService.getUserProfile(username);
    if (profile != null) {
      profileNotifier.value = profile;
    }
  }

  static void clear() {
    profileNotifier.value = null;
  }
}
