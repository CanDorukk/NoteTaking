import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notetaking/core/LocaleManager.dart';
import 'package:notetaking/core/ThemeManager.dart';
import 'package:notetaking/screens/crud_screen.dart';
import 'package:notetaking/screens/login_screen.dart';
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
    SettingsScreen(),
    CrudScreen()
  ];

  void _onItemTapped(int index) async{
    final localManager = Provider.of<LocalManager>(context, listen: false); // 🔹 listen: false ekledik
    if(index == 3){  // Profil ekranı seçildiğinde
      final currentUser = FirebaseAuth.instance.currentUser;
      if(currentUser == null){
        // Eğer kullanıcı giriş yapmadıysa SnackBar göster ve sonra LoginScreen'e yönlendir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localManager.translate("loginization_message")),
            duration: Duration(milliseconds: 1000),
          ),
        );

        // Kullanıcıyı LoginScreen'e yönlendiriyoruz
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
      }else{
        setState(() {
          _selectedIndex = index;
        });
      }
    }else{
      setState(() {
        _selectedIndex = index;
      });
    }

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
            SizedBox(height: 16,),
            // 📌 Giriş Yap & Çıkış Yap Butonu
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      user == null
                          ? ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text(localManager.translate('login')),
                      )
                          : ElevatedButton(
                        onPressed: () async {
                          // 1. "Çıkış yapılıyor..." mesajını göster
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localManager.translate('logging_out')),
                              duration: Duration(milliseconds: 1500), // 1.5 saniye
                            ),
                          );

                          await Future.delayed(Duration(milliseconds: 1500));

                          // 2. Firebase'den çıkış yap
                          await FirebaseAuth.instance.signOut();

                          setState(() {
                            _selectedIndex = 0; // Ana Sayfa'ya dön
                          });

                          // 3. "Başarıyla çıkış yapıldı." mesajını göster
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localManager.translate('logout_success')),
                              duration: Duration(milliseconds: 1500), // 1.5 saniye
                            ),
                          );
                        },
                        child: Text(localManager.translate('logout')),
                      ),
                    ],
                  ),
                );
              },
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