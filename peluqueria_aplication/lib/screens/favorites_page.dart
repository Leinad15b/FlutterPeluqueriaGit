import 'package:flutter/material.dart';
import 'service_detail_page.dart';
import 'home_tab_page.dart';
import '../models/api_service.dart';
import '../models/api_models.dart';
import 'package:peluqueria_aplication/widgets/floating_ai_button.dart';

class FavoritesPage extends StatefulWidget {
  final String userName;
  const FavoritesPage({Key? key, required this.userName}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<ServiceModel>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoritesFuture = ApiService.getServices().then((services) {
        return services.where((s) => s.isLikedByMe).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Mis Favoritos", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<ServiceModel>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No tienes favoritos aún",
                      style: TextStyle(color: Colors.grey[600], fontSize: 16))
                ],
              ),
            );
          }

          final favoriteServices = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: favoriteServices.length,
            itemBuilder: (context, index) {
              final service = favoriteServices[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceDetailPage(service: service),
                    ),
                  ).then((_) {
                    _loadFavorites();
                  });
                },
                child: ServiceCard(service: service, showLikes: true),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingAiButton(),
    );
  }
}
