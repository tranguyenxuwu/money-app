import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:money_app/screens/login_and_signup/login_screen.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_app/services/sync_service.dart';

class UserInterfaceScreen extends StatefulWidget {
  const UserInterfaceScreen({super.key});

  @override
  State<UserInterfaceScreen> createState() => _UserInterfaceScreenState();
}

class _UserInterfaceScreenState extends State<UserInterfaceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    // Load avatar path specific to the current user
    if (_auth.currentUser != null) {
      setState(() {
        _avatarPath = prefs.getString('avatar_${_auth.currentUser!.uid}');
      });
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const LoginScreen();
        },
      ),
      (_) => false,
    );
  }

  Future<void> _pickAndSaveImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || _auth.currentUser == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final savedImage =
        await File(image.path).copy('${appDir.path}/$fileName');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_${_auth.currentUser!.uid}', savedImage.path);

    setState(() {
      _avatarPath = savedImage.path;
    });
  }

  Future<void> _selectAndSetBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && _auth.currentUser != null) {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'birthday': Timestamp.fromDate(picked)});
      setState(() {}); // Refresh UI
    }
  }

  Future<void> _syncData() async {
    final bool success = await SyncService.syncAllDataToFirebase();
    if (mounted) {
      final message = success
          ? 'Đồng bộ dữ liệu thành công!'
          : 'Không có dữ liệu mới hoặc có lỗi xảy ra.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: const Color(0xFF00D09E),
        actions: [
          // This button will only be visible when the user is logged in
          StreamBuilder<User?>(
            stream: _auth.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _signOut,
                  tooltip: 'Logout',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in, build the full profile UI
            return _buildUserProfile(context, snapshot.data!);
          } else {
            // User is not logged in
            return _buildLoginPrompt();
          }
        },
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, User user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickAndSaveImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
              child: _avatarPath == null ? const Icon(Icons.person, size: 50) : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user.email ?? 'No email',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(user.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                // Handle case where user document doesn't exist yet.
                // The sync is automatic, so we don't need to show a button here.
                return Container();
              }
              final userData = snapshot.data!.data() as Map<String, dynamic>?;
              final birthday = userData?['birthday'] as Timestamp?;
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.cake),
                    title: const Text('Birthday'),
                    subtitle: Text(birthday != null
                        ? DateFormat.yMMMMd().format(birthday.toDate())
                        : 'Not set'),
                    trailing: const Icon(Icons.edit),
                    onTap: _selectAndSetBirthday,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('Đồng bộ thủ công'),
                    subtitle: const Text('Đẩy dữ liệu local lên đám mây'),
                    onTap: _syncData,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'You are not logged in.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D09E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Login / Register'),
          ),
        ],
      ),
    );
  }
}

class BankCardManagementScreen extends StatelessWidget {
  const BankCardManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder screen.
    // You would build a form here to collect card details.
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bank Cards')),
      body: const Center(
        child: Text('Card management functionality to be implemented here.'),
      ),
    );
  }
}
