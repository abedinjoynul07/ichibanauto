import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';

class AdminBookingList {
  static Widget adminBookingList({
    required BuildContext context,
    required List<Booking> bookings,
    required Function(Booking) onTap,
    required Function(String) onEdit,
    required Function(String) onDelete,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (bookings.isEmpty) {
      return const Center(
        child: Text(
          'No bookings available for this day.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final String formattedStartDate = DateFormat.yMMMd().add_jm().format(booking.startDate);
        final String formattedEndDate = DateFormat.yMMMd().add_jm().format(booking.endDate);

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(booking.mechanicId)
              .get(),
          builder: (context, mechanicSnapshot) {
            if (mechanicSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (mechanicSnapshot.hasError || !mechanicSnapshot.hasData) {
              return const ListTile(
                title: Text('Error loading mechanic details'),
              );
            }

            final mechanicData = mechanicSnapshot.data!.data() as Map<String, dynamic>;
            final String mechanicEmail = mechanicData['email'] ?? 'Unknown Email';

            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.03),
                title: Text(
                  booking.bookingTitle,
                  style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      'Cstmr: ${booking.customerName}',
                      style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.w500, color: Colors.black54),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: screenWidth * 0.035, color: Colors.black54),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            'Start: $formattedStartDate',
                            style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: screenWidth * 0.035, color: Colors.black54),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            'End: $formattedEndDate',
                            style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Mechanic",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      mechanicEmail.split("@")[0],
                      style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                onTap: () => onTap(booking),
                isThreeLine: true,
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => onEdit(booking.id ?? ''),
                      child: Icon(
                        Icons.edit,
                        size: screenWidth * 0.06,
                        color: Colors.green,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onDelete(booking.id ?? ''),
                      child: Icon(
                        Icons.delete,
                        size: screenWidth * 0.06,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
