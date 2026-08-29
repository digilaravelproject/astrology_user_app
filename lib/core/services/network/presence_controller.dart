import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:astro_user/features/astrologers/controllers/astrologer_controller.dart';

class PresenceController extends GetxController {
  // Source of truth for raw socket connectivity
  final RxSet<int> onlineUserIds = <int>{}.obs;

  // Timer map for debouncing member_removed events
  final Map<int, Timer> _debounceTimers = {};

  final int debounceDurationSeconds = 7;

  /// Called when pusher_internal:subscription_succeeded is received for presence-room
  void handleSubscriptionSucceeded(Map<String, dynamic> data) {
    try {
      final presence = data['presence'];
      if (presence != null && presence['hash'] != null) {
        final Map hash = presence['hash'];
        final List<int> ids =
            hash.keys
                .map((k) => int.tryParse(k.toString()) ?? 0)
                .where((id) => id > 0)
                .toList();
        onlineUserIds.clear();
        onlineUserIds.addAll(ids);
        debugPrint(
          '[PresenceController] Initial sync: ${ids.length} users online.',
        );
      }
    } catch (e) {
      debugPrint(
        '[PresenceController] Error in handleSubscriptionSucceeded: $e',
      );
    }
  }

  /// Called when pusher_internal:member_added is received
  void handleMemberAdded(int userId) {
    if (userId <= 0) return;

    // Cancel any pending removal timer
    if (_debounceTimers.containsKey(userId)) {
      _debounceTimers[userId]?.cancel();
      _debounceTimers.remove(userId);
      debugPrint(
        '[PresenceController] Cancelled offline debounce for user $userId',
      );
    }

    if (!onlineUserIds.contains(userId)) {
      onlineUserIds.add(userId);
      debugPrint('[PresenceController] User $userId marked ONLINE');
      _syncToAstrologerController(userId, true);
    }
  }

  /// Called when pusher_internal:member_removed is received
  void handleMemberRemoved(int userId) {
    if (userId <= 0) return;

    // Start debounce timer
    _debounceTimers[userId]?.cancel();

    debugPrint(
      '[PresenceController] Starting offline debounce for user $userId',
    );
    _debounceTimers[userId] = Timer(
      Duration(seconds: debounceDurationSeconds),
      () {
        _debounceTimers.remove(userId);
        if (onlineUserIds.contains(userId)) {
          onlineUserIds.remove(userId);
          debugPrint(
            '[PresenceController] User $userId marked OFFLINE after debounce',
          );
          _syncToAstrologerController(userId, false);
        }
      },
    );
  }

  void _syncToAstrologerController(int astrologerId, bool isOnline) {
    if (Get.isRegistered<AstrologerController>()) {
      final controller = Get.find<AstrologerController>();

      bool currentBusy = false;
      String currentStatus = isOnline ? 'Online' : 'Offline';

      // Find current state
      final currentList =
          controller.astrologers.where((a) => a.id == astrologerId).toList();
      if (currentList.isNotEmpty) {
        currentBusy = currentList.first.isBusy;
        if (isOnline) {
          currentStatus = currentBusy ? 'Busy' : 'Online';
        }
      }

      controller.updateAstrologerAvailability(
        astrologerId: astrologerId,
        isOnline: isOnline,
        isBusy: isOnline ? currentBusy : false,
        availabilityStatus: currentStatus,
      );
    }
  }

  @override
  void onClose() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    super.onClose();
  }
}
