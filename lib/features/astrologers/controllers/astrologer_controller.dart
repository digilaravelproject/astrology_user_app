import 'package:get/get.dart';
import '../domain/models/astrologer_model.dart';
import '../domain/usecases/get_astrologers_usecase.dart';
import '../domain/usecases/get_astrologer_by_id_usecase.dart';
import '../domain/usecases/block_astrologer_usecase.dart';
import '../domain/usecases/report_astrologer_usecase.dart';
import '../domain/usecases/post_review_usecase.dart';
import '../domain/usecases/get_reviews_usecase.dart';
import '../domain/usecases/follow_astrologer_usecase.dart';
import '../domain/usecases/get_gifts_usecase.dart';
import '../domain/usecases/send_gift_usecase.dart';
import '../domain/models/review_model.dart';
import '../domain/models/gift_model.dart';
import '../domain/models/gift_history_model.dart';
import '../domain/usecases/get_gift_history_usecase.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../wallet/widgets/recharge_bottom_sheet.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';

class AstrologerController extends GetxController {
  final GetAstrologersUseCase _getAstrologersUseCase;
  final GetAstrologerByIdUseCase _getAstrologerByIdUseCase;
  final BlockAstrologerUseCase _blockAstrologerUseCase;
  final ReportAstrologerUseCase _reportAstrologerUseCase;
  final PostReviewUseCase _postReviewUseCase;
  final GetReviewsUseCase _getReviewsUseCase;
  final FollowAstrologerUseCase _followAstrologerUseCase;
  final GetGiftsUseCase _getGiftsUseCase;
  final SendGiftUseCase _sendGiftUseCase;
  final GetGiftHistoryUseCase _getGiftHistoryUseCase;

  AstrologerController({
    required GetAstrologersUseCase getAstrologersUseCase,
    required GetAstrologerByIdUseCase getAstrologerByIdUseCase,
    required BlockAstrologerUseCase blockAstrologerUseCase,
    required ReportAstrologerUseCase reportAstrologerUseCase,
    required PostReviewUseCase postReviewUseCase,
    required GetReviewsUseCase getReviewsUseCase,
    required FollowAstrologerUseCase followAstrologerUseCase,
    required GetGiftsUseCase getGiftsUseCase,
    required SendGiftUseCase sendGiftUseCase,
    required GetGiftHistoryUseCase getGiftHistoryUseCase,
  })  : _getAstrologersUseCase = getAstrologersUseCase,
        _getAstrologerByIdUseCase = getAstrologerByIdUseCase,
        _blockAstrologerUseCase = blockAstrologerUseCase,
        _reportAstrologerUseCase = reportAstrologerUseCase,
        _postReviewUseCase = postReviewUseCase,
        _getReviewsUseCase = getReviewsUseCase,
        _followAstrologerUseCase = followAstrologerUseCase,
        _getGiftsUseCase = getGiftsUseCase,
        _sendGiftUseCase = sendGiftUseCase,
        _getGiftHistoryUseCase = getGiftHistoryUseCase;

  final RxList<AstrologerModel> astrologers = <AstrologerModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<AstrologerModel?> selectedAstrologer = Rx<AstrologerModel?>(null);
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isReviewsLoading = false.obs;
  final RxBool isFollowing = false.obs;
  final RxList<GiftModel> gifts = <GiftModel>[].obs;
  final RxBool isGiftsLoading = false.obs;
  final RxList<GiftHistoryItem> giftHistory = <GiftHistoryItem>[].obs;
  final RxBool isHistoryLoading = false.obs;
  final RxnInt sendingGiftId = RxnInt();
  
  // Isolated lists for Listing Screens to avoid affecting Home
  final RxList<AstrologerModel> filteredAstrologers = <AstrologerModel>[].obs;
  final RxBool isFilteredLoading = false.obs;
  
  // Isolated search results
  final RxList<AstrologerModel> searchResults = <AstrologerModel>[].obs;
  final RxBool isSearchLoading = false.obs;
  
  // Separate list for Top Astrologers (Stories)
  final RxList<AstrologerModel> topAstrologers = <AstrologerModel>[].obs;
  final RxBool isTopLoading = false.obs;

  // Filter States
  final RxString selectedType = 'all'.obs; // all, favourite, new, top
  final RxString selectedServiceType = 'all'.obs; // all, chat, call
  final RxInt minPrice = 0.obs;
  final RxInt maxPrice = 1000.obs;
  final RxList<String> selectedSkills = <String>[].obs;
  final RxList<String> selectedLanguages = <String>[].obs;
  final RxDouble minRating = 0.0.obs;
  final RxBool isOnlineOnly = false.obs;
  final RxString sortBy = 'rating_high_to_low'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch astrologers when controller is initialized
    fetchAstrologers();
    fetchGifts();
    
