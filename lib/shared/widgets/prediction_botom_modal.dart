import 'package:flutter/material.dart';

typedef OnPredictionSubmit = void Function(Map<String, dynamic> prediction);

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

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

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
  }

  @override
  void dispose() {
    _teamAScoreController.dispose();
    _teamBScoreController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() {
    final scoreA = int.tryParse(_teamAScoreController.text);
    final scoreB = int.tryParse(_teamBScoreController.text);

    if (scoreA == null || scoreB == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid scores'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onSubmit({'scoreA': scoreA, 'scoreB': scoreB});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.teamA} vs ${widget.teamB}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                onPressed: _submit,
                child: const Text('Submit Prediction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
