import 'package:flutter/material.dart';
import 'package:peluqueria_aplication/screens/hair_changer_screen.dart';

class FloatingAiButton extends StatelessWidget {
  const FloatingAiButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.orange,
      elevation: 6,
      tooltip: 'Cambio de Look IA',
      child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HairChangerScreen()),
        );
      },
    );
  }
}
