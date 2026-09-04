import 'package:astro_user/core/services/config/env_config.dart';

class AppUrls {
  // ==========================================
  // Core Configuration
  // ==========================================
  static const String apiVersion = "v1";
  static String get baseUrl => EnvConfig.baseUrl;
  static String get apiUrl => "$baseUrl/api/$apiVersion";
  static String get baseImageUrl => "$baseUrl/storage/";
  static String get webSocketUrl =>
      "${baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://')}/app/astrology-key?protocol=7&client=js&version=8.4.0-rc2&flash=false";
  static const String broadcastingAuth = "/broadcasting/auth";

  // ==========================================
  // Authentication & Onboarding
  // ==========================================
  static String sendOtp = "/user/send-otp";
  static String verifyOtp = "/user/verify-otp";
  static String resendOtp = "/user/resend-otp";
  static const String deleteAccount = '/user/delete-account';
  static const String logout = '/user/logout';

  // ==========================================
  // Profile
  // ==========================================
  static String getProfile(int id) => "/user/profile/$id";
  static String updateProfile(int id) => "/user/profile/$id";
  static String updateProfilePhoto = "/user/profile/photo";
  static String updateProfileInApp = "/user/profileInAppUpdate";

  // ==========================================
  // Notifications & Device Tokens
  // ==========================================
  static const String registerDeviceToken = '/user/device-token';
  static const String removeDeviceToken = '/user/remove-token';
  static String getNotificationCount(int userId) => '/user/notifications/count';
  static String getNotifications(int userId) => '/user/notifications';
  static String getNotificationById(int id, int userId) => '/user/notifications/$id';
  static String markNotificationRead(int id, int userId) => '/user/notifications/$id/mark-read';
  static const String markAllNotificationsRead = '/user/notifications/mark-all-read';
  static String deleteNotification(int id) => '/user/notifications/$id';
  static const String deleteAllNotifications = '/user/notifications/delete-all';

  // ==========================================
  // Astrologers & Matrimony
  // ==========================================
  static const String astrologers = '/user/astrologers';
  static String getAstrologerDetails(int id) => '/user/astrologers/$id';
  static const String following = '/user/following';
  static String blockAstrologer(int id) => '/user/astrologers/$id/block';
  static String unblockAstrologer(int id) => '/user/astrologers/$id/unblock';
  static const String blockedAstrologers = '/user/blocked-astrologers';

  static const String getMatrimonyProfile = '/user/matrimony/profiles';
  static const String matrimonyProfile = '/user/matrimony/profile';
  static const String updateMatrimonyProfile = '/user/matrimony/update_profile';
  static String getMatrimonyProfileDetails(int id) => '/user/matrimony/profiles/$id';
  static String getMyMatrimonyProfileDetails(int id) => '/user/matrimony/profiles_user_id/$id';
  static String matrimonySearch(String query) => '/user/matrimony/search?q=$query';
  static String blockMatrimonyProfile(int id) => '$astrologers/$id/block';
  static String reportMatrimonyProfile(int id) => '$astrologers/$id/report';

  // ==========================================
  // Wallet, Subscriptions & Packages
  // ==========================================
  static const String wallet = '/user/wallet';
  static const String walletTopup = '/user/wallet/topup';
  static const String walletTopupVerify = '/user/wallet/verify-topup';
  static const String walletTransactions = '/user/wallet/transactions';
  static String walletInvoice(int transactionId) => '/user/wallet/transactions/$transactionId/invoice';

  static const String plans = '/user/plans';
  static const String upgradePlans = '/user/plans/upgrade';
  static const String upgradePlansVerify = '/user/plans/upgrade/verify';
  
