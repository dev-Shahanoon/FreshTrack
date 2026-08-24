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
  late final TextEditingController nameController;
  late final TextEditingController categoryController;

  DateTime? selectedDate;

  final FirestoreService firestore = FirestoreService();

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.scannedName ?? '',
    );

    categoryController = TextEditingController(
      text: widget.scannedCategory ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // PICK EXPIRY DATE
  // --------------------------------------------------

  Future<void> pickDate() async {
    final DateTime today = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(2035),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // --------------------------------------------------
  // SAVE FOOD
  // --------------------------------------------------

  Future<void> saveFood() async {
    // Prevent multiple taps.
    if (isSaving) {
      return;
    }

    final String name = nameController.text.trim();
    final String category = categoryController.text.trim();

    // Validate fields.
    if (name.isEmpty ||
        category.isEmpty ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields',
          ),
        ),
      );

      return;
    }

    // Start saving.
    setState(() {
      isSaving = true;
    });

    try {
      // --------------------------------------------------
      // SAVE TO FIRESTORE
      // --------------------------------------------------

      await firestore.addFood(
        name: name,
        category: category,
        expiryDate: selectedDate!,
      );

      if (!mounted) {
        return;
      }

      // --------------------------------------------------
      // RETURN SUCCESS RESULT
      // --------------------------------------------------
      //
      // If opened from normal Add Food:
      //
      // Home -> Add Food -> Save -> Home
      //
      // If opened from scanner:
      //
      // Home -> Scan -> Add Food -> Save
      //                      ↓
      //                   returns true
      //                      ↓
      //                    Scan
      //                      ↓
      //                    Home
      //
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save food: $e',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // --------------------------------------------------
      // APP BAR
      // --------------------------------------------------

      appBar: AppBar(
        title: const Text(
          'Add Food',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // --------------------------------------------------
      // BODY
      // --------------------------------------------------

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // --------------------------------------------------
              // FOOD NAME
              // --------------------------------------------------

              TextField(
                controller: nameController,
                enabled: !isSaving,
                textInputAction: TextInputAction.next,

                decoration: InputDecoration(
                  labelText: 'Food Name',
                  hintText: 'Enter food name',

                  prefixIcon: const Icon(
                    Icons.fastfood_outlined,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Colors.green,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // CATEGORY
              // --------------------------------------------------

              TextField(
                controller: categoryController,
                enabled: !isSaving,
                textInputAction: TextInputAction.done,

                decoration: InputDecoration(
                  labelText: 'Category',
                  hintText: 'Enter category',

                  prefixIcon: const Icon(
                    Icons.category_outlined,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Colors.green,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // EXPIRY DATE
              // --------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 55,

                child: OutlinedButton.icon(
                  onPressed: isSaving ? null : pickDate,

                  icon: const Icon(
                    Icons.calendar_month,
                  ),

                  label: Text(
                    selectedDate == null
                        ? 'Choose Expiry Date'
                        : 'Expiry: '
                            '${selectedDate!.year}-'
                            '${selectedDate!.month.toString().padLeft(2, '0')}-'
                            '${selectedDate!.day.toString().padLeft(2, '0')}',
                  ),

                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        theme.colorScheme.primary,

                    side: BorderSide(
                      color:
                          theme.colorScheme.primary,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --------------------------------------------------
              // SAVE BUTTON
              // --------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed:
                      isSaving ? null : saveFood,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,

                    disabledBackgroundColor:
                        Colors.green.withValues(
                      alpha: 0.5,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),

                  child: isSaving
                      ? const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(width: 12),

                            Text(
                              'Saving...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Save Food',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // INFO
              // --------------------------------------------------

              Container(
                padding:
                    const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: Colors.green.withValues(
                    alpha: 0.08,
                  ),

                  borderRadius:
                      BorderRadius.circular(15),
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.green,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Add the expiry date to receive '
                        'expiry alerts and keep your '
                        'food inventory updated.',
                        style: TextStyle(
                          color: theme
                              .textTheme
                              .bodyMedium
                              ?.color,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}