import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/wallet_manager.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<User?>>((ref) {
      return AuthViewModel();
    });

class AuthViewModel extends StateNotifier<AsyncValue<User?>> {
  AuthViewModel() : super(const AsyncValue.loading()) {
    _init();
  }

  final _auth = FirebaseAuth.instance;
  final _walletManager = WalletManager();

  void _init() {
    _auth.authStateChanges().listen((user) {
      state = AsyncValue.data(user);
    });
  }

  // Sign up with email
  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Auto-create wallet
      await _walletManager.createWallet();

      state = AsyncValue.data(credential.user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Sign in with email
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if wallet exists, restore if needed
      final hasWallet = await _walletManager.hasWallet();
      if (!hasWallet) {
        await _walletManager.restoreWallet();
      }

      state = AsyncValue.data(credential.user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    state = const AsyncValue.data(null);
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
