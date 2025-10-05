import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

Future<void> testFirebaseConnection() async {
  try {
    print("🧪 Testing Firebase connection...");
    
    // Test network connectivity
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
    
    // Test Firebase initialization
    print("🔍 Testing Firebase initialization...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");
    
    // Test Firebase Database
    print("🔍 Testing Firebase Database...");
    final database = FirebaseDatabase.instance;
    print("🔍 Database URL: ${database.databaseURL}");
    
    // Test simple read
    print("🔍 Testing simple read...");
    final snapshot = await database.ref('test').get().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print("⏰ Firebase read timed out");
        throw Exception('Firebase read timed out');
      },
    );
    
    print("✅ Firebase read successful: ${snapshot.exists}");
    
  } catch (e) {
    print("❌ Firebase test failed: $e");
    print("❌ Error type: ${e.runtimeType}");
  }
}
