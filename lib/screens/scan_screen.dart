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
  final ProductService productService = ProductService();

  bool isLoading = false;

  // Prevent multiple barcode detections.
  bool barcodeDetected = false;

  // Prevent the same barcode from being searched repeatedly.
  String? lastBarcode;

  // --------------------------------------------------
  // SEARCH PRODUCT
  // --------------------------------------------------

  Future<void> searchProduct(String barcode) async {
    barcode = barcode.trim();

    if (barcode.isEmpty) {
      return;
    }

    // Don't process another barcode while searching.
    if (barcodeDetected || isLoading) {
      return;
    }

    // Don't immediately search the same barcode again.
    if (lastBarcode == barcode) {
      return;
    }

    // Lock scanner immediately.
    barcodeDetected = true;
    lastBarcode = barcode;

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      debugPrint("🔎 Searching barcode: $barcode");

      final product =
          await productService.getProduct(barcode);

      if (!mounted) {
        return;
      }

      // --------------------------------------------------
      // PRODUCT FOUND
      // --------------------------------------------------

      if (product != null) {
        setState(() {
          isLoading = false;
        });

        debugPrint(
          "✅ Product found: ${product["name"]}",
        );

        // --------------------------------------------------
        // OPEN ADD FOOD
        // --------------------------------------------------

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddFoodScreen(
              scannedName: product["name"],
              scannedCategory: product["category"],
            ),
          ),
        );

        if (!mounted) {
          return;
        }

        // --------------------------------------------------
        // FOOD SUCCESSFULLY SAVED
        // --------------------------------------------------

        if (result == true) {
          debugPrint(
            "✅ Food saved. Returning to HomeScreen.",
          );

          // Return true to HomeScreen.
          Navigator.pop(context, true);

          return;
        }

        // --------------------------------------------------
        // USER CAME BACK WITHOUT SAVING
        // --------------------------------------------------

        setState(() {
          barcodeDetected = false;
          lastBarcode = null;
        });

        return;
      }

      // --------------------------------------------------
      // PRODUCT NOT FOUND
      // --------------------------------------------------

      setState(() {
        isLoading = false;
      });

      debugPrint(
        "❌ Product not found: $barcode",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Product not found in Open Food Facts.",
          ),
          duration: Duration(seconds: 3),
        ),
      );

      // Wait before allowing another scan.
      await Future.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        barcodeDetected = false;
        lastBarcode = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      debugPrint(
        "❌ Barcode search error: $e",
      );

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Could not search product.",
          ),
          duration: Duration(seconds: 3),
        ),
      );

      await Future.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        barcodeDetected = false;
        lastBarcode = null;
      });
    }
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan Food",
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: Stack(
        children: [
          // --------------------------------------------------
          // BARCODE SCANNER
          // --------------------------------------------------

          MobileScanner(
            onDetect: (capture) {
              if (barcodeDetected || isLoading) {
                return;
              }

              for (final barcode
                  in capture.barcodes) {
                final String? value =
                    barcode.rawValue;

                if (value != null &&
                    value.trim().isNotEmpty) {
                  searchProduct(
                    value.trim(),
                  );

                  break;
                }
              }
            },
          ),

          // --------------------------------------------------
          // SCANNER BOX
          // --------------------------------------------------

          Center(
            child: Container(
              width: 280,
              height: 180,

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),

                borderRadius:
                    BorderRadius.circular(20),
              ),
            ),
          ),

          // --------------------------------------------------
          // INSTRUCTION
          // --------------------------------------------------

          const Positioned(
            top: 30,
            left: 20,
            right: 20,

            child: Text(
              "Place the barcode inside the box",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,

                shadows: [
                  Shadow(
                    blurRadius: 5,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),

          // --------------------------------------------------
          // LOADING
          // --------------------------------------------------

          if (isLoading)
            Container(
              color: Colors.black54,

              child: const Center(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),

                    SizedBox(height: 15),

                    Text(
                      "Finding product...",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // --------------------------------------------------
          // TEST BUTTON
          // --------------------------------------------------

          Positioned(
            bottom: 40,
            left: 30,
            right: 30,

            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green,

                foregroundColor:
                    Colors.white,

                disabledBackgroundColor:
                    Colors.green.withValues(
                  alpha: 0.5,
                ),

                padding:
                    const EdgeInsets.all(15),
              ),

              onPressed:
                  (isLoading ||
                          barcodeDetected)
                      ? null
                      : () {
                          searchProduct(
                            "8901030899002",
                          );
                        },

              child: const Text(
                "Test Barcode Scan",

                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}