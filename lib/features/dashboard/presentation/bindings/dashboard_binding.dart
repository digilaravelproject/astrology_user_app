import 'package:get/get.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/features/matrimony/presentation/controllers/matrimony_controller.dart';
import 'package:astro_user/features/matrimony/domain/repositories/matrimony_repository.dart';
import 'package:astro_user/features/matrimony/data/datasources/matrimony_service.dart';
import 'package:astro_user/features/matrimony/domain/usecases/save_matrimony_profile_usecase.dart';
import 'package:astro_user/features/matrimony/domain/usecases/update_matrimony_profile_usecase.dart';
import 'package:astro_user/features/matrimony/domain/usecases/get_matrimony_profile_usecase.dart';
import 'package:astro_user/features/matrimony/domain/usecases/get_matrimony_profile_details_usecase.dart';
import 'package:astro_user/features/matrimony/domain/usecases/get_my_matrimony_profile_details_usecase.dart';
import 'package:astro_user/features/matrimony/domain/usecases/search_matrimony_profiles_usecase.dart';
import 'package:astro_user/features/matrimony/domain/usecases/block_matrimony_profile_usecase.dart';
import 'package:astro_user/features/matrimony/domain/usecases/report_matrimony_profile_usecase.dart';
import 'package:astro_user/features/home/presentation/controllers/founder_controller.dart';
import 'package:astro_user/features/live/presentation/bindings/live_binding.dart';
import 'package:astro_user/features/home/domain/repositories/founder_repository.dart';
import 'package:astro_user/features/home/data/datasources/founder_service.dart';
import 'package:astro_user/features/home/domain/usecases/get_founder_words_usecase.dart';
import 'package:astro_user/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:astro_user/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:astro_user/features/wallet/data/datasources/wallet_service.dart';
import 'package:astro_user/features/wallet/domain/usecases/get_wallet_usecase.dart';
import 'package:astro_user/features/wallet/domain/usecases/top_up_wallet_usecase.dart';
import 'package:astro_user/features/wallet/domain/usecases/verify_top_up_usecase.dart';
import 'package:astro_user/features/wallet/domain/usecases/get_transactions_usecase.dart';
import 'package:astro_user/features/auth/data/datasources/auth_service_interface.dart';
import 'package:astro_user/core/services/payment/razorpay/razorpay_service.dart';
import 'package:astro_user/features/profile/domain/repositories/profile_repository.dart';
import 'package:astro_user/features/profile/data/datasources/profile_service.dart';
import 'package:astro_user/features/profile/domain/usecases/get_profile_usecase.dart';


