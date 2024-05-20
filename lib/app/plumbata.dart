import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:plumbata/app/routes.dart';
import 'package:plumbata/generated/l10n.dart';
import 'package:plumbata/net/api_executor.dart';
import 'package:plumbata/providers/locale/locale.dart';
import 'package:plumbata/providers/theme.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/repo/app_repo.dart';
import 'package:plumbata/repo/app_repo_impl.dart';
import 'package:plumbata/repo/auth/auth_repo.dart';
import 'package:plumbata/ui/widgets/network_sensitive.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class PlumbataApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppRepo>(
            create: (context) => AppRepoImpl(
                GetIt.instance<ApiExecutor>(), GetIt.instance<AuthRepo>())),


        ChangeNotifierProvider(
            create: (context) => UserProvider(
                context.read<AppRepo>(), GetIt.instance<AuthRepo>())),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, theme, locale, child) {
          var themeProvider = Provider.of<ThemeProvider>(context);
          return ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            child: GetMaterialApp(
              title: 'Plumbata',
              navigatorKey: rootNavigatorKey,
              routes: Routes.routes,
              initialRoute: '/',
              textDirection:
                  locale.selectedLanguage.textDirection ?? TextDirection.ltr,
              locale: locale.selectedLocal,
              theme: themeProvider.getThemeData(context),
              //darkTheme: theme.darkTheme(context),
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                return ResponsiveBreakpoints.builder(
                  breakpoints: [
                    const Breakpoint(start: 0, end: 500, name: PHONE),
                    const Breakpoint(
                        start: 501, end: double.infinity, name: TABLET),
                  ],
                  child: StreamProvider<ConnectivityResult?>(
                    create: (ctx) => Connectivity().onConnectivityChanged,
                    initialData: null,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                      child: NetworkSensitive(child: child!),
                    ),
                  ),
                );
              },
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                // SfGlobalLocalizations.delegate,
                S.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
            ),
          );
        },
      ),
    );
  }
}
