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
      // Backend may return 'fotoBase64' or 'foto_base64'
      fotoBase64: json['fotoBase64'] ?? json['foto_base64'],
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
  final int? bloqueHorarioId;

  SlotDTO({required this.start, required this.end, required this.available, this.bloqueHorarioId});

  factory SlotDTO.fromJson(Map<String, dynamic> json) {
    return SlotDTO(
      start: json['horaInicio'] ?? "00:00",
      end: json['horaFin'] ?? "00:00",
      available: json['disponible'] ?? false,
      bloqueHorarioId: json['bloqueHorarioId'],
    );
  }
}

class Cita {
  final int id;
  final String servicioNombre;
  final int? servicioId;   // needed for valoracion request
  final String fecha;
  final String horaInicio;
  final String estado;

  Cita({
    required this.id,
    required this.servicioNombre,
    this.servicioId,
    required this.fecha,
    required this.horaInicio,
    required this.estado,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    String nombreServicio = "Servicio";
    int? servId;

    if (json['servicio'] != null && json['servicio'] is Map) {
      nombreServicio = json['servicio']['nombre'] ?? "Servicio";
      servId = json['servicio']['id'];
    } else if (json['servicioNombre'] != null) {
      nombreServicio = json['servicioNombre'];
    }
    // also try flat field
    servId ??= json['servicioId'];

    return Cita(
      id: json['id'],
      servicioNombre: nombreServicio,
      servicioId: servId,
      fecha: json['fecha'] ?? "",
      horaInicio: json['horaInicio'] ?? "",
      estado: json['estado'] ?? "PENDIENTE",
    );
  }
}

class Valoracion {
  final int id;
  final int citaId;
  final String comentario;
  final int calificacion;
  final String? imagenBase64;
  final String fecha;

  Valoracion({
    required this.id,
    required this.citaId,
    required this.comentario,
    required this.calificacion,
    this.imagenBase64,
    required this.fecha,
  });

  factory Valoracion.fromJson(Map<String, dynamic> json) {
    return Valoracion(
      id: json['id'] ?? 0,
      citaId: json['cita']?['id'] ?? json['citaId'] ?? 0,
      comentario: json['comentario'] ?? "",
      calificacion: json['calificacion'] ?? 0,
      imagenBase64: json['imagenBase64'],
      fecha: json['fecha'] ?? "",
    );
  }
}

class ValoracionRequest {
  final int citaId;
  final int calificacion;
  final String comentario;
  final String? imagenBase64;
  final int? usuarioId;
  final int? servicioId;

  ValoracionRequest({
    required this.citaId,
    required this.calificacion,
    required this.comentario,
    this.imagenBase64,
    this.usuarioId,
    this.servicioId,
  });

  Map<String, dynamic> toJson() {
    return {
      "citaId": citaId,
      if (usuarioId != null) "usuarioId": usuarioId,
      if (servicioId != null) "servicioId": servicioId,
      "calificacion": calificacion,
      "comentario": comentario,
      if (imagenBase64 != null) "imagenBase64": imagenBase64,
    };
  }
}