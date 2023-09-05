import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/root_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Environment.init(
    apiBaseUrl: 'https://example.com',
  );

  FirebaseOptions options = const FirebaseOptions(
      apiKey: "AIzaSyCgH5j2uZIJPZDhUchANuhwsU8OX7gb3kw",
      authDomain: "sbi-rewards.firebaseapp.com",
      projectId: "sbi-rewards",
      storageBucket: "sbi-rewards.appspot.com",
      messagingSenderId: "978109418340",
      appId: "1:978109418340:web:ad7d7e631a603e00988871",
      measurementId: "G-BVLWKWXL1W"
  );
  await Firebase.initializeApp(
    options: options,
  );

  runApp(const RootApp());
}
