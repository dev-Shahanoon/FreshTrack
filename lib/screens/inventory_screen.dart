import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'edit_food_screen.dart';


class InventoryScreen extends StatelessWidget {


  const InventoryScreen({super.key});



  String getStatus(int days) {

    if(days < 0){

      return "Expired";

    }
    else if(days <= 3){

      return "Expiring Soon";

    }
    else{

      return "Fresh";

    }

  }




  Color getStatusColor(int days) {


    if(days < 0){

      return Colors.red;

    }
    else if(days <=3){

      return Colors.orange;

    }
    else{

      return Colors.green;

    }

  }




  int getDaysLeft(Timestamp expiry){


    DateTime expiryDate =
    expiry.toDate();


    DateTime today =
    DateTime.now();



    return DateTime(

      expiryDate.year,

      expiryDate.month,

      expiryDate.day,

    )
        .difference(

      DateTime(

        today.year,

        today.month,

        today.day,

      ),

    )
        .inDays;

  }






  Future<void> deleteFood(String id) async {


    await FirebaseFirestore.instance

        .collection("foods")

        .doc(id)

        .delete();


  }






  @override
  Widget build(BuildContext context) {


    final user =
    FirebaseAuth.instance.currentUser;



    if(user == null){


      return const Scaffold(

        body:

        Center(

          child:

          Text("Please login"),

        ),

      );


    }






    return Scaffold(



      appBar: AppBar(


        title:

        const Text("Inventory"),



        backgroundColor:

        Colors.green,



        foregroundColor:

        Colors.white,


      ),





      body:StreamBuilder<QuerySnapshot>(



        stream:

        FirebaseFirestore.instance

            .collection("foods")

            .where(

          "userId",

          isEqualTo:user.uid,

        )

            .snapshots(),





        builder:(context,snapshot){



          if(snapshot.hasError){


            return Center(

              child:

              Text(

                snapshot.error.toString(),

              ),

            );


          }





          if(snapshot.connectionState ==
              ConnectionState.waiting){


            return const Center(

              child:

              CircularProgressIndicator(),

            );


          }





          if(!snapshot.hasData ||
              snapshot.data!.docs.isEmpty){


            return const Center(

              child:

              Text(

                "No food items found",

                style:

                TextStyle(

                  fontSize:18,

                ),

              ),

            );


          }





          return ListView.builder(



            itemCount:

            snapshot.data!.docs.length,





            itemBuilder:(context,index){



              final food =
              snapshot.data!.docs[index];



              final Timestamp expiry =
              food["expiryDate"];



              final int days =
              getDaysLeft(expiry);






              return Dismissible(



                key:

                ValueKey(food.id),




                direction:

                DismissDirection.horizontal,





                background:

                Container(


                  alignment:

                  Alignment.centerLeft,


                  padding:

                  const EdgeInsets.only(left:20),



                  color:

                  Colors.green,



                  child:

                  const Icon(

                    Icons.edit,

                    color:

                    Colors.white,

                  ),


                ),





                secondaryBackground:

                Container(


                  alignment:

                  Alignment.centerRight,


                  padding:

                  const EdgeInsets.only(right:20),



                  color:

                  Colors.red,



                  child:

                  const Icon(

                    Icons.delete,

                    color:

                    Colors.white,

                  ),


                ),






                confirmDismiss:

                    (direction) async {



                  if(direction ==
                      DismissDirection.endToStart){



                    await deleteFood(food.id);



                    ScaffoldMessenger.of(context)

                        .showSnackBar(

                      const SnackBar(

                        content:

                        Text(
                          "Food deleted",
                        ),

                      ),

                    );



                    return true;


                  }







                  if(direction ==
                      DismissDirection.startToEnd){



                    Navigator.push(


                      context,


                      MaterialPageRoute(


                        builder:(context)=>


                        EditFoodScreen(


                          id:

                          food.id,



                          name:

                          food["name"],



                          category:

                          food["category"],



                          expiryDate:

                          expiry.toDate(),


                        ),


                      ),


                    );



                    return false;


                  }



                  return false;



                },








                child:

                Card(



                  margin:

                  const EdgeInsets.symmetric(

                    horizontal:15,

                    vertical:8,

                  ),



                  elevation:

                  3,





                  child:

                  ListTile(




                    leading:

                    CircleAvatar(


                      backgroundColor:

                      getStatusColor(days),



                      child:

                      const Icon(

                        Icons.fastfood,

                        color:

                        Colors.white,

                      ),


                    ),





                    title:

                    Text(


                      food["name"],



                      style:

                      const TextStyle(

                        fontWeight:

                        FontWeight.bold,

                      ),


                    ),





                    subtitle:

                    Column(



                      crossAxisAlignment:

                      CrossAxisAlignment.start,



                      children:[




                        Text(

                          food["category"],

                        ),





                        Text(

                          "Expires: ${expiry.toDate().toString().split(" ")[0]}",

                        ),





                        Text(


                          days < 0

                              ?

                          "${days.abs()} days expired"

                              :

                          "$days days remaining",



                          style:

                          TextStyle(


                            color:

                            getStatusColor(days),



                            fontWeight:

                            FontWeight.bold,


                          ),


                        ),




                      ],



                    ),







                    trailing:

                    Container(



                      padding:

                      const EdgeInsets.symmetric(

                        horizontal:10,

                        vertical:5,

                      ),



                      decoration:

                      BoxDecoration(


                        color:

                        getStatusColor(days),



                        borderRadius:

                        BorderRadius.circular(20),


                      ),




                      child:

                      Text(



                        getStatus(days),



                        style:

                        const TextStyle(



                          color:

                          Colors.white,



                          fontSize:12,



                        ),



                      ),



                    ),




                  ),



                ),



              );


            },



          );


        },


      ),



    );


  }


}