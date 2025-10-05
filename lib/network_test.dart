import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> testNetworkConnectivity() async {
  print("🌐 Testing network connectivity...");
  
  // Test 1: DNS lookup
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print("✅ DNS lookup successful: ${result[0].address}");
    } else {
      print("❌ DNS lookup failed");
    }
  } catch (e) {
    print("❌ DNS lookup error: $e");
  }
  
  // Test 2: HTTP request
  try {
    final response = await http.get(Uri.parse('https://www.google.com')).timeout(
      const Duration(seconds: 5),
    );
    if (response.statusCode == 200) {
      print("✅ HTTP request successful: ${response.statusCode}");
    } else {
      print("❌ HTTP request failed: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ HTTP request error: $e");
  }
  
  // Test 3: Firebase URL specifically
  try {
    final response = await http.get(Uri.parse('https://walkie-e86f4-default-rtdb.firebaseio.com')).timeout(
      const Duration(seconds: 5),
    );
    print("✅ Firebase URL accessible: ${response.statusCode}");
  } catch (e) {
    print("❌ Firebase URL error: $e");
  }
}
