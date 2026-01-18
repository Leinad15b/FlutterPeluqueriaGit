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

class ProfilePage extends StatefulWidget {
  final String userName;
  const ProfilePage({Key? key, required this.userName}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _userProfile;
  bool _isLoading = true;
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

  void _loadUserProfile() async {
    await UserManager.loadProfile(widget.userName);
    final profile = UserManager.profileNotifier.value;
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _isLoading = false;
        if (profile != null) {
          _emailController.text = profile.email;
          _phoneController.text = profile.telefono;
          _allergensController.text = profile.alergenos;
          _conditionsController.text = profile.afecciones;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        String? base64 = await ApiService.imageToBase64(image.path);
        if (base64 != null && _userProfile != null) {
          
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
        }
      }
    } catch (e) {
      print("Error imagen: $e");
    }
  }

  Future<void> _saveProfile() async {
    if (_userProfile == null) return;
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
      UserManager.profileNotifier.value = updatedData;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Perfil actualizado"), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al guardar"), backgroundColor: Colors.red));
    }
  }

  Widget _buildTextField({required String label, required IconData icon, required TextEditingController controller, bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: readOnly ? Colors.grey[200] : Colors.white
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: Text("Mi Perfil"), centerTitle: true, backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: (_userProfile?.fotoBase64 != null && _userProfile!.fotoBase64!.isNotEmpty)
                    ? MemoryImage(base64Decode(_userProfile!.fotoBase64!))
                    : NetworkImage("https://i.imgur.com/lB5bLMY.jpg") as ImageProvider,
                child: Align(alignment: Alignment.bottomRight, child: CircleAvatar(backgroundColor: Colors.orange, radius: 18, child: Icon(Icons.camera_alt, color: Colors.white, size: 18))),
              ),
            ),
            SizedBox(height: 30),
            
            ListTile(
              leading: Icon(Icons.calendar_month, color: Colors.orange),
              title: Text("Ver Mis Citas"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyAppointmentsPage()));
              },
            ),
            Divider(),
            SizedBox(height: 20),

            _buildTextField(label: "Email", icon: Icons.email, controller: _emailController, readOnly: true),
            SizedBox(height: 15),
            _buildTextField(label: "Teléfono", icon: Icons.phone, controller: _phoneController),
            SizedBox(height: 15),
            _buildTextField(label: "Alérgenos", icon: Icons.warning, controller: _allergensController),
            SizedBox(height: 15),
            _buildTextField(label: "Afecciones", icon: Icons.medical_services, controller: _conditionsController),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
              onPressed: _saveProfile,
              child: Text("Guardar Cambios", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 15),
            TextButton.icon(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
              },
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}