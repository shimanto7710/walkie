import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/call_state.dart';
import '../provider/webrtc_provider.dart';
import '../../login/provider/auth_provider.dart';

class CallScreen extends ConsumerStatefulWidget {
  final User friend;
  
  const CallScreen({
    super.key,
    required this.friend,
  });

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen>
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
      end: const Offset(0, -0.3), // Move up by 30% of button height
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOutBack,
    ));

    _pulseController.repeat(reverse: true);
    _waveController.repeat();

    // Initialize WebRTC after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add a small delay to ensure the widget is fully built
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _initializeWebRTC();
        }
      });
    });
  }

  void _initializeWebRTC() async {
    try {
      final authState = ref.read(authProvider);
      if (authState.currentUser != null) {
        print('🔧 Initializing WebRTC for user: ${authState.currentUser!.id}');
        
        final webrtcNotifier = ref.read(webRTCNotifierProvider.notifier);
        await webrtcNotifier.initialize(authState.currentUser!.id);
        
        print('✅ WebRTC initialized successfully');
        
        // Set up automatic call acceptance listener
        _setupAutomaticCallAcceptance();
      } else {
        print('❌ No current user found for WebRTC initialization');
      }
    } catch (e) {
      print('❌ Failed to initialize WebRTC: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize call system: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setupAutomaticCallAcceptance() {
    // This method is no longer needed - we'll handle this in the build method
    print('🔧 Automatic call acceptance will be handled in build method');
  }

  void _acceptIncomingCall() async {
    final webrtcNotifier = ref.read(webRTCNotifierProvider.notifier);
    await webrtcNotifier.acceptCall();
    print('✅ Call automatically accepted - ID exchange completed');
  }

  void _initiateAutomaticCall() async {
    final authState = ref.read(authProvider);
    if (authState.currentUser != null) {
      final webrtcNotifier = ref.read(webRTCNotifierProvider.notifier);
      
      print('🚀 Initiating automatic call with ID exchange...');
      print('📤 Sending call request from ${authState.currentUser!.id} to ${widget.friend.id}');
      
      // Start the call - this will trigger the ID exchange flow
      await webrtcNotifier.startCall(widget.friend.id);
      
      print('✅ Call request sent - waiting for automatic ID exchange...');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _swipeController.dispose();
    
    // Dispose WebRTC
    final webrtcNotifier = ref.read(webRTCNotifierProvider.notifier);
    webrtcNotifier.dispose();
    
    super.dispose();
  }

  void _onHoldStart() {
    print('🎤 _onHoldStart called - setting _isHolding to true');
    setState(() {
      _isHolding = true;
    });
    
    // Check current call state
    final currentCallState = ref.read(webRTCNotifierProvider);
    
    if (currentCallState.status == CallStatus.connected) {
      print('🎤 Hold started - call already connected, ready to talk!');
      // Call is already connected, just start talking
      return;
    } else if (currentCallState.status == CallStatus.ringing) {
      print('🎤 Hold started - call is ringing, waiting for connection...');
      // Call is ringing, don't initiate new call
      return;
    } else {
      print('🎤 Hold started - initiating automatic ID exchange...');
      // Call is not started yet, initiate the call
      _initiateAutomaticCall();
    }
  }

  void _onHoldEnd() {
    if (!_isCallSustained && !_isSwipeGesture) {
      setState(() {
        _isHolding = false;
      });
      print('🎤 Hold ended - checking call state...');
      
      // Check if call is connected before ending
      final callState = ref.read(webRTCNotifierProvider);
      if (callState.status == CallStatus.connected) {
        print('📞 Call is connected - ending call...');
        _endCall();
      } else if (callState.status == CallStatus.calling || callState.status == CallStatus.ringing) {
        print('⏳ ID exchange in progress - waiting for completion...');
        // Give more time for ID exchange to complete
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && !_isCallSustained) {
            final currentCallState = ref.read(webRTCNotifierProvider);
            if (currentCallState.status != CallStatus.connected) {
              print('❌ ID exchange failed or timed out - ending call...');
              _endCall();
            }
          }
        });
      } else {
        print('❌ Call not in progress - ending call...');
        _endCall();
      }
    }
  }

  void _onSwipeUp() {
    print('📞 _onSwipeUp called - setting sustained state');
    setState(() {
      _isCallSustained = true;
      _isSwipeGesture = true;
    });
    print('📞 Call sustained - continuing call...');
    print('📞 State after swipe: _isCallSustained: $_isCallSustained, _isSwipeGesture: $_isSwipeGesture');
    // TODO: Implement sustained call logic
    
    // Trigger the swipe up animation
    _swipeController.forward();
  }

  void _endCall() async {
    setState(() {
      _isHolding = false;
      _isCallSustained = false;
      _isSwipeGesture = false;
    });
    print('📞 Call ended - navigating to home');
    
    // End WebRTC call
    final webrtcNotifier = ref.read(webRTCNotifierProvider.notifier);
    await webrtcNotifier.endCall();

    // Reset the swipe animation
    _swipeController.reset();

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    // Listen to WebRTC state changes
    ref.listen<CallState>(webRTCNotifierProvider, (previous, next) {
      if (next.status == CallStatus.connected) {
        print('📞 WebRTC call connected - ID exchange successful!');
        setState(() {
          // Update UI to show connection is established
        });
      } else if (next.status == CallStatus.failed) {
        print('❌ WebRTC call failed: ${next.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ID exchange failed: ${next.errorMessage ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
        // Auto-end call on failure
        if (mounted && !_isCallSustained) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) _endCall();
          });
        }
      } else if (next.status == CallStatus.ended) {
        print('📞 WebRTC call ended');
        context.go('/home');
      } else if (next.status == CallStatus.ringing) {
        print('📞 Incoming call - automatically accepting...');
        // Automatically accept incoming calls
        _acceptIncomingCall();
      } else if (next.status == CallStatus.calling) {
        print('📞 Calling - sending ID to remote user...');
      }
    });

    final callState = ref.watch(webRTCNotifierProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with friend info and end call button
            _buildHeader(),
            
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print('🔙 Back button pressed - navigating to home');
                context.go('/home');
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
                  _isCallSustained 
                    ? 'Call Active' 
                    : _isHolding 
                      ? 'Connecting...' 
                      : 'Ready to Call',
                  style: TextStyle(
                    color: _isCallSustained 
                      ? Colors.green 
                      : _isHolding 
                        ? Colors.orange 
                        : Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // End call button (only visible when call is sustained)
          if (_isCallSustained)
            IconButton(
              onPressed: _endCall,
              icon: const Icon(
                Icons.call_end,
                color: Colors.red,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent(CallState callState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Friend avatar with status
          _buildFriendAvatar(),
          
          const SizedBox(height: 40),
          
          // Call status text
          _buildCallStatus(callState),
          
          const SizedBox(height: 60),
          
          // Instructions
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildFriendAvatar() {
    return Stack(
      children: [
        // Animated background waves
        if (_isHolding || _isCallSustained)
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
    String statusText;
    Color statusColor;
    
    if (callState.status == CallStatus.connected) {
      statusText = 'Call Connected';
      statusColor = Colors.green;
    } else if (callState.isConnecting) {
      statusText = 'Exchanging IDs...';
      statusColor = Colors.orange;
    } else if (callState.status == CallStatus.calling) {
      statusText = 'Sending ID...';
      statusColor = Colors.blue;
    } else if (callState.status == CallStatus.ringing) {
      statusText = 'Receiving ID...';
      statusColor = Colors.purple;
    } else if (_isCallSustained) {
      statusText = 'Call Active';
      statusColor = Colors.green;
    } else if (_isHolding) {
      statusText = 'Exchanging IDs...';
      statusColor = Colors.orange;
    } else {
      statusText = 'Hold to Exchange IDs';
      statusColor = Colors.grey[400]!;
    }
    
    return Text(
      statusText,
      style: TextStyle(
        color: statusColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInstructions() {
    if (_isCallSustained) {
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
        'Exchanging IDs automatically...\nSwipe up to sustain call\nRelease to disconnect',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'Hold to exchange IDs and start talking\nSwipe up while holding to sustain call',
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
              print('🎤 onPointerDown detected - _isCallSustained: $_isCallSustained');
              if (!_isCallSustained) {
                print('🎤 Hold started');
                _onHoldStart();
              } else {
                print('🎤 Call already sustained, ignoring hold');
              }
            },
            onPointerUp: (_) {
              print('🎤 onPointerUp detected - _isCallSustained: $_isCallSustained, _isSwipeGesture: $_isSwipeGesture');
              if (!_isCallSustained && !_isSwipeGesture) {
                print('🎤 Hold ended');
                _onHoldEnd();
              } else {
                print('🎤 onPointerUp ignored - call sustained or swipe gesture');
              }
            },
            onPointerCancel: (_) {
              print('🎤 onPointerCancel detected - _isCallSustained: $_isCallSustained, _isSwipeGesture: $_isSwipeGesture');
              if (!_isCallSustained && !_isSwipeGesture) {
                print('🎤 Hold cancelled');
                _onHoldEnd();
              } else {
                print('🎤 onPointerCancel ignored - call sustained or swipe gesture');
              }
            },
            onPointerMove: (details) {
              print('🎤 onPointerMove - delta: ${details.delta.dy}, _isHolding: $_isHolding, _isCallSustained: $_isCallSustained');
              // Check for swipe up gesture
              if (details.delta.dy < -10 && _isHolding && !_isCallSustained) {
                print('⬆️ Swipe up detected - delta: ${details.delta.dy}');
                _onSwipeUp();
              }
            },
            child: GestureDetector(
              onTap: () {
                if (_isCallSustained) {
                  print('📞 Sustained call tapped - ending call');
                  _endCall();
                }
              },
              child: AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _swipeAnimation]),
              builder: (context, child) {
                return Transform.translate(
                  offset: _isCallSustained 
                    ? Offset(0, _swipeAnimation.value.dy * 100) // 100 is button height
                    : Offset.zero,
                  child: Transform.scale(
                    scale: _isHolding ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (_isHolding || _isCallSustained) 
                          ? Colors.green 
                          : Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: ((_isHolding || _isCallSustained) 
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
                  color: _isHolding || _isCallSustained 
                    ? Colors.green 
                    : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isCallSustained 
                  ? 'Call Active' 
                  : _isHolding 
                    ? 'Connecting' 
                    : 'Ready',
                style: TextStyle(
                  color: _isHolding || _isCallSustained 
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
