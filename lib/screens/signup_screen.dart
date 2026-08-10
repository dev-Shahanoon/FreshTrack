import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }


  Future<void> signup() async {

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    setState(() {
      isLoading = true;
    });


    try {

UserCredential userCredential =
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: emailController.text.trim(),
  password: passwordController.text.trim(),
);


await FirebaseFirestore.instance
    .collection("users")
    .doc(userCredential.user!.uid)
    .set({
  "name": nameController.text.trim(),
  "email": emailController.text.trim(),
  "createdAt": Timestamp.now(),
});


      if (!mounted) return;


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account Created Successfully"),
          backgroundColor: Colors.green,
        ),
      );


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );


    } on FirebaseAuthException catch (e) {

      String message = "Signup failed";


      if (e.code == 'email-already-in-use') {
        message = "Email already registered";
      }
      else if (e.code == 'weak-password') {
        message = "Password is too weak";
      }
      else if (e.code == 'invalid-email') {
        message = "Invalid email address";
      }


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );


    } finally {

      setState(() {
        isLoading = false;
      });

    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
  title: const Text("Create Account"),
  backgroundColor: Theme.of(context).colorScheme.primary,
  foregroundColor: Theme.of(context).colorScheme.onPrimary,
),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: SingleChildScrollView(

            child: Column(

              children: [

                const SizedBox(height:20),


                const Icon(
                  Icons.person_add,
                  size:90,
                  color:Colors.green,
                ),


                const SizedBox(height:20),



                TextField(
                  controller:nameController,
                  decoration:InputDecoration(
                    labelText:"Full Name",
                    prefixIcon:const Icon(Icons.person),
                    border:OutlineInputBorder(
                      borderRadius:BorderRadius.circular(15),
                    ),
                  ),
                ),


                const SizedBox(height:20),



                TextField(
                  controller:emailController,
                  keyboardType:TextInputType.emailAddress,

                  decoration:InputDecoration(
                    labelText:"Email",
                    prefixIcon:const Icon(Icons.email),
                    border:OutlineInputBorder(
                      borderRadius:BorderRadius.circular(15),
                    ),
                  ),
                ),


                const SizedBox(height:20),



                TextField(
                  controller:passwordController,
                  obscureText:true,

                  decoration:InputDecoration(
                    labelText:"Password",
                    prefixIcon:const Icon(Icons.lock),
                    border:OutlineInputBorder(
                      borderRadius:BorderRadius.circular(15),
                    ),
                  ),
                ),


                const SizedBox(height:20),



                TextField(
                  controller:confirmPasswordController,
                  obscureText:true,

                  decoration:InputDecoration(
                    labelText:"Confirm Password",
                    prefixIcon:const Icon(Icons.lock_outline),
                    border:OutlineInputBorder(
                      borderRadius:BorderRadius.circular(15),
                    ),
                  ),
                ),



                const SizedBox(height:30),



                SizedBox(

                  width:double.infinity,
                  height:55,

                  child:ElevatedButton(

                    onPressed:isLoading ? null : signup,


                    child:isLoading

                    ? const CircularProgressIndicator(
                        color:Colors.white,
                      )

                    : const Text(
                        "Create Account",
                        style:TextStyle(fontSize:18),
                      ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}