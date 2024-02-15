import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NextPage extends StatefulWidget {
  final String documentId;

  NextPage({required this.documentId});

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  String imageUrl = '';
  String selectedButton = ''; // Variable to track selected button

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController rcNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('userProfile')
          .doc(widget.documentId)
          .get();
      setState(() {
        imageUrl = documentSnapshot['imageLink'];
      });
    } catch (error) {
      print('Error fetching data from Firestore: $error');
    }
  }

  Future<void> submitData() async {
    // Check if all text form fields are filled
    if (nameController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty &&
        vehicleTypeController.text.isNotEmpty &&
        rcNumberController.text.isNotEmpty) {
      try {
        // Store data in Firebase Firestore
        await FirebaseFirestore.instance.collection('financeData').add({
          'name': nameController.text,
          'phoneNumber': phoneNumberController.text,
          'vehicleType': vehicleTypeController.text,
          'rcNumber': rcNumberController.text,
          // Add more fields as needed
        });
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data submitted successfully!'),
          ),
        );
      } catch (error) {
        print('Error submitting data to Firestore: $error');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit data. Please try again later.'),
          ),
        );
      }
    } else {
      // Show error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedButton = 'finance'; // Set selected button to finance
                      });
                    },
                    child: Text('Finance'),
                    style: ElevatedButton.styleFrom(
                      primary: selectedButton == 'finance' ? Colors.green : Colors.blue, // Change color based on selection
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedButton = 'insurance'; // Set selected button to insurance
                      });
                    },
                    child: Text('Insurance'),
                    style: ElevatedButton.styleFrom(
                      primary: selectedButton == 'insurance' ? Colors.green : Colors.blue, // Change color based on selection
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12.0),
                        image: imageUrl.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                            : DecorationImage(
                          image: AssetImage('assets/placeholder_image.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 60),
                    buildTextField('Name', nameController),
                    SizedBox(height: 7),
                    buildTextField('Phone Number', phoneNumberController),
                    SizedBox(height: 7),
                    buildTextField('Type of Vehicle', vehicleTypeController),
                    SizedBox(height: 7),
                    buildTextField('RC Number', rcNumberController),
                    SizedBox(height: 25),
                    SizedBox(
                      width: 80, // Set width
                      height: 40, // Set height
                      child: ElevatedButton(
                        onPressed: submitData, // Call submitData function when button is pressed
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50), // Add extra spacing at the bottom for the submit button to appear above the keyboard
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: controller, // Assign controller to text field
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white, // Set background color
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
