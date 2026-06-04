
class AppUrls {
  static String baseUrl = "https://suryapathkundli.com";
  //static String baseUrl = "https://darkgoldenrod-peafowl-305286.hostingersite.com";
  static const String baseImageUrl = "https://suryapathkundli.com/storage/app/public/";
  //static const String baseImageUrl = "https://darkgoldenrod-peafowl-305286.hostingersite.com/storage/app/public/";
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
  static const String wallet = '/api/v1/user/wallet';
  static const String walletTopup = '/api/v1/user/wallet/topup';
  static const String walletTopupVerify = '/api/v1/user/wallet/topup/verify';
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

  static const String faqs = '/api/v1/faqs';
  static const String privacyPolicy = '/api/v1/privacy-policy';
  static const String paymentPolicy = '/api/v1/payment-policy';
  static const String termsAndConditions = '/api/v1/terms-and-conditions';
  static const String paymentSuccess = '/payment-success';

  // Notifications
  static String getNotificationCount(int userId) => '/api/v1/user/notifications/count?user_id=$userId';
  static String getNotifications(int userId) => '/api/v1/user/notifications?user_id=$userId';
  static String getNotificationById(int id, int userId) => '/api/v1/user/notifications/$id?user_id=$userId';
  static String markNotificationRead(int id, int userId) => '/api/v1/user/notifications/$id/mark-read?user_id=$userId';

  // Gifts
  static const String gifts = '/api/v1/gifts';
  static const String sendGift = '/api/v1/gifts/send';
  static String getGiftHistory(int id) => '/api/v1/astrologers/$id/gifts';

  // Chat
  static const String initiateChat = '/api/v1/chat/initiate';
  static const String currentSession = '/api/v1/chat/current-session';
  static String rejectChatSession(int sessionId) => '/api/v1/chat/$sessionId/reject';

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



  static String getPanchangByDate(String date) => 'https://api.vedika.io/sandbox/panchang/$date';

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
  static String endChatSession(int sessionId) => '/api/v1/chat/$sessionId/end';
  static const String uploadAttachment = '/api/v1/chat/upload-attachment';
  static const String getCurrentSession = '/api/v1/chat/sessions/current';
  static const String markMessagesRead = '/api/v1/chat/messages/read';
  static const String userChatSessions = '/api/v1/chat/sessions/user';

}