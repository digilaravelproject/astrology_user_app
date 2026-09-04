import 'package:astro_user/features/astrologers/presentation/screens/astrologer_detail_screen.dart';
import 'package:astro_user/features/matching/presentation/bindings/kundli_binding.dart';
import 'package:astro_user/features/kundli/kundli_screen.dart';
import 'package:astro_user/features/panchang/panchang_screen.dart';
import 'package:astro_user/features/panchang/presentation/bindings/panchang_binding.dart';
import 'package:astro_user/features/profile/presentation/bindings/profile_binding.dart';
import 'package:astro_user/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:astro_user/features/profile/presentation/screens/following_screen.dart';
import 'package:astro_user/features/profile/presentation/screens/payment_policy_screen.dart';
import 'package:astro_user/features/profile/presentation/screens/subscription_details_screen.dart';
import 'package:astro_user/features/profile/presentation/screens/subscription_screen.dart';
import 'package:astro_user/features/profile/presentation/screens/subscription_success_screen.dart';
import 'package:get/get.dart';
import 'package:astro_user/features/auth/presentation/screens/login_screen.dart';
import 'package:astro_user/features/auth/presentation/screens/otp_screen.dart';
import 'package:astro_user/features/auth/presentation/screens/intro_screen.dart';
import 'package:astro_user/features/auth/presentation/screens/arrival_screen.dart';
import 'package:astro_user/features/auth/presentation/screens/name_screen.dart';
import 'package:astro_user/features/auth/presentation/screens/gender_screen.dart';
import 'package:astro_user/features/auth/presentation/screens/birth_details_screen.dart';
import 'package:astro_user/features/matching/presentation/screens/kundali_matching_screen.dart';
import 'package:astro_user/features/splash/presentation/screens/splash_screen.dart';
import 'package:astro_user/features/splash/presentation/screens/permission_screen.dart';
import 'package:astro_user/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:astro_user/features/auth/presentation/screens/registration_success_screen.dart';
import 'package:astro_user/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:astro_user/features/language/presentation/screens/language_selection_screen.dart';
import 'package:astro_user/features/home/presentation/screens/home_screen.dart';
import 'package:astro_user/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:astro_user/features/wallet/presentation/screens/payment_success_screen.dart';
import 'package:astro_user/features/matrimony/presentation/screens/matrimony_screen.dart';
import 'package:astro_user/features/matrimony/presentation/screens/my_matrimony_profile_screen.dart';
import 'package:astro_user/features/remedy/presentation/screens/remedy_detail_screen.dart';
import 'package:astro_user/features/call/presentation/screens/call_list_screen.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_list_screen.dart';
import 'package:astro_user/features/home/presentation/bindings/home_binding.dart';
import 'package:astro_user/features/wallet/presentation/bindings/wallet_binding.dart';
import 'package:astro_user/features/matrimony/presentation/bindings/matrimony_binding.dart';
import 'package:astro_user/features/dashboard/presentation/bindings/dashboard_binding.dart';
import 'package:astro_user/features/call/presentation/bindings/call_binding.dart';
import 'package:astro_user/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_user/features/support/presentation/bindings/support_binding.dart';
import 'package:astro_user/features/profile/presentation/screens/faq_screen.dart';
import 'package:astro_user/features/profile/presentation/screens/privacy_policy_screen.dart';
import 'package:astro_user/features/profile/presentation/screens/terms_and_conditions_screen.dart';
import 'package:astro_user/features/notification/presentation/screens/notification_screen.dart';
import 'package:astro_user/features/notification/presentation/bindings/notification_binding.dart';
import 'app_routes.dart';

class RouteHelper {
  static String getSplashRoute() => AppRoutes.splash;
  static String getPermissionRoute() => AppRoutes.permission;
  static String getLoginRoute() => AppRoutes.login;
  static String getOtpRoute() => AppRoutes.otp;
  static String getIntroRoute() => AppRoutes.intro;
  static String getArrivalRoute() => AppRoutes.arrival;
  static String getNameSetupRoute() => AppRoutes.nameSetup;
  static String getGenderSetupRoute() => AppRoutes.genderSetup;
  static String getBirthDetailsRoute() => AppRoutes.birthDetails;
  static String getCompleteProfileRoute() => AppRoutes.completeProfile;
  static String getRegistrationSuccessRoute() => AppRoutes.registrationSuccess;
  static String getHomeRoute() => AppRoutes.home;
  static String getLanguageSelectionRoute() => AppRoutes.languageSelection;
  static String getDashboardRoute() => AppRoutes.dashboard;
  static String getWalletRoute() => AppRoutes.wallet;
  static String getMatrimonyRoute() => AppRoutes.matrimony;
  static String getMyMatrimonyProfileRoute() => AppRoutes.myMatrimonyProfile;
  static String getRemedyDetailRoute(int id) => '${AppRoutes.remedyDetail}/$id';
  static String getCallListRoute() => AppRoutes.callList;
  static String getChatListRoute() => AppRoutes.chatList;
  static String getEditProfileRoute() => AppRoutes.editProfile;
  static String getPaymentSuccessRoute() => AppRoutes.paymentSuccess;
  static String getNotificationRoute() => AppRoutes.notification;


