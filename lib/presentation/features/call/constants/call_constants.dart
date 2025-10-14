class CallConstants {
  // Handshake Status Values
  static const String callInitiate = 'call_initiate';
  static const String callAcknowledge = 'call_acknowledge';
  static const String closeCall = 'close_call';
  static const String ringing = 'ringing';
  static const String connected = 'connected';
  
  // SDP Types
  static const String sdpOffer = 'offer';
  static const String sdpAnswer = 'answer';
  
  // Log Messages - WebRTC
  static const String webRtcServiceNotInitialized = 'WebRTC service not initialized';
  static const String webRtcServiceInitializedSuccessfully = 'WebRTC service initialized successfully';
  static const String failedToInitializeWebRtcService = 'Failed to initialize WebRTC service';
  static const String webRtcOperationError = 'WebRTC operation error';
  static const String creatingSdpOffer = 'Creating SDP offer';
  static const String creatingSdpAnswer = 'Creating SDP answer';
  static const String sdpOfferCreatedSuccessfully = 'SDP offer created successfully';
  static const String sdpAnswerCreatedSuccessfully = 'SDP answer created successfully';
  static const String sdpOfferCreationFailed = 'SDP offer creation failed';
  static const String sdpAnswerCreationFailed = 'SDP answer creation failed';
  static const String gatheringIceCandidates = 'Gathering ICE candidates';
  static const String gatheredIceCandidates = 'Gathered ICE candidates';
  static const String noIceCandidatesGathered = 'No ICE candidates gathered within timeout';
  static const String localDescriptionSetSuccessfully = 'Local description set successfully';
  static const String remoteDescriptionSetSuccessfully = 'Remote description set successfully';
  static const String failedToSetLocalDescription = 'Failed to set local description';
  static const String failedToSetRemoteDescription = 'Failed to set remote description';
  static const String iceCandidateAddedSuccessfully = 'ICE candidate added successfully';
  static const String failedToAddIceCandidate = 'Failed to add ICE candidate';
  
  // Log Messages - Handshake
  static const String stoppingHandshakeListener = 'Stopping handshake listener';
  static const String handshakeInitiatedSuccessfully = 'Handshake initiated successfully';
  static const String errorInitiatingHandshake = 'Error initiating handshake';
  static const String startingToListenToHandshakeChanges = 'Starting to listen to handshake changes (Role: role)';
  static const String receivedHandshakeStatus = 'Received handshake status';
  static const String callClosedByRemoteParty = 'Call closed by remote party';
  static const String handlingCallAcknowledgment = 'Handling call acknowledgment from receiver';
  static const String ignoringCallAcknowledgeStatus = 'Ignoring call_acknowledge status (receiver should not handle this)';
  static const String errorListeningToHandshake = 'Error listening to handshake';
  
  // Log Messages - Caller
  static const String webRtcServiceNotAvailableForMicrophone = 'WebRTC service not available for microphone toggle';
  static const String togglingMicrophone = 'Toggling microphone';
  static const String failedToToggleMicrophone = 'Failed to toggle microphone';
  static const String microphoneToggledSuccessfully = 'Microphone toggled successfully';
  static const String errorTogglingMicrophone = 'Error toggling microphone';
  static const String startingPushToTalk = 'Starting push-to-talk';
  static const String stoppingPushToTalk = 'Stopping push-to-talk';
  static const String closingCallBetween = 'Closing call between';
  static const String initiatingHandshakeBetween = 'Initiating handshake between';
  static const String settingLocalDescriptionWithSdpOffer = 'Setting local description with SDP offer';
  static const String gatheredIceCandidatesCount = 'Gathered ICE candidates';
  static const String noSdpAnswerReceived = 'No SDP answer received from receiver';
  static const String addingIceCandidatesFromReceiver = 'Adding ICE candidates from receiver';
  static const String noIceCandidatesReceivedFromReceiver = 'No ICE candidates received from receiver';
  static const String errorAddingIceCandidate = 'Error adding ICE candidate';
  static const String localMediaStreamObtainedSuccessfully = 'Local media stream obtained successfully';
  static const String failedToAddLocalAudioStream = 'Failed to add local audio stream';
  static const String localAudioStreamAddedSuccessfully = 'Local audio stream added successfully';
  static const String failedToObtainLocalMediaStream = 'Failed to obtain local media stream';
  static const String callAcknowledgedByReceiver = 'Call acknowledged by receiver, establishing connection';
  static const String failedToStartCall = 'Failed to start call';
  static const String webRtcCallEstablishedSuccessfully = 'WebRTC Call established successfully';
  static const String errorHandlingCallAcknowledge = 'Error handling call acknowledge';
  static const String failedToEstablishConnection = 'Failed to establish connection';
  
  // Log Messages - Receiver
  static const String startingToListenToHandshake = 'Starting to listen to handshake between';
  static const String incomingCallDetected = 'Incoming call detected - starting to listen for handshake changes';
  static const String handshakeId = 'Handshake ID';
  static const String firebaseHandshakeInitializedForOutgoingCall = 'Firebase handshake initialized for outgoing call';
  static const String addedIceCandidatesFromCaller = 'Added ICE candidates from caller';
  static const String failedToAddLocalStream = 'Failed to add local stream';
  static const String localAudioStreamAddedForIncomingCall = 'Local audio stream added for incoming call';
  static const String incomingCallIsReady = 'Incoming call is ready - SDP and ICE exchange completed';
  static const String initiatingIncomingCall = 'Initiating incoming call...';
  static const String failedToAcceptCall = 'Failed to accept call';
  static const String incomingCallAcceptedSuccessfully = 'Incoming call accepted successfully';
  static const String cannotProceedAnswerSdpMissing = 'Cannot proceed: Answer SDP is missing';
  static const String closeCallDetectedInGlobalProvider = 'Close call detected in global provider for user';
  static const String userHandshakeStreamError = 'User handshake stream error';
  static const String errorHandlingIncomingCall = 'Error handling incoming call';
  
  // Log Messages - Call
  static const String callStateChanged = 'Call state changed';
  static const String callEndedNavigatingToHome = 'Call ended - navigating to home';
  
  // Error Messages
  static const String sdpOfferCreationFailedMessage = 'SDP offer creation failed';
  static const String sdpAnswerCreationFailedMessage = 'SDP answer creation failed';
  static const String noSdpAnswerReceivedMessage = 'No SDP answer received';
  static const String failedToStartCallMessage = 'Failed to start call';
  static const String failedToEstablishConnectionMessage = 'Failed to establish connection';
  
  // Microphone States
  static const String microphoneOn = 'ON';
  static const String microphoneOff = 'OFF';
  
  // Role Names
  static const String callerRole = 'Caller';
  static const String receiverRole = 'Receiver';
  static const String webRtcRole = 'WebRTC';
  static const String handshakeRole = 'Handshake';
  static const String callRole = 'Call';
  static const String firebaseRole = 'Firebase';
  
  // SDP Logging
  static const String sdpType = 'SDP Type';
  static const String sdpLength = 'SDP Length';
  
  // ICE Candidate Logging
  static const String iceCandidate = 'ICE Candidate';
  static const String sdpMid = 'SDP Mid';
  static const String sdpMLineIndex = 'SDP MLine Index';
  
  // Timeout Messages
  static const String timeoutSeconds = 's timeout';
  
  // Default Values
  static const String defaultSdpMid = '0';
  static const int defaultSdpMLineIndex = 0;
  static const String emptyString = '';
}
