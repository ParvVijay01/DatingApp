// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datingapp/Widgets/alert_box.dart';
import 'package:datingapp/authScreens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController clubController = TextEditingController();

  bool passwordVisible = false;
  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  validateForm() {
    if (nameController.text.length < 3) {
      AlertBox.CustomAlertbox(
          context, "Name should contain atleast 3 characters");
    } else if (!emailController.text.contains("@")) {
      AlertBox.CustomAlertbox(context, "Invalid Email ID");
    } else if (clubController.text.isEmpty) {
      AlertBox.CustomAlertbox(
          context, "Please enter a valib Club name / Organisations");
    } else if (passwordController.text.length < 6) {
      AlertBox.CustomAlertbox(
          context, "Password should contain atleast 6 characters");
    } else {
      saveSignupinfo(
        emailController.text.toString(),
        passwordController.text.toString(),
        nameController.text.toString(),
        clubController.text.toString(),
      );
    }
  }

  saveSignupinfo(
      String email, String password, String name, String club) async {
    UserCredential? userCredential;
    try {
      uploadData();
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) =>
              Fluttertoast.showToast(msg: "Account created successfully!!!"))
          .then(
            (value) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            ),
          );

      FirebaseFirestore.instance
          .collection("Users")
          .doc(email)
          .set({"Email": email, "Name": name, "club": club});
    } on FirebaseAuthException catch (ex) {
      return AlertBox.CustomAlertbox(context, ex.code.toString());
    }
  }

  File? pickedImage;

  showAlertBox() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pick image from"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.camera),
                title: const Text("Camera"),
              ),
              ListTile(
                onTap: () {
                  pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.image),
                title: const Text("Gallery"),
              ),
            ],
          ),
        );
      },
    );
  }

  uploadData() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("Profile Pics")
        .child(emailController.text.toString())
        .putFile(pickedImage!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String url = await taskSnapshot.ref.getDownloadURL();
    FirebaseFirestore.instance
        .collection("Users")
        .doc(emailController.text.toString())
        .set({
      "Club": clubController.text.toString(),
      "Name": nameController.text.toString(),
      "Email": emailController.text.toString(),
      "Image": url,
    }).then(
      (value) => {
        log("User Uploaded"),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Dating App",
          style: TextStyle(fontSize: 25),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
              child: InkWell(
                onTap: () {
                  showAlertBox();
                },
                child: pickedImage != null
                    ? CircleAvatar(
                        radius: 10,
                        backgroundImage: FileImage(pickedImage!),
                      )
                    : const CircleAvatar(
                        radius: 100,
                        backgroundColor: Color(0xFFfdebe7),
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.black54,
                        ),
                      ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: TextField(
                controller: nameController,
                cursorColor: Colors.black,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.person,
                  ),
                  labelText: "Name",
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFBD4175))),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: TextField(
                controller: clubController,
                cursorColor: Colors.black,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.person,
                  ),
                  labelText: "Club / Organisations",
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFBD4175))),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: TextField(
                controller: emailController,
                cursorColor: Colors.black,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.mail,
                  ),
                  labelText: "email",
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFBD4175))),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: TextField(
                controller: passwordController,
                obscureText: passwordVisible,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.password,
                  ),
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFFBD4175),
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                    icon: Icon(passwordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFfdebe7)),
                onPressed: () {
                  validateForm();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => const LoginScreen()),
                  ),
                );
              },
              child: const Text(
                "Already have an Account? Login",
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 17,
                    decoration: TextDecoration.underline),
              ),
            )
          ],
        ),
      ),
    );
  }

  pickImage(ImageSource imageSource) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageSource);
      if (photo == null) {
        return;
      }
      final tempImage = File(photo.path);
      setState(() {
        pickedImage = tempImage;
      });
    } catch (ex) {
      log(ex.toString());
    }
  }
}
