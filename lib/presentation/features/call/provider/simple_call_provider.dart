import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/call_state.dart';

part 'simple_call_provider.g.dart';

@riverpod
class SimpleCallNotifier extends _$SimpleCallNotifier {
  @override
  CallState build() {
    return const CallState();
  }

  void startCall() {
    state = state.copyWith(
      status: CallStatus.calling,
      isConnecting: true,
    );
  }

  void acceptCall() {
    state = state.copyWith(
      status: CallStatus.connected,
      isConnecting: false,
      isConnected: true,
    );
  }

  void endCall() {
    state = state.copyWith(
      status: CallStatus.ended,
      isConnecting: false,
      isConnected: false,
    );
  }

  void reset() {
    state = const CallState();
  }
}
