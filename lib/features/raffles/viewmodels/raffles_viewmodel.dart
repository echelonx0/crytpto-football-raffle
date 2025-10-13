import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/raffle_service.dart';
import '../../../core/models/raffle_model.dart';

final rafflesViewModelProvider =
    StateNotifierProvider<RafflesViewModel, AsyncValue<List<RaffleModel>>>((
      ref,
    ) {
      return RafflesViewModel();
    });

class RafflesViewModel extends StateNotifier<AsyncValue<List<RaffleModel>>> {
  RafflesViewModel() : super(const AsyncValue.loading()) {
    loadRaffles();
  }

  final _raffleService = RaffleService();

  Future<void> loadRaffles() async {
    state = const AsyncValue.loading();
    try {
      final raffles = await _raffleService.getActiveRaffles();
      state = AsyncValue.data(raffles);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await loadRaffles();
  }
}

// Provider for single raffle detail
final raffleDetailProvider = FutureProvider.family<RaffleDetailModel, String>((
  ref,
  raffleId,
) async {
  return await RaffleService().getRaffleDetails(raffleId);
});
