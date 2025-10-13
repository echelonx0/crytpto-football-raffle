import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/raffles_viewmodel.dart';
import '../widgets/raffle_card.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../../shared/widgets/error_widget.dart';

class RafflesListScreen extends ConsumerWidget {
  const RafflesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rafflesState = ref.watch(rafflesViewModelProvider);

    return Scaffold(
      body: rafflesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => GlobalErrorWidget(
          message: 'Error: $error',
          onRetry: () => ref.read(rafflesViewModelProvider.notifier).refresh(),
        ),
        data: (raffles) {
          if (raffles.isEmpty) {
            return GlobalEmptyWidget(
              message: 'No active raffles\nCheck back soon!',
              icon: Icons.casino_outlined,
              onAction: () =>
                  ref.read(rafflesViewModelProvider.notifier).refresh(),
              actionLabel: 'Refresh',
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(rafflesViewModelProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: raffles.length,
              itemBuilder: (context, index) =>
                  RaffleCard(raffle: raffles[index], index: index),
            ),
          );
        },
      ),
    );
  }
}
