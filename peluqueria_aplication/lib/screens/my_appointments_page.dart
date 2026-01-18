import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cita_provider.dart';
import 'appointment_detail_page.dart';

class MyAppointmentsPage extends StatefulWidget {
  @override
  _MyAppointmentsPageState createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<CitaProvider>(context, listen: false).fetchMisCitas());
  }

  @override
  Widget build(BuildContext context) {
    final citaProvider = Provider.of<CitaProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Mis Citas"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      backgroundColor: Colors.grey[100],
      body: citaProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : citaProvider.misCitas.isEmpty
              ? Center(child: Text("No tienes citas reservadas"))
              : RefreshIndicator(
                  onRefresh: () => citaProvider.fetchMisCitas(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: citaProvider.misCitas.length,
                    itemBuilder: (context, index) {
                      final cita = citaProvider.misCitas[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: Icon(Icons.calendar_today, color: Colors.orange.shade800),
                          ),
                          title: Text(cita.servicioNombre, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${cita.fecha} - ${cita.horaInicio}"),
                              Text(cita.estado, style: TextStyle(
                                color: cita.estado == 'CANCELADA' ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold
                              )),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AppointmentDetailPage(cita: cita)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}