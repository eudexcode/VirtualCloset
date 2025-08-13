import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:closet_virtual/theme/app_colors.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';
import 'localization/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(
    fileName: ".env",
  ); //Cargar las variables de entorno desde el archivo .env
  await Supabase.initialize(
    // Inicializar Supabase con las variables de entorno
    url: dotenv.env['SUPABASE_URL']!, // URL de mi proyecto de Supabase
    anonKey: dotenv
        .env['SUPABASE_ANON_KEY']!, 
    storageOptions: const StorageClientOptions(
      retryAttempts: 3,
    ),// Clave anónima de mi proyecto de Supabase
  );
  runApp(const VirtualCloset()); // Ejecutar la aplicación Flutter
}

class VirtualCloset extends StatefulWidget {
  const VirtualCloset({super.key});

  @override
  State<VirtualCloset> createState() => _VirtualClosetState();
}

class _VirtualClosetState extends State<VirtualCloset> {
  bool _isDarkMode = false;
  String _currentLanguage = 'Español';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  // Cargar configuración del usuario al inicializar
  Future<void> _loadUserSettings() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('user_settings')
            .select('dark_mode_enabled, language, theme')
            .eq('user_id', user.id)
            .single();
        
        setState(() {
          _isDarkMode = response['dark_mode_enabled'] ?? false;
          _currentLanguage = response['language'] ?? 'Español';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para cambiar el tema
  void toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  // Método para cambiar el idioma
  void changeLanguage(String language) {
    setState(() {
      _currentLanguage = language;
    });
    print('Language changed to: $language');
  }

  // Convertir idioma a Locale
  Locale _getLocale() {
    switch (_currentLanguage) {
      case 'English':
        return const Locale('en', 'US');
      case 'Français':
        return const Locale('fr', 'FR');
      case 'Español':
      default:
        return const Locale('es', 'ES');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        title: 'Virtual Closet',
        theme: _getLightTheme(),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Virtual Closet',
      theme: _isDarkMode ? _getDarkTheme() : _getLightTheme(),
      locale: _getLocale(),
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // English
        Locale('fr', 'FR'), // Français
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: AuthGate(
        onThemeChanged: toggleTheme,
        onLanguageChanged: changeLanguage,
      ),
    );
  }

  ThemeData _getLightTheme() {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.platinum,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.tealMist,
        primary: AppColors.tealMist,
        secondary: AppColors.thistle,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.tealMist,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkText),
        bodyMedium: TextStyle(color: AppColors.darkText),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.liberty,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppColors.platinum,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  ThemeData _getDarkTheme() {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.tealMist,
        primary: AppColors.tealMist,
        secondary: AppColors.thistle,
        brightness: Brightness.dark,
        surface: const Color(0xFF2D2D2D),
        background: const Color(0xFF1A1A1A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.tealMist,
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFF2D2D2D),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D2D),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final Function(String) onLanguageChanged;
  
  const AuthGate({
    super.key,
    required this.onThemeChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return session == null 
            ? const LoginScreen() 
            : HomeScreen(
                onThemeChanged: onThemeChanged,
                onLanguageChanged: onLanguageChanged,
              );
      },
    );
  }
}