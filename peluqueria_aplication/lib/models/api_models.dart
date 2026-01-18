class AuthResponse {
  final String token;
  final String username;
  final List<String> roles;

  AuthResponse({
    required this.token,
    required this.username,
    required this.roles,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['accessToken'] ?? json['token'] ?? "",
      username: json['username'] ?? "",
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    );
  }
}

class UserProfile {
  final int id;
  final String username;
  final String email;
  final String telefono;
  final String alergenos;
  final String afecciones;
  final String? fotoBase64;
  final String defaultImage = "https://i.imgur.com/lB5bLMY.jpg";

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.telefono = "",
    this.alergenos = "",
    this.afecciones = "",
    this.fotoBase64,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      username: json['username'] ?? "",
      email: json['email'] ?? "",
      telefono: json['telefono'] ?? "",
      alergenos: json['alergenos'] ?? "",
      afecciones: json['afecciones'] ?? "",
      fotoBase64: json['fotoBase64'],
    );
  }
}

class ServiceModel {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int duracionBloques;
  final String categoria;
  final String? imageBase64;
  final int likesCount;
  final bool isLikedByMe;

  final String defaultImagePath = "https://i.imgur.com/L4yT2xR.jpeg";

  String get titulo => nombre;
  int get duracion => duracionBloques;

  ServiceModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.duracionBloques,
    required this.categoria,
    this.imageBase64,
    this.likesCount = 0,
    this.isLikedByMe = false,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? "",
      precio: (json['precio'] as num).toDouble(),
      duracionBloques: json['duracion_minutos'] ?? 30,
      categoria: json['categoria'] ?? "General",
      imageBase64: json['imageBase64'],
      likesCount: json['likesCount'] ?? json['likes'] ?? 0, 
      isLikedByMe: json['likedByMe'] ?? false,
    );
  }
}

class SlotDTO {
  final String start;
  final String end;
  final bool available;

  SlotDTO({required this.start, required this.end, required this.available});

  factory SlotDTO.fromJson(Map<String, dynamic> json) {
    return SlotDTO(
     
      start: json['horaInicio'] ?? "00:00", 
      end: json['horaFin'] ?? "00:00",
      available: json['disponible'] ?? false,
    );
  }
}

class Cita {
  final int id;
  final String servicioNombre;
  final String fecha;
  final String horaInicio;
  final String estado;

  Cita({
    required this.id,
    required this.servicioNombre,
    required this.fecha,
    required this.horaInicio,
    required this.estado,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    String nombreServicio = "Servicio";

    if (json['servicio'] != null && json['servicio'] is Map) {
      nombreServicio = json['servicio']['nombre'] ?? "Servicio";
    } else if (json['servicioNombre'] != null) {
        nombreServicio = json['servicioNombre'];
    }

    return Cita(
      id: json['id'],
      servicioNombre: nombreServicio,
      fecha: json['fecha'] ?? "",
      horaInicio: json['horaInicio'] ?? "",
      estado: json['estado'] ?? "PENDIENTE",
    );
  }
}