import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/call_state.dart';
import '../entities/signal_message.dart';

abstract class WebRTCRepository {
  // Connection management
  Future<Either<Failure, void>> initialize();
  Future<Either<Failure, void>> dispose();
  
  // Call management
  Future<Either<Failure, void>> startCall(String remoteUserId);
  Future<Either<Failure, void>> acceptCall();
  Future<Either<Failure, void>> rejectCall();
  Future<Either<Failure, void>> endCall();
  
  // Audio control
  Future<Either<Failure, void>> toggleMute();
  Future<Either<Failure, void>> toggleSpeaker();
  
  // Signaling
  Future<Either<Failure, void>> sendSignal(SignalMessage message);
  Stream<SignalMessage> get signalStream;
  
  // State
  Stream<CallState> get callStateStream;
  CallState get currentCallState;
}
