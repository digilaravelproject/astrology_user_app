
class AppUrls {
  static String baseUrl = "https://suryapathkundli.com";
  //static String baseUrl = "https://darkgoldenrod-peafowl-305286.hostingersite.com";
  static const String baseImageUrl = "https://suryapathkundli.com/storage/";
  static const String webSocketUrl = "wss://suryapathkundli.com/app/astrology-key?protocol=7&client=js&version=8.4.0-rc2&flash=false";
  static const String broadcastingAuth = "/api/v1/broadcasting/auth";
  static String sendOtp = "/api/v1/user/send-otp";
  static String verifyOtp = "/api/v1/user/verify-otp";
  static String resendOtp = "/api/v1/user/resend-otp";
  static String updateProfile(int id) => "/api/v1/user/profile/$id";
  static String updateProfilePhoto = "/api/v1/user/profile/photo";
  static String getProfile(int id) => "/api/v1/user/profile/$id";
  static String updateProfileInApp = "/api/v1/user/profileInAppUpdate";
  static String remedies = "/api/v1/user/remedies";
  static const String blogs = '/api/v1/user/blogs';
  static const String astrologers = '/api/v1/user/astrologers';
  static String getAstrologerDetails(int id) => '/api/v1/user/astrologers/$id';
  static String blockAstrologer(int id) => '/api/v1/user/astrologers/$id/block';
  static String unblockAstrologer(int id) => '/api/v1/user/astrologers/$id/unblock';
  static const String blockedAstrologers = '/api/v1/user/blocked-astrologers';
  static const String wallet = '/api/v1/user/wallet';
  static const String walletTopup = '/api/v1/user/wallet/topup';
  static const String walletTopupVerify = '/api/v1/user/wallet/verify-topup';
  static String walletInvoice(int transactionId) => '/api/v1/user/wallet/transactions/$transactionId/invoice';
  static const String walletTransactions = '/api/v1/user/wallet/transactions';
  static const String matrimonyProfile = '/api/v1/user/matrimony/profile';
  static const String updateMatrimonyProfile = '/api/v1/user/matrimony/update_profile';
  static const String getMatrimonyProfile = '/api/v1/user/matrimony/profiles';
  static String getMatrimonyProfileDetails(int id) => '/api/v1/user/matrimony/profiles/$id';
  static String getMyMatrimonyProfileDetails(int id) => '/api/v1/user/matrimony/profiles_user_id/$id';
  static String matrimonySearch(String query) => '/api/v1/user/matrimony/search?q=$query';
  static String blockMatrimonyProfile(int id) => '$astrologers/$id/block';
  static String reportMatrimonyProfile(int id) => '$astrologers/$id/report';


  static const String deleteAccount = '/api/v1/user/delete-account';
  static const String logout = '/api/v1/user/logout';

  static const String following = '/api/v1/user/following';
  static const String plans = '/api/v1/user/plans';
  static const String upgradePlans = '/api/v1/user/plans/upgrade';
  static const String upgradePlansVerify = '/api/v1/user/plans/upgrade/verify';
  static const String purchasePackage = '/api/v1/user/packages/purchase';
  static const String packageActiveStatus = '/api/v1/user/packages/active-status';
  static const String packageSessionStart = '/api/v1/user/packages/session/start';
  static const String packageSessionEnd = '/api/v1/user/packages/session/end';
  static const String packageSpawnChannel = '/api/v1/user/packages/session/spawn-channel';
  static const String packageTerminateChannel = '/api/v1/user/packages/session/terminate-channel';
  static const String packageHeartbeat = '/api/v1/user/packages/session/heartbeat';
  static const String packageActiveBanner = '/api/v1/user/packages/active-banner';

  static const String faqs = '/api/v1/faqs';
  static const String privacyPolicy = '/api/v1/privacy-policy';
  static const String paymentPolicy = '/api/v1/payment-policy';
  static const String termsAndConditions = '/api/v1/terms-and-conditions';
  static const String paymentSuccess = '/payment-success';

