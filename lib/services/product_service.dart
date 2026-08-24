import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProductService {
  Future<Map<String, dynamic>?> getProduct(String barcode) async {
    try {
      // Clean the barcode before sending it.
      final cleanBarcode = barcode.trim();

      if (cleanBarcode.isEmpty) {
        return null;
      }

      debugPrint("🔎 Searching barcode: $cleanBarcode");

      final url = Uri.parse(
        "https://world.openfoodfacts.org/api/v2/product/$cleanBarcode.json",
      );

      final response = await http.get(
        url,
        headers: {
          "User-Agent":
              "FreshTrack/1.0 (FreshTrack food inventory app)",
          "Accept": "application/json",
        },
      );

      debugPrint("📡 API status: ${response.statusCode}");
      debugPrint("📦 API response: ${response.body}");

      if (response.statusCode != 200) {
        debugPrint(
          "❌ Open Food Facts returned ${response.statusCode}",
        );
        return null;
      }

      final data = jsonDecode(response.body);

      // Product does not exist in Open Food Facts.
      if (data["status"] != 1) {
        debugPrint("❌ Product not found: $cleanBarcode");
        return null;
      }

      final product = data["product"];

      if (product == null) {
        debugPrint("❌ Product data is empty.");
        return null;
      }

      // Try several possible product-name fields.
      String name = "";

      if (product["product_name"] != null) {
        name = product["product_name"].toString().trim();
      }

      if (name.isEmpty &&
          product["product_name_en"] != null) {
        name = product["product_name_en"].toString().trim();
      }

      if (name.isEmpty &&
          product["generic_name"] != null) {
        name = product["generic_name"].toString().trim();
      }

      if (name.isEmpty) {
        name = "Unknown Food";
      }

      // Get category.
      String category = "";

      if (product["categories"] != null) {
        category = product["categories"].toString().trim();
      }

      if (category.isEmpty &&
          product["categories_tags_en"] != null) {
        final categories =
            product["categories_tags_en"];

        if (categories is List &&
            categories.isNotEmpty) {
          category = categories.last.toString();
        }
      }

      if (category.isEmpty) {
        category = "General";
      }

      debugPrint("✅ Product found!");
      debugPrint("🍎 Name: $name");
      debugPrint("📂 Category: $category");

      return {
        "name": name,
        "category": category,
        "barcode": cleanBarcode,
      };
    } catch (e) {
      debugPrint("❌ Product lookup error: $e");
      return null;
    }
  }
}