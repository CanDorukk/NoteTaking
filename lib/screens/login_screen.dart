import 'package:notetaking/core/LocaleManager.dart';
import 'package:notetaking/models/authentication_model.dart';
import 'package:notetaking/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final AuthenticationModel _authModel = AuthenticationModel();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _login() async{
    try{
      await _authModel.loginWithEmailAndPassword(
          _emailController.text,
          _passwordController.text

      );
      Navigator.pop(context, true);
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final localManager = Provider.of<LocalManager>(context);
    return Scaffold(
      appBar: AppBar(title: Text(localManager.translate("login")),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              onPressed: _login,
              child: Text(localManager.translate("login")),
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                  onPressed: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context)=>RegisterScreen())
                    );
                  },
                  child: Text(localManager.translate("sign_up_message"))
              ),
            ),
          ],
        ),
      ),
    );
  }
}