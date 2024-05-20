import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plumbata/utils/icons.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({this.radius = 65, this.splash = false});
  final bool splash;
  /// Logo radius.
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: splash ? radius * 5 : radius * 2,
      width: splash ? radius * 5 : radius * 2,
      decoration: splash ? BoxDecoration(
        borderRadius: BorderRadius.circular(32),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: const Offset(6, 13),
              blurRadius: 26,
              color: Color(0xffD3D1D8).withOpacity(0.38),
              spreadRadius: 1.0,
            ),
          ]): BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 0),
              blurRadius: 26,
              color: Color(0xffD3D1D8).withOpacity(0.38),
              spreadRadius: 1.0,
            ),
          ]),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(splash ? 32 : 10),
          child: Image.asset(splash ? kSplashLogoIcon : kLogoIcon)),
    );
  }
}
