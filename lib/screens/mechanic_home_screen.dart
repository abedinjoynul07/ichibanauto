import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'booking_details_screen.dart';
import 'create_booking_screen.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../models/booking.dart';
import 'login_screen.dart';

class MechanicHomeScreen extends StatelessWidget {
  const MechanicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser; // Get the current logged-in user

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanic Home'),
      ),
      drawer: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(), // Fetch user document
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

          // Extract user details
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String userEmail = userData['email'] ?? 'Unknown Email';
          final String userRole = userData['role'] ?? 'Unknown Role';
          final mechanicId = snapshot.data!.id; // Mechanic ID

          debugPrint("Mechanic Id -> $mechanicId");

          return Drawer(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(userRole),
                  accountEmail: Text(userEmail),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      userRole.isNotEmpty
                          ? userRole.substring(0, 1).toUpperCase()
                          : 'M', // Default to 'M' if empty
                      style: const TextStyle(fontSize: 40.0, color: Colors.blueAccent),
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
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    BlocProvider.of<AuthBloc>(context).add(LoggedOut());
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('mechanic', isEqualTo: user?.uid) // Fetch bookings for this mechanic
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching bookings.'));
          }

          final bookings = snapshot.data?.docs ?? [];

          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings available.'));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;
              final booking = Booking.fromMap(data);
              final bookingId = bookings[index].id;

              final String formattedStartDate = DateFormat.yMMMd().add_jm().format(booking.startDate);
              final String formattedEndDate = DateFormat.yMMMd().add_jm().format(booking.endDate);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailScreen(booking: booking),
                    ),
                  );
                },
                child: ListTile(
                  title: Text('${booking.bookingTitle} - ${booking.customerName}'),
                  subtitle: Text('Start: $formattedStartDate\nEnd: $formattedEndDate'),
                  leading: Icon(
                    Icons.car_repair,
                    color: _isEndingSoon(booking.endDate) ? Colors.red : Colors.green,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to check if the booking is ending soon (within 1 hour)
  bool _isEndingSoon(DateTime endDate) {
    final DateTime now = DateTime.now();
    return endDate.isBefore(now.add(const Duration(hours: 1))) && endDate.isAfter(now);
  }
}
