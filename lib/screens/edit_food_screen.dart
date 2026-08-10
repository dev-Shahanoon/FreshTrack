import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class EditFoodScreen extends StatefulWidget {

  final String id;
  final String name;
  final String category;
  final DateTime expiryDate;


  const EditFoodScreen({
    super.key,
    required this.id,
    required this.name,
    required this.category,
    required this.expiryDate,
  });


  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();

}


class _EditFoodScreenState extends State<EditFoodScreen> {


  late TextEditingController nameController;
  late TextEditingController categoryController;

  late DateTime selectedDate;


  final FirestoreService firestore = FirestoreService();



  @override
  void initState() {

    super.initState();

    nameController =
        TextEditingController(text: widget.name);

    categoryController =
        TextEditingController(text: widget.category);

    selectedDate = widget.expiryDate;

  }



  Future<void> pickDate() async {

    DateTime? picked =
        await showDatePicker(

      context: context,

      initialDate: selectedDate,

      firstDate: DateTime.now(),

      lastDate: DateTime(2035),

    );


    if(picked != null){

      setState(() {

        selectedDate = picked;

      });

    }

  }



  Future<void> updateFood() async {


    await firestore.updateFood(

      id: widget.id,

      name: nameController.text,

      category: categoryController.text,

      expiryDate: selectedDate,

    );


    if(!mounted) return;


    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("Food Updated Successfully"),
      ),

    );


    Navigator.pop(context);


  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Edit Food"),

        backgroundColor: Colors.green,

        foregroundColor: Colors.white,

      ),


      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [


            TextField(

              controller: nameController,

              decoration: const InputDecoration(

                labelText: "Food Name",

              ),

            ),



            const SizedBox(height:20),



            TextField(

              controller: categoryController,

              decoration: const InputDecoration(

                labelText: "Category",

              ),

            ),



            const SizedBox(height:20),



            ElevatedButton(

              onPressed: pickDate,

              child: Text(

                selectedDate
                    .toString()
                    .split(" ")[0],

              ),

            ),



            const SizedBox(height:30),



            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: updateFood,

                child: const Text(
                  "Update Food",
                ),

              ),

            )

          ],

        ),

      ),

    );

  }

}