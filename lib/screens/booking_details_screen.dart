import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final String formattedStartDate = DateFormat.yMMMd().format(booking.startDate);
    final String formattedStartTime = DateFormat.jm().format(booking.startDate);
    final String formattedEndDate = DateFormat.yMMMd().format(booking.endDate);
    final String formattedEndTime = DateFormat.jm().format(booking.endDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CAR SERVICE DETAILS',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('CAR DETAILS'),
            const SizedBox(height: 8),
            _buildDetailRow('Make', booking.make),
            _buildDetailRow('Model', booking.model),
            _buildDetailRow('Year', booking.year),
            _buildDetailRow('Registration Plate', booking.registrationPlate),
            const SizedBox(height: 20),
            _buildSectionTitle('OWNER DETAILS'),
            const SizedBox(height: 8),
            _buildDetailRow('Name', booking.customerName),
            _buildDetailRow('Phone', booking.customerPhone),
            _buildDetailRow('Email', booking.customerEmail),
            const SizedBox(height: 20),
            _buildSectionTitle('CAR SERVICE STARTED'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailCard('Date', formattedStartDate),
                const SizedBox(width: 10,),
                _buildDetailCard('Time', formattedStartTime),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('CAR SERVICE DEADLINE'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailCard('Date', formattedEndDate),
                const SizedBox(width: 10,),
                _buildDetailCard('Time', formattedEndTime),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('WHO IS WORKING'),
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

                return Text(
                  'Email: $mechanicEmail',
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}