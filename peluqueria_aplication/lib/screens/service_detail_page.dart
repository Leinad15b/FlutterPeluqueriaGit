import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/api_models.dart';
import 'booking_page.dart';

class ServiceDetailPage extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailPage({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageHeader(context),
                _buildSummarySection(),
                _buildDescriptionSection(),
                SizedBox(height: 100),
              ],
            ),
          ),
          _buildBottomButton(context),
          _buildTopButtons(context),
        ],
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    ImageProvider imageProvider;

    if (service.imageBase64 != null && service.imageBase64!.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(service.imageBase64!));
      } catch (e) {
        imageProvider = NetworkImage(service.defaultImagePath);
      }
    } else {
      imageProvider = NetworkImage(service.defaultImagePath);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 350,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(service.categoria,
                    style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold)),
              ),
              Row(children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text("4.8",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
              ]),
            ],
          ),
          SizedBox(height: 15),
          Text(service.titulo,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, height: 1.2)),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.grey, size: 20),
              SizedBox(width: 5),
              Text("${service.duracion} min",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              SizedBox(width: 20),
              Icon(Icons.euro, color: Colors.grey, size: 20),
              SizedBox(width: 5),
              Text("${service.precio}€",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Descripción",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
              service.descripcion.isNotEmpty
                  ? service.descripcion
                  : "Disfruta de un servicio profesional con los mejores productos del mercado.",
              style: TextStyle(
                  fontSize: 16, color: Colors.grey[600], height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: SizedBox(
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ReservarCitaScreen(service: service)));
          },
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Reservar ahora", style: TextStyle(fontSize: 18)),
            SizedBox(width: 10),
            Icon(Icons.calendar_month, size: 20)
          ]),
        ),
      ),
    );
  }

  Widget _buildTopButtons(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.4),
              child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop()),
            ),
          ],
        ),
      ),
    );
  }
}