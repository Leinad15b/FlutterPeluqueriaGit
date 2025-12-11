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
      token: json['token'],
      username: json['username'],
      roles: List<String>.from(json['roles']),
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
      id: json['id'],
      username: json['username'],
      email: json['email'],
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
      descripcion: json['descripcion'],
      precio: (json['precio'] as num).toDouble(),
      duracionBloques: json['duracion_bloques'] ?? 30,
      categoria: json['categoria'] ?? "General",
      imageBase64: json['imageBase64'],
      likesCount: json['likesCount'] ?? 0,
      isLikedByMe: json['likedByMe'] ?? false,
    );
  }
}
