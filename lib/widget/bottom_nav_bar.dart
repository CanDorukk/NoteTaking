import 'package:flutter/material.dart';
import 'package:notetaking/core/LocaleManager.dart';
import 'package:provider/provider.dart';
class BottomNavBar extends StatelessWidget{
  final int selectedIndex;
  final Function(int) onTop;

  const BottomNavBar({required this.selectedIndex, required this.onTop});

  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context);
    return BottomNavigationBar(
        currentIndex: selectedIndex,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.red,
        onTap: onTop,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: localManager.translate('home'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: localManager.translate('profile'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: localManager.translate('settings'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: localManager.translate('crud'),
          ),
        ]
    );
  }
}