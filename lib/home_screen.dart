import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User logout
  Future<void> _logout(BuildContext context) async {
  await _auth.signOut();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Message Boards')),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Message Boards'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {},
            ),
            ListTile(
  title: Text('Settings'),
  onTap: () => _logout(context),
),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('boards').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final boards = snapshot.data!.docs;
          return ListView.builder(
            itemCount: boards.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(boards[index]['name']),
                leading: CircleAvatar(child: Icon(Icons.chat)),
                onTap: () {
                  // Navigate to chat window
                },
              );
            },
          );
        },
      ),
    );
  }
}
