// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:money_app/features/authentication/screens/login_screen.dart';
import 'package:money_app/firebase_options.dart';
import 'package:money_app/screens/home_interface/home_screen.dart';
import 'package:money_app/screens/transaction_interface/transaction_screen.dart';
import 'screens/chat_interface/chat_interface.dart'; // nhớ file này có ChatInterfaceScreen


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "lib/.env");

  // Guard initialization: only initialize Firebase if no apps are initialized yet.
  // This avoids the [core/duplicate-app] error during hot restart/hot reload.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // ... your theme
      ),
      home:
          const LoginScreen(), // Bắt đầu với LoginScreen để tránh lỗi Firebase
      routes: {
        '/figma': (_) => const ChatInterfaceScreen(),
        "/home": (_) => const HomeScreen(),
        "/transaction": (_) => const TransactionScreen(),
      },
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             // Cách 1: push thẳng widget
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (_) => const ChatInterfaceScreen(),
//               ),
//             );
//
//             // Cách 2 (tuỳ chọn): nếu dùng named route ở trên
//             // Navigator.of(context).pushNamed('/figma');
//           },
//           child: const Text('Đi tới UI Figma'),
//         ),
//       ),
//     );
//   }
// }
