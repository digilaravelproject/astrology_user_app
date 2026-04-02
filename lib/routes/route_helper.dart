import 'package:astro_user/features/astrologers/screens/astrologer_detail_screen.dart';
import 'package:astro_user/features/profile/bindings/profile_binding.dart';
import 'package:astro_user/features/profile/screens/edit_profile_screen.dart';
import 'package:astro_user/features/profile/screens/following_screen.dart';
import 'package:astro_user/features/profile/screens/payment_policy_screen.dart';
import 'package:astro_user/features/profile/screens/subscription_details_screen.dart';
import 'package:astro_user/features/profile/screens/subscription_screen.dart';
import 'package:get/get.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/intro_screen.dart';
import '../features/auth/screens/arrival_screen.dart';
import '../features/auth/screens/name_screen.dart';
import '../features/auth/screens/gender_screen.dart';
import '../features/auth/screens/birth_details_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/auth/screens/complete_profile_screen.dart';
import '../features/auth/screens/registration_success_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/language/screens/language_selection_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/wallet/screens/wallet_screen.dart';
import '../features/matrimony/screens/matrimony_screen.dart';
import '../features/remedy/screens/remedy_detail_screen.dart';
import '../features/call/screens/call_list_screen.dart';
import '../features/chat/screens/chat_list_screen.dart';
import '../features/home/bindings/home_binding.dart';
import '../features/wallet/bindings/wallet_binding.dart';
import '../features/matrimony/bindings/matrimony_binding.dart';
import '../features/dashboard/bindings/dashboard_binding.dart';
import '../features/call/bindings/call_binding.dart';
import '../features/chat/bindings/chat_binding.dart';
import '../features/support/presentation/bindings/support_binding.dart';
import '../features/profile/screens/faq_screen.dart';
import '../features/profile/screens/privacy_policy_screen.dart';
import '../features/profile/screens/terms_and_conditions_screen.dart';
import 'app_routes.dart';

class RouteHelper {
  static String getSplashRoute() => AppRoutes.splash;
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
  static String getRemedyDetailRoute(int id) => '${AppRoutes.remedyDetail}/$id';
  static String getCallListRoute() => AppRoutes.callList;
  static String getChatListRoute() => AppRoutes.chatList;
  static String getEditProfileRoute() => AppRoutes.editProfile;

  static List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
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
  ];
}
