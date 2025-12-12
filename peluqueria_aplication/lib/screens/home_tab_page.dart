import 'dart:convert';
import 'package:flutter/material.dart';
import 'service_detail_page.dart';
import '../models/api_service.dart';
import '../models/api_models.dart';
import '../widgets/user_avatar.dart';
import 'package:peluqueria_aplication/widgets/floating_ai_button.dart';

enum SortOption { none, priceAsc, priceDesc, likesDesc }

class HomeTabPage extends StatefulWidget {
  final String userName;
  HomeTabPage({Key? key, required this.userName}) : super(key: key);

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  String _selectedFilter = "Todos";
  final _searchController = TextEditingController();
  String _searchQuery = "";
  SortOption _sortOption = SortOption.none;
  late Future<List<ServiceModel>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() {
    setState(() {
      _servicesFuture = ApiService.getServices();
    });
  }

  List<ServiceModel> _applyFilters(List<ServiceModel> services) {
    List<ServiceModel> filteredList = services;

    if (_selectedFilter != "Todos") {
      filteredList =
          filteredList.where((s) => s.categoria == _selectedFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList
          .where((s) =>
              s.titulo.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    switch (_sortOption) {
      case SortOption.priceAsc:
        filteredList.sort((a, b) => a.precio.compareTo(b.precio));
        break;
      case SortOption.priceDesc:
        filteredList.sort((a, b) => b.precio.compareTo(a.precio));
        break;
      case SortOption.likesDesc:
        filteredList.sort((a, b) => b.likesCount.compareTo(a.likesCount));
        break;
      case SortOption.none:
        break;
    }
    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingAiButton(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryFilter(),
            Expanded(child: _buildServiceList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bienvenido,",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              SizedBox(height: 4),
              Text(widget.userName.split('@')[0],
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ],
          ),
          UserAvatar(radius: 25),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Buscar servicio...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
          SizedBox(width: 10),
          _buildSortButton(),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.orange.shade600,
          borderRadius: BorderRadius.circular(15)),
      child: PopupMenuButton<SortOption>(
        icon: Icon(Icons.sort, color: Colors.white),
        onSelected: (SortOption result) {
          setState(() {
            _sortOption = result;
          });
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
          const PopupMenuItem(
              value: SortOption.none, child: Text('Por defecto')),
          const PopupMenuItem(
              value: SortOption.priceAsc, child: Text('Precio: Menor a Mayor')),
          const PopupMenuItem(
              value: SortOption.priceDesc,
              child: Text('Precio: Mayor a Menor')),
          const PopupMenuItem(
              value: SortOption.likesDesc, child: Text('Más populares')),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      "Todos",
      "Corte",
      "Peinado",
      "Tinte",
      "Barba",
      "Tratamiento"
    ];
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedFilter == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = category;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceList() {
    return FutureBuilder<List<ServiceModel>>(
      future: _servicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error al cargar servicios"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No hay servicios disponibles"));
        }

        final filteredServices = _applyFilters(snapshot.data!);

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: filteredServices.length,
          itemBuilder: (context, index) {
            return _buildServiceCard(filteredServices[index]);
          },
        );
      },
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ServiceDetailPage(service: service)),
        ).then((_) => _loadServices());
      },
      child: ServiceCard(service: service),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final ServiceModel service;
  final bool showLikes;
  const ServiceCard({Key? key, required this.service, this.showLikes = true})
      : super(key: key);

  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.service.isLikedByMe;
    _likeCount = widget.service.likesCount;
  }

  void _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      bool success = await ApiService.toggleLike(widget.service.id);
      if (!success) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
      }
    } catch (e) {
      setState(() {
        _isLiked = !_isLiked;
        _likeCount += _isLiked ? 1 : -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (widget.service.imageBase64 != null &&
        widget.service.imageBase64!.isNotEmpty) {
      try {
        imageWidget = Image.memory(
          base64Decode(widget.service.imageBase64!),
          height: 100,
          width: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
              height: 100,
              width: 100,
              color: Colors.grey[300],
              child: Icon(Icons.broken_image, color: Colors.grey)),
        );
      } catch (e) {
        imageWidget = Image.network(
          widget.service.defaultImagePath,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        );
      }
    } else {
      imageWidget = Image.network(
        widget.service.defaultImagePath,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 5))
          ]),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: imageWidget,
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(widget.service.categoria,
                        style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 8),
                  Text(widget.service.titulo,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  if (widget.showLikes)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked ? Colors.red : Colors.grey),
                          onPressed: _toggleLike,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        SizedBox(width: 5),
                        Text("$_likeCount",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700)),
                        SizedBox(width: 10),
                        Text("${widget.service.precio.toStringAsFixed(0)}€",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700)),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