  static String getPanchangRoute() => AppRoutes.panchangScreen;
  static String getKundaliRoute() => AppRoutes.kundaliScreen;
  static String getKundaliMatchingRoute() => AppRoutes.kundaliMatchingScreen;

  static List<GetPage> routes = [
    GetPage(
      name: AppRoutes.notification,
      page: () => const NotificationScreen(),
      binding: NotificationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.permission,
      page: () => const PermissionScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.intro,
      page: () => const IntroScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      binding: ProfileBinding(),
      page: () => const EditProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.arrival,
      page: () => const ArrivalScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.nameSetup,
      page: () => const NameSetupScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.genderSetup,
      page: () => const GenderSetupScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.birthDetails,
      page: () => const BirthDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.completeProfile,
      page: () => const CompleteProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.registrationSuccess,
      page: () => const RegistrationSuccessScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.languageSelection,
      page: () => const LanguageSelectionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      transition: Transition.fadeIn,
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletScreen(),
      transition: Transition.rightToLeft,
      binding: WalletBinding(),
    ),
    GetPage(
      name: AppRoutes.matrimony,
      page: () => const MatrimonyScreen(),
      transition: Transition.rightToLeft,
      binding: MatrimonyBinding(),
    ),
    GetPage(
      name: AppRoutes.myMatrimonyProfile,
      page: () => const MyMatrimonyProfileScreen(),
      transition: Transition.rightToLeft,
      binding: MatrimonyBinding(),
    ),
    GetPage(
      name: AppRoutes.remedyDetail,
      page: () => RemedyDetailScreen(remedyId: 0, imageUrl: ''),
      transition: Transition.rightToLeft,
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.callList,
      page: () => const CallListScreen(),
      transition: Transition.rightToLeft,
      binding: CallBinding(),
    ),
    GetPage(
      name: AppRoutes.chatList,
      page: () => const ChatListScreen(),
      transition: Transition.rightToLeft,
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.followingScreen,
      page: () => const FollowingScreen(),
      transition: Transition.rightToLeft,
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.subscriptionScreen,
      page: () => const SubscriptionScreen(),
      transition: Transition.rightToLeft,
      binding: ProfileBinding()
    ),
    GetPage(
        name: AppRoutes.subscriptionDetailScreen,
        page: () => SubscriptionDetailScreen(planId: 0),
        transition: Transition.rightToLeft,
        binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.faq,
      page: () => const FaqScreen(),
      transition: Transition.rightToLeft,
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      transition: Transition.rightToLeft,
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentPolicy,
      page: () => const PaymentPolicyScreen(),
      transition: Transition.rightToLeft,
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.termsAndConditions,
      page: () => const TermsAndConditionsScreen(),
      transition: Transition.rightToLeft,
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentSuccess,
      page: () => const PaymentSuccessScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.subscriptionSuccess,
      page: () => const SubscriptionSuccessScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.panchangScreen,
      page: () => const PanchangScreen(),
      transition: Transition.fadeIn,
      binding: PanchangBinding(),
    ),

    GetPage(
      name: AppRoutes.kundaliScreen,
      page: () {
        final args = Get.arguments is Map<String, dynamic> ? Get.arguments as Map<String, dynamic> : {};
        return KundliScreen(
          fullName: args['fullName'] ?? args['name'] ?? '',
          gender: args['gender'] ?? '',
          dob: args['dob'] ?? '',
          tob: args['tob'] ?? args['time'] ?? '',
          place: args['place'] ?? '',
          latitude: (args['latitude'] is num) ? (args['latitude'] as num).toDouble() : (double.tryParse(args['latitude']?.toString() ?? '') ?? 0.0),
          longitude: (args['longitude'] is num) ? (args['longitude'] as num).toDouble() : (double.tryParse(args['longitude']?.toString() ?? '') ?? 0.0),
        );
      },
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.kundaliMatchingScreen,
      page: () => const KundliMatchScreen(),
      transition: Transition.fadeIn,
      binding: KundliBinding(),
    ),
  ];
}
