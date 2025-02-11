import 'package:firebase_auth/firebase_auth.dart';
import 'package:notetaking/core/LocaleManager.dart';
import 'package:flutter/material.dart';
import 'package:notetaking/screens/home_screen.dart';
import 'package:provider/provider.dart';
class RegisterScreen extends StatefulWidget{
  @override
  _RegisteScreenState createState() => _RegisteScreenState();
}

class _RegisteScreenState extends State<RegisterScreen>{
  final FirebaseAuth _authModel = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("İsim alanı boş bırakılamaz!")),
      );
      return; // İsim girilmemişse işlem yapma
    }

    try {
      UserCredential userCredential = await _authModel.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Kullanıcı adını kaydet
      await userCredential.user?.updateDisplayName(_nameController.text.trim());
      await userCredential.user?.reload(); // Güncellenen veriyi anında yansıt

      // Kayıt başarılı mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kayıt başarılı!")),
      );

      // 1.5 saniye sonra HomeScreen'e yönlendirme, geri tuşu geçmişi sıfırlanmış olacak
      await Future.delayed(Duration(milliseconds: 1000));  // 1 saniyelik bekleme
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false,  // Bu, tüm önceki sayfaları temizler
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context);
    return WillPopScope(
        onWillPop: () async {
      // Geri butonuna basıldığında ana ekrana yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
      return false; // Geri butonu işlemi gerçekleştirilmesin
    },
    child: Scaffold(
      appBar: AppBar(title: Text(localManager.translate("register"))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: localManager.translate("reg_name_field")),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: localManager.translate("password")),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text(localManager.translate("register")),
            ),
            SizedBox(height: 16),

          ],
        ),
      ),
    ),
    );
  }
}