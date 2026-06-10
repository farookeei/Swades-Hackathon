import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/booking_controller.dart';
import '../../../core/theme/app_theme.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  String _formatDisplayDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      final year = parts[0];
      final monthInt = int.parse(parts[1]);
      final day = parts[2];
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '$day ${months[monthInt - 1]} $year';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 48.sp,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No active bookings yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: bookings.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final booking = bookings[index];

              return Dismissible(
                key: Key(booking.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.w),
                  decoration: BoxDecoration(
                    color: AppTheme.booked,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cancel Booking'),
                      content: const Text('Are you sure you want to cancel this booking?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('No'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.booked,
                          ),
                          child: const Text('Yes, Cancel'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  ref.read(bookingControllerProvider.notifier).cancel(
                        bookingId: booking.id,
                        refreshVenueId: booking.venueId,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking canceled successfully.'),
                    ),
                  );
                },
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.venueName ?? 'Unknown Venue',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14.sp,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    booking.venueLocation ?? 'N/A',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    size: 14.sp,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _formatDisplayDate(booking.date),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            booking.slot,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
