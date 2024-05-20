import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/home_page.dart';
import 'package:plumbata/ui/register/register_page.dart';
import 'package:plumbata/ui/welcome/welcome_page.dart';
import 'package:plumbata/ui/widgets/logo.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _kSplashDuration = const Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    initData();
  }
    initData() async{

      await context.read<UserProvider>().init();
      Future.delayed(_kSplashDuration).then((_) {
        if (mounted) {
          _goNext();
        }
      });
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: LogoWidget(radius: 50, splash: true,)),
    );
  }

  void _goNext() async {
    try {
      UserProvider provider = context.read<UserProvider>();
      var result = await provider.getLoginInfo();

      if (result.isLoggedIn) {
        var hasData = await provider.doesUserCompleteRegister();
        if (hasData) {
          Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (c) => HomePage()), (
              _) => false);
        } else {
          Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(
              builder: (c) => RegisterPage(isComplete: true,)), (_) => false);
        }
      } else {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (c) => WelcomePage()), (_) => false);
      }
    } catch (e) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (c) => WelcomePage()), (_) => false);
    }
  }
}
