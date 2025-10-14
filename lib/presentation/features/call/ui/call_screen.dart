import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/permissions_helper.dart';
import '../../../../core/utils/Utils.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/call_state.dart';
import '../provider/call_provider.dart';

class _CallScreenConstants {
  static const Duration pulseAnimationDuration = Duration(milliseconds: 1000);
  static const Duration waveAnimationDuration = Duration(milliseconds: 2000);
  static const Duration swipeAnimationDuration = Duration(milliseconds: 300);
  static const Duration pushToTalkDelay = Duration(milliseconds: 100);
  
  static const double avatarSize = 200.0;
  static const double avatarBorderWidth = 4.0;
  static const double avatarInitialFontSize = 80.0;
  static const double waveAnimationMaxSize = 50.0;
  static const double buttonSize = 100.0;
  static const double buttonIconSize = 40.0;
  static const double statusIndicatorSize = 12.0;
  
  static const double pulseScaleBegin = 1.0;
  static const double pulseScaleEnd = 1.2;
  static const double waveOpacityBegin = 0.3;
  static const double waveOpacityEnd = 0.1;
  
  static const double swipeThreshold = -10.0;
  static const double swipeOffsetMultiplier = 100.0;
  
  static const EdgeInsets headerPadding = EdgeInsets.all(20);
  static const EdgeInsets controlsPadding = EdgeInsets.symmetric(horizontal: 40, vertical: 20);
  static const EdgeInsets instructionsPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets backButtonPadding = EdgeInsets.all(8);
  
  static const double headerSpacing = 4.0;
  static const double mainContentSpacing = 40.0;
  static const double statusSpacing = 60.0;
  static const double controlsSpacing = 20.0;
  static const double bottomPadding = 40.0;
  static const double statusIndicatorSpacing = 8.0;
  
  static const double headerFontSize = 24.0;
  static const double subtitleFontSize = 16.0;
  static const double statusFontSize = 20.0;
  static const double instructionsFontSize = 16.0;
  static const double statusIndicatorFontSize = 14.0;
  
  static const double backButtonSize = 24.0;
  static const double endCallButtonSize = 28.0;
  static const double backButtonBorderRadius = 20.0;
  
  static const double shadowBlurRadius = 20.0;
  static const double shadowSpreadRadius = 5.0;
  static const double shadowOpacity = 0.3;
  
  static const int maxInstructionsLines = 4;
  
  static const Color backgroundColor = Colors.black;
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Colors.white70;
  static const Color connectedColor = Colors.green;
  static const Color connectingColor = Colors.orange;
  static const Color callingColor = Colors.blue;
  static const Color ringingColor = Colors.purple;
  static const Color talkingColor = Colors.orange;
  static const Color inactiveColor = Colors.grey;
  static const Color endCallColor = Colors.red;
}

