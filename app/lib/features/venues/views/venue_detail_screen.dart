import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/venue_detail_controller.dart';
import '../models/venue.dart';
import '../models/slot.dart';
import '../../bookings/controllers/booking_controller.dart'; // We'll mock/link this in Step 15
import '../../../core/theme/app_theme.dart';

class VenueDetailScreen extends ConsumerWidget {
  final Venue venue;
  const VenueDetailScreen({super.key, required this.venue});

  String _displayDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(venueDetailControllerProvider(venue.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(venue.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Venue Info Summary Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          venue.location,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 16.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Maximum Capacity: ${venue.capacity} players',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Date Picker Selector
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Selected Date: ${_displayDate(detailState.selectedDate)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: detailState.selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      ref
                          .read(venueDetailControllerProvider(venue.id).notifier)
                          .changeDate(picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Change'),
                ),
              ],
            ),
          ),

          // Time-of-Day Filter Chips
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TimeOfDayFilter.values.map((filter) {
                  final isSelected = detailState.activeFilter == filter;
                  final label = filter.name[0].toUpperCase() + filter.name.substring(1);
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(venueDetailControllerProvider(venue.id).notifier)
                              .changeFilter(filter);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const Divider(),

          // Slots Grid Section
          Expanded(
            child: detailState.slotsAsync.when(
              data: (_) {
                final filteredSlots = detailState.filteredSlots;

                if (filteredSlots.isEmpty) {
                  return Center(
                    child: Text(
                      'No slots found for this time of day.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.all(16.r),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 columns for hourly list
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: filteredSlots.length,
                  itemBuilder: (context, index) {
                    final slot = filteredSlots[index];
                    final isAvailable = slot.isAvailable;

                    return Card(
                      color: isAvailable
                          ? AppTheme.available.withOpacity(0.08)
                          : AppTheme.booked.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(
                          color: isAvailable ? AppTheme.available : AppTheme.booked,
                          width: 1.2,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: isAvailable
                            ? () => _confirmBooking(context, ref, slot)
                            : null, // Disabled if booked
                        child: Padding(
                          padding: EdgeInsets.all(8.r),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                slot.time,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                isAvailable ? 'Available' : (slot.bookedBy ?? 'Booked'),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                      color: isAvailable ? AppTheme.available : AppTheme.booked,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                    SizedBox(height: 16.h),
                    Text(
                      error.toString().replaceAll('CustomException:', '').trim(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(venueDetailControllerProvider(venue.id).notifier)
                          .refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBooking(BuildContext context, WidgetRef ref, Slot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Slot'),
        content: Text('Would you like to book ${venue.name} at ${slot.time}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Trigger booking logic (Step 15 controller wiring)
              ref.read(bookingControllerProvider.notifier).bookSlot(
                    venueId: venue.id,
                    date: ref.read(venueDetailControllerProvider(venue.id)).selectedDate,
                    slot: slot.time,
                    context: context,
                  );
            },
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }
}