  // Notifications & Device Tokens
  static const String registerDeviceToken = '/api/v1/user/device-token';
  static const String removeDeviceToken = '/api/v1/user/remove-token';
  static String getNotificationCount(int userId) => '/api/v1/user/notifications/count';
  static String getNotifications(int userId) => '/api/v1/user/notifications';
  static String getNotificationById(int id, int userId) => '/api/v1/user/notifications/$id';
  static String markNotificationRead(int id, int userId) => '/api/v1/user/notifications/$id/mark-read';
  static const String markAllNotificationsRead = '/api/v1/user/notifications/mark-all-read';
  static String deleteNotification(int id) => '/api/v1/user/notifications/$id';
  static const String deleteAllNotifications = '/api/v1/user/notifications/delete-all';

  // Gifts
  static const String gifts = '/api/v1/gifts';
  static const String sendGift = '/api/v1/gifts/send';
  static String getGiftHistory(int id) => '/api/v1/astrologers/$id/gifts';

  // Live Streams
  static const String activeLiveSessions = "/api/v1/user/live/now";
  static String liveSessionDetail(int id) => "/api/v1/user/live/$id";
  static String joinLiveSession(int id) => "/api/v1/user/live/$id/join";
  static String leaveLiveSession(int id) => "/api/v1/user/live/$id/leave";
  static String sendLiveComment(int id) => "/api/v1/user/live/$id/comment";
  static String sendSuperChat(int id) => "/api/v1/user/live/$id/super-chat";
  static String getLiveComments(int id) => "/api/v1/user/live/$id/comments";
  static String watchLiveSession(int id) => "/api/v1/user/live/$id/watch";


  // Chat
  static const String initiateChat = '/api/v1/chat/initiate';
  static const String currentSession = '/api/v1/chat/current-session';
  static String cancelChatSession(int sessionId) => '/api/v1/chat/$sessionId/cancel';

  // Feedback & Static Pages
  static const String feedback = '/api/v1/feedback';
  static const String aboutUs = '/api/v1/static-pages/about_us';
  static const String customerSupport = '/api/v1/static-pages/customer_support';
  static const String foundersWords = '/api/v1/user/founders-words';



  static const String createKundali = '/api/v1/kundli/create';
  static const String getKundali = '/api/v1/kundli';
  static String getKundaliById(int id) => '/api/v1/kundli/$id';
  static String updateKundali(int id) => '/api/v1/kundli/$id';
  static String deleteKundali(int id) => '/api/v1/kundli/$id';





  // WebSocket / Pusher Events
  static const String pusherConnectionEstablished = 'pusher:connection_established';
  static const String pusherSubscriptionSucceeded = 'pusher_internal:subscription_succeeded';
  static const String pusherSubscribe = 'pusher:subscribe';
  static const String pusherPing = 'pusher:ping';
  static const String pusherPong = '{"event":"pusher:pong"}';

  // Chat System Events
  static const String eventChatInitiated = 'ChatInitiated';
  static const String eventChatAccepted = 'ChatAccepted';
  static const String eventChatEnded = 'ChatEnded';
  static const String eventMessageSent = 'MessageSent';
  static const String eventMessageStatusUpdated = 'MessageStatusUpdated';
  static const String eventPresenceUpdated = 'PresenceUpdated';
  static const String eventChatDismissed = 'ChatDismissed';

  // Channel Names
  static String privateUserChannel(int userId) => 'private-user.$userId';
  static const String presenceRoomChannel = 'presence-room';

