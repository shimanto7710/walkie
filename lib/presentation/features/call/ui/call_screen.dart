import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/call_state.dart';
import '../provider/simple_call_provider.dart';

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

    // No initialization needed for simple call UI
  }

  void _startCall() {
    final callNotifier = ref.read(simpleCallNotifierProvider.notifier);
    callNotifier.startCall();
  }

  void _acceptCall() {
    final callNotifier = ref.read(simpleCallNotifierProvider.notifier);
    callNotifier.acceptCall();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _swipeController.dispose();
    
    // Reset call state
    final callNotifier = ref.read(simpleCallNotifierProvider.notifier);
    callNotifier.reset();
    
    super.dispose();
  }

  void _onHoldStart() {
    setState(() {
      _isHolding = true;
    });
    
    // Check current call state
    final currentCallState = ref.read(simpleCallNotifierProvider);
    
    if (currentCallState.status == CallStatus.connected) {
      // Call is already connected, just start talking
      return;
    } else if (currentCallState.status == CallStatus.ringing) {
      // Call is ringing, don't initiate new call
      return;
    } else {
      // Call is not started yet, initiate the call
      _startCall();
    }
  }

  void _onHoldEnd() {
    if (!_isCallSustained && !_isSwipeGesture) {
      setState(() {
        _isHolding = false;
      });
      
      // Check if call is connected before ending
      final callState = ref.read(simpleCallNotifierProvider);
      if (callState.status == CallStatus.connected) {
        _endCall();
      } else if (callState.status == CallStatus.calling || callState.status == CallStatus.ringing) {
        // Give more time for call to complete
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_isCallSustained) {
            final currentCallState = ref.read(simpleCallNotifierProvider);
            if (currentCallState.status != CallStatus.connected) {
              _endCall();
            }
          }
        });
      } else {
        _endCall();
      }
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
    
    // End call
    final callNotifier = ref.read(simpleCallNotifierProvider.notifier);
    callNotifier.endCall();

    // Reset the swipe animation
    _swipeController.reset();

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    // Listen to call state changes
    ref.listen<CallState>(simpleCallNotifierProvider, (previous, next) {
      if (next.status == CallStatus.connected) {
        setState(() {
          // Update UI to show connection is established
        });
      } else if (next.status == CallStatus.ended) {
        context.go('/home');
      }
    });

    final callState = ref.watch(simpleCallNotifierProvider);
    
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
      statusText = 'Connecting...';
      statusColor = Colors.orange;
    } else {
      statusText = 'Hold to Call';
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
        'Connecting automatically...\nSwipe up to sustain call\nRelease to disconnect',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'Hold to call and start talking\nSwipe up while holding to sustain call',
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
