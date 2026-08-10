import 'package:flutter/material.dart';
import '../services/firestore_service.dart';


class AddFoodScreen extends StatefulWidget {


  final String? scannedName;
  final String? scannedCategory;


  const AddFoodScreen({

    super.key,

    this.scannedName,

    this.scannedCategory,

  });



  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();

}




class _AddFoodScreenState extends State<AddFoodScreen> {


  late TextEditingController nameController;

  late TextEditingController categoryController;


  DateTime? selectedDate;


  final FirestoreService firestore =
      FirestoreService();





  @override
  void initState() {

    super.initState();


    nameController = TextEditingController(

      text: widget.scannedName ?? "",

    );


    categoryController = TextEditingController(

      text: widget.scannedCategory ?? "",

    );


  }





  Future<void> pickDate() async {


    DateTime? picked = await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime.now(),

      lastDate: DateTime(2035),

    );



    if(picked != null){

      setState(() {

        selectedDate = picked;

      });

    }


  }







  Future<void> saveFood() async {


    if(nameController.text.isEmpty ||

        categoryController.text.isEmpty ||

        selectedDate == null){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text("Please fill all fields"),

        ),

      );


      return;

    }






    await firestore.addFood(

      name: nameController.text,

      category: categoryController.text,

      expiryDate: selectedDate!,

    );





    if(!mounted) return;





    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        content:
        Text("Food Added Successfully"),

      ),

    );





    Navigator.pop(context);



  }








  @override
  Widget build(BuildContext context) {


    return Scaffold(



      appBar: AppBar(


        title:
        const Text("Add Food"),


        backgroundColor:
        Colors.green,


        foregroundColor:
        Colors.white,


      ),





      body:


      Padding(


        padding:
        const EdgeInsets.all(20),




        child:


        Column(



          children:[





            TextField(


              controller:
              nameController,


              decoration:
              const InputDecoration(


                labelText:
                "Food Name",


                border:
                OutlineInputBorder(),


              ),


            ),





            const SizedBox(height:20),





            TextField(


              controller:
              categoryController,


              decoration:
              const InputDecoration(


                labelText:
                "Category",


                border:
                OutlineInputBorder(),


              ),


            ),






            const SizedBox(height:20),






            SizedBox(


              width:
              double.infinity,



              child:


              ElevatedButton(


                onPressed:
                pickDate,



                child:


                Text(


                  selectedDate == null

                      ? "Choose Expiry Date"

                      :

                  selectedDate
                      .toString()
                      .split(" ")[0],


                ),


              ),


            ),







            const SizedBox(height:30),







            SizedBox(


              width:
              double.infinity,



              child:


              ElevatedButton(


                style:
                ElevatedButton.styleFrom(


                  backgroundColor:
                  Colors.green,


                  foregroundColor:
                  Colors.white,


                ),



                onPressed:
                saveFood,



                child:
                const Text(
                    "Save Food"
                ),



              ),


            ),





          ],


        ),


      ),


    );


  }


}