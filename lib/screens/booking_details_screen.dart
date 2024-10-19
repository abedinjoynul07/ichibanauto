import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final String formattedStartDate = DateFormat.yMMMd().add_jm().format(booking.startDate);
    final String formattedEndDate = DateFormat.yMMMd().add_jm().format(booking.endDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.bookingTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Car Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Make: ${booking.make}'),
            Text('Model: ${booking.model}'),
            Text('Year: ${booking.year}'),
            Text('Registration Plate: ${booking.registrationPlate}'),
            const SizedBox(height: 20),
            const Text(
              'Customer Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Name: ${booking.customerName}'),
            Text('Phone: ${booking.customerPhone}'),
            Text('Email: ${booking.customerEmail}'),
            const SizedBox(height: 20),
            const Text(
              'Booking Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Start: $formattedStartDate'),
            Text('End: $formattedEndDate'),
            const SizedBox(height: 20),
            const Text(
              'Assigned Mechanic',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(booking.mechanicId)
                  .get(),
              builder: (context, mechanicSnapshot) {
                if (mechanicSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (mechanicSnapshot.hasError || !mechanicSnapshot.hasData) {
                  return const Text('Error loading mechanic details.');
                }

                final mechanicData = mechanicSnapshot.data!.data() as Map<String, dynamic>;
                final String mechanicEmail = mechanicData['email'] ?? 'Unknown Email';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: $mechanicEmail'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
