import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/services/websocket/handlers/call_ws_handler.dart';
import 'package:astro_user/core/services/websocket/handlers/chat_ws_handler.dart';
import 'package:astro_user/core/services/websocket/handlers/live_ws_handler.dart';
import 'package:astro_user/core/services/websocket/handlers/package_ws_handler.dart';
import 'package:astro_user/core/services/websocket/handlers/astrologer_ws_handler.dart';
import 'package:astro_user/core/services/websocket/handlers/auth_ws_handler.dart';

class WebSocketEventRouter {
  static void routeEvent(String event, dynamic data) {
    if (event == AppUrls.eventChatAccepted) {
      ChatWsHandler.handleChatAccepted(data);
    } else if (event == AppUrls.eventChatEnded) {
      ChatWsHandler.handleChatEnded(data);
    } else if (event == AppUrls.eventChatDismissed ||
        event == 'App\\Events\\${AppUrls.eventChatDismissed}' ||
        event == '.${AppUrls.eventChatDismissed}') {
      ChatWsHandler.handleChatDismissed(data);
    } else if (event == AppUrls.eventMessageSent ||
        event == 'App\\Events\\${AppUrls.eventMessageSent}') {
      ChatWsHandler.handleMessageSent(data);
    } else if (event == AppUrls.eventMessageStatusUpdated ||
        event == 'App\\Events\\${AppUrls.eventMessageStatusUpdated}') {
      ChatWsHandler.handleMessageStatusUpdated(data);
    } else if (event == AppUrls.eventPresenceUpdated ||
        event == 'App\\Events\\${AppUrls.eventPresenceUpdated}') {
      ChatWsHandler.handlePresenceUpdated(data);
    } else if (event == AppUrls.eventCallAccepted ||
        event == 'App\\Events\\${AppUrls.eventCallAccepted}') {
      CallWsHandler.handleCallAccepted(data);
    } else if (event == AppUrls.eventCallDismissed ||
        event == 'App\\Events\\${AppUrls.eventCallDismissed}') {
      CallWsHandler.handleCallDismissed(data);
    } else if (event == AppUrls.eventCallEnded ||
        event == 'App\\Events\\${AppUrls.eventCallEnded}') {
      CallWsHandler.handleCallEnded(data);
    } else if (event == AppUrls.eventIceCandidateSent ||
        event == 'App\\Events\\${AppUrls.eventIceCandidateSent}') {
      CallWsHandler.handleIceCandidateSent(data);
    } else if (event == AppUrls.eventWebRtcSdpUpdated ||
        event == 'App\\Events\\${AppUrls.eventWebRtcSdpUpdated}') {
      CallWsHandler.handleWebRtcSdpUpdated(data);
    } else if (event == AppUrls.eventViewerCountUpdated ||
        event == 'App\\Events\\${AppUrls.eventViewerCountUpdated}' ||
        event == '.${AppUrls.eventViewerCountUpdated}') {
      LiveWsHandler.handleViewerCountUpdated(data);
    } else if (event == AppUrls.eventNewLiveComment ||
        event == 'App\\Events\\${AppUrls.eventNewLiveComment}' ||
        event == '.${AppUrls.eventNewLiveComment}') {
      LiveWsHandler.handleNewLiveComment(data);
    } else if (event == AppUrls.eventSuperChatReceived ||
        event == 'App\\Events\\${AppUrls.eventSuperChatReceived}' ||
        event == '.${AppUrls.eventSuperChatReceived}') {
      LiveWsHandler.handleSuperChatReceived(data);
    } else if (event == AppUrls.eventLiveSessionStarted ||
        event == 'App\\Events\\${AppUrls.eventLiveSessionStarted}' ||
        event == '.${AppUrls.eventLiveSessionStarted}') {
      LiveWsHandler.handleLiveSessionStarted(data);
    } else if (event == AppUrls.eventActiveLiveSessionsUpdated ||
        event == 'App\\Events\\${AppUrls.eventActiveLiveSessionsUpdated}') {
      LiveWsHandler.handleActiveLiveSessionsUpdated(data);
    } else if (event == AppUrls.eventLiveSessionEnded ||
        event == 'App\\Events\\${AppUrls.eventLiveSessionEnded}' ||
        event == '.${AppUrls.eventLiveSessionEnded}') {
      LiveWsHandler.handleLiveSessionEnded(data);
    } else if (event == AppUrls.eventAstrologerBroadcastStarted ||
        event == 'App\\Events\\${AppUrls.eventAstrologerBroadcastStarted}' ||
        event == '.${AppUrls.eventAstrologerBroadcastStarted}') {
      LiveWsHandler.handleAstrologerBroadcastStarted(data);
    } else if (event == AppUrls.eventAstrologerMediaStatusChanged ||
        event == 'App\\Events\\${AppUrls.eventAstrologerMediaStatusChanged}' ||
        event == '.${AppUrls.eventAstrologerMediaStatusChanged}') {
      LiveWsHandler.handleAstrologerMediaStatusChanged(data);
    } else if (event == AppUrls.eventUserJoinedLiveSession ||
        event == 'App\\Events\\${AppUrls.eventUserJoinedLiveSession}' ||
        event == '.${AppUrls.eventUserJoinedLiveSession}') {
      LiveWsHandler.handleUserJoinedLiveSession(data);
    } else if (event == AppUrls.eventUserLeftLiveSession ||
        event == 'App\\Events\\${AppUrls.eventUserLeftLiveSession}' ||
        event == '.${AppUrls.eventUserLeftLiveSession}') {
      LiveWsHandler.handleUserLeftLiveSession(data);
    } else if (event == AppUrls.eventChatAssistanceMessageSent ||
        event == 'App\\Events\\${AppUrls.eventChatAssistanceMessageSent}') {
      ChatWsHandler.handleMessageSent(data);
    } else if (event == AppUrls.eventChatAssistanceMessageStatusUpdated ||
        event == 'App\\Events\\${AppUrls.eventChatAssistanceMessageStatusUpdated}') {
      ChatWsHandler.handleMessageStatusUpdated(data);
    } else if (event == AppUrls.eventChatAssistanceLimitReached ||
        event == 'App\\Events\\${AppUrls.eventChatAssistanceLimitReached}') {
      ChatWsHandler.handleChatAssistanceLimitReached(data);
    } else if (event == AppUrls.eventPackageSubSessionStarted ||
        event == 'App\\Events\\${AppUrls.eventPackageSubSessionStarted}') {
      PackageWsHandler.handlePackageSubSessionStarted(data);
    } else if (event == AppUrls.eventPackageSubSessionEnded ||
        event == 'App\\Events\\${AppUrls.eventPackageSubSessionEnded}') {
      PackageWsHandler.handlePackageSubSessionEnded(data);
    } else if (event == AppUrls.eventPackageSessionTerminated ||
        event == 'App\\Events\\${AppUrls.eventPackageSessionTerminated}') {
      PackageWsHandler.handlePackageSessionTerminated(data);
    } else if (event == AppUrls.eventPackageSessionStateUpdated ||
        event == 'App\\Events\\${AppUrls.eventPackageSessionStateUpdated}') {
      PackageWsHandler.handlePackageSessionStateUpdated(data);
    } else if (event == AppUrls.eventAstrologerAvailabilityUpdated ||
        event == '.${AppUrls.eventAstrologerAvailabilityUpdated}' ||
        event == 'App\\Events\\${AppUrls.eventAstrologerAvailabilityUpdated}') {
      AstrologerWsHandler.handleAstrologerAvailabilityUpdated(data);
    } else if (event == AppUrls.eventUserForceLoggedOut ||
        event == '.${AppUrls.eventUserForceLoggedOut}' ||
        event == 'App\\Events\\${AppUrls.eventUserForceLoggedOut}') {
      AuthWsHandler.handleForceLoggedOut(data);
    }
  }
}