class CallScreen extends ConsumerStatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final User friend;
  final bool isIncomingCall;
  final String? handshakeId;
  
  const CallScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
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
    

    _pulseController = AnimationController(
      duration: _CallScreenConstants.pulseAnimationDuration,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: _CallScreenConstants.pulseScaleBegin,
      end: _CallScreenConstants.pulseScaleEnd,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveController = AnimationController(
      duration: _CallScreenConstants.waveAnimationDuration,
      vsync: this,
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _swipeController = AnimationController(
      duration: _CallScreenConstants.swipeAnimationDuration,
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
    
    _initializeWebRTC();

  }

  Future<void> _initializeWebRTC() async {
    try {
      final hasAudioPermission = await PermissionsHelper.requestAudioPermissions();
      if (!hasAudioPermission) {
        _showPermissionDialog('Microphone permission is required for voice calls.');
        return;
      }

      _initializeHandshake();

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
      final callNotifier = ref.read(callNotifierProvider.notifier);
      
      if (widget.isIncomingCall) {
        Utils.log('Receiver', 'Incoming call detected - starting to listen for handshake changes');
        Utils.log('Receiver', 'Handshake ID: ${widget.handshakeId}');
        
        final callerId = widget.friend.id;
        final receiverId = widget.currentUserId;
        
        callNotifier.startListeningToHandshake(
          callerId: callerId,
          receiverId: receiverId,
        );
        
      } else {
        await callNotifier.initiateHandshake(
          callerId: widget.currentUserId,
          receiverId: widget.friend.id,
        );
        
        Utils.log('Caller', 'Firebase handshake initialized for outgoing call');
      }
    } catch (e) {
      Utils.log('Call', 'Error initializing handshake: $e');
    }
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
    
    final callNotifier = ref.read(callNotifierProvider.notifier);
    callNotifier.reset();

    
    super.dispose();
  }

  void _onHoldStart() {
    setState(() {
      _isHolding = true;
    });
    
    Future.delayed(_CallScreenConstants.pushToTalkDelay, () {
      ref.read(callNotifierProvider.notifier).startPushToTalk();
    });
  }

  void _onHoldEnd() {
    if (!_isSwipeGesture) {
      setState(() {
        _isHolding = false;
      });

      Future.delayed(_CallScreenConstants.pushToTalkDelay, () {
        ref.read(callNotifierProvider.notifier).stopPushToTalk();
      });
    } else {
    }
  }


  void _onSwipeUp() {
    setState(() {
      _isCallSustained = true;
      _isSwipeGesture = true;
    });
    
    _acceptCall();
    
    _swipeController.forward();
  }

  void _endCall() async {
    setState(() {
      _isHolding = false;
      _isCallSustained = false;
      _isSwipeGesture = false;
    });
    
    final callNotifier = ref.read(callNotifierProvider.notifier);
    
    await callNotifier.closeCall(
      callerId: widget.currentUserId,
      receiverId: widget.friend.id,
    );

    _swipeController.reset();
  }

  String _getCallStatusText() {
    if (_isCallSustained) {
      return 'Call Active - Hold to Talk';
    } else if (_isHolding) {
      return 'Talking...';
    } else {
      return 'Hold to Talk';
    }
  }

  Color _getCallStatusColor() {
    if (_isCallSustained) {
      return _CallScreenConstants.connectedColor;
    } else if (_isHolding) {
      return _CallScreenConstants.talkingColor;
    } else {
      return _CallScreenConstants.inactiveColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CallState>(callNotifierProvider, (previous, next) {
      Utils.log('Call', 'Call state changed: ${previous?.status} -> ${next.status}');
      
      if (next.status == CallStatus.connected) {
        setState(() {
        });
      } else if (next.status == CallStatus.ended) {
        Utils.log('Call', 'Call ended - navigating to home');
        context.go('/home');
      }
    });

    final callState = ref.watch(callNotifierProvider);
    
    return Scaffold(
      backgroundColor: _CallScreenConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildMainContent(callState),
            ),
            _buildCallControls(callState),
            const SizedBox(height: _CallScreenConstants.bottomPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: _CallScreenConstants.headerPadding,
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _endCall,
              borderRadius: BorderRadius.circular(_CallScreenConstants.backButtonBorderRadius),
              child: Container(
                padding: _CallScreenConstants.backButtonPadding,
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: _CallScreenConstants.primaryTextColor,
                  size: _CallScreenConstants.backButtonSize,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.friend.name,
                  style: const TextStyle(
                    color: _CallScreenConstants.primaryTextColor,
                    fontSize: _CallScreenConstants.headerFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: _CallScreenConstants.headerSpacing),
                Text(
                  _getCallStatusText(),
                  style: TextStyle(
                    color: _getCallStatusColor(),
                    fontSize: _CallScreenConstants.subtitleFontSize,
                  ),
                ),
              ],
            ),
          ),
          
          if (_isCallSustained)
            IconButton(
              onPressed: _endCall,
              icon: const Icon(
                Icons.call_end,
                color: _CallScreenConstants.endCallColor,
                size: _CallScreenConstants.endCallButtonSize,
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
          minHeight: MediaQuery.of(context).size.height - 200,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFriendAvatar(),
              const SizedBox(height: _CallScreenConstants.mainContentSpacing),
              _buildCallStatus(callState),
              const SizedBox(height: _CallScreenConstants.statusSpacing),
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
        if (_isHolding || _isCallSustained)
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return Container(
                width: _CallScreenConstants.avatarSize + (_waveAnimation.value * _CallScreenConstants.waveAnimationMaxSize),
                height: _CallScreenConstants.avatarSize + (_waveAnimation.value * _CallScreenConstants.waveAnimationMaxSize),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _CallScreenConstants.connectedColor.withOpacity(
                      _CallScreenConstants.waveOpacityBegin - (_waveAnimation.value * 0.2)
                    ),
                    width: 2,
                  ),
                ),
              );
            },
          ),
        
        Container(
          width: _CallScreenConstants.avatarSize,
          height: _CallScreenConstants.avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.friend.status ? _CallScreenConstants.connectedColor : _CallScreenConstants.inactiveColor,
            border: Border.all(
              color: _CallScreenConstants.primaryTextColor,
              width: _CallScreenConstants.avatarBorderWidth,
            ),
          ),
          child: Center(
            child: Text(
              widget.friend.initial,
              style: const TextStyle(
                color: _CallScreenConstants.primaryTextColor,
                fontSize: _CallScreenConstants.avatarInitialFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallStatus(CallState callState) {
    final statusInfo = _getCallStatusInfo(callState);
    
    return Text(
      statusInfo.text,
      style: TextStyle(
        color: statusInfo.color,
        fontSize: _CallScreenConstants.statusFontSize,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  ({String text, Color color}) _getCallStatusInfo(CallState callState) {
    if (callState.status == CallStatus.connected) {
      return (text: 'Call Connected', color: _CallScreenConstants.connectedColor);
    } else if (callState.isConnecting) {
      return (text: 'Connecting...', color: _CallScreenConstants.connectingColor);
    } else if (callState.status == CallStatus.calling) {
      return (text: 'Calling...', color: _CallScreenConstants.callingColor);
    } else if (callState.status == CallStatus.ringing) {
      return (text: 'Ringing...', color: _CallScreenConstants.ringingColor);
    } else if (_isCallSustained) {
      return (text: 'Call Active', color: _CallScreenConstants.connectedColor);
    } else if (_isHolding) {
      return (text: 'Talking...', color: _CallScreenConstants.talkingColor);
    } else {
      return (text: 'Hold to Talk', color: _CallScreenConstants.inactiveColor);
    }
  }

  Widget _buildInstructions() {
    return Container(
      padding: _CallScreenConstants.instructionsPadding,
      child: Text(
        _getInstructionsText(),
        style: const TextStyle(
          color: _CallScreenConstants.secondaryTextColor,
          fontSize: _CallScreenConstants.instructionsFontSize,
        ),
        textAlign: TextAlign.center,
        maxLines: _CallScreenConstants.maxInstructionsLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _getInstructionsText() {
    if (_isCallSustained) {
      return 'Call is active. Tap end call to disconnect.';
    } else if (_isHolding) {
      return 'Talking...\nSwipe up to sustain call\nRelease to stop talking';
    } else {
      return 'Hold to talk\nSwipe up while holding to sustain call\nRelease to stop talking';
    }
  }

  Color _getButtonColor() {
    return (_isHolding || _isCallSustained) 
      ? _CallScreenConstants.connectedColor 
      : _CallScreenConstants.endCallColor;
  }

  Color _getStatusIndicatorColor() {
    return (_isHolding || _isCallSustained) 
      ? _CallScreenConstants.connectedColor 
      : _CallScreenConstants.inactiveColor;
  }

  String _getStatusIndicatorText() {
    if (_isCallSustained) {
      return 'Call Active';
    } else if (_isHolding) {
      return 'Talking';
    } else {
      return 'Hold to Talk';
    }
  }

  Widget _buildCallControls(CallState callState) {
    return Container(
      padding: _CallScreenConstants.controlsPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              if (details.delta.dy < _CallScreenConstants.swipeThreshold && _isHolding && !_isCallSustained) {
                _onSwipeUp();
              }
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _swipeAnimation]),
              builder: (context, child) {
                return Transform.translate(
                  offset: _isCallSustained 
                    ? Offset(0, _swipeAnimation.value.dy * _CallScreenConstants.swipeOffsetMultiplier)
                    : Offset.zero,
                  child: Transform.scale(
                    scale: _isHolding ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: _CallScreenConstants.buttonSize,
                      height: _CallScreenConstants.buttonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getButtonColor(),
                        boxShadow: [
                          BoxShadow(
                            color: _getButtonColor().withOpacity(_CallScreenConstants.shadowOpacity),
                            blurRadius: _CallScreenConstants.shadowBlurRadius,
                            spreadRadius: _CallScreenConstants.shadowSpreadRadius,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.mic,
                        color: _CallScreenConstants.primaryTextColor,
                        size: _CallScreenConstants.buttonIconSize,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: _CallScreenConstants.controlsSpacing),
          
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: _CallScreenConstants.statusIndicatorSize,
                  height: _CallScreenConstants.statusIndicatorSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusIndicatorColor(),
                  ),
                ),
                const SizedBox(width: _CallScreenConstants.statusIndicatorSpacing),
                Flexible(
                  child: Text(
                    _getStatusIndicatorText(),
                    style: TextStyle(
                      color: _getStatusIndicatorColor(),
                      fontSize: _CallScreenConstants.statusIndicatorFontSize,
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
