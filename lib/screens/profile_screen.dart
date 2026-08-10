import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';


class ProfileScreen extends StatelessWidget {

  const ProfileScreen({super.key});


  Future<void> logout(BuildContext context) async {

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );

  }



  @override
  Widget build(BuildContext context) {


    User? user =
        FirebaseAuth.instance.currentUser;


    final theme =
        Theme.of(context);



    return Scaffold(

      backgroundColor:
      theme.scaffoldBackgroundColor,


      appBar: AppBar(

        elevation: 0,

        backgroundColor:
        Colors.transparent,


        title: Text(

          "Profile",

          style: TextStyle(

            color:
            theme.textTheme.bodyLarge!.color,

            fontWeight:
            FontWeight.bold,

          ),

        ),


        iconTheme: IconThemeData(

          color:
          theme.textTheme.bodyLarge!.color,

        ),

      ),



      body: SingleChildScrollView(


        padding:
        const EdgeInsets.all(20),



        child: Column(

          children: [



            const SizedBox(height:20),




            CircleAvatar(

              radius:55,


              backgroundColor:
              theme.colorScheme.primary,


              child: const Icon(

                Icons.person,

                size:65,

                color: Colors.white,

              ),

            ),



            const SizedBox(height:20),




            Text(

              user?.email ?? "User",


              style: TextStyle(

                fontSize:20,

                fontWeight:
                FontWeight.bold,

                color:
                theme.textTheme.bodyLarge!.color,

              ),

            ),




            const SizedBox(height:30),




            profileCard(

              context,

              icon: Icons.email,

              title: "Email",

              value:
              user?.email ?? "Not available",

            ),



            profileCard(

              context,

              icon: Icons.security,

              title: "Account",

              value:
              "Firebase Authentication",

            ),



            profileCard(

              context,

              icon: Icons.eco,

              title: "Application",

              value:
              "FreshTrack",

            ),





            const SizedBox(height:30),




            SizedBox(

              width:
              double.infinity,


              height:55,



              child: ElevatedButton.icon(


                style:
                ElevatedButton.styleFrom(


                  backgroundColor:
                  Colors.red,


                  foregroundColor:
                  Colors.white,



                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(18),

                  ),

                ),



                icon:
                const Icon(Icons.logout),



                label:
                const Text(

                  "Logout",

                  style:
                  TextStyle(

                    fontSize:18,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),



                onPressed: () {


                  showDialog(

                    context: context,


                    builder: (context) {


                      return AlertDialog(


                        backgroundColor: theme.dialogTheme.backgroundColor,



                        title:
                        const Text(
                          "Logout",
                        ),



                        content:
                        const Text(

                          "Are you sure you want to logout?",

                        ),




                        actions: [



                          TextButton(

                            onPressed: () {

                              Navigator.pop(context);

                            },


                            child:
                            const Text(
                              "Cancel",
                            ),

                          ),




                          TextButton(

                            onPressed: () {

                              Navigator.pop(context);

                              logout(context);

                            },


                            child:
                            const Text(

                              "Logout",

                              style:
                              TextStyle(

                                color:
                                Colors.red,

                              ),

                            ),

                          ),


                        ],


                      );


                    },


                  );


                },


              ),

            ),




            const SizedBox(height:25),




            Text(

              "FreshTrack v1.0.0",


              style: TextStyle(

                color:
                theme.textTheme.bodySmall!.color,

              ),

            ),



          ],


        ),


      ),


    );


  }







  Widget profileCard(

      BuildContext context,

      {

        required IconData icon,

        required String title,

        required String value,

      }

      ) {



    final theme =
        Theme.of(context);



    return Card(


      elevation:3,


      color:
      theme.cardColor,



      margin:
      const EdgeInsets.only(

        bottom:15,

      ),




      shape:
      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(20),

      ),



      child:
      ListTile(



        leading:
        CircleAvatar(


          backgroundColor:
          theme.colorScheme.primary.withValues(alpha:0.15),



          child:
          Icon(

            icon,

            color:
            theme.colorScheme.primary,

          ),


        ),




        title:
        Text(

          title,

          style: TextStyle(

            fontWeight:
            FontWeight.bold,

            color:
            theme.textTheme.bodyLarge!.color,

          ),

        ),




        subtitle:
        Text(

          value,

          style: TextStyle(

            color:
            theme.textTheme.bodyMedium!.color,

          ),

        ),



      ),


    );


  }


}