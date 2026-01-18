import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/api_models.dart';
import '../providers/cita_provider.dart';

class AppointmentDetailPage extends StatelessWidget {
  final Cita cita;

  const AppointmentDetailPage({Key? key, required this.cita}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalle de Cita"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      title: Text("Servicio"),
                      subtitle: Text(cita.servicioNombre, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.calendar_month, color: Colors.orange),
                      title: Text("Fecha y Hora"),
                      subtitle: Text("${cita.fecha} a las ${cita.horaInicio}"),
                    ),
                    ListTile(
                      leading: Icon(Icons.info, color: Colors.blue),
                      title: Text("Estado"),
                      subtitle: Text(cita.estado, style: TextStyle(
                        color: cita.estado == 'CANCELADA' ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold
                      )),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Text("Valorar Servicio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "Comentario",
                border: OutlineInputBorder(),
                hintText: "Escribe tu opinión...",
                filled: true,
                fillColor: Colors.grey[200]
              ),
              enabled: false, 
            ),
            SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) => Icon(Icons.star_border, color: Colors.grey, size: 30)),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: null, 
              icon: Icon(Icons.camera_alt),
              label: Text("Subir Foto"),
              style: ElevatedButton.styleFrom(disabledBackgroundColor: Colors.grey[300]),
            ),
            SizedBox(height: 40),
            if (cita.estado != "CANCELADA" && cita.estado != "FINALIZADA")
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  onPressed: () async {
                    bool confirm = await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("Cancelar Cita"),
                        content: Text("¿Seguro que quieres cancelar esta cita?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("No")),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Sí")),
                        ],
                      )
                    ) ?? false;

                    if (confirm) {
                      bool success = await Provider.of<CitaProvider>(context, listen: false).cancelarCita(cita.id);
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cita cancelada")));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al cancelar")));
                      }
                    }
                  },
                  child: Text("Cancelar Cita", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              )
          ],
        ),
      ),
    );
  }
}