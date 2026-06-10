import 'package:flutter/material.dart';
import '../models/venue.dart';

class VenueDetailScreen extends StatelessWidget {
  final Venue venue;
  const VenueDetailScreen({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(venue.name)),
      body: const Center(child: Text('Venue Detail Screen ')),
    );
  }
}
