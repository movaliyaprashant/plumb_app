import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/fonts.dart';
import 'package:plumbata/utils/icons.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool enabled;
  final Color textColor;
  final bool isLoading;
  final Color bgColor;
  final Color iconColor;
  final String? iconPath;

  PrimaryButton(
    this.text, {
    required this.onPressed,
    this.bgColor = AppColors.lightPrimaryColor,
    this.enabled = true,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.isLoading = false,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 54,
      padding: EdgeInsets.zero,
      color: kPurpleBlue,
      borderRadius: BorderRadius.circular(16.0),
      disabledColor: Theme.of(context).disabledColor,
      onPressed: enabled && !isLoading ? onPressed : null,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconPath != null)
                    Flexible(
                      child: SvgPicture.asset(
                        iconPath!,
                        color: iconColor ?? textColor,
                      ),
                    ),
                  if (iconPath != null) const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontFamily: kOpenSansFont,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class SimpleOutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool enabled;
  final bool isLoading;
  final String? iconPath;
  final Color? bgColor;
  final TextStyle? textStyle;

  SimpleOutlinedButton(this.text,
      {required this.onPressed,
      this.enabled = true,
      this.isLoading = false,
      this.bgColor,
      this.textStyle,
      this.iconPath});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 52,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(15.0),
      disabledColor: AppColors.lightBorderColor,
      onPressed: enabled && !isLoading ? onPressed : null,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Color(0xffeeeeee)),
            color: bgColor ?? Colors.white),
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconPath != null)
                    Flexible(
                      child: SvgPicture.asset(
                        iconPath!,
                      ),
                    ),
                  if (iconPath != null) const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: textStyle ?? TextStyle(
                        color: Color(0xff9da4bb),
                        fontSize: 16,
                        fontFamily: kOpenSansFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class PrimaryIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData iconData;
  final bool enabled;
  final Color? bgColor;
  final Color? iconColor;

  PrimaryIconButton(
      {required this.onPressed,
      required this.iconData,
      this.bgColor,
      this.enabled = true,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 42,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(15.0), boxShadow: [
        BoxShadow(
          offset: Offset(0, 3),
          color: Theme.of(context).shadowColor,
          blurRadius: 5,
          spreadRadius: 1,
        )
      ]),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(15.0),
        color: bgColor ?? Theme.of(context).cardColor,
        onPressed: enabled ? onPressed : null,
        child: Icon(
          iconData,
          color: iconColor ?? Theme.of(context).textTheme.headline6?.color,
          size: 20,
        ),
      ),
    );
  }
}

class OutlinedIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData iconData;
  final bool enabled;
  final Color? color;

  OutlinedIconButton(
      {required this.iconData,
      this.onPressed,
      this.enabled = true,
      this.color});

  @override
  Widget build(BuildContext context) {
    Color mainColor = color ?? Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
          width: 52,
          height: 52,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              border: Border.all(color: mainColor.withOpacity(0.3), width: 1.5),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(
            iconData,
            color: mainColor,
          )),
    );
  }
}

class RedeemButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool enabled;
  final Color textColor;
  final bool isLoading;
  final Color? bgColor;
  final Color? iconColor;
  final String iconPath;

  RedeemButton(
    this.text, {
    required this.onPressed,
    this.bgColor,
    this.enabled = true,
    this.textColor = Colors.white,
    this.iconColor,
    this.isLoading = false,
    this.iconPath = kPhoneNfcIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 24,
      child: CupertinoButton(
        minSize: 20,
        padding: EdgeInsets.zero,
        color: kPurpleBlue,
        borderRadius: BorderRadius.circular(6),
        disabledColor: Theme.of(context).disabledColor,
        onPressed: enabled && !isLoading ? onPressed : null,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (iconPath != null)
                      Flexible(
                        child: Container(
                          width: 14,
                          height: 14.2,
                          child: SvgPicture.asset(
                            iconPath,
                            color: iconColor ?? textColor,
                          ),
                        ),
                      ),
                    if (iconPath != null) const SizedBox(width: 4),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 10,
                          fontFamily: kOpenSansFont,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
