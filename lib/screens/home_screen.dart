import 'package:flutter/material.dart';
import 'package:notetaking/core/LocaleManager.dart';
import 'package:notetaking/core/ThemeManager.dart';
import 'package:notetaking/screens/crud_screen.dart';
import 'package:notetaking/screens/proife_screen.dart';
import 'package:notetaking/screens/settings_screen.dart';
import 'package:notetaking/widget/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget{
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text('Ana Sayfa', style: TextStyle(fontSize: 24))),
    ProfileScreen(),
    SettingsScreen(),
    CrudScreen()
  ];

  void _onItemTapped(int index) async{
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context);
    final themeManager = Provider.of<ThemeManager>(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(localManager.translate('title')),
        ),
      ),


      // 📌 Hamburger Menü (Drawer) Eklendi ve İçine Tema & Dil Seçimi Koyduk
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                localManager.translate("settings"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),

            // 📌 Tema Değiştirme Seçeneği
            SwitchListTile(
              title: Text(localManager.translate('dark_theme')),
              value: themeManager.themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                themeManager.toggleTheme();
              },
              secondary: Icon(Icons.brightness_6),
            ),

            // 📌 Dil Değiştirme Seçeneği
            ListTile(
              leading: Icon(Icons.language),
              title: Text(localManager.translate('language')),
              trailing: DropdownButton<Locale>(
                value: localManager.currentLocale,
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    localManager.changedLocale(newLocale);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: Locale('en'),
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: Locale('tr'),
                    child: Text('Türkçe'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),




      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Center(
            child: Text(
              localManager.translate('home'),
              style: TextStyle(fontSize: 24),
            ),
          ),

          // ekranların açılma sırası aşşağıda
          ProfileScreen(),
          SettingsScreen(),
          CrudScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onTop: _onItemTapped),
    );
  }
}