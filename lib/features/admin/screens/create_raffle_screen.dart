import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/admin_viewmodel.dart';

class CreateRaffleScreen extends ConsumerStatefulWidget {
  const CreateRaffleScreen({super.key});

  @override
  ConsumerState<CreateRaffleScreen> createState() => _CreateRaffleScreenState();
}

class _CreateRaffleScreenState extends ConsumerState<CreateRaffleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _minBetController = TextEditingController(text: '5');
  final _maxBetController = TextEditingController(text: '0');
  final _maxParticipantsController = TextEditingController(text: '0');
  final _durationController = TextEditingController(text: '24');
  final _creatorFeeController = TextEditingController(text: '0');

  bool _isCreating = false;

  @override
  void dispose() {
    _minBetController.dispose();
    _maxBetController.dispose();
    _maxParticipantsController.dispose();
    _durationController.dispose();
    _creatorFeeController.dispose();
    super.dispose();
  }

  Future<void> _createRaffle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      await ref
          .read(adminViewModelProvider.notifier)
          .createRaffle(
            minBet: double.parse(_minBetController.text),
            maxBet: double.parse(_maxBetController.text),
            maxParticipants: int.parse(_maxParticipantsController.text),
            durationHours: int.parse(_durationController.text),
            creatorFeePercent: int.parse(_creatorFeeController.text),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Raffle created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      log('Error creating raffle $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Raffle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'A secure seed will be auto-generated and stored safely',
                        style: TextStyle(color: Colors.blue[900], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Min Bet
              TextFormField(
                controller: _minBetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minimum Bet (USDT)',
                  prefixText: '\$ ',
                  helperText: 'Lowest amount users can bet',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) return 'Must be > 0';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Max Bet
              TextFormField(
                controller: _maxBetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Maximum Bet (USDT)',
                  prefixText: '\$ ',
                  helperText: '0 = unlimited',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) return 'Must be >= 0';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Max Participants
              TextFormField(
                controller: _maxParticipantsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Participants',
                  helperText: '0 = unlimited',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final count = int.tryParse(value);
                  if (count == null || count < 0) return 'Must be >= 0';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Duration
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (Hours)',
                  helperText: 'How long raffle runs',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final hours = int.tryParse(value);
                  if (hours == null || hours < 1) return 'Must be >= 1';
                  if (hours > 720) return 'Max 720 hours (30 days)';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Creator Fee
              TextFormField(
                controller: _creatorFeeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Creator Fee (%)',
                  helperText: 'Your cut (0-10%)',
                  suffixText: '%',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final fee = int.tryParse(value);
                  if (fee == null || fee < 0) return 'Must be >= 0';
                  if (fee > 10) return 'Max 10%';
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Preview Card
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PreviewRow(
                        label: 'Min Bet',
                        value: '\$${_minBetController.text}',
                      ),
                      _PreviewRow(
                        label: 'Max Bet',
                        value: _maxBetController.text == '0'
                            ? 'Unlimited'
                            : '\$${_maxBetController.text}',
                      ),
                      _PreviewRow(
                        label: 'Duration',
                        value: '${_durationController.text}h',
                      ),
                      _PreviewRow(
                        label: 'Your Fee',
                        value: '${_creatorFeeController.text}%',
                      ),
                      _PreviewRow(label: 'Platform Fee', value: '2.5%'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Create Button
              ElevatedButton(
                onPressed: _isCreating ? null : _createRaffle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create Raffle',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
