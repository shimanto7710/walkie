import 'package:flutter_test/flutter_test.dart';
import 'package:walkie/data/services/webrtc_service.dart';

void main() {
  group('WebRTC Service Tests', () {
    test('WebRTC Service Singleton Instance', () {
      // Test singleton pattern
      final instance1 = FlutterWebRTCService.instance;
      final instance2 = FlutterWebRTCService.instance;
      final instance3 = FlutterWebRTCService();
      
      expect(instance1, same(instance2));
      expect(instance1, same(instance3));
    });

    test('WebRTC Service Initial State', () {
      final service = FlutterWebRTCService.instance;
      final state = service.currentState;
      
      expect(state.isInitialized, false);
      expect(state.status.toString(), 'WebRTCConnectionStatus.disconnected');
    });

    test('WebRTC Service Configuration', () {
      final service = FlutterWebRTCService.instance;
      
      // Test that service has required methods
      expect(service.initialize, isA<Function>());
      expect(service.createOffer, isA<Function>());
      expect(service.createAnswer, isA<Function>());
      expect(service.setLocalDescription, isA<Function>());
      expect(service.setRemoteDescription, isA<Function>());
      expect(service.addIceCandidate, isA<Function>());
      expect(service.getIceCandidates, isA<Function>());
    });
  });
}
