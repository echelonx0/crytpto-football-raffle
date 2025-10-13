import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class EncryptionHelper {
  static const _keyLength = 32;

  // Generate encryption key from device-specific data
  static Future<String> _getEncryptionKey() async {
    // In production, combine with device ID, Firebase user ID, etc.
    // For now, using a static key (REPLACE IN PRODUCTION)
    const deviceSecret = 'YOUR_DEVICE_SECRET_KEY_HERE';
    final bytes = utf8.encode(deviceSecret);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes);
  }

  // Encrypt data
  static Future<String> encryptData(String plainText) async {
    try {
      final keyString = await _getEncryptionKey();
      final key = enc.Key.fromBase64(keyString);
      final iv = enc.IV.fromSecureRandom(16);

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Combine IV and encrypted data
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  // Decrypt data
  static Future<String> decryptData(String encryptedText) async {
    try {
      final parts = encryptedText.split(':');
      if (parts.length != 2) throw Exception('Invalid encrypted text format');

      final keyString = await _getEncryptionKey();
      final key = enc.Key.fromBase64(keyString);
      final iv = enc.IV.fromBase64(parts[0]);

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      final encrypted = enc.Encrypted.fromBase64(parts[1]);
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  // Generate random seed for raffle
  static BigInt generateRandomSeed() {
    final random = Random.secure();
    final bytes = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      bytes[i] = random.nextInt(256);
    }
    return BigInt.parse(
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16,
    );
  }

  // Hash seed for commit
  static String hashSeed(BigInt seed) {
    final seedHex = seed.toRadixString(16).padLeft(64, '0');
    final bytes = _hexToBytes(seedHex);
    final digest = sha256.convert(bytes);
    return '0x${digest.toString()}';
  }

  static Uint8List _hexToBytes(String hex) {
    if (hex.startsWith('0x')) hex = hex.substring(2);
    final bytes = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < hex.length; i += 2) {
      bytes[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return bytes;
  }
}
