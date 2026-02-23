import 'package:flutter/material.dart';
import 'home_tab_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import '../models/user_manager.dart';
import '../l10n/app_strings.dart';

class MainNavigationScreen extends StatefulWidget {
  final String userName;
  MainNavigationScreen({Key? key, required this.userName}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    UserManager.loadProfile(widget.userName);
    _widgetOptions = <Widget>[
      HomeTabPage(userName: widget.userName),
      FavoritesPage(userName: widget.userName),
      ProfilePage(userName: widget.userName),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: AppStrings.watch(context, 'nav_home')),
          BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: AppStrings.watch(context, 'nav_favorites')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: AppStrings.watch(context, 'nav_profile')),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange.shade800,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
