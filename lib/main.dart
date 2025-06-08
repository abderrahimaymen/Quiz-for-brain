import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/theme_provider.dart'; // Import ThemeProvider
import 'screens/home_screen.dart';
import 'utils/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // Use MultiProvider
      providers: [
        ChangeNotifierProvider(create: (context) => QuizProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()), // Add ThemeProvider
      ],
      child: Consumer<ThemeProvider>( // Consumer to access ThemeProvider
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'BrainSpark Quiz',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode, // Use themeMode from provider
            theme: ThemeData( // Light Theme
              brightness: Brightness.light,
              primaryColor: AppColors.primaryLight,
              scaffoldBackgroundColor: AppColors.backgroundLight,
              fontFamily: 'Poppins',
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryLight,
                secondary: AppColors.secondaryLight,
                surface: AppColors.surfaceLight,
                background: AppColors.backgroundLight,
                error: AppColors.incorrectLight,
                onPrimary: AppColors.onPrimaryLight,
                onSecondary: AppColors.onSecondaryLight,
                onSurface: AppColors.onSurfaceLight,
                onBackground: AppColors.onBackgroundLight,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: AppColors.primaryLight,
                iconTheme: IconThemeData(color: AppColors.onPrimaryLight),
                titleTextStyle: TextStyle(
                  color: AppColors.onPrimaryLight,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.onPrimaryLight,
                  backgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, fontFamily: 'Poppins')
                ),
              ),
              cardTheme: CardTheme(
                elevation: 3.0,
                color: AppColors.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.surfaceLight.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.7)),
                prefixIconColor: AppColors.primaryLight,
              ),
              textTheme: const TextTheme(
                headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.onBackgroundLight),
                titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onBackgroundLight),
                bodyLarge: TextStyle(fontSize: 16, color: AppColors.onBackgroundLight),
                bodyMedium: TextStyle(fontSize: 14, color: AppColors.textLight),
              )
            ),
            darkTheme: ThemeData( // Dark Theme
              brightness: Brightness.dark,
              primaryColor: AppColors.primaryDark,
              scaffoldBackgroundColor: AppColors.backgroundDark,
              fontFamily: 'Poppins',
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryDark,
                secondary: AppColors.secondaryDark,
                surface: AppColors.surfaceDark,
                background: AppColors.backgroundDark,
                error: AppColors.incorrectDark,
                onPrimary: AppColors.onPrimaryDark,
                onSecondary: AppColors.onSecondaryDark,
                onSurface: AppColors.onSurfaceDark,
                onBackground: AppColors.onBackgroundDark,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: AppColors.surfaceDark, // Darker app bar for contrast
                iconTheme: IconThemeData(color: AppColors.onSurfaceDark),
                titleTextStyle: TextStyle(
                  color: AppColors.onSurfaceDark,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.onPrimaryDark,
                  backgroundColor: AppColors.primaryDark,
                   shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, fontFamily: 'Poppins')
                ),
              ),
              cardTheme: CardTheme(
                elevation: 1.0, // Subtle elevation for dark mode
                color: AppColors.surfaceDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.surfaceDark.withOpacity(0.8),
                 border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryDark.withOpacity(0.5)),
                ),
                hintStyle: TextStyle(color: AppColors.textDark.withOpacity(0.7)),
                prefixIconColor: AppColors.secondaryDark,
              ),
              textTheme: const TextTheme(
                headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.onBackgroundDark),
                titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onBackgroundDark),
                bodyLarge: TextStyle(fontSize: 16, color: AppColors.onBackgroundDark),
                bodyMedium: TextStyle(fontSize: 14, color: AppColors.textDark),
              )
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}