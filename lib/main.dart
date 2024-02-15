import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insurence_transmaa2/utils.dart';

import 'firebase_options.dart';
import 'lastone.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? _image;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  Future<void> saveProfileAndNavigate() async {
    try {
      String imageUrl = await uploadImageToStorage('profileImage', _image!);
      String documentId = await saveDataToFirestore(imageUrl);
      print('Image uploaded and stored successfully! Document ID: $documentId');

      // After saving, navigate to the next page with the document ID
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NextPage(documentId: documentId),
        ),
      );
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    Reference ref = _storage.ref().child(childName).child('id');
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveDataToFirestore(String imageUrl) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      // Add data to Firestore and get the document ID
      DocumentReference docRef = await _firestore.collection('userProfile').add({
        'imageLink': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Return the document ID
      return docRef.id;
    } catch (error) {
      print('Error saving data to Firestore: $error');
      throw error; // Rethrow the error so that it can be caught in the calling function
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 5),
                Container(
                  color: Colors.red,
                  height: 7,
                  width: 90,
                ),
                SizedBox(width: 5),
                Container(
                  color: Colors.red,
                  height: 7,
                  width: 90,
                ),
                SizedBox(width: 5),
                Container(
                  color: Colors.red,
                  height: 7,
                  width: 90,
                ),
                SizedBox(width: 5),
                Container(
                  color: Colors.red,
                  height: 7,
                  width: 85,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: Text(
              'Upload pic',
              style: TextStyle(fontSize: 22),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                      radius: 70,
                      backgroundImage: MemoryImage(_image!),
                    )
                        : CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(
                        'https://example.com/default_image.jpg',
                      ),
                    ),
                    Positioned(
                      child: IconButton(
                        onPressed: selectImage,
                        icon: Icon(Icons.add_a_photo),
                      ),
                      bottom: -10,
                      left: 80,
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveProfileAndNavigate,
        tooltip: 'Save Profile and Navigate',
        child: Icon(
          Icons.arrow_forward_rounded,
          size: 30,
          color: Colors.red,
        ),
        backgroundColor: Colors.orangeAccent,
        elevation: 2,
        shape: CircleBorder(
          side: BorderSide(color: Colors.red, width: 7),
        ),
      ),
    );
  }
}