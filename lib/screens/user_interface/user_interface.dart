import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:money_app/features/authentication/screens/login_screen.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    setState(() {
      _avatarPath = null;
    });
    // The StreamBuilder will automatically handle the UI update
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
            // User is logged in
            return StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .snapshots(),
              builder: (context, userDocSnapshot) {
                if (!userDocSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final user = snapshot.data!;
                final userData =
                    userDocSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                return _buildUserProfile(user, userData);
              },
            );
          } else {
            // User is not logged in
            return _buildLoginPrompt();
          }
        },
      ),
    );
  }

  Widget _buildUserProfile(User user, Map<String, dynamic> userData) {
    final birthday = userData['birthday'] as Timestamp?;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickAndSaveImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage:
                  _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
              child: _avatarPath == null
                  ? Text(
                      user.email?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 40),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome!',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            user.email ?? 'No email provided',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
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
          // Bank card section will be added here
          _buildBankCardSection(),
        ],
      ),
    );
  }

  Widget _buildBankCardSection() {
    // For simplicity, we'll just show a button to add a card.
    // A real implementation would involve a form and secure storage.
    return ListTile(
      leading: const Icon(Icons.credit_card),
      title: const Text('Bank Cards'),
      subtitle: const Text('Add or manage your cards'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // Navigate to a new screen to add/manage cards
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const BankCardManagementScreen()));
      },
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
