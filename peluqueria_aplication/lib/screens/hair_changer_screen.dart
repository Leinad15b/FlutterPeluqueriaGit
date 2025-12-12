import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/AiHairService.dart';

class HairChangerScreen extends StatefulWidget {
  @override
  _HairChangerScreenState createState() => _HairChangerScreenState();
}

class _HairChangerScreenState extends State<HairChangerScreen> {
  final HairAiService _aiService = HairAiService();

  XFile? _originalImage;
  Uint8List? _resultImage;
  bool _isLoading = false;
  final TextEditingController _promptController = TextEditingController();

  List<Offset?> _points = [];
  final GlobalKey _paintKey = GlobalKey();

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512);
    if (image != null) {
      setState(() {
        _originalImage = image;
        _points.clear();
        _resultImage = null;
      });
    }
  }

  Future<Uint8List?> _createMaskFromDrawing() async {
    try {
      final renderBox =
          _paintKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return null;
      final size = renderBox.size;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder,
          Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));

      canvas.drawColor(Colors.black, BlendMode.src);

      final paint = Paint()
        ..color = Colors.white
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 30.0;

      for (int i = 0; i < _points.length - 1; i++) {
        if (_points[i] != null && _points[i + 1] != null) {
          canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
        }
      }

      final picture = recorder.endRecording();
      final img =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error creando máscara visual: $e");
      return null;
    }
  }

  Future<void> _processChange() async {
    if (_originalImage == null || _promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Por favor sube foto, pinta el pelo y escribe un estilo.")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageBytes = await _originalImage!.readAsBytes();
      final maskBytes = await _createMaskFromDrawing();

      if (maskBytes == null)
        throw "Primero debes pintar sobre el pelo con el dedo.";

      final newImage = await _aiService.generateNewHair(
          imageBytes: imageBytes,
          maskBytes: maskBytes,
          promptText: _promptController.text);

      if (newImage != null) {
        setState(() {
          _resultImage = newImage;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Peluquería IA"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),

            Container(
              height: 400,
              width: double.infinity,
              color: Colors.grey[300],
              child: _originalImage == null
                  ? Center(
                      child:
                          Text("1. Sube tu foto\n2. Pinta tu pelo con el dedo"))
                  : GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          RenderBox box = _paintKey.currentContext!
                              .findRenderObject() as RenderBox;
                          _points
                              .add(box.globalToLocal(details.globalPosition));
                        });
                      },
                      onPanEnd: (details) => _points.add(null),
                      child: RepaintBoundary(
                        key: _paintKey,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(_originalImage!.path,
                                fit: BoxFit.cover),
                            CustomPaint(painter: DrawingPainter(_points)),
                          ],
                        ),
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.camera_alt),
                        label: Text("Cámara"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.photo_library),
                        label: Text("Galería"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                      IconButton(
                        icon: Icon(Icons.undo, color: Colors.red),
                        onPressed: () => setState(() => _points.clear()),
                        tooltip: "Borrar dibujo",
                      )
                    ],
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      labelText: "¿Qué peinado quieres?",
                      hintText: "Ej: Blonde curly hair, Short punk hair...",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      onPressed: _isLoading ? null : _processChange,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("GENERAR NUEVO LOOK",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            // --- RESULTADO ---
            if (_resultImage != null) ...[
              Divider(),
              Text("¡Tu nuevo Look!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2)),
                  child: Image.memory(_resultImage!)),
              SizedBox(height: 30),
            ]
          ],
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 30.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
