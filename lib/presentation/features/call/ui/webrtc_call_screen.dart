/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/call_state.dart';
import '../../../../core/utils/permissions_helper.dart';
import '../provider/simple_webrtc_provider.dart';
import '../../login/provider/auth_provider.dart';

class WebRTCCallScreen extends ConsumerStatefulWidget {
  final User friend;
  final bool isIncomingCall;
  final String? handshakeId;
  
  const WebRTCCallScreen({
    super.key,
    required this.friend,
    this.isIncomingCall = false,
    this.handshakeId,
  });

  @override
  ConsumerState<WebRTCCallScreen> createState() => _WebRTCCallScreenState();
}

class _WebRTCCallScreenState extends ConsumerState<WebRTCCallScreen>
    with TickerProviderStateMixin {
  bool _isHolding = false;
  bool _isCallSustained = false;
  bool _isSwipeGesture = false;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _swipeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<Offset> _swipeAnimation;

  @override
  void initState() {
    super.initState();
    
    _setupAnimations();
    _initializeWebRTC();
  }

  void _setupAnimations() {
    // Pulse animation for the call button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Wave animation for the background
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    // Swipe up animation for the call button
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.3),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOutBack,
    ));

    _pulseController.repeat(reverse: true);
    _waveController.repeat();
    
    // Initialize WebRTC and permissions
    _initializeWebRTC();
  }

  Future<void> _initializeWebRTC() async {
    try {
      // Request permissions
      final hasAudioPermission = await PermissionsHelper.requestAudioPermissions();
      if (!hasAudioPermission) {
        _showPermissionDialog('Microphone permission is required for voice calls.');
        return;
      }

      // Initialize WebRTC
      final controller = ref.read(webrtcCallStateProvider.notifier);
      await controller.initialize();

      // Set local user ID
      final authState = ref.read(authProvider);
      if (authState.currentUser != null) {
        controller.setLocalUserId(authState.currentUser!.id);
      }

      // Note: ref.listen calls are now handled in the build method

    } catch (e) {
      print('❌ Error initializing WebRTC: $e');
      _showErrorDialog('Failed to initialize call: $e');
    }
  }


  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionsHelper.openSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startCallWebRTC() async {
    final controller = ref.read(webrtcCallStateProvider.notifier);
    await controller.startCall(widget.friend.id);
  }

  void _acceptCallWebRTC() async {
    final controller = ref.read(webrtcCallStateProvider.notifier);
    await controller.acceptCall();
  }

  void _rejectCallWebRTC() async {
    final controller = ref.read(webrtcCallStateProvider.notifier);
    await controller.rejectCall();
    context.go('/home');
  }

  void _endCallWebRTC() async {
    final controller = ref.read(webrtcCallStateProvider.notifier);
    await controller.endCall();
    context.go('/home');
  }

  void _toggleMuteWebRTC() async {
    final controller = ref.read(webrtcCallStateProvider.notifier);
    await controller.toggleMute();
  }

  void _toggleSpeakerWebRTC() async {
    final controller = ref.read(webrtcCallStateProvider.notifier);
    await controller.toggleSpeaker();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _swipeController.dispose();
    
    // Reset WebRTC state
    final controller = ref.read(webrtcCallStateProvider.notifier);
    controller.reset();
    
    super.dispose();
  }

  void _onHoldStart() {
    setState(() {
      _isHolding = true;
    });
  }

  void _onHoldEnd() {
    if (!_isSwipeGesture) {
      setState(() {
        _isHolding = false;
      });
    }
  }

  void _onSwipeUp() {
    setState(() {
      _isCallSustained = true;
      _isSwipeGesture = true;
    });
    
    if (widget.isIncomingCall) {
      _acceptCall();
    } else {
      _startCall();
    }
    
    _swipeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to WebRTC call state changes
    ref.listen<CallState>(webrtcCallStateProvider, (previous, next) {
      if (next.status == CallStatus.connected) {
        setState(() {
          _isCallSustained = true;
        });
      } else if (next.status == CallStatus.ended) {
        context.go('/home');
      } else if (next.status == CallStatus.failed) {
        _showErrorDialog(next.errorMessage ?? 'Call failed');
      }
    });

    final callState = ref.watch(webrtcCallStateProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with friend info and controls
            _buildHeader(callState),
            
            // Main content area
            Expanded(
              child: _buildMainContent(callState),
            ),
            
            // Call controls
            _buildCallControls(callState),
            
            // Bottom padding
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CallState callState) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (callState.status == CallStatus.connected) {
                  _endCall();
                } else {
                  _rejectCall();
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          
          // Friend info
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.friend.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(callState),
                  style: TextStyle(
                    color: _getStatusColor(callState),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Mute button
          IconButton(
            onPressed: _toggleMute,
            icon: Icon(
              callState.isMuted ? Icons.mic_off : Icons.mic,
              color: callState.isMuted ? Colors.red : Colors.white,
              size: 28,
            ),
          ),
          
          // Speaker button
          IconButton(
            onPressed: _toggleSpeaker,
            icon: Icon(
              callState.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
              color: callState.isSpeakerOn ? Colors.green : Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(CallState callState) {
    if (callState.status == CallStatus.connected) {
      return 'Call Active';
    } else if (callState.isConnecting) {
      return 'Connecting...';
    } else if (callState.status == CallStatus.calling) {
      return 'Calling...';
    } else if (callState.status == CallStatus.ringing) {
      return 'Ringing...';
    } else if (_isCallSustained) {
      return 'Call Active';
    } else if (_isHolding) {
      return 'Talking...';
    } else {
      return 'Ready to Call';
    }
  }

  Color _getStatusColor(CallState callState) {
    if (callState.status == CallStatus.connected || _isCallSustained) {
      return Colors.green;
    } else if (callState.isConnecting || callState.status == CallStatus.calling) {
      return Colors.orange;
    } else if (callState.status == CallStatus.ringing) {
      return Colors.purple;
    } else if (_isHolding) {
      return Colors.orange;
    } else {
      return Colors.grey[400]!;
    }
  }

  Widget _buildMainContent(CallState callState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Friend avatar with status
          _buildFriendAvatar(callState),
          
          const SizedBox(height: 40),
          
          // Call status text
          _buildCallStatus(callState),
          
          const SizedBox(height: 60),
          
          // Instructions
          _buildInstructions(callState),
        ],
      ),
    );
  }

  Widget _buildFriendAvatar(CallState callState) {
    return Stack(
      children: [
        // Animated background waves
        if (_isHolding || _isCallSustained || callState.status == CallStatus.connected)
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return Container(
                width: 200 + (_waveAnimation.value * 50),
                height: 200 + (_waveAnimation.value * 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3 - (_waveAnimation.value * 0.2)),
                    width: 2,
                  ),
                ),
              );
            },
          ),
        
        // Friend avatar
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.friend.status ? Colors.green : Colors.grey,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
          ),
          child: Center(
            child: Text(
              widget.friend.initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallStatus(CallState callState) {
    return Text(
      _getStatusText(callState),
      style: TextStyle(
        color: _getStatusColor(callState),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInstructions(CallState callState) {
    if (callState.status == CallStatus.connected || _isCallSustained) {
      return const Text(
        'Call is active. Tap end call to disconnect.',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      );
    } else if (_isHolding) {
      return const Text(
        'Talking...\nSwipe up to sustain call\nRelease to stop talking',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'Hold to talk\nSwipe up while holding to sustain call\nRelease to stop talking',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _buildCallControls(CallState callState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        children: [
          // Hold to talk button
          Listener(
            onPointerDown: (_) {
              _onHoldStart();
            },
            onPointerUp: (_) {
              if (!_isSwipeGesture) {
                _onHoldEnd();
              }
            },
            onPointerCancel: (_) {
              if (!_isSwipeGesture) {
                _onHoldEnd();
              }
            },
            onPointerMove: (details) {
              if (details.delta.dy < -10 && _isHolding && !_isCallSustained) {
                _onSwipeUp();
              }
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _swipeAnimation]),
              builder: (context, child) {
                return Transform.translate(
                  offset: _isCallSustained 
                    ? Offset(0, _swipeAnimation.value.dy * 100)
                    : Offset.zero,
                  child: Transform.scale(
                    scale: _isHolding ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (_isHolding || _isCallSustained || callState.status == CallStatus.connected) 
                          ? Colors.green 
                          : Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: ((_isHolding || _isCallSustained || callState.status == CallStatus.connected) 
                              ? Colors.green 
                              : Colors.red).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Status indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isHolding || _isCallSustained || callState.status == CallStatus.connected
                    ? Colors.green 
                    : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusText(callState),
                style: TextStyle(
                  color: _isHolding || _isCallSustained || callState.status == CallStatus.connected
                    ? Colors.green 
                    : Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/
