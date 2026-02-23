import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'my_appointments_page.dart';
import '../models/api_service.dart';
import '../models/api_models.dart';
import '../models/user_manager.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  const ProfilePage({Key? key, required this.userName}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _errorMsg;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _allergensController;
  late TextEditingController _conditionsController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _allergensController = TextEditingController();
    _conditionsController = TextEditingController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final profile = await ApiService.getUserProfile(widget.userName);
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
          if (profile != null) {
            _emailController.text = profile.email;
            _phoneController.text = profile.telefono;
            _allergensController.text = profile.alergenos;
            _conditionsController.text = profile.afecciones;
            UserManager.profileNotifier.value = profile;
          } else {
            _errorMsg = 'No se pudo cargar el perfil (usuario: ${widget.userName}).\nComprueba que el servidor está encendido.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Error de red: $e';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    if (_userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Espera a que cargue el perfil'), backgroundColor: Colors.orange));
      return;
    }
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
      if (image != null) {
        String? base64 = await ApiService.xFileToBase64(image);
        if (base64 != null) {
          setState(() {
            _userProfile = UserProfile(
              id: _userProfile!.id,
              username: _userProfile!.username,
              email: _userProfile!.email,
              telefono: _phoneController.text,
              alergenos: _allergensController.text,
              afecciones: _conditionsController.text,
              fotoBase64: base64,
            );
          });
          _saveProfile();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo leer la imagen'), backgroundColor: Colors.red)
          );
        }
      }
    } catch (e) {
      print("Error imagen: $e");
    }
  }

  Future<void> _saveProfile() async {
    if (_userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El perfil aún no ha cargado'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);

    UserProfile updatedData = UserProfile(
      id: _userProfile!.id,
      username: _userProfile!.username,
      email: _userProfile!.email,
      telefono: _phoneController.text,
      alergenos: _allergensController.text,
      afecciones: _conditionsController.text,
      fotoBase64: _userProfile!.fotoBase64,
    );

    bool success = await ApiService.updateProfile(widget.userName, updatedData);
    setState(() => _isLoading = false);

    if (success) {
      setState(() => _userProfile = updatedData);
      UserManager.profileNotifier.value = updatedData;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil actualizado"), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al guardar. Revisa la conexión."), backgroundColor: Colors.red));
    }
  }

  Widget _buildTextField({required String label, required IconData icon, required TextEditingController controller, bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: const TextStyle(color: Colors.black, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[800]),
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: readOnly ? Colors.grey[200] : Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (_errorMsg != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mi Perfil"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(_errorMsg!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadUserProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reintentar"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Mi Perfil"), centerTitle: true, backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: (_userProfile?.fotoBase64 != null && _userProfile!.fotoBase64!.isNotEmpty)
                    ? MemoryImage(base64Decode(_userProfile!.fotoBase64!))
                    : const NetworkImage("https://i.imgur.com/lB5bLMY.jpg") as ImageProvider,
                child: Align(alignment: Alignment.bottomRight, child: CircleAvatar(backgroundColor: Colors.orange, radius: 18, child: const Icon(Icons.camera_alt, color: Colors.white, size: 18))),
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.orange),
              title: const Text("Ver Mis Citas"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyAppointmentsPage())),
            ),
            const Divider(),
            const SizedBox(height: 20),
            _buildTextField(label: "Email", icon: Icons.email, controller: _emailController, readOnly: true),
            const SizedBox(height: 15),
            _buildTextField(label: "Teléfono", icon: Icons.phone, controller: _phoneController),
            const SizedBox(height: 15),
            _buildTextField(label: "Alérgenos", icon: Icons.warning, controller: _allergensController),
            const SizedBox(height: 15),
            _buildTextField(label: "Afecciones", icon: Icons.medical_services, controller: _conditionsController),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
              onPressed: _saveProfile,
              child: const Text("Guardar Cambios", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 15),
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, _) {
                final isEn = localeProvider.isEnglish;
                return OutlinedButton.icon(
                  onPressed: () => localeProvider.setLocale(isEn ? 'es' : 'en'),
                  icon: Text(isEn ? '🇪🇸' : '🇬🇧', style: const TextStyle(fontSize: 20)),
                  label: Text(
                    isEn ? 'Cambiar a Español' : 'Switch to English',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            TextButton.icon(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}