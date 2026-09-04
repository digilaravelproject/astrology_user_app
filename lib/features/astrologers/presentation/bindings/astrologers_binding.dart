import 'package:get/get.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/features/astrologers/domain/repositories/astrologer_repository.dart';
import 'package:astro_user/features/astrologers/data/datasources/astrologer_service.dart';
import 'package:astro_user/features/astrologers/domain/usecases/get_astrologers_usecase.dart';
import 'package:astro_user/features/astrologers/domain/usecases/get_astrologer_by_id_usecase.dart';
import 'package:astro_user/features/astrologers/domain/usecases/block_astrologer_usecase.dart';
import 'package:astro_user/features/astrologers/domain/usecases/report_astrologer_usecase.dart';
import 'package:astro_user/features/astrologers/domain/usecases/post_review_usecase.dart';
import 'package:astro_user/features/astrologers/domain/usecases/get_reviews_usecase.dart';
import 'package:astro_user/features/astrologers/domain/usecases/follow_astrologer_usecase.dart';
import 'package:astro_user/features/astrologers/domain/usecases/get_gifts_usecase.dart';
import 'package:astro_user/features/astrologers/domain/usecases/send_gift_usecase.dart';
import 'package:astro_user/features/astrologers/domain/usecases/get_gift_history_usecase.dart';
import 'package:astro_user/features/astrologers/domain/usecases/get_astrologer_gallery_usecase.dart';
import 'package:astro_user/features/astrologers/domain/repositories/gift_repository.dart';
import 'package:astro_user/features/astrologers/data/datasources/gift_service.dart';
import 'package:astro_user/features/astrologers/presentation/controllers/astrologer_controller.dart';

class AstrologersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AstrologerRepository(apiClient: Get.find()));
    Get.lazyPut(() => AstrologerService(repository: Get.find()));
    Get.lazyPut(() => GetAstrologersUseCase(service: Get.find()));
    Get.lazyPut(() => GetAstrologerByIdUseCase(service: Get.find()));
    Get.lazyPut(() => BlockAstrologerUseCase(service: Get.find()));
    Get.lazyPut(() => ReportAstrologerUseCase(service: Get.find()));
    Get.lazyPut(() => PostReviewUseCase(service: Get.find()));
    Get.lazyPut(() => GetReviewsUseCase(service: Get.find()));
    Get.lazyPut(() => FollowAstrologerUseCase(service: Get.find()));
    Get.lazyPut(() => GiftRepository(apiClient: Get.find()));
    Get.lazyPut(() => GiftService(repository: Get.find()));
    Get.lazyPut(() => GetGiftsUseCase(service: Get.find()));
    Get.lazyPut(() => SendGiftUseCase(service: Get.find()));
    Get.lazyPut(() => GetGiftHistoryUseCase(service: Get.find()));
    Get.lazyPut(() => GetAstrologerGalleryUseCase(service: Get.find()));
    Get.lazyPut(() => AstrologerController(
      getAstrologersUseCase: Get.find(),
      getAstrologerByIdUseCase: Get.find(),
      blockAstrologerUseCase: Get.find(),
      reportAstrologerUseCase: Get.find(),
      postReviewUseCase: Get.find(),
      getReviewsUseCase: Get.find(),
      followAstrologerUseCase: Get.find(),
      getGiftsUseCase: Get.find(),
      sendGiftUseCase: Get.find(),
      getGiftHistoryUseCase: Get.find(),
      getAstrologerGalleryUseCase: Get.find(),
    ));
  }
}
