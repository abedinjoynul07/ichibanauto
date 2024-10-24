import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ichibanauto/screens/admin/widgets/admin_booking_item.dart';

import '../../models/booking.dart';
import '../shared_widgets/booking_details_screen.dart';
import '../shared_widgets/calander_view_screen.dart';
import 'create_booking_screen.dart';
import '../authentication/login/login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  AdminHomeScreenState createState() => AdminHomeScreenState();
}

class AdminHomeScreenState extends State<AdminHomeScreen> {
  bool _showCalendarView = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
        actions: [
          IconButton(
            icon: Icon(_showCalendarView ? Icons.list : Icons.calendar_today),
            onPressed: () {
              setState(() {
                _showCalendarView = !_showCalendarView;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading user details.'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User details not found.'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final String userEmail = userData['email'] ?? 'Unknown Email';
            final String userRole = userData['role'] ?? 'Unknown Role';

            return Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(userRole),
                  accountEmail: Text(userEmail),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      userRole.isNotEmpty
                          ? userRole.substring(0, 1).toUpperCase()
                          : 'M',
                      style: const TextStyle(
                          fontSize: 40.0, color: Colors.blueAccent),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Create Booking'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateBookingScreen()),
                    );
                  },
                ),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    _auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AuthScreen()),
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            );
          },
        ),
      ),
      body: _showCalendarView ? _buildCalendarView() : _buildListView(context),
    );
  }

  Widget _buildCalendarView() {
    return const CalendarViewScreen(userType: UserType.admin);
  }

  Widget _buildListView(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('startDate', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching bookings.'));
        }

        final List<Booking> bookings = snapshot.data?.docs
            .map((doc) => Booking.fromMap(
            doc.data() as Map<String, dynamic>,
            id: doc.id))
            .toList() ??
            [];

        final filteredBookings = _selectedDay == null
            ? bookings
            : bookings.where((booking) {
          return booking.startDate.year == _selectedDay!.year &&
              booking.startDate.month == _selectedDay!.month &&
              booking.startDate.day == _selectedDay!.day;
        }).toList();

        if (filteredBookings.isEmpty) {
          return const Center(
              child: Text('No bookings available for this day.'));
        }

        return AdminBookingList.adminBookingList(
          context: context,
          bookings: filteredBookings,
          onTap: (booking) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingDetailScreen(booking: booking),
              ),
            );
          },
          onEdit: (bookingId) {
            final booking = filteredBookings.firstWhere((b) => b.id == bookingId);
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
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .delete();
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