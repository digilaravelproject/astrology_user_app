import 'dart:convert';
import 'package:astro_user/core/utils/logger.dart';
import 'package:astro_user/core/services/websocket/websocket_state.dart';

class AstrologerWsHandler {
  static void handleAstrologerAvailabilityUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        try {
          eventData = jsonDecode(rawData);
        } catch (_) {}
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      WebSocketState.astrologerAvailabilityEvent.add(eventData);
    } catch (e) {
      Logger.e('AstrologerWsHandler: Error handling availability update -> $e');
    }
  }
}
