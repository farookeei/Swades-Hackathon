import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/slot.dart';
import '../repositories/i_venue_repository.dart';
import '../repositories/venue_repository.dart';

enum TimeOfDayFilter { all, morning, afternoon, evening }

class VenueDetailState {
  final DateTime selectedDate;
  final AsyncValue<List<Slot>> slotsAsync;
  final TimeOfDayFilter activeFilter;

  VenueDetailState({
    required this.selectedDate,
    required this.slotsAsync,
    required this.activeFilter,
  });

  VenueDetailState copyWith({
    DateTime? selectedDate,
    AsyncValue<List<Slot>>? slotsAsync,
    TimeOfDayFilter? activeFilter,
  }) {
    return VenueDetailState(
      selectedDate: selectedDate ?? this.selectedDate,
      slotsAsync: slotsAsync ?? this.slotsAsync,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  List<Slot> get filteredSlots {
    return slotsAsync.maybeWhen(
      data: (slots) {
        final now = DateTime.now();
        final isToday = selectedDate.year == now.year &&
            selectedDate.month == now.month &&
            selectedDate.day == now.day;

        return slots.where((slot) {
          final timeStr = slot.time.split(' ')[0];
          final isPM = slot.time.contains('PM');
          int hour = int.parse(timeStr.split(':')[0]);
          if (isPM && hour != 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;

          if (isToday && hour <= now.hour) {
            return false;
          }

          switch (activeFilter) {
            case TimeOfDayFilter.morning:
              return hour >= 6 && hour < 12;
            case TimeOfDayFilter.afternoon:
              return hour >= 12 && hour < 17;
            case TimeOfDayFilter.evening:
              return hour >= 17 && hour <= 22;
            case TimeOfDayFilter.all:
            default:
              return true;
          }
        }).toList();
      },
      orElse: () => [],
    );
  }
}

final venueDetailControllerProvider =
    AutoDisposeNotifierProviderFamily<VenueDetailController, VenueDetailState, int>(() {
  return VenueDetailController();
});

class VenueDetailController extends AutoDisposeFamilyNotifier<VenueDetailState, int> {
  late final IVenueRepository _repository;

  @override
  VenueDetailState build(int arg) {
    _repository = ref.watch(venueRepositoryProvider);
    final today = DateTime.now();

    // Fetch slots after state initialization
    Future.microtask(() => _fetchSlots(today));

    return VenueDetailState(
      selectedDate: today,
      slotsAsync: const AsyncLoading(),
      activeFilter: TimeOfDayFilter.all,
    );
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _fetchSlots(DateTime date) async {
    state = state.copyWith(slotsAsync: const AsyncLoading());
    try {
      final dateStr = _formatDate(date);
      final result = await _repository.getSlots(arg, dateStr);
      final slots = result['slots'] as List<Slot>;
      state = state.copyWith(slotsAsync: AsyncValue.data(slots));
    } catch (e, stack) {
      state = state.copyWith(slotsAsync: AsyncValue.error(e, stack));
    }
  }

  void changeDate(DateTime newDate) {
    state = state.copyWith(selectedDate: newDate);
    _fetchSlots(newDate);
  }

  void changeFilter(TimeOfDayFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<void> refresh() async {
    await _fetchSlots(state.selectedDate);
  }
}
