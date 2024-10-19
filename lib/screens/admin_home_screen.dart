import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'create_booking_screen.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../models/booking.dart';
import 'login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Mohammad Joynul Abedin'),
              accountEmail: Text('shokal@gmail.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'M',
                  style: TextStyle(fontSize: 40.0, color: Colors.blueAccent),
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

                  return ListTile(
                    title: Text('${booking.bookingTitle} - ${booking.customerName}'),
                    subtitle: Text('Start: $formattedStartDate\nEnd: $formattedEndDate'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Assigned Mechanic", style: TextStyle(fontWeight: FontWeight.bold),),
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
                          onTap: (){},
                          child: Icon(
                            Icons.edit,
                            size: 20,
                            color: _isEndingSoon(booking.endDate) ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
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
