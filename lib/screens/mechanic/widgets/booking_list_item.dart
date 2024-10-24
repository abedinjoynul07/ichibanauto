import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/booking.dart';

class BookingListItem {
  static Widget buildBookingList({
    required BuildContext context,
    required List<Booking> bookings,
    required Function(Booking) onTap,
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

        return GestureDetector(
          onTap: () => onTap(booking),
          child: Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.03),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.bookingTitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    'Customer: ${booking.customerName}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: screenWidth * 0.04, color: Colors.teal[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Start: $formattedStartDate',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: screenWidth * 0.04, color: Colors.teal[600]),
                      const SizedBox(width: 8),
                      Text(
                        'End: $formattedEndDate',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => onTap(booking),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Details',
                            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: screenWidth * 0.03, color: Colors.white),
                        ],
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
  }
}
