import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notetaking/screens/login_screen.dart';

class CrudScreen extends StatefulWidget {
  @override
  _CrudScreenState createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Kullanıcı giriş yapmamışsa giriş ekranına yönlendir
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()), // Giriş ekranı
        );
      });
    }
  }

  // Veri ekleme fonksiyonu (Sadece giriş yapmış kullanıcı ekleyebilir)
  Future<void> _createItem(String value) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Kullanıcı giriş yapmamış!");
      return;
    }

    await _fireStore.collection("items").add({
      'name': value,
      'userId': user.uid, // Kullanıcı kimliği eklendi
    });
  }

  // veritabanınına item güncelleme
  Future<void> _updateItems(String id, String newValue) async {
    await _fireStore.collection("items").doc(id).update({'name': newValue});
  }

  // veritabanınından item silme
  Future<void> _deleteItems(String id) async {
    await _fireStore.collection("items").doc(id).delete();
  }

  Future<void> _showUpdateDialog(String id, String currentName) async {
    final TextEditingController updateController =
    TextEditingController(text: currentName);

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Güncelle"),
            content: TextField(
              controller: updateController,
              decoration: InputDecoration(
                labelText: 'Yeni Değer',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("İptal")),
              TextButton(
                  onPressed: () {
                    if (updateController.text.isNotEmpty) {
                      _updateItems(id, updateController.text);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Güncelle")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase CRUD"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Yeni veri ekle",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _createItem(_controller.text);
                  _controller.clear();
                }
              },
              child: Text('Ekle')),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseAuth.instance.currentUser != null
                    ? _fireStore
                    .collection('items')
                    .where('userId',
                    isEqualTo:
                    FirebaseAuth.instance.currentUser!.uid)
                    .snapshots()
                    : Stream.empty(), // Kullanıcı giriş yapmamışsa boş stream döndür
                builder: (context, snapshots) {
                  // Kullanıcı giriş yapmamışsa uyarı ver
                  if (FirebaseAuth.instance.currentUser == null) {
                    return Center(child: Text('Lütfen giriş yapın'));
                  }

                  if (snapshots.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshots.hasError) {
                    return Center(
                      child: Text('Hata: ${snapshots.error}'),
                    );
                  }

                  // Veri yoksa gösterilecek mesaj
                  if (snapshots.hasData == false ||
                      snapshots.data!.docs.isEmpty) {
                    return Center(
                      child: Text("Henüz veri yok"),
                    );
                  }

                  final docs = snapshots.data!.docs;

                  return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final name = doc['name'];
                        return ListTile(
                          title: Text(name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showUpdateDialog(doc.id, name);
                                },
                                icon: Icon(Icons.edit),
                              ),
                              IconButton(
                                  onPressed: () {
                                    _deleteItems(doc.id);
                                  },
                                  icon: Icon(Icons.delete))
                            ],
                          ),
                        );
                      });
                }),
          ),
        ],
      ),
    );
  }
}
