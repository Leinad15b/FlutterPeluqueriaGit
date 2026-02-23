import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../models/api_models.dart';
import '../providers/cita_provider.dart';
import '../l10n/app_strings.dart';

class ReservarCitaScreen extends StatefulWidget {
  final ServiceModel service;

  const ReservarCitaScreen({Key? key, required this.service}) : super(key: key);

  @override
  _ReservarCitaScreenState createState() => _ReservarCitaScreenState();
}

class _ReservarCitaScreenState extends State<ReservarCitaScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final DateTime _today = DateTime.now();
  bool _localeInitialized = false;
  SlotDTO? _selectedSlot;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      if (mounted) {
        setState(() => _localeInitialized = true);
        _fetchSlots(_selectedDay);
      }
    });
  }

  void _fetchSlots(DateTime date) {
    setState(() => _selectedSlot = null);
    Provider.of<CitaProvider>(context, listen: false).loadDisponibilidad(widget.service.id, date);
  }

  void _confirmarCita() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.get(context, 'book_select_slot')), backgroundColor: Colors.red));
      return;
    }
    if (_selectedDay.isBefore(DateTime(_today.year, _today.month, _today.day))) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No puedes reservar en el pasado"), backgroundColor: Colors.red));
      return;
    }

    final citaProvider = Provider.of<CitaProvider>(context, listen: false);
    final result = await citaProvider.reservarCita(
      widget.service.id,
      _selectedDay,
      _selectedSlot!,
    );

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.get(context, 'book_success')), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.get(ctx, 'error')),
          content: Text(result['msg'] ?? "Error desconocido"),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.get(ctx, 'accept')))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final citaProvider = Provider.of<CitaProvider>(context);

    if (!_localeInitialized) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Reservar: ${widget.service.titulo}", style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              locale: 'es_ES',
              firstDay: _today,
              lastDay: DateTime(_today.year + 1, _today.month, _today.day),
              focusedDay: _focusedMonth,
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Colors.orange.shade200, shape: BoxShape.circle),
              ),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedMonth = focusedDay;
                  });
                  _fetchSlots(selectedDay);
                }
              },
              headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Text(AppStrings.watch(context, 'book_available'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (citaProvider.isLoading) SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                ],
              ),
            ),
            Expanded(
              child: citaProvider.slots.isEmpty && !citaProvider.isLoading
                  ? Center(child: Text("No hay huecos disponibles."))
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, childAspectRatio: 2.5, crossAxisSpacing: 10, mainAxisSpacing: 10),
                      itemCount: citaProvider.slots.length,
                      itemBuilder: (context, index) {
                        final slot = citaProvider.slots[index];
                        final isSelected = _selectedSlot == slot;
                        final isAvailable = slot.available;

                        return GestureDetector(
                          onTap: isAvailable ? () => setState(() => _selectedSlot = slot) : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: !isAvailable ? Colors.grey[200] : (isSelected ? Colors.green[100] : Colors.white),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.black : (!isAvailable ? Colors.red.shade200 : Colors.green),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                slot.start.substring(0, 5),
                                style: TextStyle(
                                  color: !isAvailable ? Colors.grey : Colors.black,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  decoration: !isAvailable ? TextDecoration.lineThrough : null,
                                ),
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
                  onPressed: citaProvider.isLoading ? null : _confirmarCita,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text(AppStrings.watch(context, 'book_confirm'), style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}