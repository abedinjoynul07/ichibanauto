import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';


class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  CreateBookingScreenState createState() => CreateBookingScreenState();
}

class CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();
  final TextEditingController _customerEmailController =
      TextEditingController();
  final TextEditingController _bookingTitleController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedMechanic;

  List<DocumentSnapshot> _mechanics = [];

  @override
  void initState() {
    super.initState();
    _fetchMechanics();
  }

  clearFields() {
    _makeController.clear();
    _modelController.clear();
    _yearController.clear();
    _registrationController.clear();
    _customerNameController.clear();
    _customerPhoneController.clear();
    _customerEmailController.clear();
    _bookingTitleController.clear();
  }

  Future<void> _fetchMechanics() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'mechanic')
        .get();

    setState(() {
      _mechanics = snapshot.docs;
    });
  }

  Future<void> _createBooking() async {
    if (_formKey.currentState!.validate()) {
      final booking = {
        'make': _makeController.text,
        'model': _modelController.text,
        'year': _yearController.text,
        'registrationPlate': _registrationController.text,
        'customerName': _customerNameController.text,
        'customerPhone': _customerPhoneController.text,
        'customerEmail': _customerEmailController.text,
        'bookingTitle': _bookingTitleController.text,
        'startDate': _startDate,
        'endDate': _endDate,
        'mechanic': _selectedMechanic,
      };

      await FirebaseFirestore.instance.collection('bookings').add(booking);

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Booking created successfully!')),
      // );

      Fluttertoast.showToast(
        msg: "Booking created successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );

      _formKey.currentState!.reset();
      clearFields();
      Navigator.pop(context); // Close the drawer
    }
  }

  Future<void> _pickDateTime(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isStartDate) {
            _startDate = fullDateTime;
          } else {
            _endDate = fullDateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Car Service Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Car Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _makeController,
                  decoration: const InputDecoration(labelText: 'Make'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter car make' : null,
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(labelText: 'Model'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter car model' : null,
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Year'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter car year' : null,
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _registrationController,
                  decoration:
                      const InputDecoration(labelText: 'Registration Plate'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter registration plate' : null,
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Customer Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter customer name' : null,
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _customerPhoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter customer phone' : null,
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _customerEmailController,
                  decoration:
                      const InputDecoration(labelText: 'Customer Email'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter customer email' : null,
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Booking Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _bookingTitleController,
                  decoration: const InputDecoration(labelText: 'Booking Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter booking title' : null,
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () => _pickDateTime(context, true),
                  child: Text(_startDate == null
                      ? 'Select Start Date & Time'
                      : 'Start: ${_startDate.toString()}'),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () => _pickDateTime(context, false),
                  child: Text(_endDate == null
                      ? 'Select End Date & Time'
                      : 'End: ${_endDate.toString()}'),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Assign Mechanic',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedMechanic,
                  hint: const Text('Select Mechanic'),
                  items: _mechanics.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc.id, // mechanic's user ID
                      child: Text(doc['email']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMechanic = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a mechanic' : null,
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _createBooking,
                  child: const Text('Create Booking'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
