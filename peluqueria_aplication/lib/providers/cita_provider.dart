import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/api_models.dart';
import 'auth_provider.dart';

class CitaProvider extends ChangeNotifier {
  final AuthProvider authProvider;

  CitaProvider(this.authProvider);

  List<SlotDTO> _slots = [];
  List<Cita> _misCitas = [];
  bool _isLoading = false;

  List<SlotDTO> get slots => _slots;
  List<Cita> get misCitas => _misCitas;
  bool get isLoading => _isLoading;

  Future<void> loadDisponibilidad(int servicioId, DateTime fecha) async {
    _isLoading = true;
    _slots = [];
    notifyListeners();

    final dateStr = "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
    final url = Uri.parse('${authProvider.baseUrl}/citas/disponibilidad?servicioId=$servicioId&fecha=$dateStr');

    try {
      final headers = await authProvider.getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _slots = data.map((json) => SlotDTO.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error cargando disponibilidad: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> reservarCita(int servicioId, DateTime fecha, SlotDTO slot) async {
    _isLoading = true;
    notifyListeners();

    // Use the bloqueHorarioId from the slot returned by the availability endpoint.
    // If it's null (old backend without the field), fall back to deriving from date.
    final int bloqueId = slot.bloqueHorarioId ?? _getBloqueIdFromDate(fecha);

    final body = {
      "servicioId": servicioId,
      "bloqueHorarioId": bloqueId,
      "fecha": "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}",
      "horaInicio": slot.start,
    };

    print("Reservando cita: $body");

    final url = Uri.parse('${authProvider.baseUrl}/citas/reservar');

    try {
      final headers = await authProvider.getAuthHeaders();
      final response = await http.post(url, headers: headers, body: jsonEncode(body));

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        return {"success": true, "msg": "Cita reservada"};
      } else {
        // Try to parse error message from backend
        String errorMsg = response.body;
        try {
          final decoded = jsonDecode(response.body);
          errorMsg = decoded['error'] ?? decoded['message'] ?? decoded['msg'] ?? response.body;
        } catch (_) {}
        print("Error reservar: ${response.statusCode} - $errorMsg");
        return {"success": false, "msg": errorMsg};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {"success": false, "msg": "Error de conexión: $e"};
    }
  }

  /// Fallback: derive a block ID from day of week (1=Mon ... 7=Sun)
  int _getBloqueIdFromDate(DateTime fecha) {
    return fecha.weekday; // weekday: 1=Monday, 7=Sunday
  }

  Future<void> fetchMisCitas() async {
    _isLoading = true;
    notifyListeners();
    
    final url = Uri.parse('${authProvider.baseUrl}/citas/mis-citas');
    
    try {
      final headers = await authProvider.getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        _misCitas = data.map((json) => Cita.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error mis citas: $e");
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> cancelarCita(int citaId) async {
    final url = Uri.parse('${authProvider.baseUrl}/citas/$citaId');
    final body = {"estado": "CANCELADA"};

    try {
      final headers = await authProvider.getAuthHeaders();
      final response = await http.put(url, headers: headers, body: jsonEncode(body));
      
      if (response.statusCode == 200) {
        await fetchMisCitas();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}