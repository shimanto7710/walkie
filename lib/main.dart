import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print("🚀 Starting Firebase initialization...");
    
    // Test network connectivity first
    print("🔍 Testing network connectivity...");
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print("✅ Network connectivity: OK");
      } else {
        print("❌ Network connectivity: FAILED");
      }
    } catch (e) {
      print("❌ Network connectivity test failed: $e");
    }
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print("✅ Firebase initialized successfully");
    print("🔍 Firebase app name: ${Firebase.app().name}");
    print("🔍 Firebase options: ${Firebase.app().options}");
    print("🔍 Firebase project ID: ${Firebase.app().options.projectId}");
    print("🔍 Firebase database URL: ${Firebase.app().options.databaseURL}");
    
    // Configure dependencies
    await configureDependencies();
    print("✅ Dependencies configured successfully");
    
  } catch (e) {
    print("❌ Error during initialization: $e");
    rethrow;
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Walkie',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}