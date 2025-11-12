import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'services/database_service.dart';
import 'services/user_data_service.dart';
import 'services/admob_service.dart';
import 'services/purchase_service.dart';
import 'utils/constants.dart';

// Import screens
import 'screens/home_screen.dart';

/// Main entry point for Serendib Guide app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob
  await AdMobService.initialize();

  runApp(const SerendibGuideApp());
}

/// Root application widget
class SerendibGuideApp extends StatelessWidget {
  const SerendibGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // App State Provider
        ChangeNotifierProvider(
          create: (_) => AppStateProvider()..initialize(),
        ),

        // Database Services
        Provider(
          create: (_) => DatabaseService(),
        ),
        Provider(
          create: (_) => UserDataService(),
        ),

        // Monetization Services
        Provider(
          create: (_) => PurchaseService()..initialize(),
        ),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, appState, _) {
          return MaterialApp(
            // App Identity
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // Theme Configuration
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // Localization
            locale: appState.currentLocale,
            supportedLocales: const [
              Locale('en'),
              Locale('si'),
              Locale('ta'),
            ],
            localizationsDelegates: const [
              // AppLocalizations.delegate, // TODO: Uncomment when l10n is generated
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Routes
            home: const HomeScreen(),

            // Named Routes
            // routes: {
            //   '/attraction': (context) => const AttractionDetailScreen(),
            //   '/map': (context) => const MapScreen(),
            //   '/favorites': (context) => const FavoritesScreen(),
            //   '/trips': (context) => const TripPlannerScreen(),
            //   '/info': (context) => const InfoScreen(),
            //   '/settings': (context) => const SettingsScreen(),
            //   '/premium': (context) => const PremiumScreen(),
            // },
          );
        },
      ),
    );
  }

  /// Build light theme
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.deepOceanBlue,
        brightness: Brightness.light,
        primary: AppConstants.deepOceanBlue,
        secondary: AppConstants.tropicalGreen,
        tertiary: AppConstants.sunsetOrange,
        error: AppConstants.errorRed,
        background: AppConstants.cleanWhite,
        surface: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w300),
        displayMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400),
        displaySmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400),
        headlineMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400),
        headlineSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
        titleLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.deepOceanBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[200],
        selectedColor: AppConstants.deepOceanBlue,
        labelStyle: const TextStyle(fontFamily: 'Roboto'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConstants.sunsetOrange,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Build dark theme
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.deepOceanBlue,
        brightness: Brightness.dark,
        primary: AppConstants.deepOceanBlue,
        secondary: AppConstants.tropicalGreen,
        tertiary: AppConstants.sunsetOrange,
        error: AppConstants.errorRed,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w300),
        displayMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400),
        displaySmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400),
        headlineMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400),
        headlineSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
        titleLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.deepOceanBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
      ),
    );
  }
}
