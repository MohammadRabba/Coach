import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coatch/model/userModel.dart';
import 'package:coatch/view/home/bars/appDrower.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String photo;
  const ChatScreen({
    super.key,
    required this.photo,
    required this.userId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String receiverName = '';
  String userType = '0';
  final TextEditingController _textEditingController = TextEditingController();
  late Stream<QuerySnapshot> _messagesStream;

  @override
  void initState() {
    super.initState();
    _fetchReceiverNameAndType();
    _messagesStream = FirebaseFirestore.instance
        .collection('conversations')
        .doc(_generateConversationId())
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _fetchReceiverNameAndType() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userId)
          .get();
      if (userSnapshot.exists) {
        setState(() {
          receiverName = userSnapshot['name'] ?? 'Unknown ';
          userType = userSnapshot['type'] ?? '0';
        });
      }
    } catch (error) {
      print('Error fetching receiver details: $error');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      File imageFile = File(file.path);

      String imageUrl = await uploadFile(imageFile);

      await _sendMessage(imageUrl: imageUrl);
    }
  }

  Future<String> uploadFile(File file) async {
    String filePath =
        'files/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    Reference ref = FirebaseStorage.instance.ref().child(filePath);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);

      String fileUrl = await uploadFile(file);

      await _sendMessage(fileUrl: fileUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    String photo = widget.photo ?? '';
    return Scaffold(
      drawer: AppDrawer(model: new UserModel()), // هنا تضيف الـ Drawer

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            photo != ''
                ? CircleAvatar(backgroundImage: NetworkImage(photo))
                : const CircleAvatar(
                    backgroundImage: AssetImage('assets/default.png')),
            const SizedBox(width: 8),
            Text(
              receiverName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const CircleAvatar(
              radius: 6,
              backgroundColor: Colors.green,
            ),
          ],
        ),
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet.'),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Future<void> _openFile(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  Widget _buildMessageBubble(DocumentSnapshot message) {
    final bool isSentByCurrentUser =
        FirebaseAuth.instance.currentUser!.uid == message['senderID'];
    final formattedTime = message['timestamp'] != null
        ? DateFormat.Hm().format(message['timestamp'].toDate())
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Align(
        alignment:
            isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isSentByCurrentUser
                ? const Color.fromARGB(255, 93, 8, 240)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: isSentByCurrentUser
                  ? const Color.fromARGB(255, 116, 54, 240)
                  : Colors.grey.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message['messageContent'],
                style: TextStyle(
                  color: isSentByCurrentUser
                      ? Colors.white
                      : const Color.fromARGB(255, 116, 54, 240),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedTime,
                style: TextStyle(
                  color: isSentByCurrentUser
                      ? Colors.white
                      : const Color.fromARGB(255, 201, 15, 15),
                  fontSize: 10,
                ),
              ),
              if (message['imageUrl'] != null && message['imageUrl'].isNotEmpty)
                Image.network(message['imageUrl']),
              if (message['fileUrl'] != null && message['fileUrl'].isNotEmpty)
                InkWell(
                  onTap: () => _openFile(message['fileUrl']),
                  child: const Icon(Icons.attachment),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: _pickAndUploadImage,
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _pickAndUploadFile,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Send a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      await _sendMessage();
                      _textEditingController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// In _ChatScreenState
  Future<void> _sendMessage({String imageUrl = '', String fileUrl = ''}) async {
    String messageText = _textEditingController.text.trim();
    _textEditingController.clear();

    if (messageText.isEmpty && imageUrl.isEmpty && fileUrl.isEmpty) {
      return;
    }
    String conversationId = _generateConversationId();

    CollectionReference conversationsCollection =
        FirebaseFirestore.instance.collection('conversations');

    try {
      // Add the message to the subcollection
      await conversationsCollection
          .doc(conversationId)
          .collection('messages')
          .add({
        'senderID': FirebaseAuth.instance.currentUser!.uid,
        'receiverID': widget.userId,
        'messageContent': messageText,
        'imageUrl': imageUrl,
        'fileUrl': fileUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Retrieve current user and receiver names for conversation metadata
      String currentUserName = '';
      String receiverUserName = '';

      // Fetch current user's name
      DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (currentUserDoc.exists) {
        currentUserName = currentUserDoc['name'] ?? '';
      }

      // Fetch receiver's name
      DocumentSnapshot receiverUserDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userId)
          .get();
      if (receiverUserDoc.exists) {
        receiverUserName = receiverUserDoc['name'] ?? '';
      }

      // Update the conversation document
      await conversationsCollection.doc(conversationId).set(
        {
          'lastMessage': messageText,
          // If you have an 'unreadCount' for the whole conversation, update it carefully.
          // For example, increment for the receiver. This depends on your unread logic.
          // 'unreadCount': FieldValue.increment(1), // Be careful with unreadCount in top-level doc
          'participants': [
            FirebaseAuth.instance.currentUser!.uid,
            widget.userId
          ],
          'userNames': {
            // Ensure names are not null or empty if used as keys
            FirebaseAuth.instance.currentUser!.uid: currentUserName,
            widget.userId: receiverUserName,
          },
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
        },
        SetOptions(
            merge:
                true), // Use merge to update existing fields without overwriting others
      );
    } catch (error) {
      print('Failed to send message: $error');
    }
  }

  String _generateConversationId() {
    List<String> ids = [FirebaseAuth.instance.currentUser!.uid, widget.userId];
    ids.sort();
    return ids.join('_');
  }
}
