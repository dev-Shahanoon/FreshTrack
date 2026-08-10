import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'signup_screen.dart';
import 'home_screen.dart';


class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});


  @override
  State<LoginScreen> createState() => _LoginScreenState();

}




class _LoginScreenState extends State<LoginScreen> {


  final _formKey = GlobalKey<FormState>();


  final emailController = TextEditingController();

  final passwordController = TextEditingController();


  bool isLoading = false;

  bool hidePassword = true;




  @override
  void dispose(){

    emailController.dispose();

    passwordController.dispose();

    super.dispose();

  }






  Future<void> login() async {


    if(!_formKey.currentState!.validate()){

      return;

    }



    setState(() {

      isLoading = true;

    });




    try{


      await FirebaseAuth.instance
          .signInWithEmailAndPassword(

        email:
        emailController.text.trim(),

        password:
        passwordController.text.trim(),

      );



      if(!mounted)return;



      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder:(context)=>
          const HomeScreen(),

        ),

      );



    }

    on FirebaseAuthException catch(e){


      String message =
      "Login failed";


      if(e.code=="user-not-found"){

        message="No account found";

      }

      else if(e.code=="wrong-password"){

        message="Wrong password";

      }

      else if(e.code=="invalid-email"){

        message="Invalid email";

      }

      else if(e.code=="invalid-credential"){

        message="Email or password incorrect";

      }




      if(!mounted)return;



      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(message),

          backgroundColor:
          Colors.red,

        ),

      );


    }




    finally{


      if(mounted){

        setState(() {

          isLoading=false;

        });

      }


    }


  }







  @override
  Widget build(BuildContext context){



    return Scaffold(


      backgroundColor:

      Theme.of(context)
          .scaffoldBackgroundColor,




      body:

      SafeArea(

        child:

        Center(

          child:

          SingleChildScrollView(

            padding:
            const EdgeInsets.all(25),


            child:

            Form(

              key:_formKey,


              child:

              Column(

                children:[




                  Container(

                    height:110,

                    width:110,


                    decoration:

                    BoxDecoration(

                      color:
                      Colors.green,

                      borderRadius:
                      BorderRadius.circular(60),

                    ),



                    child:

                    const Icon(

                      Icons.eco,

                      size:65,

                      color:
                      Colors.white,

                    ),


                  ),






                  const SizedBox(height:20),




                  Text(

                    "FreshTrack",

                    style:

                    TextStyle(

                      fontSize:34,

                      fontWeight:
                      FontWeight.bold,


                      color:

                      Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color,

                    ),

                  ),






                  const SizedBox(height:8),





                  const Text(

                    "Smart Food Waste Management",

                    style:

                    TextStyle(

                      color:
                      Colors.grey,

                      fontSize:16,

                    ),

                  ),






                  const SizedBox(height:35),





                  Card(

                    color:

                    Theme.of(context)
                        .cardColor,


                    elevation:5,


                    shape:

                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(20),

                    ),



                    child:

                    Padding(

                      padding:
                      const EdgeInsets.all(20),



                      child:

                      Column(

                        children:[




                          TextFormField(

                            controller:
                            emailController,


                            keyboardType:
                            TextInputType.emailAddress,



                            decoration:

                            InputDecoration(


                              labelText:
                              "Email",



                              prefixIcon:

                              const Icon(
                                  Icons.email),



                              filled:true,


                              fillColor:

                              Theme.of(context)
                                  .scaffoldBackgroundColor,



                              border:

                              OutlineInputBorder(

                                borderRadius:
                                BorderRadius.circular(15),

                              ),

                            ),



                            validator:(value){


                              if(value==null ||
                                  value.isEmpty){

                                return "Enter email";

                              }


                              if(!value.contains("@")){

                                return "Invalid email";

                              }


                              return null;


                            },


                          ),







                          const SizedBox(height:20),






                          TextFormField(


                            controller:
                            passwordController,


                            obscureText:
                            hidePassword,



                            decoration:

                            InputDecoration(


                              labelText:
                              "Password",



                              prefixIcon:

                              const Icon(
                                  Icons.lock),



                              suffixIcon:

                              IconButton(

                                icon:

                                Icon(

                                  hidePassword

                                      ? Icons.visibility_off

                                      : Icons.visibility,

                                ),



                                onPressed:(){


                                  setState(() {

                                    hidePassword =
                                    !hidePassword;

                                  });


                                },


                              ),




                              filled:true,


                              fillColor:

                              Theme.of(context)
                                  .scaffoldBackgroundColor,




                              border:

                              OutlineInputBorder(

                                borderRadius:
                                BorderRadius.circular(15),

                              ),


                            ),




                            validator:(value){


                              if(value==null ||
                                  value.isEmpty){

                                return "Enter password";

                              }


                              if(value.length<6){

                                return "Minimum 6 characters";

                              }


                              return null;


                            },


                          ),








                          const SizedBox(height:30),







                          SizedBox(

                            width:
                            double.infinity,


                            height:55,



                            child:

                            ElevatedButton(


                              style:

                              ElevatedButton.styleFrom(

                                backgroundColor:
                                Colors.green,


                                foregroundColor:
                                Colors.white,


                                shape:

                                RoundedRectangleBorder(

                                  borderRadius:
                                  BorderRadius.circular(15),

                                ),

                              ),




                              onPressed:

                              isLoading
                                  ? null
                                  : login,





                              child:

                              isLoading

                                  ?

                              const CircularProgressIndicator(

                                color:
                                Colors.white,

                              )


                                  :

                              const Text(

                                "Login",

                                style:

                                TextStyle(

                                  fontSize:18,

                                  fontWeight:
                                  FontWeight.bold,

                                ),

                              ),


                            ),


                          ),



                        ],


                      ),


                    ),


                  ),







                  const SizedBox(height:15),






                  TextButton(

                    onPressed:(){


                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder:(context)=>
                          const SignupScreen(),

                        ),

                      );


                    },


                    child:

                    const Text(

                      "Create New Account",

                    ),


                  ),




                ],

              ),

            ),

          ),

        ),

      ),


    );


  }


}