  // Chat API Endpoints
  static String getChatMessages(int sessionId) => '/api/v1/chat/$sessionId/messages';
  static String sendChatMessage(int sessionId) => '/api/v1/chat/$sessionId/message';
  static String markChatRead(int sessionId) => '/api/v1/chat/$sessionId/read';
  static String syncChatStatus(int sessionId) => '/api/v1/chat/$sessionId/sync-status';
  static String endChatSession(int sessionId) => '/api/v1/chat/$sessionId/end';
  static const String uploadAttachment = '/api/v1/chat/upload-attachment';
  static const String getCurrentSession = '/api/v1/chat/sessions/current';
  static const String markMessagesRead = '/api/v1/chat/messages/read';
  static const String userChatSessions = '/api/v1/chat/sessions/user';
  // Call System Endpoints
  static const String initiateCall = '/api/v1/call/initiate';
  static String acceptCall(int sessionId) => '/api/v1/call/$sessionId/accept';
  static String rejectCall(int sessionId) => '/api/v1/call/$sessionId/reject';
  static String cancelCall(int sessionId) => '/api/v1/call/$sessionId/cancel';
  static String endCallSession(int sessionId) => '/api/v1/call/$sessionId/end';
  static String updateSdp(int sessionId) => '/api/v1/call/$sessionId/sdp';
  static String sendIceCandidate(int sessionId) => '/api/v1/call/$sessionId/ice-candidate';
  static const String currentCallSession = '/api/v1/call/current-session';
  static const String turnCredentials = '/api/v1/call/turn-credentials';
  static const String userCallSessions = '/api/v1/call/sessions/user';
  static const String astrologerCallSessions = '/api/v1/call/sessions/astrologer';

  // Call System Events
  static const String eventCallInitiated = 'CallInitiated';
  static const String eventCallAccepted = 'CallAccepted';
  static const String eventCallDismissed = 'CallDismissed';
  static const String eventCallEnded = 'CallEnded';
  static const String eventIceCandidateSent = 'IceCandidateSent';
  static const String eventWebRtcSdpUpdated = 'WebRtcSdpUpdated';

  // Live Session System Events
  static const String eventUserJoinedLiveSession = 'UserJoinedLiveSession';
  static const String eventUserLeftLiveSession = 'UserLeftLiveSession';
  static const String eventLiveSessionEnded = 'LiveSessionEnded';
  static const String eventAstrologerMediaStatusChanged = 'AstrologerMediaStatusChanged';
  static const String eventLiveSessionStarted = 'LiveSessionStarted';
  static const String eventViewerCountUpdated = 'ViewerCountUpdated';
  static const String eventNewLiveComment = 'NewLiveComment';
  static const String eventSuperChatReceived = 'SuperChatReceived';
  static const String eventAstrologerBroadcastStarted = 'AstrologerBroadcastStarted';

  // Chat Assistance API Endpoints
  static const String initiateChatAssistance = '/api/v1/chat-assistance/initiate';
  static const String chatAssistanceSessions = '/api/v1/chat-assistance/sessions';
  static String getChatAssistanceMessages(int sessionId) => '/api/v1/chat-assistance/$sessionId/messages';
  static String sendChatAssistanceMessage(int sessionId) => '/api/v1/chat-assistance/$sessionId/message';
  static String syncChatAssistanceStatus(int sessionId) => '/api/v1/chat-assistance/$sessionId/sync-status';
  static const String getAstrologerChatAssistanceStatus = '/api/v1/chat-assistance/astrologer/status';

  // Chat Assistance System Events
  static const String eventChatAssistanceInitiated = 'ChatAssistanceInitiated';
  static const String eventChatAssistanceMessageSent = 'ChatAssistanceMessageSent';
  static const String eventChatAssistanceMessageStatusUpdated = 'ChatAssistanceMessageStatusUpdated';
  static const String eventChatAssistanceLimitReached = 'ChatAssistanceLimitReached';

  // Prepaid Package Session Events
  static const String eventPackageSubSessionStarted = 'PackageSubSessionStarted';
  static const String eventPackageSubSessionEnded = 'PackageSubSessionEnded';
  static const String eventPackageSessionTerminated = 'PackageSessionTerminated';
}