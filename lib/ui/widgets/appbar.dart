import 'package:flutter/material.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/fonts.dart';

import 'buttons.dart';

const double kCustomToolbarHeight = 90;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double kAppBarPadding = 20.0;

  CustomAppBar(
      {required this.title,
      this.showBackButton = true,
      this.actionIcon,
      this.onActionItemPressed});

  final bool showBackButton;
  final String title;
  final IconData? actionIcon;
  final VoidCallback? onActionItemPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: kAppBarPadding, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IgnorePointer(
                ignoring: !showBackButton,
                child: Opacity(
                  opacity: showBackButton ? 1 : 0,
                  child: PrimaryIconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    iconData: Icons.arrow_back_ios_rounded,
                  ),
                ),
              ),
              Text(
                title ?? '',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    ?.copyWith(fontSize: 18),
              ),
              onActionItemPressed != null && actionIcon != null
                  ? IgnorePointer(
                      ignoring: actionIcon == null,
                      child: Opacity(
                        opacity: actionIcon != null ? 1 : 0,
                        child: PrimaryIconButton(
                          onPressed: onActionItemPressed!,
                          iconData: actionIcon!,
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kCustomToolbarHeight);
}

const double kContractsToolbarHeight = 100;

class ContractsAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double kAppBarPadding = 20.0;

  ContractsAppBar(
      {required this.title,
      this.showBackButton = true,
      this.actionIcon,
      this.onActionItemPressed});

  final bool showBackButton;
  final String title;
  final IconData? actionIcon;
  final VoidCallback? onActionItemPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kContractsToolbarHeight,
      color: AppColors.lightPrimaryColor,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: kAppBarPadding, vertical: 0),
          child: GestureDetector(
            onTap: onActionItemPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: kAvenirMediumFont,
                        ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kContractsToolbarHeight);
}

const double kGeneralToolbarHeight = 90;

class GeneralAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double kAppBarPadding = 20.0;

  GeneralAppBar(
      {required this.title, this.backBtn = false, this.onBack, this.actions});

  final String title;
  final bool? backBtn;
  final Function? onBack;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {

    if(backBtn == false && actions == null ){
      return Container(
        height: kContractsToolbarHeight,
        color: AppColors.lightPrimaryColor,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: kAppBarPadding, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Center the title with expanded container
                  Expanded(
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.5,
                      child: Center(
                        child: Text(
                          title ?? '',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: kAvenirMediumFont,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: kContractsToolbarHeight,
      color: AppColors.lightPrimaryColor,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: kAppBarPadding, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                backBtn == true
                    ? Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (onBack != null) {
                            onBack!();
                          }
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                    : SizedBox(),
                // Center the title with expanded container
                Expanded(
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.5,
                    child: Center(
                      child: Text(
                        title ?? '',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: kAvenirMediumFont,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.2,
                  child: actions ?? SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
    @override
  Size get preferredSize => Size.fromHeight(kGeneralToolbarHeight);
}