  static const String purchasePackage = '/user/packages/purchase';
  static const String packageActiveStatus = '/user/packages/active-status';
  static const String packageSessionStart = '/user/packages/session/start';
  static const String packageSessionEnd = '/user/packages/session/end';
  static const String packageSpawnChannel = '/user/packages/session/spawn-channel';
  static const String packageSwitchChannel = '/user/packages/session/switch-channel';
  static const String packageTerminateChannel = '/user/packages/session/terminate-channel';
  static const String packageHeartbeat = '/user/packages/session/heartbeat';
  static const String packageActiveBanner = '/user/packages/active-banner';

  // ==========================================
  // Live Streaming APIs
  // ==========================================
  static const String activeLiveSessions = "/user/live/now";
  static String liveSessionDetail(int id) => "/user/live/$id";
  static String joinLiveSession(int id) => "/user/live/$id/join";
  static String leaveLiveSession(int id) => "/user/live/$id/leave";
  static String getLiveComments(int id) => "/user/live/$id/comments";
  static String sendLiveComment(int id) => "/user/live/$id/comment";
  static String sendSuperChat(int id) => "/user/live/$id/super-chat";
  static String watchLiveSession(int id) => "/user/live/$id/watch";

  static const String gifts = '/gifts';
  static const String sendGift = '/gifts/send';
  static String getGiftHistory(int id) => '/astrologers/$id/gifts';

  // ==========================================
  // Call Feature APIs
  // ==========================================
  static const String initiateCall = '/call/initiate';
  static String acceptCall(int sessionId) => '/call/$sessionId/accept';
  static String rejectCall(int sessionId) => '/call/$sessionId/reject';
  static String cancelCall(int sessionId) => '/call/$sessionId/cancel';
  static String endCallSession(int sessionId) => '/call/$sessionId/end';
  static String updateSdp(int sessionId) => '/call/$sessionId/sdp';
  static String sendIceCandidate(int sessionId) => '/call/$sessionId/ice-candidate';
  static const String turnCredentials = '/call/turn-credentials';
  static const String currentCallSession = '/call/current-session';
  static const String userCallSessions = '/call/sessions/user';
  static const String astrologerCallSessions = '/call/sessions/astrologer';

  // ==========================================
  // Chat Feature APIs
  // ==========================================
  static const String initiateChat = '/chat/initiate';
  static const String currentSession = '/chat/current-session';
  static String cancelChatSession(int sessionId) => '/chat/$sessionId/cancel';
  static const String getCurrentSession = '/chat/sessions/current';
  static const String userChatSessions = '/chat/sessions/user';
  static String getChatMessages(int sessionId) => '/chat/$sessionId/messages';
  static String sendChatMessage(int sessionId) => '/chat/$sessionId/message';
  static String markChatRead(int sessionId) => '/chat/$sessionId/read';
  static String syncChatStatus(int sessionId) => '/chat/$sessionId/sync-status';
  static String endChatSession(int sessionId) => '/chat/$sessionId/end';
  static const String uploadAttachment = '/chat/upload-attachment';
  static const String markMessagesRead = '/chat/messages/read';

  // ==========================================
  // Chat Assistance APIs
  // ==========================================
  static const String initiateChatAssistance = '/chat-assistance/initiate';
  static const String chatAssistanceSessions = '/chat-assistance/sessions';
  static String getChatAssistanceMessages(int sessionId) => '/chat-assistance/$sessionId/messages';
  static String sendChatAssistanceMessage(int sessionId) => '/chat-assistance/$sessionId/message';
  static String syncChatAssistanceStatus(int sessionId) => '/chat-assistance/$sessionId/sync-status';
  static const String getAstrologerChatAssistanceStatus = '/chat-assistance/astrologer/status';

  // ==========================================
  // Kundli, Remedies & Blogs
  // ==========================================
  static const String createKundali = '/kundli/create';
  static const String getKundali = '/kundli';
  static String getKundaliById(int id) => '/kundli/$id';
  static String updateKundali(int id) => '/kundli/$id';
  static String deleteKundali(int id) => '/kundli/$id';

  static const String remedies = "/user/remedies";
  static const String blogs = '/user/blogs';

