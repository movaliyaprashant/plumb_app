import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/icons.dart';

import 'logo.dart';

class MainLayout extends StatelessWidget {
  MainLayout({
    required this.child,
    this.showBackArrow = true,
    this.showLogo = false,
    this.title,
    this.logoRadius,
  });

  final Widget child;
  final bool showBackArrow;
  final bool showLogo;
  final String? title;
  final double? logoRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            kShadowImage,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color.fromARGB(200, 246, 245, 255),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                          border: Border.all(color: Colors.white, width: 2)),
                      child:  showLogo ? null : child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  if (showLogo)
                    LogoWidget(
                      radius: logoRadius ?? 65,
                    ),
                  if (showLogo) Expanded(child: child)
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (showBackArrow)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Container(
                        height: 42,
                        width: 42,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(
                          Icons.arrow_back_ios_sharp,
                          color: Colors.black,
                          size: 20,
                        )),
                  ),
                const SizedBox(width: 16),
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                        color: kLightGreyBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )
              ],
            ),
          )),
        ),
      ],
    ));
  }
}
