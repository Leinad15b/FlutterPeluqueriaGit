import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showDialog(String title, String message, {bool success = false}) {
    showDialog(
      context: context,
      barrierDismissible: !success,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red, size: 80),
              const SizedBox(height: 20),
              Text(title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              child: Text("ACEPTAR",
                  style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.white, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade600, Colors.yellow.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("CREAR CUENTA",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2)),
                  const SizedBox(height: 40),
                  _buildTextField(
                      _nameController, "Nombre Completo", Icons.person),
                  const SizedBox(height: 20),
                  _buildTextField(
                      _emailController, "Correo Electrónico", Icons.email),
                  const SizedBox(height: 20),
                  _buildTextField(_passwordController, "Contraseña", Icons.lock,
                      isPassword: true),
                  const SizedBox(height: 20),
                  _buildTextField(_confirmPasswordController,
                      "Confirmar Contraseña", Icons.lock_outline,
                      isPassword: true),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        elevation: 5,
                      ),
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              String name = _nameController.text.trim();
                              String email = _emailController.text.trim();
                              String pass = _passwordController.text.trim();
                              String confirmPass =
                                  _confirmPasswordController.text.trim();

                              if (name.isEmpty ||
                                  email.isEmpty ||
                                  pass.isEmpty ||
                                  confirmPass.isEmpty) {
                                _showDialog(
                                    "Error", "Por favor, rellena todos los campos.");
                              } else if (pass != confirmPass) {
                                _showDialog("Error", "Las contraseñas no coinciden.");
                              } else {
                                
                                bool success = await authProvider.register(
                                    name, email, pass);
                                
                                if (success) {
                                  _showDialog("¡ÉXITO!",
                                      "Tu cuenta ha sido creada correctamente. Inicia sesión.",
                                      success: true);
                                 
                                } else {
                                  _showDialog("Error",
                                      "Error al registrar. El usuario o email ya existen.");
                                }
                              }
                            },
                      child: authProvider.isLoading
                          ? CircularProgressIndicator(color: Colors.orange)
                          : const Text("REGISTRARSE",
                              style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("¿Ya tienes cuenta? Inicia sesión",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}