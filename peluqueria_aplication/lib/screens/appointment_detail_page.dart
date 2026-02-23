import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/api_models.dart';
import '../models/api_service.dart';
import '../providers/cita_provider.dart';
import '../l10n/app_strings.dart';

class AppointmentDetailPage extends StatefulWidget {
  final Cita cita;

  const AppointmentDetailPage({Key? key, required this.cita}) : super(key: key);

  @override
  _AppointmentDetailPageState createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  String? _base64Image;
  bool _isLoading = true;
  bool _isSubmitting = false;
  Valoracion? _existingValoracion;
  bool _isEditing = false;
  int? _userId;
  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _checkExistingValoracion();
  }

  Future<void> _loadUserId() async {
    final idStr = await _storage.read(key: 'user_id');
    if (mounted) setState(() => _userId = idStr != null ? int.tryParse(idStr) : null);
  }

  Future<void> _checkExistingValoracion() async {
    final val = await ApiService.getValoracionPorCita(widget.cita.id);
    if (mounted) {
      setState(() {
        _existingValoracion = val;
        _isLoading = false;
        if (val != null) {
          _rating = val.calificacion;
          _commentController.text = val.comentario;
          _base64Image = val.imagenBase64;
          _isEditing = false;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      final base64String = await ApiService.imageToBase64(pickedFile.path);
      setState(() {
        _base64Image = base64String;
      });
    }
  }

  Future<void> _submitValoracion() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.get(context, 'val_select_stars')), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSubmitting = true);

    final req = ValoracionRequest(
      citaId: widget.cita.id,
      calificacion: _rating,
      comentario: _commentController.text,
      imagenBase64: _base64Image,
      usuarioId: _userId,
      servicioId: widget.cita.servicioId,
    );

    bool success;
    if (_existingValoracion != null) {
      success = await ApiService.actualizarValoracion(_existingValoracion!.id, req);
    } else {
      success = await ApiService.crearValoracion(req);
    }

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.get(context, 'val_saved_ok')), backgroundColor: Colors.green));
      _isEditing = false;
      _checkExistingValoracion();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.get(context, 'val_save_error')), backgroundColor: Colors.red));
    }
  }

  Future<void> _deleteValoracion() async {
    if (_existingValoracion == null) return;
    
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get(ctx, 'val_delete_title')),
        content: Text(AppStrings.get(ctx, 'val_delete_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.get(ctx, 'no'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.get(ctx, 'yes'), style: TextStyle(color: Colors.red))),
        ],
      )
    ) ?? false;

    if (!confirm) return;

    setState(() => _isSubmitting = true);
    final success = await ApiService.eliminarValoracion(_existingValoracion!.id);
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.get(context, 'val_deleted_ok')), backgroundColor: Colors.green));
      setState(() {
        _existingValoracion = null;
        _rating = 0;
        _commentController.clear();
        _base64Image = null;
        _isEditing = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.get(context, 'val_delete_error')), backgroundColor: Colors.red));
    }
  }

  Widget _buildStars(bool readOnly) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
            size: 40,
          ),
          onPressed: readOnly ? null : () {
            setState(() => _rating = index + 1);
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFinalizada = widget.cita.estado == "FINALIZADA";
    final bool hasReview = _existingValoracion != null;
    final bool canEditReview = isFinalizada && (!hasReview || _isEditing);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.watch(context, 'appt_detail_title')), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
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
                        title: Text(AppStrings.watch(context, 'appt_service')),
                        subtitle: Text(widget.cita.servicioNombre, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.calendar_month, color: Colors.orange),
                        title: Text(AppStrings.watch(context, 'appt_date_time')),
                        subtitle: Text("${widget.cita.fecha} ${AppStrings.watch(context, 'appt_at')} ${widget.cita.horaInicio}"),
                      ),
                      ListTile(
                        leading: Icon(Icons.info, color: Colors.blue),
                        title: Text(AppStrings.watch(context, 'appt_status')),
                        subtitle: Text(widget.cita.estado, style: TextStyle(
                          color: widget.cita.estado == 'CANCELADA' ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold
                        )),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              
              if (isFinalizada) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(hasReview && !_isEditing ? AppStrings.watch(context, 'val_my_review') : AppStrings.watch(context, 'val_title'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (hasReview && !_isEditing)
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => setState(() => _isEditing = true),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: _deleteValoracion,
                          )
                        ],
                      )
                  ]
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: "Comentario",
                    border: OutlineInputBorder(),
                    hintText: "Escribe tu opinión...",
                    filled: true,
                    fillColor: canEditReview ? Colors.white : Colors.grey[100]
                  ),
                  maxLines: 3,
                  enabled: canEditReview, 
                ),
                SizedBox(height: 10),
                _buildStars(!canEditReview),
                SizedBox(height: 10),
                
                if (_base64Image != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(_base64Image!),
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                if (canEditReview)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage, 
                      icon: Icon(Icons.camera_alt),
                      label: Text(_base64Image == null ? "Subir Foto (Opcional)" : "Cambiar Foto"),
                    ),
                  ),

                if (canEditReview) ...[
                  SizedBox(height: 20),
                  Row(
                    children: [
                      if (_isEditing)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              padding: EdgeInsets.symmetric(vertical: 15),
                              side: BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _rating = _existingValoracion!.calificacion;
                                _commentController.text = _existingValoracion!.comentario;
                                _base64Image = _existingValoracion!.imagenBase64;
                              });
                            },
                            child: Text("Cancelar"),
                          ),
                        ),
                      if (_isEditing) SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                          ),
                          onPressed: _isSubmitting ? null : _submitValoracion,
                          child: _isSubmitting 
                            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(hasReview ? "Guardar Cambios" : "Enviar Valoración", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ]
              ],

              SizedBox(height: 40),
              if (widget.cita.estado != "CANCELADA" && widget.cita.estado != "FINALIZADA")
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
                        bool success = await Provider.of<CitaProvider>(context, listen: false).cancelarCita(widget.cita.id);
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