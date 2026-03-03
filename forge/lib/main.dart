import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Core
import 'core/theme/app_theme.dart';

// Providers (State Management)
import 'providers/auth_provider.dart' as app_auth;
import 'providers/user_provider.dart';
import 'providers/job_provider.dart';

// Screens - Auth
import 'screens/auth/splash_screen.dart';
import 'screens/auth/phone_login_screen.dart';
import 'screens/auth/otp_verify_screen.dart';
import 'screens/auth/role_select_screen.dart';

// Screens - Provider
import 'screens/provider/provider_setup_screen.dart';
import 'screens/provider/provider_home_screen.dart';

// Screens - Client
import 'screens/client/client_setup_screen.dart';
import 'screens/client/client_home_screen.dart';
import 'screens/client/provider_detail_screen.dart';
import 'screens/client/rate_provider_screen.dart';

// Screens - Chat
import 'screens/chat/chat_screen.dart';
import 'screens/chat/chat_list_screen.dart';

/// App entry point.
/// Initializes Firebase and sets up Provider state management.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ForgeApp());
}

class ForgeApp extends StatelessWidget {
  const ForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth state provider
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),

        // User profile provider
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // Job workflow provider
        ChangeNotifierProvider(create: (_) => JobProvider()),
      ],
      child: MaterialApp(
        title: 'Forge',
        debugShowCheckedModeBanner: false,

        // ── Theme ───────────────────────────────────────
        theme: AppTheme.lightTheme,

        // ── Initial Route ───────────────────────────────
        initialRoute: '/',

        // ── Named Routes ────────────────────────────────
        routes: {
          // Auth flow
          '/': (context) => const SplashScreen(),
          '/login': (context) => const PhoneLoginScreen(),
          '/otp-verify': (context) => const OtpVerifyScreen(),
          '/role-select': (context) => const RoleSelectScreen(),

          // Provider flow
          '/provider-setup': (context) => const ProviderSetupScreen(),
          '/provider-home': (context) => const ProviderHomeScreen(),

          // Client flow
          '/client-setup': (context) => const ClientSetupScreen(),
          '/client-home': (context) => const ClientHomeScreen(),
          '/provider-detail': (context) => const ProviderDetailScreen(),
          '/rate-provider': (context) => const RateProviderScreen(),

          // Chat
          '/chat': (context) => const ChatScreen(),
          '/chat-list': (context) => const ChatListScreen(),
        },
      ),
    );
  }
}