    // Setup debouncer for search
    debounce(searchQuery, (_) => fetchAstrologers(), time: const Duration(milliseconds: 500));
  }

  Future<void> fetchTopAstrologers({String? serviceType}) async {
    try {
      isTopLoading.value = true;
      final Map<String, dynamic> params = {'type': 'top'};
      if (serviceType != null && serviceType != 'all') {
        params['service_type'] = serviceType;
      } else if (serviceType == 'all') {
        params['service_type'] = 'all';
      }
      
      final result = await _getAstrologersUseCase.execute(params: params);
      topAstrologers.assignAll(result);
    } catch (e) {
      print('Error fetching top astrologers: $e');
    } finally {
      isTopLoading.value = false;
    }
  }

  Future<void> fetchFilteredAstrologers({String? type, String? serviceType, List<String>? skills, bool? online}) async {
    try {
      isFilteredLoading.value = true;
      
      // Sync global states so UI chips update
      if (serviceType != null) selectedServiceType.value = serviceType;
      if (online != null) isOnlineOnly.value = online;
      
      // Ensure type is 'all' when filtering by skill if not specified, 
      // as per user requirement: {type: all, service_type: chat, skills: ...}
      if (type != null) {
        selectedType.value = type;
      } else if (skills != null && skills.isNotEmpty) {
        selectedType.value = 'all';
      }

      if (skills != null) {
        selectedSkills.assignAll(skills);
        selectedSkills.refresh();
      } else if (type == 'all' && online == null) {
        // Only clear everything if 'All' is clicked (and online is not being toggled)
        selectedSkills.clear();
        selectedSkills.refresh();
        isOnlineOnly.value = false;
      }

      final Map<String, dynamic> params = {};
      params['type'] = selectedType.value;
      if (selectedServiceType.value != 'all') params['service_type'] = selectedServiceType.value;
      if (isOnlineOnly.value) params['is_online'] = 1;
      if (selectedSkills.isNotEmpty) params['skills'] = selectedSkills.join(',');
      
      print('--- Astrologer Filter Debug ---');
      print('Params: $params');
      print('Selected Type: ${selectedType.value}');
      print('Selected Skills: $selectedSkills');
      print('-------------------------------');
      
      final result = await _getAstrologersUseCase.execute(params: params);
      filteredAstrologers.assignAll(result);
      filteredAstrologers.refresh();
    } catch (e) {
      print('Error fetching filtered astrologers: $e');
    } finally {
      isFilteredLoading.value = false;
    }
  }

  Future<void> searchAstrologers({required String query, String? serviceType}) async {
    try {
      isSearchLoading.value = true;
      final Map<String, dynamic> params = {
        'search_query': query,
      };
      if (serviceType != null) params['service_type'] = serviceType;
      
      final result = await _getAstrologersUseCase.execute(params: params);
      searchResults.assignAll(result);
    } catch (e) {
      print('Error searching astrologers: $e');
    } finally {
      isSearchLoading.value = false;
    }
  }

  Future<void> fetchAstrologers() async {
    try {
      isLoading.value = true;

      final Map<String, dynamic> params = {};

      if (selectedType.value != 'all') {
        params['type'] = selectedType.value;
      }

      if (selectedServiceType.value != 'all') {
        params['service_type'] = selectedServiceType.value;
      }
      
      if (minPrice.value > 0) {
        params['min_price'] = minPrice.value;
      }
      
      if (maxPrice.value < 1000) {
        params['max_price'] = maxPrice.value;
      }

      if (minRating.value > 0) {
        params['min_rating'] = minRating.value;
      }

      if (isOnlineOnly.value) {
        params['is_online'] = 1;
      }

      if (sortBy.value.isNotEmpty && sortBy.value != 'rating_high_to_low') {
        params['sort_by'] = sortBy.value;
      }

      if (searchQuery.value.isNotEmpty) {
        params['search_query'] = searchQuery.value;
      }

      if (selectedSkills.isNotEmpty) {
        params['skills'] = selectedSkills.join(',');
      }
      if (selectedLanguages.isNotEmpty) {
        params['language'] = selectedLanguages.join(',');
      }

      final result = await _getAstrologersUseCase.execute(params: params);
      astrologers.assignAll(result);
    } catch (e) {
      print('Error fetching astrologers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateType(String type) {
    selectedType.value = type;
    fetchAstrologers();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void setFilters({
    String? type,
    String? serviceType,
    int? minP,
    int? maxP,
    List<String>? skills,
    List<String>? langs,
    double? rating,
    bool? online,
    String? sort,
  }) {
    if (type != null) selectedType.value = type;
    if (serviceType != null) selectedServiceType.value = serviceType;
    if (minP != null) minPrice.value = minP;
    if (maxP != null) maxPrice.value = maxP;
    if (skills != null) selectedSkills.assignAll(skills);
    if (langs != null) selectedLanguages.assignAll(langs);
    if (rating != null) minRating.value = rating;
    if (online != null) isOnlineOnly.value = online;
    if (sort != null) sortBy.value = sort;
    
    fetchAstrologers();
  }

  void toggleSkill(String skill, {String? serviceType}) {
    if (serviceType != null) {
      // Prepare the new skill set for single selection listing screens
      List<String> newSkills = [];
      if (!selectedSkills.contains(skill)) {
        newSkills = [skill];
      }
      
      // Update state and fetch via the unified filter method
      fetchFilteredAstrologers(type: 'all', serviceType: serviceType, skills: newSkills);
    } else {
      // Multiple selection for general filters
      if (selectedSkills.contains(skill)) {
        selectedSkills.remove(skill);
      } else {
        selectedSkills.add(skill);
      }
      fetchAstrologers();
    }
  }

  void clearFilters() {
    minPrice.value = 0;
    maxPrice.value = 1000;
    selectedSkills.clear();
    selectedLanguages.clear();
    minRating.value = 0.0;
    isOnlineOnly.value = false;
    selectedType.value = 'all';
    selectedServiceType.value = 'all';
    sortBy.value = 'rating_high_to_low';
    fetchAstrologers();
  }

  Future<AstrologerModel?> fetchAstrologerById(int id) async {
    try {
      selectedAstrologer.value = null; // Clear previous data
      final result = await _getAstrologerByIdUseCase.execute(id);
      selectedAstrologer.value = result;
      // Set follow status based on API response
      isFollowing.value = result?.isFollowed ?? false;
      return result;
    } catch (e) {
      print('Error fetching astrologer: $e');
      return null;
    }
  }

  Future<ResponseModel> blockAstrologer(int id) async {
    final result = await _blockAstrologerUseCase.execute(id);
    if (result.isSuccess) {
      fetchAstrologerById(id);
    }
    return result;
  }

  Future<ResponseModel> unblockAstrologer(int id) async {
    final result = await _blockAstrologerUseCase.execute(id);
    if (result.isSuccess) {
      fetchAstrologerById(id);
    }
    return result;
  }

  Future<ResponseModel> reportAstrologer(int id, String reason) async {
    return await _reportAstrologerUseCase.execute(id, reason);
  }

  Future<ResponseModel> postReview(int astrologerId, int rating, String review) async {
    return await _postReviewUseCase.execute(astrologerId, rating, review);
  }

  Future<void> fetchReviews(int astrologerId) async {
    try {
      isReviewsLoading.value = true;
      final result = await _getReviewsUseCase.execute(astrologerId);
      print('Reviews fetched: ${result.length}');
      reviews.assignAll(result);
    } catch (e) {
      print('Error fetching reviews: $e');
    } finally {
      isReviewsLoading.value = false;
    }
  }

  Future<ResponseModel> followAstrologer(int id) async {
    return await _followAstrologerUseCase.execute(id);
  }
  
  Future<void> fetchGifts() async {
    try {
      isGiftsLoading.value = true;
      final result = await _getGiftsUseCase.execute();
      gifts.assignAll(result);
    } catch (e) {
      print('Error fetching gifts: $e');
    } finally {
      isGiftsLoading.value = false;
    }
  }

  Future<void> sendGift(GiftModel gift, int astrologerId) async {
    final walletController = Get.find<WalletController>();
    final double? price = double.tryParse(gift.price);
    final String balanceStr = walletController.balance;
    final double balance = double.tryParse(balanceStr) ?? 0.0;

    if (price != null && balance < price) {
      _showInsufficientBalanceSheet();
      return;
    }

    try {
      sendingGiftId.value = gift.id;
      final response = await _sendGiftUseCase.execute(gift.id, astrologerId);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Gift sent successfully!');
        // Refresh wallet balance after sending gift
        walletController.fetchWallet();
      } else {
        // If API returns insufficient balance error (e.g. 422 or specific message)
        if (response.message.toLowerCase().contains('balance') || response.message.toLowerCase().contains('funds')) {
           _showInsufficientBalanceSheet();
        } else {
           CustomSnackbar.showError(response.message);
        }
      }
    } catch (e) {
      print('Error sending gift: $e');
      CustomSnackbar.showError('Something went wrong. Please try again.');
    } finally {
      sendingGiftId.value = null;
    }
  }

  Future<void> fetchGiftHistory(int astrologerId) async {
    try {
      isHistoryLoading.value = true;
      giftHistory.clear();
      final result = await _getGiftHistoryUseCase.execute(astrologerId);
      giftHistory.assignAll(result);
    } catch (e) {
      print('Error fetching gift history: $e');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  void _showInsufficientBalanceSheet() {
    Get.bottomSheet(
      const RechargeBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Filtered astrologers based on search query
  List<AstrologerModel> getFilteredAstrologers(String query) {
    if (query.isEmpty) return astrologers;
    return astrologers
        .where((a) => a.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
