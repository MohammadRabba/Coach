import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coatch/view/chat/chatpage.dart';
import 'package:coatch/view/home/bars/appDrower.dart';
import 'package:coatch/view/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConversationsScreen extends StatefulWidget {
  final String id;
  const ConversationsScreen({super.key, required this.id});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final TextEditingController searchController = TextEditingController();
  Future<String> returnType(String id) async {
    print(id);
    DocumentSnapshot type =
        await FirebaseFirestore.instance.collection('user').doc(id).get();
    if (type['type'] == '0') {
      print("Type : 0");
      return '0';
    } else {
      print("Type : 1");
      return '1';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: onSearchTextChanged,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('user').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No users available.'),
                  );
                }
                List<DocumentSnapshot> users = snapshot.data!.docs;

                Future<String> typeFuture = returnType(widget.id);

                return FutureBuilder<String>(
                  future: typeFuture,
                  builder: (context, typeSnapshot) {
                    if (typeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (typeSnapshot.hasData) {
                      String userType = typeSnapshot.data!;
                      if (userType == '0') {
                        users =
                            users.where((user) => user['type'] == '1').toList();
                      }
                    } else if (typeSnapshot.hasError) {
                      print("Error fetching user type: ${typeSnapshot.error}");
                      // Optionally display an error message to the user
                    }

                    List<DocumentSnapshot> filteredUsers = users
                        .where((user) =>
                            user['name']?.toLowerCase()?.contains(
                                searchController.text.toLowerCase()) ??
                            false)
                        .toList();

                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        return UserCard(filteredUsers[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void onSearchTextChanged(String text) {
    setState(() {});
  }
}

class UserCard extends StatelessWidget {
  final DocumentSnapshot userData;

  const UserCard(this.userData, {super.key});

  @override
  Widget build(BuildContext context) {
    String photoUrl = 'assets/default.png';

    return Column(
      children: [
        InkWell(
          onTap: () {
            String userId = userData.id;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(userId: userId, photo: photoUrl),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            child: Row(
              children: [
                photoUrl != ''
                    ? CircleAvatar(backgroundImage: NetworkImage(photoUrl))
                    : const CircleAvatar(
                        backgroundImage: AssetImage('assets/default.png')),
                const SizedBox(width: 16),
                Text(
                  userData['name'] ?? 'No Name',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                UnreadIndicator(userId: userData.id),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class UnreadIndicator extends StatelessWidget {
  final String userId;

  const UnreadIndicator({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .doc(userId)
          .collection('messages')
          .where('receiverID',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        bool hasUnread = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return hasUnread
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Talk to Coatch'),
              );
      },
    );
  }
}
