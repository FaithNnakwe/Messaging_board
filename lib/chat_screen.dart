import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String boardName;

  const ChatScreen({Key? key, required this.boardName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final displayName = '${userDoc['firstName']} ${userDoc['lastName']}';

    await _firestore
        .collection('messageBoards')
        .doc(widget.boardName)
        .collection('messages')
        .add({
      'text': _messageController.text.trim(),
      'senderId': user.uid,
      'senderName': displayName,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = _firestore
        .collection('messageBoards')
        .doc(widget.boardName)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
  title: Text(widget.boardName),
  backgroundColor: widget.boardName == "General Chat"
      ? Color(0xFFC8E6C9)
      : widget.boardName == "Tech Talk"
          ? Color(0xFFFFD1DC)
          : widget.boardName == "Random"
              ? Color(0xFFB3E5FC)
              : Color(0xFFE1BEE7),
),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == _auth.currentUser?.uid;

return Align(
  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
  child: Container(
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isMe ? Colors.deepPurple.shade100 : Colors.grey.shade300,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
        bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          msg['text'],
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          '${msg['senderName']} • ${msg['timestamp'] != null ? (msg['timestamp'] as Timestamp).toDate().toLocal().toString().substring(0, 16) : 'Sending...'}',
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
      ],
    ),
  ),
);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
