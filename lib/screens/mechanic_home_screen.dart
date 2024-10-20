import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'booking_details_screen.dart';
import 'calander_view_screen.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../models/booking.dart';
import 'login_screen.dart';

class MechanicHomeScreen extends StatefulWidget {
  const MechanicHomeScreen({super.key});

  @override
  MechanicHomeScreenState createState() => MechanicHomeScreenState();
}

class MechanicHomeScreenState extends State<MechanicHomeScreen> {
  bool _isCalendarView = true;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanic Home'),
        actions: [
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_today),
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
          ),
        ],
      ),
      drawer: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
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
          final mechanicId = snapshot.data!.id;

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
                          : 'M',
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
      body: _isCalendarView
          ? const CalendarViewScreen(userType: UserType.mechanic)
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('mechanic', isEqualTo: user.uid)
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

  bool _isEndingSoon(DateTime endDate) {
    final DateTime now = DateTime.now();
    return endDate.isBefore(now.add(const Duration(hours: 1))) && endDate.isAfter(now);
  }
}
