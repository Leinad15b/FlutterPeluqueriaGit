import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';
import '../models/api_service.dart';
import '../models/api_models.dart';
import '../models/user_manager.dart';

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
        }
      }
    } catch (e) {
      print("Error al seleccionar imagen: $e");
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
      fotoBase64:
          _userProfile!.fotoBase64, 
    );

    
    bool success = await ApiService.updateProfile(widget.userName, updatedData);

    setState(() => _isLoading = false); 

    if (success) {
      
      UserManager.profileNotifier.value = updatedData;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Perfil actualizado correctamente"),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al guardar cambios"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    bool isReadOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange.shade700),
        filled: true,
        fillColor: isReadOnly ? Colors.grey[200] : Colors.grey[100],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildProfileImage() {
    ImageProvider imageProvider;
    if (_userProfile != null &&
        _userProfile!.fotoBase64 != null &&
        _userProfile!.fotoBase64!.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(_userProfile!.fotoBase64!));
      } catch (e) {
        imageProvider = NetworkImage(
            _userProfile?.defaultImage ?? "https://i.imgur.com/lB5bLMY.jpg");
      }
    } else {
      imageProvider = NetworkImage(
          _userProfile?.defaultImage ?? "https://i.imgur.com/lB5bLMY.jpg");
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[300],
      backgroundImage: imageProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text("Mi Perfil", style: TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                _buildProfileImage(),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                        backgroundColor: Colors.orange,
                        radius: 18,
                        child: IconButton(
                            icon: Icon(Icons.camera_alt,
                                size: 18, color: Colors.white),
                            onPressed: _pickImage))),
              ],
            ),
            SizedBox(height: 30),
            _buildTextField(
                label: "Email",
                icon: Icons.email,
                controller: _emailController,
                isReadOnly: true),
            SizedBox(height: 15),
            _buildTextField(
                label: "Teléfono",
                icon: Icons.phone,
                controller: _phoneController,
                inputType: TextInputType.phone),
            SizedBox(height: 15),
            _buildTextField(
                label: "Alérgenos",
                icon: Icons.warning,
                controller: _allergensController),
            SizedBox(height: 15),
            _buildTextField(
                label: "Afecciones",
                icon: Icons.medical_services,
                controller: _conditionsController,
                maxLines: 3),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              onPressed: _saveProfile,
              child: Text("Guardar Cambios"),
            ),
            SizedBox(height: 15),
            TextButton.icon(
              onPressed: () {
                ApiService.logout();
                UserManager.clear();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false);
              },
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text("Cerrar sesión",
                  style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
