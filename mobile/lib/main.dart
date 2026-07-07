import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AIReceptionistApp()));
}

class AIReceptionistApp extends StatelessWidget {
  const AIReceptionistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyElena',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    await _authService.init();
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _authService,
      child: Consumer(
        builder: (context, ref, _) {
          final auth = ref.watch(authServiceProvider);
          if (auth.isAuthenticated) {
            return const DashboardScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  return AuthService();
});
