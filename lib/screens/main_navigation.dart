import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_sample_screen.dart';
import 'records_screen.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    AddSampleScreen(),
    RecordsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo),
            activeIcon: Icon(Icons.add_a_photo),
            label: 'Add Sample',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            activeIcon: Icon(Icons.list_alt),
            label: 'Records',
          ),
        ],
      ),
    );
  }
}
