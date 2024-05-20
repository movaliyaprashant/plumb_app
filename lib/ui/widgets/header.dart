import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plumbata/ui/settings/settings_page.dart';
import 'package:plumbata/utils/icons.dart';


class AppHeader extends StatelessWidget {
  const AppHeader({required this.title, this.showSettingsIcon = true});

  final String title;
  final bool showSettingsIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        color: Color(0xff6D48F5),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -80,
            child: Center(
              child: Container(
                width: 202,
                height: 202,
                child: SvgPicture.asset(
                  kCircleIcon,
                  fit: BoxFit.cover,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
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
                      const SizedBox(width: 24),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                              color: Color(0xffB6A3FA),
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      if (showSettingsIcon)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SettingsPage()));
                          },
                          child: Container(
                              width: 30,
                              height: 30,
                              child: SvgPicture.asset(kSettingsIcon)),
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
