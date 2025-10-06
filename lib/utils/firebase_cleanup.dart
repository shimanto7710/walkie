import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';

/// Utility class for cleaning up Firebase signals
class FirebaseCleanup {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  /// Delete all signals from Firebase
  static Future<void> deleteAllSignals() async {
    try {
      log('🧹 FirebaseCleanup - Deleting all signals...');
      
      // Get count before deletion
      final beforeCount = await getSignalCount();
      
      // Delete all signals
      await _database.child('signals').remove();
      
      log('✅ FirebaseCleanup - Deleted $beforeCount signals successfully!');
    } catch (e) {
      log('❌ FirebaseCleanup - Failed to delete signals: $e');
      rethrow;
    }
  }
  
  /// Delete signals older than specified minutes
  static Future<void> deleteOldSignals({int maxAgeMinutes = 5}) async {
    try {
      final cutoffTime = DateTime.now().subtract(Duration(minutes: maxAgeMinutes)).millisecondsSinceEpoch;
      
      log('🧹 FirebaseCleanup - Deleting signals older than $maxAgeMinutes minutes...');
      
      final snapshot = await _database.child('signals').get();
      if (snapshot.exists) {
        final signals = snapshot.value as Map<dynamic, dynamic>;
        int deletedCount = 0;
        
        for (final roomEntry in signals.entries) {
          final roomId = roomEntry.key;
          final roomData = roomEntry.value as Map<dynamic, dynamic>;
          
          for (final signalEntry in roomData.entries) {
            final signalData = signalEntry.value as Map<dynamic, dynamic>;
            final timestamp = signalData['timestamp'] as int?;
            
            if (timestamp != null && timestamp < cutoffTime) {
              await _database.child('signals').child(roomId).child(signalEntry.key).remove();
              deletedCount++;
              log('🗑️ FirebaseCleanup - Deleted old signal: ${signalEntry.key} from room: $roomId');
            }
          }
        }
        
        log('✅ FirebaseCleanup - Deleted $deletedCount old signals');
      } else {
        log('ℹ️ FirebaseCleanup - No signals found to clean up');
      }
    } catch (e) {
      log('❌ FirebaseCleanup - Failed to delete old signals: $e');
    }
  }
  
  /// Get signal count for debugging
  static Future<int> getSignalCount() async {
    try {
      final snapshot = await _database.child('signals').get();
      if (snapshot.exists) {
        final signals = snapshot.value as Map<dynamic, dynamic>;
        int count = 0;
        
        for (final roomEntry in signals.entries) {
          final roomData = roomEntry.value as Map<dynamic, dynamic>;
          count += roomData.length;
        }
        
        log('📊 FirebaseCleanup - Total signals: $count');
        return count;
      } else {
        log('📊 FirebaseCleanup - No signals found');
        return 0;
      }
    } catch (e) {
      log('❌ FirebaseCleanup - Failed to count signals: $e');
      return 0;
    }
  }
  
  /// Get detailed signal information
  static Future<Map<String, dynamic>> getSignalInfo() async {
    try {
      final snapshot = await _database.child('signals').get();
      if (snapshot.exists) {
        final signals = snapshot.value as Map<dynamic, dynamic>;
        Map<String, int> roomCounts = {};
        int totalSignals = 0;
        
        for (final roomEntry in signals.entries) {
          final roomId = roomEntry.key;
          final roomData = roomEntry.value as Map<dynamic, dynamic>;
          final roomSignalCount = roomData.length;
          roomCounts[roomId] = roomSignalCount;
          totalSignals += roomSignalCount;
        }
        
        final info = {
          'totalSignals': totalSignals,
          'totalRooms': roomCounts.length,
          'roomCounts': roomCounts,
        };
        
        log('📊 FirebaseCleanup - Signal info: $info');
        return info;
      } else {
        log('📊 FirebaseCleanup - No signals found');
        return {
          'totalSignals': 0,
          'totalRooms': 0,
          'roomCounts': <String, int>{},
        };
      }
    } catch (e) {
      log('❌ FirebaseCleanup - Failed to get signal info: $e');
      return {
        'totalSignals': 0,
        'totalRooms': 0,
        'roomCounts': <String, int>{},
      };
    }
  }
}
