import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';


class BookingListItem{
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

          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.03),
              leading: Icon(
                Icons.car_repair,
                size: screenWidth * 0.1,
                color: Colors.blueAccent,
              ),
              title: Text(
                booking.bookingTitle,
                style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    'Customer: ${booking.customerName}',
                    style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.w500, color: Colors.black54),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: screenWidth * 0.035, color: Colors.black54),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Start: $formattedStartDate',
                        style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black54),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: screenWidth * 0.035, color: Colors.black54),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'End: $formattedEndDate',
                        style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent, size: screenWidth * 0.03),
                onPressed: () => onTap(booking),
              ),
            ),
          );
        },
      );
    }
}