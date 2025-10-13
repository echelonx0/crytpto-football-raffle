// lib/services/wallet_connect_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_connect_v2/wallet_connect_v2.dart';

class WalletConnectService {
  static final WalletConnectService _instance =
      WalletConnectService._internal();
  factory WalletConnectService() => _instance;
  WalletConnectService._internal();

  static const String _projectId =
      'YOUR_PROJECT_ID'; // Get from cloud.walletconnect.com

  final _wcPlugin = WalletConnectV2();
  Session? _session;
  String? _currentAddress;
  final _connectionController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _session != null;
  String? get address => _currentAddress;
  Session? get session => _session;

  Future<void> initialize() async {
    _wcPlugin.onConnectionStatus = (isConnected) {
      debugPrint('WC Connection Status: $isConnected');
      _connectionController.add(isConnected);
    };

    _wcPlugin.onSessionSettle = (session) {
      _session = session;
      _extractAddress();
      debugPrint('Session settled: ${session.topic}');
    };

    _wcPlugin.onSessionDelete = (_) {
      _session = null;
      _currentAddress = null;
      debugPrint('Session deleted');
    };

    _wcPlugin.onEventError = (code, message) {
      debugPrint('WC Error: $code - $message');
    };

    await _wcPlugin.init(
      projectId: _projectId,
      appMetadata: AppMetadata(
        name: 'Football Raffle',
        description: 'Football Raffle Betting App',
        url: 'https://yourapp.com',
        icons: ['https://yourapp.com/icon.png'],
        redirect: 'footballraffle://',
      ),
    );

    await _wcPlugin.connect();
  }

  Future<String> connect() async {
    final uri = await _wcPlugin.createPair(
      namespaces: {
        'eip155': ProposalNamespace(
          chains: ['eip155:4202'], // Lisk Sepolia
          methods: [
            'eth_sendTransaction',
            'eth_signTransaction',
            'personal_sign',
            'eth_signTypedData',
          ],
          events: ['chainChanged', 'accountsChanged'],
        ),
      },
    );

    if (uri == null) throw Exception('Failed to create pairing');

    // Launch wallet app
    await _launchWalletApp(uri);

    // Wait for session to be established
    await _waitForSession();

    if (_currentAddress == null) {
      throw Exception('Failed to get wallet address');
    }

    return _currentAddress!;
  }

  Future<void> _launchWalletApp(String uri) async {
    try {
      // Try MetaMask first
      final metamaskUri = Uri.parse(
        'metamask://wc?uri=${Uri.encodeComponent(uri)}',
      );
      final launched = await launchUrl(
        metamaskUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Fallback to universal WC link
        final wcUri = Uri.parse(uri);
        await launchUrl(wcUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Launch error: $e');
      // Show QR code as fallback
      rethrow;
    }
  }

  Future<void> _waitForSession({int timeoutSeconds = 60}) async {
    final completer = Completer<void>();
    Timer? timeout;

    final subscription = _connectionController.stream.listen((connected) {
      if (connected && _session != null) {
        timeout?.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });

    timeout = Timer(Duration(seconds: timeoutSeconds), () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Connection timeout'));
      }
    });

    try {
      await completer.future;
    } finally {
      await subscription.cancel();
      timeout.cancel();
    }
  }

  void _extractAddress() {
    if (_session == null) return;

    final accounts = _session!.namespaces['eip155']?.accounts;
    if (accounts != null && accounts.isNotEmpty) {
      _currentAddress = accounts.first.split(':').last;
    }
  }

  Future<String> sendTransaction({
    required String to,
    required BigInt value,
    String? data,
  }) async {
    if (_session == null || _currentAddress == null) {
      throw Exception('Not connected');
    }

    final tx = {
      'from': _currentAddress,
      'to': to,
      'value': '0x${value.toRadixString(16)}',
      if (data != null) 'data': data,
    };

    final request = Request(
      method: 'eth_sendTransaction',
      chainId: 'eip155:4202',
      topic: _session!.topic,
      params: [tx],
    );

    await _wcPlugin.sendRequest(request: request);

    // Launch wallet to approve
    _session!.peer.redirect?.launch();

    // Wait for response (you'll need to handle this via onSessionResponse)
    throw UnimplementedError('Implement response handling');
  }

  Future<String> signMessage(String message) async {
    if (_session == null || _currentAddress == null) {
      throw Exception('Not connected');
    }

    final request = Request(
      method: 'personal_sign',
      chainId: 'eip155:4202',
      topic: _session!.topic,
      params: [message, _currentAddress],
    );

    await _wcPlugin.sendRequest(request: request);
    _session!.peer.redirect?.launch();

    throw UnimplementedError('Implement response handling');
  }

  Future<void> disconnect() async {
    if (_session != null) {
      await _wcPlugin.disconnectSession(topic: _session!.topic);
      _session = null;
      _currentAddress = null;
    }
  }

  void dispose() {
    _connectionController.close();
    _wcPlugin.dispose();
  }
}

extension _StringLaunch on String {
  Future<void> launch({int delayMs = 500}) async {
    try {
      await Future.delayed(Duration(milliseconds: delayMs));
      final uri = Uri.parse(contains(':') ? this : '$this:');

      if (startsWith('http')) {
        await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Launch failed: $e');
    }
  }
}
