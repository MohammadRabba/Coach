import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coatch/view/chat/chatpage.dart';
import 'package:coatch/view/home/bars/appDrower.dart';
import 'package:flutter/material.dart';
import 'package:coatch/ColoreApp/colors.dart';
import 'package:coatch/model/userModel.dart';
import 'package:coatch/view/chat/chatListPage.dart';
import 'package:coatch/view/home/MainPage.dart';
import 'package:coatch/view/profilePage.dart/profilePage.dart';

class UserHomePage extends StatefulWidget {
  final UserModel userModel;

  const UserHomePage({super.key, required this.userModel});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 1;

  late final List<Widget> _pages;

  final List<String> _buttontitle = [
    "Chat",
    "Home",
    "Profile",
  ];

  final List<IconData> _buttonicon = [
    Icons.chat_bubble_outline,
    Icons.home_outlined,
    Icons.person_outline,
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      ConversationsScreen(id: widget.userModel.id ?? ''),
      MainPage(userModel: widget.userModel),
      UserProfile(model: widget.userModel),
    ];
  }

  Future<void> getAdminId(String id) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('type', isEqualTo: '1')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        id = querySnapshot.docs.first.id;
      } else {
        print('No admin user found.');
      }
    } catch (error) {
      print('Error fetching admin ID: $error');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(model: widget.userModel), // هنا تضيف الـ Drawer
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 4,
        centerTitle: true,
        title: Text(
          'Motion Gym',
          style: const TextStyle(
            color: AppColors.background,
            fontFamily: "FFS",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primary,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.background,
        unselectedItemColor: AppColors.garyC,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 13,
        unselectedFontSize: 11,
        items: List.generate(
          _buttontitle.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(_buttonicon[index]),
            label: _buttontitle[index],
          ),
        ),
      ),
    );
  }
}
