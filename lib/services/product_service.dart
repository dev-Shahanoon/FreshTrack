import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class ProductService {


  Future<Map<String, dynamic>?> getProduct(
      String barcode
      ) async {


    try {


      final url = Uri.parse(
        "https://world.openfoodfacts.org/api/v0/product/$barcode.json",
      );


      final response = await http.get(url);



      if (response.statusCode == 200) {


        final data = json.decode(response.body);



        if (data["status"] == 1) {


          final product = data["product"];



          return {


            "name":
            product["product_name"] ?? "Unknown Food",


            "category":
            product["categories"] ?? "General",


          };


        }


      }


    } catch (e) {


      debugPrint(e.toString());


    }


    return null;


  }


}