import 'package:get/get.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/intro_screen.dart';
import '../features/auth/screens/arrival_screen.dart';
import '../features/auth/screens/name_screen.dart';
import '../features/auth/screens/gender_screen.dart';
import '../features/auth/screens/birth_details_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/language/screens/language_selection_screen.dart';
import '../features/home/screens/home_screen.dart';
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
  static String getHomeRoute() => AppRoutes.home;
  static String getLanguageSelectionRoute() => AppRoutes.languageSelection;
  static String getDashboardRoute() => AppRoutes.dashboard;

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
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
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
    ),
  ];
}
