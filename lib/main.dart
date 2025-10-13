import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/admin/screens/admin_dashboard.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/signin_screen.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/wallet/screens/wallet_screen.dart';
import 'features/wallet/screens/fund_wallet_screen.dart';
import 'features/raffles/screens/raffles_list_screen.dart';
import 'features/raffles/screens/raffle_detail_screen.dart';
import 'shared/widgets/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return MaterialApp(
      title: 'Football Raffle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
        ),
      ),
      home: authState.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => const SignupScreen(),
        data: (user) =>
            user == null ? const SignupScreen() : const HomeScreen(),
      ),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/signin': (context) => const SigninScreen(),
        '/home': (context) => const HomeScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/fund-wallet': (context) => const FundWalletScreen(),
        '/raffles': (context) => const RafflesListScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/raffle/') ?? false) {
          final raffleId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => RaffleDetailScreen(raffleId: raffleId),
          );
        }
        return null;
      },
    );
  }
}
