import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hackathon/features/venues/models/slot.dart';
import 'package:hackathon/features/venues/models/venue.dart';
import 'package:hackathon/features/venues/repositories/i_venue_repository.dart';
import 'package:hackathon/features/venues/repositories/venue_repository.dart';
import 'package:hackathon/features/venues/views/venue_detail_screen.dart';

// Mock repository to inject deterministic slots
class MockVenueRepository implements IVenueRepository {
  @override
  Future<List<Venue>> getVenues() async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getSlots(int venueId, String date) async {
    return {
      'date': date,
      'slots': [
        const Slot(time: '08:00', isAvailable: true, bookedBy: null),
        const Slot(time: '09:00', isAvailable: false, bookedBy: 'User B'),
      ]
    };
  }
}

void main() {
  testWidgets('VenueDetailScreen - Booking button states test: Available vs Booked', (WidgetTester tester) async {
    // 1. Create a dummy venue
    const dummyVenue = Venue(
      id: 1,
      name: 'Test Court',
      location: 'Test Location',
      capacity: 10,
    );

    // 2. Setup the ProviderScope overriding the repository
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          venueRepositoryProvider.overrideWithValue(MockVenueRepository()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return const MaterialApp(
              home: VenueDetailScreen(venue: dummyVenue),
            );
          },
        ),
      ),
    );

    // 3. Let the Future in the controller resolve (fetching mocked slots)
    await tester.pumpAndSettle();

    // 4. Verify slots are rendered on the screen
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);

    // 5. Verify the availability statuses
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('User B'), findsOneWidget); // Slot 09:00 is booked by User B

    // 6. Test interaction on the Available slot (08:00)
    await tester.tap(find.text('08:00'));
    await tester.pumpAndSettle();
    
    // The confirmation dialog should appear for available slots
    expect(find.text('Book Slot'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Close the dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // 7. Test interaction on the Booked slot (09:00)
    await tester.tap(find.text('09:00'));
    await tester.pumpAndSettle();

    // The dialog should NOT appear because booked slots have `onTap: null`
    expect(find.text('Book Slot'), findsNothing);
  });
}
