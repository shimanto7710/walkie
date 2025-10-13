import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/utils/permissions_helper.dart';
import '../../../../core/utils/Utils.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/call_state.dart';
import '../../../../data/services/webrtc_service.dart';
import '../provider/call_provider.dart';
import '../../login/provider/auth_provider.dart';
// WebRTC is now handled by singleton service in call_provider

class CallScreen extends ConsumerStatefulWidget {
  final User friend;
  final bool isIncomingCall;
  final String? handshakeId;
  
  const CallScreen({
    super.key,
    required this.friend,
    this.isIncomingCall = false,
    this.handshakeId,
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
    
    // Initialize WebRTC and permissions
    _initializeWebRTC();
    
    // Initialize Firebase handshake when entering call
    // _initializeHandshake();

    // No initialization needed for simple call UI
  }

  Future<void> _initializeWebRTC() async {
    try {
      // Request permissions
      final hasAudioPermission = await PermissionsHelper.requestAudioPermissions();
      if (!hasAudioPermission) {
        _showPermissionDialog('Microphone permission is required for voice calls.');
        return;
      }

      // WebRTC is now handled by singleton service in providers
      // No need to initialize here as it's done in call_provider

      _initializeHandshake();

      // Note: ref.listen calls are now handled in the build method

    } catch (e) {
      Utils.log('Call', 'Error initializing WebRTC: $e');
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

  void _initializeHandshake() async {
    try {
      final authState = ref.read(authProvider);
      if (authState.currentUser != null) {
        final callNotifier = ref.read(callNotifierProvider.notifier);
        
        if (widget.isIncomingCall) {
          Utils.log('Receiver', 'Incoming call detected - starting to listen for handshake changes');
          Utils.log('Receiver', 'Handshake ID: ${widget.handshakeId}');
          
          // For incoming calls, just start listening without initializing
          // Extract caller and receiver from handshakeId or use friend.id as caller
          final callerId = widget.friend.id; // The friend is the caller in incoming calls
          final receiverId = authState.currentUser!.id; // Current user is the receiver
          
          // Start listening to handshake changes for incoming calls
          callNotifier.startListeningToHandshake(
            callerId: callerId,
            receiverId: receiverId,
          );
          
        } else {
          // For outgoing calls, initialize handshake and start listening
          await callNotifier.initiateHandshake(
            callerId: authState.currentUser!.id,
            receiverId: widget.friend.id,
          );
          
          Utils.log('Caller', 'Firebase handshake initialized for outgoing call');
        }
      }
    } catch (e) {
      Utils.log('Call', 'Error initializing handshake: $e');
    }
  }

  void _startCall() {
    final callNotifier = ref.read(callNotifierProvider.notifier);
    callNotifier.startCall();
  }

  void _acceptCall() {
    final callNotifier = ref.read(callNotifierProvider.notifier);
    callNotifier.acceptCall();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _swipeController.dispose();
    
    // Reset call state
    final callNotifier = ref.read(callNotifierProvider.notifier);
    callNotifier.reset();

    // WebRTC state is now managed by singleton service
    
    super.dispose();
  }

  void _onHoldStart() {
    setState(() {
      _isHolding = true;
    });
    
    // Start talking - enable microphone with delay to ensure UI is updated
    Future.delayed(const Duration(milliseconds: 100), () {
      _toggleMicrophone(true);
    });
  }

  void _onHoldEnd() {
    
    // Mic button should ALWAYS work as push-to-talk toggle
    // Never ends the call, regardless of call state (sustained or not)
    if (!_isSwipeGesture) {
      setState(() {
        _isHolding = false;
      });
      
      
      // Stop talking - disable microphone with delay
      Future.delayed(const Duration(milliseconds: 100), () {
        _toggleMicrophone(false);
      });
    } else {
    }
  }

  /// Toggle microphone on/off for push-to-talk
  void _toggleMicrophone(bool isEnabled) async {
    try {
      
      // Try WebRTC approach first
      bool webrtcSuccess = false;
      try {
        final webrtcService = FlutterWebRTCService.instance;
        
        // Print current WebRTC state safely
        try {
          webrtcService.printDebugInfo();
        } catch (e) {
        }
        
        // Call toggleMute with timeout
        final result = await webrtcService.toggleMute().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            return Left(Failure.unknownFailure('Operation timed out'));
          },
        );
        
        result.fold(
          (failure) {
            webrtcSuccess = false;
          },
          (_) {
            webrtcSuccess = true;
          },
        );
        
      } catch (e) {
        webrtcSuccess = false;
      }
      
      // If WebRTC failed, try simple approach
      if (!webrtcSuccess) {
        try {
          // Just update UI state without WebRTC
          setState(() {
            // Update visual state only
          });
        } catch (e) {
        }
      }
      
      
    } catch (e) {
      // Don't rethrow the error to prevent app crash
    }
  }

  void _onSwipeUp() {
    setState(() {
      _isCallSustained = true;
      _isSwipeGesture = true;
    });
    
    // Accept the call when swiping up
    _acceptCall();
    
    // Trigger the swipe up animation
    _swipeController.forward();
  }

  void _endCall() async {
    setState(() {
      _isHolding = false;
      _isCallSustained = false;
      _isSwipeGesture = false;
    });
    
    // Get current user and close call with Firebase update
    final authState = ref.read(authProvider);
    final callNotifier = ref.read(callNotifierProvider.notifier);
    
    if (authState.currentUser != null) {
      // Close call and update Firebase status to 'close_call'
      await callNotifier.closeCall(
        callerId: authState.currentUser!.id,
        receiverId: widget.friend.id,
      );
    } else {
      // Fallback to regular end call if no auth state
      callNotifier.endCall();
    }

    // Reset the swipe animation
    _swipeController.reset();

    // Navigation to home will be handled by the call state listener
  }

  // WebRTC operations are now handled by singleton service in call_provider

  @override
  Widget build(BuildContext context) {
    // Listen to simple call state changes
    ref.listen<CallState>(callNotifierProvider, (previous, next) {
      Utils.log('Call', 'Call state changed: ${previous?.status} -> ${next.status}');
      
      if (next.status == CallStatus.connected) {
        setState(() {
          // Update UI to show connection is established
        });
      } else if (next.status == CallStatus.ended) {
        // Navigate to home when call ends (either by user action or remote close)
        Utils.log('Call', 'Call ended - navigating to home');
        context.go('/home');
      }
    });

    // WebRTC call state changes are now handled by call_provider

    // Handshake changes are now handled within the CallNotifier

    final callState = ref.watch(callNotifierProvider);
    
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
                _endCall();
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
                    ? 'Call Active - Hold to Talk' 
                    : _isHolding 
                      ? 'Talking...' 
                      : 'Hold to Talk',
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
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 200, // Account for header and controls
        ),
        child: IntrinsicHeight(
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
        ),
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
      statusText = 'Connecting...';
      statusColor = Colors.orange;
    } else if (callState.status == CallStatus.calling) {
      statusText = 'Calling...';
      statusColor = Colors.blue;
    } else if (callState.status == CallStatus.ringing) {
      statusText = 'Ringing...';
      statusColor = Colors.purple;
    } else if (_isCallSustained) {
      statusText = 'Call Active';
      statusColor = Colors.green;
    } else if (_isHolding) {
      statusText = 'Talking...';
      statusColor = Colors.orange;
    } else {
      statusText = 'Hold to Talk';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        _isCallSustained
            ? 'Call is active. Tap end call to disconnect.'
            : _isHolding
                ? 'Talking...\nSwipe up to sustain call\nRelease to stop talking'
                : 'Hold to talk\nSwipe up while holding to sustain call\nRelease to stop talking',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCallControls(CallState callState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hold to talk button
          Listener(
            onPointerDown: (details) {
              _onHoldStart();
            },
            onPointerUp: (details) {
              
              if (!_isSwipeGesture) {
                _onHoldEnd();
              } else {
              }
            },
            onPointerCancel: (details) {

              
              if (!_isSwipeGesture) {

                _onHoldEnd();
              } else {

              }
              
            },
            onPointerMove: (details) {
              // Check for swipe up gesture
              if (details.delta.dy < -10 && _isHolding && !_isCallSustained) {
                _onSwipeUp();
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
          
          const SizedBox(height: 20),
          
          // Status indicator
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
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
                Flexible(
                  child: Text(
                    _isCallSustained 
                      ? 'Call Active' 
                      : _isHolding 
                        ? 'Talking' 
                        : 'Hold to Talk',
                    style: TextStyle(
                      color: _isHolding || _isCallSustained 
                        ? Colors.green 
                        : Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}
