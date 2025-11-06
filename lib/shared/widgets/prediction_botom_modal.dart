// lib/features/raffle/widgets/prediction_bottom_modal.dart

import 'package:flutter/material.dart';
import '../../features/raffles/services/prediction-service.dart';

typedef OnPredictionSubmit =
    void Function({
      required String prediction,
      required String secret,
      required String commit,
    });

class PredictionBottomModal extends StatefulWidget {
  final String teamA;
  final String teamB;
  final OnPredictionSubmit onSubmit;

  const PredictionBottomModal({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.onSubmit,
  });

  @override
  State<PredictionBottomModal> createState() => _PredictionBottomModalState();
}

class _PredictionBottomModalState extends State<PredictionBottomModal>
    with SingleTickerProviderStateMixin {
  final _teamAScoreController = TextEditingController();
  final _teamBScoreController = TextEditingController();
  final _predictionService = PredictionService();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  String? _generatedSecret;
  String? _generatedCommit;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    // Pre-generate secret (shown as "locked" icon to user)
    _generatedSecret = _predictionService.generateSecret();
  }

  @override
  void dispose() {
    _teamAScoreController.dispose();
    _teamBScoreController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_isProcessing) return;

    final scoreA = int.tryParse(_teamAScoreController.text);
    final scoreB = int.tryParse(_teamBScoreController.text);

    if (scoreA == null || scoreB == null) {
      _showError('Enter valid scores');
      return;
    }

    if (scoreA < 0 || scoreB < 0) {
      _showError('Scores cannot be negative');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Format prediction
      final prediction = _predictionService.formatPrediction(
        teamA: widget.teamA,
        teamB: widget.teamB,
        scoreA: scoreA,
        scoreB: scoreB,
      );

      // Generate commit
      final commit = _predictionService.generateCommit(
        prediction,
        _generatedSecret!,
      );

      _generatedCommit = commit;

      // Pass data back to parent
      widget.onSubmit(
        prediction: prediction,
        secret: _generatedSecret!,
        commit: commit,
      );

      Navigator.pop(context);
    } catch (e) {
      _showError('Failed to process prediction: $e');
      setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.sports_soccer, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.teamA} vs ${widget.teamB}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.lock_outline, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Your prediction is encrypted and stored securely',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _teamAScoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: widget.teamA,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.home),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _teamBScoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: widget.teamB,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.sports),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _submit,
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Prediction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