import 'package:astro_user/features/home/domain/repositories/remedy_repository.dart';
import 'package:astro_user/features/home/data/datasources/remedy_service.dart';
import 'package:astro_user/features/home/domain/usecases/get_remedies_usecase.dart';
import 'package:astro_user/features/home/domain/usecases/get_remedy_by_id_usecase.dart';
import 'package:astro_user/features/home/domain/repositories/blog_repository.dart';
import 'package:astro_user/features/home/data/datasources/blog_service.dart';
import 'package:astro_user/features/home/domain/usecases/get_blogs_usecase.dart';
import 'package:astro_user/features/home/domain/usecases/get_blog_by_id_usecase.dart';
import 'package:astro_user/features/home/presentation/controllers/remedy_controller.dart';
import 'package:astro_user/features/home/presentation/controllers/blog_controller.dart';
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
import 'package:astro_user/features/notification/domain/repositories/notification_repository.dart';
import 'package:astro_user/features/notification/presentation/controllers/notification_controller.dart';
import 'package:astro_user/features/matching/presentation/controllers/matching_controller.dart';
import 'package:astro_user/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:astro_user/features/matching/domain/repositories/matching_repository.dart';
import 'package:astro_user/features/matching/domain/usecases/get_matching_usecase.dart';
import 'package:astro_user/features/matching/presentation/controllers/kundli_controller.dart';
import 'package:astro_user/features/matching/data/repositories/kundli_repository_impl.dart';
import 'package:astro_user/features/matching/domain/repositories/kundli_repository.dart';
import 'package:astro_user/features/matching/domain/usecases/get_birth_chart_usecase.dart';
import 'package:astro_user/features/matching/domain/usecases/create_kundli_usecase.dart';
import 'package:astro_user/features/matching/domain/usecases/get_kundli_list_usecase.dart';
import 'package:astro_user/features/matching/domain/usecases/get_kundli_by_id_usecase.dart';
import 'package:astro_user/features/matching/domain/usecases/update_kundli_usecase.dart';
import 'package:astro_user/features/matching/domain/usecases/delete_kundli_usecase.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Profile Dependencies (Shared)
    Get.lazyPut(() => ProfileRepository(Get.find<ApiClient>()));
    Get.lazyPut(() => ProfileService(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetProfileUseCase(Get.find<ProfileService>()));

    // Matrimony
    Get.lazyPut<MatrimonyRepositoryInterface>(() => MatrimonyRepository(apiClient: Get.find()));
    Get.put<MatrimonyRepositoryInterface>(MatrimonyRepository(apiClient: Get.find()));
    Get.put<MatrimonyServiceInterface>(MatrimonyService(repository: Get.find()));
    Get.put(SaveMatrimonyProfileUseCase(service: Get.find()));
    Get.put(UpdateMatrimonyProfileUseCase(service: Get.find()));
    Get.put(GetMatrimonyProfileUseCase(service: Get.find()));
    Get.put<GetMatrimonyProfileDetailsUseCase>(GetMatrimonyProfileDetailsUseCase(Get.find<MatrimonyServiceInterface>()));
    Get.put<GetMyMatrimonyProfileDetailsUseCase>(GetMyMatrimonyProfileDetailsUseCase(Get.find<MatrimonyServiceInterface>()));
    Get.put<SearchMatrimonyProfilesUseCase>(SearchMatrimonyProfilesUseCase(Get.find<MatrimonyServiceInterface>()));
    Get.put<BlockMatrimonyProfileUseCase>(BlockMatrimonyProfileUseCase(service: Get.find<MatrimonyServiceInterface>()));
    Get.put<ReportMatrimonyProfileUseCase>(ReportMatrimonyProfileUseCase(service: Get.find<MatrimonyServiceInterface>()));
    Get.put<MatrimonyController>(
      MatrimonyController(
        saveMatrimonyProfileUseCase: Get.find<SaveMatrimonyProfileUseCase>(),
        updateMatrimonyProfileUseCase: Get.find<UpdateMatrimonyProfileUseCase>(),
        getMatrimonyProfileUseCase: Get.find<GetMatrimonyProfileUseCase>(),
        getMatrimonyProfileDetailsUseCase: Get.find<GetMatrimonyProfileDetailsUseCase>(),
        getMyMatrimonyProfileDetailsUseCase: Get.find<GetMyMatrimonyProfileDetailsUseCase>(),
        searchMatrimonyProfilesUseCase: Get.find<SearchMatrimonyProfilesUseCase>(),
        blockMatrimonyProfileUseCase: Get.find<BlockMatrimonyProfileUseCase>(),
        reportMatrimonyProfileUseCase: Get.find<ReportMatrimonyProfileUseCase>(),
        getProfileUseCase: Get.find<GetProfileUseCase>(),
      ),
    );


    // Home (Remedy & Blog)
    Get.lazyPut(() => RemedyRepository(Get.find<ApiClient>()));
    Get.lazyPut(() => RemedyService(Get.find<RemedyRepository>()));
    Get.lazyPut(() => GetRemediesUseCase(Get.find<RemedyService>()));
    Get.lazyPut(() => GetRemedyByIdUseCase(Get.find<RemedyService>()));
    Get.lazyPut(() => RemedyController(
      getRemediesUseCase: Get.find<GetRemediesUseCase>(),
      getRemedyByIdUseCase: Get.find<GetRemedyByIdUseCase>(),
    ));

    Get.lazyPut(() => BlogRepository(Get.find<ApiClient>()));
    Get.lazyPut(() => BlogService(Get.find<BlogRepository>()));
    Get.lazyPut(() => GetBlogsUseCase(Get.find<BlogService>()));
    Get.lazyPut(() => GetBlogByIdUseCase(Get.find<BlogService>()));
    Get.lazyPut(() => BlogController(
      getBlogsUseCase: Get.find<GetBlogsUseCase>(),
      getBlogByIdUseCase: Get.find<GetBlogByIdUseCase>(),
    ));

    // Astrologers
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

    // Wallet
    Get.lazyPut<WalletRepositoryInterface>(() => WalletRepository(apiClient: Get.find()));
    Get.lazyPut<WalletServiceInterface>(() => WalletService(repository: Get.find()));
    Get.lazyPut(() => GetWalletUseCase(service: Get.find()));
    Get.lazyPut(() => TopUpWalletUseCase(service: Get.find()));
    Get.lazyPut(() => VerifyTopUpUseCase(service: Get.find()));
    Get.lazyPut(() => GetTransactionsUseCase(service: Get.find()));
    Get.lazyPut(() => WalletController(
      getWalletUseCase: Get.find(),
      topUpWalletUseCase: Get.find(),
      verifyTopUpUseCase: Get.find(),
      getTransactionsUseCase: Get.find(),
      authService: Get.find<AuthServiceInterface>(),
      razorpayService: Get.find<RazorpayService>(),
    ));

    // Notifications
    Get.lazyPut(() => NotificationRepository(apiClient: Get.find()));
    Get.put(NotificationController(repository: Get.find()));

    // Founder words
    Get.lazyPut(() => FounderRepository(Get.find<ApiClient>()));
    Get.lazyPut(() => FounderService(Get.find<FounderRepository>()));
    Get.lazyPut(() => GetFounderWordsUseCase(Get.find<FounderService>()));
    Get.lazyPut(() => FounderController(
      getFounderWordsUseCase: Get.find<GetFounderWordsUseCase>(),
    ));

    // Matching (Kundli Matching)
    Get.lazyPut<MatchingRepository>(() => MatchingRepositoryImpl());
    Get.lazyPut(() => GetMatchingUseCase(repository: Get.find<MatchingRepository>()));
    Get.lazyPut(() => MatchingController(
      getMatchingUseCase: Get.find<GetMatchingUseCase>(),
    ));

    // Kundli (Birth Chart)
    Get.lazyPut<KundliRepository>(() => KundliRepositoryImpl(apiClient: Get.find<ApiClient>()));
    Get.lazyPut(() => GetBirthChartUseCase(repository: Get.find<KundliRepository>()));
    Get.lazyPut(() => CreateKundliUseCase(repository: Get.find<KundliRepository>()));
    Get.lazyPut(() => GetKundliListUseCase(repository: Get.find<KundliRepository>()));
    Get.lazyPut(() => GetKundliByIdUseCase(repository: Get.find<KundliRepository>()));
    Get.lazyPut(() => UpdateKundliUseCase(repository: Get.find<KundliRepository>()));
    Get.lazyPut(() => DeleteKundliUseCase(repository: Get.find<KundliRepository>()));
    Get.lazyPut(() => KundliController(
      getBirthChartUseCase: Get.find<GetBirthChartUseCase>(),
      createKundliUseCase: Get.find<CreateKundliUseCase>(),
      getKundliListUseCase: Get.find<GetKundliListUseCase>(),
      getKundliByIdUseCase: Get.find<GetKundliByIdUseCase>(),
      updateKundliUseCase: Get.find<UpdateKundliUseCase>(),
      deleteKundliUseCase: Get.find<DeleteKundliUseCase>(),
    ));

    // Live Session Dependencies
    LiveBinding().dependencies();
  }
}

