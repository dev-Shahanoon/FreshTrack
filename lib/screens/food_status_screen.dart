import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'edit_food_screen.dart';


class FoodStatusScreen extends StatelessWidget {

  final String status;


  const FoodStatusScreen({
    super.key,
    required this.status,
  });



  int getDaysLeft(Timestamp expiry){

    final date = expiry.toDate();
    final now = DateTime.now();


    return DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(
      DateTime(
        now.year,
        now.month,
        now.day,
      ),
    ).inDays;

  }



  Color getColor(int days){

    if(days < 0){
      return Colors.red;
    }

    if(days <=3){
      return Colors.orange;
    }

    return Colors.green;

  }



  String getStatus(int days){

    if(days < 0){
      return "Expired";
    }

    if(days <=3){
      return "Expiring Soon";
    }

    return "Fresh";

  }



  Future<void> deleteFood(String id) async{

    await FirebaseFirestore.instance
        .collection("foods")
        .doc(id)
        .delete();

  }





  @override
  Widget build(BuildContext context){


    final user =
    FirebaseAuth.instance.currentUser;



    return Scaffold(


      appBar: AppBar(

        title:Text(status),

        backgroundColor:Colors.green,

        foregroundColor:Colors.white,

      ),



      body:StreamBuilder<QuerySnapshot>(


        stream:FirebaseFirestore.instance
            .collection("foods")
            .where(
          "userId",
          isEqualTo:user!.uid,
        )
            .snapshots(),




        builder:(context,snapshot){


          if(!snapshot.hasData){

            return const Center(
              child:CircularProgressIndicator(),
            );

          }



          var foods =
          snapshot.data!.docs.where((food){


            int days =
            getDaysLeft(
              food["expiryDate"],
            );


            if(status=="Total"){
              return true;
            }


            if(status=="Expiring"){
              return days >=0 && days <=3;
             }

            if(status=="Expired"){
              return days < 0;
             }

             if(status=="Fresh"){
              return days >3;
             }

             return false;


             }).toList();

 
          if(foods.isEmpty){

            return const Center(

              child:

              Text(
                "No food found",
                style:TextStyle(fontSize:18),
              ),

            );

          }






          return ListView.builder(


            itemCount:foods.length,



            itemBuilder:(context,index){


              final food =
              foods[index];


              final expiry =
              food["expiryDate"];


              final days =
              getDaysLeft(expiry);




              return Dismissible(


                key:ValueKey(food.id),



                background:Container(

                  color:Colors.green,

                  alignment:Alignment.centerLeft,

                  padding:
                  const EdgeInsets.only(left:20),

                  child:
                  const Icon(
                    Icons.edit,
                    color:Colors.white,
                  ),

                ),




                secondaryBackground:Container(

                  color:Colors.red,

                  alignment:
                  Alignment.centerRight,

                  padding:
                  const EdgeInsets.only(right:20),

                  child:
                  const Icon(
                    Icons.delete,
                    color:Colors.white,
                  ),

                ),





                confirmDismiss:(direction) async{


                  if(direction ==
                      DismissDirection.endToStart){


                    await deleteFood(food.id);


                    return true;

                  }




                  if(direction ==
                      DismissDirection.startToEnd){


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder:(_)=>

                        EditFoodScreen(

                          id:food.id,

                          name:food["name"],

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





                child:Card(

                  margin:
                  const EdgeInsets.all(10),


                  child:ListTile(


                    leading:CircleAvatar(

                      backgroundColor:
                      getColor(days),

                      child:
                      const Icon(
                        Icons.fastfood,
                        color:Colors.white,
                      ),

                    ),




                    title:Text(

                      food["name"],

                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),

                    ),




                    subtitle:Text(

                      days < 0
                          ?
                      "${days.abs()} days expired"
                          :
                      "$days days remaining",

                    ),



                    trailing:Text(

                      getStatus(days),

                      style:

                      TextStyle(

                        color:
                        getColor(days),

                        fontWeight:
                        FontWeight.bold,

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