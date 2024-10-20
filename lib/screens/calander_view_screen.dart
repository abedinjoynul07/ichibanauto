import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ichibanauto/widgets/booking_list_item.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/booking.dart';
import '../widgets/admin_booking_item.dart';
import 'booking_details_screen.dart';
import 'create_booking_screen.dart';

enum UserType { admin, mechanic }

class CalendarViewScreen extends StatefulWidget {
  final UserType userType;
  const CalendarViewScreen({super.key, required this.userType});

  @override
  CalendarViewScreenState createState() => CalendarViewScreenState();
}

class CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Booking>> _bookingsForSelectedDay = {};
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadBookingsForMonth(_focusedDay);
  }

  void _loadBookingsForMonth(DateTime focusedDay) {
    Query bookingQuery = FirebaseFirestore.instance.collection('bookings');

    if (widget.userType == UserType.mechanic && user != null) {
      bookingQuery = bookingQuery.where('mechanic', isEqualTo: user!.uid);
    }

    bookingQuery.snapshots().listen((snapshot) {
      final Map<DateTime, List<Booking>> bookingsMap = {};
      for (var doc in snapshot.docs) {
        final booking = Booking.fromMap(doc.data() as Map<String, dynamic>);
        final bookingStart = DateTime(booking.startDate.year, booking.startDate.month, booking.startDate.day);
        if (!bookingsMap.containsKey(bookingStart)) {
          bookingsMap[bookingStart] = [];
        }
        bookingsMap[bookingStart]!.add(booking);
      }
      setState(() {
        _bookingsForSelectedDay = bookingsMap;
      });
    });
  }

  List<Booking> _getBookingsForDay(DateTime day) {
    return _bookingsForSelectedDay[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarFormat: CalendarFormat.month,
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _loadBookingsForMonth(focusedDay);
              });
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return _getBookingsForDay(day);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, bookings) {
                if (bookings.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    right: 1,
                    child: _buildMarker(bookings.length),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: widget.userType == UserType.admin ? _buildListView(context) : buildBookingList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMarker(int bookingCount) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$bookingCount',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget buildBookingList() {
    final bookings = _getBookingsForDay(_selectedDay ?? _focusedDay);

    return BookingListItem.buildBookingList(
      context: context,
      bookings: bookings,
      onTap: (booking) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailScreen(booking: booking),
          ),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('endDate', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching bookings.'));
        }

        final List<Booking> bookings = snapshot.data?.docs
            .map((doc) => Booking.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
            .toList() ?? [];

        if (bookings.isEmpty) {
          return const Center(child: Text('No bookings available.'));
        }

        return AdminBookingList.adminBookingList(
          context: context,
          bookings: bookings,
          onTap: (booking) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingDetailScreen(booking: booking),
              ),
            );
          },
          onEdit: (bookingId) {
            final booking = bookings.firstWhere((b) => b.id == bookingId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateBookingScreen(
                  booking: booking,
                  bookingId: bookingId,
                ),
              ),
            );
          },
          onDelete: (bookingId) {
            _deleteBooking(bookingId);
          },
        );
      },
    );
  }


  Future<void> _deleteBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).delete();
      Fluttertoast.showToast(
        msg: "Booking deleted successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error deleting booking: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