  // ==========================================
  // Static Pages & Feedbacks
  // ==========================================
  static const String faqs = '/faqs';
  static const String privacyPolicy = '/privacy-policy';
  static const String paymentPolicy = '/payment-policy';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String paymentSuccess = '/payment-success';
  static const String feedback = '/feedback';
  static const String aboutUs = '/static-pages/about_us';
  static const String customerSupport = '/static-pages/customer_support';
  static const String foundersWords = '/user/founders-words';

  // ==========================================
  // WebSockets Channel Names & Common Events
  // ==========================================
  static String privateUserChannel(int userId) => 'private-user.$userId';
  static const String presenceRoomChannel = 'presence-room';

  static const String pusherConnectionEstablished = 'pusher:connection_established';
  static const String pusherSubscriptionSucceeded = 'pusher_internal:subscription_succeeded';
  static const String pusherSubscribe = 'pusher:subscribe';
  static const String pusherPing = 'pusher:ping';
  static const String pusherPong = '{"event":"pusher:pong"}';

  // ==========================================
  // System Events - Call
  // ==========================================
  static const String eventCallInitiated = 'CallInitiated';
  static const String eventCallAccepted = 'CallAccepted';
  static const String eventCallDismissed = 'CallDismissed';
  static const String eventCallEnded = 'CallEnded';
  static const String eventIceCandidateSent = 'IceCandidateSent';
  static const String eventWebRtcSdpUpdated = 'WebRtcSdpUpdated';

  // ==========================================
  // System Events - Chat
  // ==========================================
  static const String eventChatInitiated = 'ChatInitiated';
  static const String eventChatAccepted = 'ChatAccepted';
  static const String eventChatEnded = 'ChatEnded';
  static const String eventChatDismissed = 'ChatDismissed';
  static const String eventMessageSent = 'MessageSent';
  static const String eventMessageStatusUpdated = 'MessageStatusUpdated';
  static const String eventPresenceUpdated = 'PresenceUpdated';

  // ==========================================
  // System Events - Live
  // ==========================================
  static const String eventLiveSessionStarted = 'LiveSessionStarted';
  static const String eventLiveSessionEnded = 'LiveSessionEnded';
  static const String eventActiveLiveSessionsUpdated = 'ActiveLiveSessionsUpdated';
  static const String eventUserJoinedLiveSession = 'UserJoinedLiveSession';
  static const String eventUserLeftLiveSession = 'UserLeftLiveSession';
  static const String eventViewerCountUpdated = 'ViewerCountUpdated';
  static const String eventAstrologerMediaStatusChanged = 'AstrologerMediaStatusChanged';
  static const String eventAstrologerBroadcastStarted = 'AstrologerBroadcastStarted';
  static const String eventNewLiveComment = 'NewLiveComment';
  static const String eventSuperChatReceived = 'SuperChatReceived';
  static const String eventAstrologerAvailabilityUpdated = 'AstrologerAvailabilityUpdated';

  // ==========================================
  // System Events - Prepaid Packages
  // ==========================================
  static const String eventPackageSubSessionStarted = 'PackageSubSessionStarted';
  static const String eventPackageSubSessionEnded = 'PackageSubSessionEnded';
  static const String eventPackageSessionTerminated = 'PackageSessionTerminated';
  static const String eventPackageSessionStateUpdated = 'PackageSessionStateUpdated';

  // ==========================================
  // System Events - Chat Assistance
  // ==========================================
  static const String eventChatAssistanceInitiated = 'ChatAssistanceInitiated';
  static const String eventChatAssistanceMessageSent = 'ChatAssistanceMessageSent';
  static const String eventChatAssistanceMessageStatusUpdated = 'ChatAssistanceMessageStatusUpdated';
  static const String eventChatAssistanceLimitReached = 'ChatAssistanceLimitReached';

  // ==========================================
  // System Events - Auth
  // ==========================================
  static const String eventUserForceLoggedOut = 'UserForceLoggedOut';
}
