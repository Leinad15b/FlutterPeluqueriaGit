import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class AppStrings {
  static Map<String, Map<String, String>> _strings = {
    // --- GENERAL ---
    'welcome': {'es': 'Bienvenido,', 'en': 'Welcome,'},
    'search': {'es': 'Buscar servicio...', 'en': 'Search service...'},
    'no_services': {'es': 'No hay servicios disponibles', 'en': 'No services available'},
    'error_loading': {'es': 'Error al cargar servicios', 'en': 'Error loading services'},
    'save_changes': {'es': 'Guardar Cambios', 'en': 'Save Changes'},
    'logout': {'es': 'Cerrar sesión', 'en': 'Log out'},
    'retry': {'es': 'Reintentar', 'en': 'Retry'},
    'cancel': {'es': 'Cancelar', 'en': 'Cancel'},
    'yes': {'es': 'Sí', 'en': 'Yes'},
    'no': {'es': 'No', 'en': 'No'},
    'send': {'es': 'Enviar', 'en': 'Send'},
    'accept': {'es': 'ACEPTAR', 'en': 'ACCEPT'},
    'error': {'es': 'Error', 'en': 'Error'},
    'success': {'es': '¡ÉXITO!', 'en': 'SUCCESS!'},

    // --- NAV ---
    'nav_home': {'es': 'Inicio', 'en': 'Home'},
    'nav_favorites': {'es': 'Favoritos', 'en': 'Favorites'},
    'nav_profile': {'es': 'Perfil', 'en': 'Profile'},

    // --- HOME ---
    'sort_default': {'es': 'Por defecto', 'en': 'Default'},
    'sort_price_asc': {'es': 'Precio: Menor a Mayor', 'en': 'Price: Low to High'},
    'sort_price_desc': {'es': 'Precio: Mayor a Menor', 'en': 'Price: High to Low'},
    'sort_popular': {'es': 'Más populares', 'en': 'Most popular'},
    'cat_all': {'es': 'Todos', 'en': 'All'},
    'like_error': {'es': 'Error al dar like', 'en': 'Error liking service'},

    // --- LOGIN ---
    'login_username': {'es': 'Usuario/Email', 'en': 'Username/Email'},
    'login_password': {'es': 'Contraseña', 'en': 'Password'},
    'login_forgot': {'es': '¿Olvidaste tu contraseña?', 'en': 'Forgot your password?'},
    'login_enter': {'es': 'ENTRAR', 'en': 'LOGIN'},
    'login_no_account': {'es': '¿No tienes cuenta? Regístrate', 'en': "Don't have an account? Sign up"},
    'login_wrong_creds': {'es': 'Credenciales incorrectas', 'en': 'Incorrect credentials'},
    'login_fill_fields': {'es': 'Rellena todos los campos', 'en': 'Fill in all fields'},

    // --- SIGNUP ---
    'signup_title': {'es': 'CREAR CUENTA', 'en': 'CREATE ACCOUNT'},
    'signup_name': {'es': 'Nombre Completo', 'en': 'Full Name'},
    'signup_email': {'es': 'Correo Electrónico', 'en': 'Email'},
    'signup_pass': {'es': 'Contraseña', 'en': 'Password'},
    'signup_confirm': {'es': 'Confirmar Contraseña', 'en': 'Confirm Password'},
    'signup_register': {'es': 'REGISTRARSE', 'en': 'SIGN UP'},
    'signup_have_account': {'es': '¿Ya tienes cuenta? Inicia sesión', 'en': 'Already have an account? Log in'},
    'signup_fill_all': {'es': 'Por favor, rellena todos los campos.', 'en': 'Please fill in all fields.'},
    'signup_pass_mismatch': {'es': 'Las contraseñas no coinciden.', 'en': 'Passwords do not match.'},
    'signup_ok_msg': {'es': 'Tu cuenta ha sido creada correctamente. Inicia sesión.', 'en': 'Your account was created successfully. Please log in.'},
    'signup_error_msg': {'es': 'Error al registrar. El usuario o email ya existen.', 'en': 'Registration error. Username or email already exists.'},

    // --- PROFILE ---
    'profile_title': {'es': 'Mi Perfil', 'en': 'My Profile'},
    'profile_email': {'es': 'Email', 'en': 'Email'},
    'profile_phone': {'es': 'Teléfono', 'en': 'Phone'},
    'profile_allergens': {'es': 'Alérgenos', 'en': 'Allergens'},
    'profile_conditions': {'es': 'Afecciones', 'en': 'Conditions'},
    'profile_see_appointments': {'es': 'Ver Mis Citas', 'en': 'My Appointments'},
    'profile_updated': {'es': 'Perfil actualizado', 'en': 'Profile updated'},
    'profile_save_error': {'es': 'Error al guardar. Revisa la conexión.', 'en': 'Save error. Check your connection.'},
    'profile_not_loaded': {'es': 'El perfil aún no ha cargado', 'en': 'Profile not loaded yet'},
    'profile_load_error': {'es': 'No se pudo cargar el perfil.\nComprueba que el servidor está encendido.', 'en': 'Could not load profile.\nCheck the server is running.'},
    'profile_img_error': {'es': 'No se pudo leer la imagen', 'en': 'Could not read image'},
    'profile_language': {'es': 'Idioma / Language', 'en': 'Language / Idioma'},

    // --- APPOINTMENTS ---
    'appts_title': {'es': 'Mis Citas', 'en': 'My Appointments'},
    'appts_none': {'es': 'No tienes citas reservadas', 'en': 'You have no appointments'},
    'appt_detail_title': {'es': 'Detalle de Cita', 'en': 'Appointment Detail'},
    'appt_service': {'es': 'Servicio', 'en': 'Service'},
    'appt_date_time': {'es': 'Fecha y Hora', 'en': 'Date & Time'},
    'appt_status': {'es': 'Estado', 'en': 'Status'},
    'appt_at': {'es': 'a las', 'en': 'at'},
    'appt_cancel': {'es': 'Cancelar Cita', 'en': 'Cancel Appointment'},
    'appt_cancel_confirm': {'es': '¿Seguro que quieres cancelar esta cita?', 'en': 'Are you sure you want to cancel this appointment?'},
    'appt_cancelled_ok': {'es': 'Cita cancelada', 'en': 'Appointment cancelled'},
    'appt_cancel_error': {'es': 'Error al cancelar', 'en': 'Error cancelling'},

    // --- VALORACIONES ---
    'val_title': {'es': 'Valorar Servicio', 'en': 'Rate Service'},
    'val_my_review': {'es': 'Tu Valoración', 'en': 'Your Review'},
    'val_comment': {'es': 'Comentario', 'en': 'Comment'},
    'val_hint': {'es': 'Escribe tu opinión...', 'en': 'Write your opinion...'},
    'val_upload_photo': {'es': 'Subir Foto (Opcional)', 'en': 'Upload Photo (Optional)'},
    'val_change_photo': {'es': 'Cambiar Foto', 'en': 'Change Photo'},
    'val_send': {'es': 'Enviar Valoración', 'en': 'Submit Review'},
    'val_save': {'es': 'Guardar Cambios', 'en': 'Save Changes'},
    'val_select_stars': {'es': 'Por favor, selecciona una calificación (estrellas)', 'en': 'Please select a star rating'},
    'val_saved_ok': {'es': 'Valoración guardada con éxito', 'en': 'Review saved successfully'},
    'val_save_error': {'es': 'Error al guardar la valoración', 'en': 'Error saving review'},
    'val_delete_title': {'es': 'Eliminar valoración', 'en': 'Delete review'},
    'val_delete_confirm': {'es': '¿Estás seguro de que quieres eliminar esta reseña?', 'en': 'Are you sure you want to delete this review?'},
    'val_deleted_ok': {'es': 'Valoración eliminada', 'en': 'Review deleted'},
    'val_delete_error': {'es': 'Error al eliminar', 'en': 'Error deleting'},

    // --- FAVORITES ---
    'fav_title': {'es': 'Mis Favoritos', 'en': 'My Favorites'},
    'fav_none': {'es': 'No tienes servicios favoritos aún.\n¡Dale like a los que te gusten!', 'en': 'No favorites yet.\nLike the services you enjoy!'},

    // --- BOOKING ---
    'book_title': {'es': 'Reservar', 'en': 'Book'},
    'book_select_date': {'es': 'Selecciona una fecha', 'en': 'Select a date'},
    'book_available': {'es': 'Horarios Disponibles', 'en': 'Available Slots'},
    'book_confirm': {'es': 'Confirmar Reserva', 'en': 'Confirm Booking'},
    'book_success': {'es': 'Cita reservada con éxito', 'en': 'Appointment booked successfully'},
    'book_error': {'es': 'Error al reservar', 'en': 'Booking error'},
    'book_select_slot': {'es': 'Selecciona un horario primero', 'en': 'Please select a time slot first'},
  };

  static String get(BuildContext context, String key) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final lang = localeProvider.locale.languageCode;
    return _strings[key]?[lang] ?? _strings[key]?['es'] ?? key;
  }

  // Helper that listens to locale changes (for widgets that need to rebuild on change)
  static String watch(BuildContext context, String key) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;
    return _strings[key]?[lang] ?? _strings[key]?['es'] ?? key;
  }
}
