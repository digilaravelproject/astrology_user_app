import 'package:get/get.dart';
import '../domain/models/astrologer_model.dart';
import '../domain/usecases/get_astrologers_usecase.dart';
import '../domain/usecases/get_astrologer_by_id_usecase.dart';
import '../domain/usecases/block_astrologer_usecase.dart';
import '../domain/usecases/report_astrologer_usecase.dart';
import '../domain/usecases/post_review_usecase.dart';
import '../domain/usecases/get_reviews_usecase.dart';
import '../domain/usecases/follow_astrologer_usecase.dart';
import '../domain/models/review_model.dart';
import '../../../../core/services/network/response_model.dart';

class AstrologerController extends GetxController {
  final GetAstrologersUseCase _getAstrologersUseCase;
  final GetAstrologerByIdUseCase _getAstrologerByIdUseCase;
  final BlockAstrologerUseCase _blockAstrologerUseCase;
  final ReportAstrologerUseCase _reportAstrologerUseCase;
  final PostReviewUseCase _postReviewUseCase;
  final GetReviewsUseCase _getReviewsUseCase;
  final FollowAstrologerUseCase _followAstrologerUseCase;

  AstrologerController({
    required GetAstrologersUseCase getAstrologersUseCase,
    required GetAstrologerByIdUseCase getAstrologerByIdUseCase,
    required BlockAstrologerUseCase blockAstrologerUseCase,
    required ReportAstrologerUseCase reportAstrologerUseCase,
    required PostReviewUseCase postReviewUseCase,
    required GetReviewsUseCase getReviewsUseCase,
    required FollowAstrologerUseCase followAstrologerUseCase,
  })  : _getAstrologersUseCase = getAstrologersUseCase,
        _getAstrologerByIdUseCase = getAstrologerByIdUseCase,
        _blockAstrologerUseCase = blockAstrologerUseCase,
        _reportAstrologerUseCase = reportAstrologerUseCase,
        _postReviewUseCase = postReviewUseCase,
        _getReviewsUseCase = getReviewsUseCase,
        _followAstrologerUseCase = followAstrologerUseCase;

  final RxList<AstrologerModel> astrologers = <AstrologerModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<AstrologerModel?> selectedAstrologer = Rx<AstrologerModel?>(null);
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isReviewsLoading = false.obs;
  final RxBool isFollowing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAstrologers();
  }

  Future<void> fetchAstrologers() async {
    try {
      isLoading.value = true;
      final result = await _getAstrologersUseCase.execute();
      astrologers.assignAll(result);
    } catch (e) {
      print('Error fetching astrologers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<AstrologerModel?> fetchAstrologerById(int id) async {
    try {
      selectedAstrologer.value = null; // Clear previous data
      final result = await _getAstrologerByIdUseCase.execute(id);
      selectedAstrologer.value = result;
      // Set follow status based on API response
      isFollowing.value = result?.isChatEnabled ?? false;
      return result;
    } catch (e) {
      print('Error fetching astrologer: $e');
      return null;
    }
  }

  Future<ResponseModel> blockAstrologer(int id) async {
    return await _blockAstrologerUseCase.execute(id);
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

  // Filtered astrologers based on search query
  List<AstrologerModel> getFilteredAstrologers(String query) {
    if (query.isEmpty) return astrologers;
    return astrologers
        .where((a) => a.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
