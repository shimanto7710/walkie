import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/session_helper.dart';

// Session state provider
final sessionProvider = FutureProvider<bool>((ref) async {
  return await SessionHelper.isLoggedIn();
});

// User data provider
final savedUserDataProvider = FutureProvider<Map<String, String?>>((ref) async {
  return await SessionHelper.getSavedUserData();
});
