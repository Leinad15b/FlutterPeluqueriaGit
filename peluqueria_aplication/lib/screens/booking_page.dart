import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:peluqueria_aplication/widgets/floating_ai_button.dart';

class ReservarCitaScreen extends StatefulWidget {
  @override
  _ReservarCitaScreenState createState() => _ReservarCitaScreenState();
}

class _ReservarCitaScreenState extends State<ReservarCitaScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final DateTime _today = DateTime.now();
  bool _localeInitialized = false;

  int? _horaSeleccionadaIndex;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      if (mounted) {
        setState(() {
          _localeInitialized = true;
        });
      }
    });
  }

  bool _esDiaDisponible(DateTime day) {
    return day.day % 2 == 0;
  }

  List<String> _generarHorasEjemplo() {
    return [
      "10:00",
      "11:00",
      "12:00",
      "13:00",
      "16:00",
      "17:00",
      "18:00",
      "19:00"
    ];
  }

  void _confirmarCita() {
    if (_horaSeleccionadaIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Por favor, selecciona un horario primero."),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "¡Cita reservada con éxito para el ${_selectedDay.day}/${_selectedDay.month} a las ${_generarHorasEjemplo()[_horaSeleccionadaIndex!]}!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeInitialized)
      return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Reservar Cita",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              locale: 'es_ES',
              firstDay: _today,
              lastDay: DateTime(_today.year + 1, _today.month, _today.day),
              focusedDay: _focusedMonth,
              enabledDayPredicate: (day) {
                return day.weekday >= DateTime.monday &&
                    day.weekday <= DateTime.friday;
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedMonth = focusedDay;
                    _horaSeleccionadaIndex = null;
                  });
                }
              },
              calendarBuilders:
                  CalendarBuilders(defaultBuilder: (context, day, focusedDay) {
                bool disponible = _esDiaDisponible(day);
                return Container(
                  margin: const EdgeInsets.all(6.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: disponible
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }, selectedBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(6.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }, todayBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(6.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }),
              headerStyle:
                  HeaderStyle(formatButtonVisible: false, titleCentered: true),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Horarios Disponibles",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: _generarHorasEjemplo().length,
                itemBuilder: (context, index) {
                  final hora = _generarHorasEjemplo()[index];

                  bool diaLleno = !_esDiaDisponible(_selectedDay);
                  bool horaOcupada = index == 4;
                  bool esSeleccionado = _horaSeleccionadaIndex == index;

                  bool deshabilitado = diaLleno || horaOcupada;

                  return GestureDetector(
                    onTap: deshabilitado
                        ? null
                        : () {
                            setState(() {
                              _horaSeleccionadaIndex = index;
                            });
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: deshabilitado
                            ? Colors.grey[200]
                            : (esSeleccionado
                                ? Colors.green[100]
                                : Colors.white),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: esSeleccionado
                              ? Colors.black
                              : (deshabilitado ? Colors.grey : Colors.green),
                          width: esSeleccionado ? 2.0 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          hora,
                          style: TextStyle(
                              color: deshabilitado ? Colors.grey : Colors.black,
                              fontWeight: esSeleccionado
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              decoration: deshabilitado
                                  ? TextDecoration.lineThrough
                                  : null),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _confirmarCita,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Text("Confirmar cita",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingAiButton(),
    );
  }
}
