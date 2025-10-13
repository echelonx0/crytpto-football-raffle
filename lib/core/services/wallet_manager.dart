import 'dart:math';

import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_wallet.dart';
import '../utils/encryption_helper.dart';
import 'contract_service.dart';

enum WalletType {
  generated, // Auto-generated
  imported, // Private key import
  walletConnect, // WalletConnect
}

class WalletManager {
  static final WalletManager _instance = WalletManager._internal();
  factory WalletManager() => _instance;
  WalletManager._internal();

  final _storage = const FlutterSecureStorage();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  static const _privateKeyKey = 'wallet_private_key';
  static const _addressKey = 'wallet_address';

  // Add this method to WalletManager class
  Future<void> _mintInitialTokens(String walletAddress) async {
    try {
      // Call your contract's faucet function
      final contractService = ContractService();
      await contractService.initialize();

      // Mint 1000 RTKN for new users
      await contractService.claimFaucet();

      print('Auto-minted 1000 RTKN for new wallet');
    } catch (e) {
      print('⚠️ Auto-mint failed (user can claim manually): $e');
    }
  }

  // Update createWallet method
  Future<UserWallet> createWallet() async {
    try {
      final credentials = EthPrivateKey.createRandom(Random.secure());
      final address = credentials.address;
      final privateKey = credentials.privateKey;

      final encryptedKey = await EncryptionHelper.encryptData(
        bytesToHex(privateKey),
      );

      await _storage.write(key: _privateKeyKey, value: encryptedKey);
      await _storage.write(key: _addressKey, value: address.hexEip55);

      await _backupToFirestore(address.hexEip55, encryptedKey);

      // ✅ Auto-mint tokens for new wallet
      await _mintInitialTokens(address.hexEip55);

      return UserWallet(
        address: address.hexEip55,
        balance: '0',
        rtknBalance: '1000', // Show initial balance
      );
    } catch (e) {
      throw Exception('Failed to create wallet: $e');
    }
  }

  // Get existing wallet
  Future<UserWallet?> getWallet() async {
    try {
      final address = await _storage.read(key: _addressKey);
      if (address == null) return null;

      return UserWallet(address: address, balance: '0', rtknBalance: '0');
    } catch (e) {
      throw Exception('Failed to get wallet: $e');
    }
  }

  // Get credentials for signing transactions
  Future<EthPrivateKey> getCredentials() async {
    try {
      final encryptedKey = await _storage.read(key: _privateKeyKey);
      if (encryptedKey == null) throw Exception('No wallet found');

      final privateKeyHex = await EncryptionHelper.decryptData(encryptedKey);
      return EthPrivateKey.fromHex(privateKeyHex);
    } catch (e) {
      throw Exception('Failed to get credentials: $e');
    }
  }

  // Get wallet address
  Future<String?> getAddress() async {
    return await _storage.read(key: _addressKey);
  }

  // Backup encrypted key to Firestore
  Future<void> _backupToFirestore(String address, String encryptedKey) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('wallets').doc(userId).set({
      'address': address,
      'encryptedKey': encryptedKey,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Restore wallet from Firestore
  Future<UserWallet?> restoreWallet() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final doc = await _firestore.collection('wallets').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final address = data['address'] as String;
      final encryptedKey = data['encryptedKey'] as String;

      // Restore to secure storage
      await _storage.write(key: _privateKeyKey, value: encryptedKey);
      await _storage.write(key: _addressKey, value: address);

      return UserWallet(address: address, balance: '0', rtknBalance: '0');
    } catch (e) {
      throw Exception('Failed to restore wallet: $e');
    }
  }

  // Delete wallet (use with caution)
  Future<void> deleteWallet() async {
    await _storage.delete(key: _privateKeyKey);
    await _storage.delete(key: _addressKey);

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('wallets').doc(userId).delete();
    }
  }

  // Check if wallet exists
  Future<bool> hasWallet() async {
    final address = await _storage.read(key: _addressKey);
    return address != null;
  }

  Future<WalletType> getWalletType() async {
    final type = await _storage.read(key: 'wallet_type');
    return WalletType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => WalletType.generated,
    );
  }

  Future<void> setWalletType(WalletType type) async {
    await _storage.write(key: 'wallet_type', value: type.name);
  }
}
