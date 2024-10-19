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

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser; // Get the current logged-in user

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
      ),
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(), // Listen to user document
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

            return Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(userRole),
                  accountEmail: Text(userEmail),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      userRole.isNotEmpty ? userRole.substring(0, 1).toUpperCase() : 'M', // Use 'M' as fallback if userRole is empty
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
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Create Booking'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateBookingScreen()),
                    );
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
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Assigned Mechanic",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(mechanicEmail),
                        ],
                      ),
                      isThreeLine: true,
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.car_repair,
                            color: _isEndingSoon(booking.endDate) ? Colors.red : Colors.green,
                          ),
                          GestureDetector(
                            onTap: () {
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
                            child: Icon(
                              Icons.edit,
                              size: 20,
                              color: _isEndingSoon(booking.endDate) ? Colors.red : Colors.green,
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
