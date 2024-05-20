
import 'package:plumbata/ui/home/home_page.dart';
import 'package:plumbata/ui/splash/splash_screen.dart';
import 'package:plumbata/ui/welcome/welcome_page.dart';

/// Used by the Flutter routing system
class Routes {
  static final routes = {
    '/': (context) => SplashScreen(),
    '/welcome': (context) => WelcomePage(),
    '/home': (context) => HomePage(),
  };
}
