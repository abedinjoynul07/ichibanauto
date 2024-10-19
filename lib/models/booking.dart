import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String? id; // Optional document ID for updating
  final String make;
  final String model;
  final String year;
  final String registrationPlate;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String bookingTitle;
  final DateTime startDate;
  final DateTime endDate;
  final String mechanicId;

  Booking({
    this.id, // Optional ID for editing
    required this.make,
    required this.model,
    required this.year,
    required this.registrationPlate,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.bookingTitle,
    required this.startDate,
    required this.endDate,
    required this.mechanicId,
  });

  // Factory method to create Booking from Firebase document
  factory Booking.fromMap(Map<String, dynamic> data, {String? id}) {
    return Booking(
      id: id,
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? '',
      registrationPlate: data['registrationPlate'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      bookingTitle: data['bookingTitle'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      mechanicId: data['mechanic'] ?? '',
    );
  }

  // Convert Booking object to map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'registrationPlate': registrationPlate,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'bookingTitle': bookingTitle,
      'startDate': startDate,
      'endDate': endDate,
      'mechanic': mechanicId,
    };
  }
}
