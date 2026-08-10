import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/product_service.dart';
import 'add_food_screen.dart';



class ScanScreen extends StatefulWidget {

  const ScanScreen({super.key});


  @override
  State<ScanScreen> createState() => _ScanScreenState();

}




class _ScanScreenState extends State<ScanScreen> {


  final ProductService productService =
      ProductService();


  bool isLoading = false;




  Future<void> searchProduct(String barcode) async {


    setState(() {

      isLoading = true;

    });



    final product =
    await productService.getProduct(barcode);



    setState(() {

      isLoading = false;

    });





    if (product != null) {

  if (!mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddFoodScreen(
        scannedName: product["name"],
        scannedCategory: product["category"],
      ),
    ),
  );

}

    else{

if (product == null) {

  if (!mounted) return;

  ScaffoldMessenger.of(context)
      .showSnackBar(
        const SnackBar(
          content: Text(
            "Product not found",
          ),
        ),
      );

}


    }


  }





  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title:
        const Text("Scan Food"),

        backgroundColor:
        Colors.green,

        foregroundColor:
        Colors.white,

      ),




      body:


      Stack(

        children:[




          MobileScanner(


            onDetect:(capture){



              if(isLoading) return;



              for(final barcode
              in capture.barcodes){



                if(barcode.rawValue != null){



                  searchProduct(
                    barcode.rawValue!,
                  );


                  break;


                }


              }


            },


          ),






          Positioned(

            bottom:40,

            left:30,

            right:30,


            child:


            ElevatedButton(


              style:

              ElevatedButton.styleFrom(

                backgroundColor:
                Colors.green,

                foregroundColor:
                Colors.white,

                padding:
                const EdgeInsets.all(15),

              ),



              onPressed:(){


                // Test barcode

                searchProduct(
                  "8901030899002",
                );


              },



              child:

              const Text(

                "Test Barcode Scan",

                style:

                TextStyle(

                  fontSize:18,

                ),

              ),



            ),


          ),






          if(isLoading)


            const Center(

              child:

              CircularProgressIndicator(),

            ),



        ],


      ),



    );


  }


}