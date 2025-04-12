import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String boardId;
  ChatScreen({required this.boardId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();

  // Send message to Firestore
  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final user = _auth.currentUser;
      await FirebaseFirestore.instance.collection('boards').doc(widget.boardId).collection('messages').add({
        'message': _messageController.text,
        'uid': user!.uid,
        'display_name': user.displayName ?? 'Anonymous',
        'datetime': Timestamp.now(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Board: ${widget.boardId}')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('boards')
                  .doc(widget.boardId)
                  .collection('messages')
                  .orderBy('datetime')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index]['message']),
                      subtitle: Text(messages[index]['display_name']),
                      trailing: Text(messages[index]['datetime'].toDate().toString()),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Enter message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
