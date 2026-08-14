import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'edit_food_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String getStatus(int days) {
    if (days < 0) {
      return "Expired";
    } else if (days <= 3) {
      return "Expiring Soon";
    } else {
      return "Fresh";
    }
  }

  Color getStatusColor(int days) {
    if (days < 0) {
      return Colors.red;
    } else if (days <= 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  int getDaysLeft(Timestamp expiry) {
    final DateTime expiryDate = expiry.toDate();
    final DateTime today = DateTime.now();

    final DateTime expiryDay = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    );

    final DateTime todayDay = DateTime(
      today.year,
      today.month,
      today.day,
    );

    return expiryDay.difference(todayDay).inDays;
  }

  Future<void> deleteFood(String id) async {
    await FirebaseFirestore.instance
        .collection("foods")
        .doc(id)
        .delete();
  }

  Future<bool?> handleDismiss(
    DismissDirection direction,
    QueryDocumentSnapshot food,
    Timestamp expiry,
  ) async {
    // =========================
    // DELETE
    // =========================
    if (direction == DismissDirection.endToStart) {
      try {
        await deleteFood(food.id);

        if (!mounted) {
          return false;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Food deleted"),
          ),
        );

        return true;
      } catch (e) {
        if (!mounted) {
          return false;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete food: $e"),
          ),
        );

        return false;
      }
    }

    // =========================
    // EDIT
    // =========================
    if (direction == DismissDirection.startToEnd) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditFoodScreen(
            id: food.id,
            name: food["name"],
            category: food["category"],
            expiryDate: expiry.toDate(),
          ),
        ),
      );

      return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please login"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("foods")
            .where(
              "userId",
              isEqualTo: user.uid,
            )
            .snapshots(),
        builder: (context, snapshot) {
          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          // Loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // No data
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No food items found",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          final List<QueryDocumentSnapshot> foods =
              snapshot.data!.docs;

          return ListView.builder(
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final QueryDocumentSnapshot food =
                  foods[index];

              final Timestamp expiry =
                  food["expiryDate"] as Timestamp;

              final int days =
                  getDaysLeft(expiry);

              return Dismissible(
                key: ValueKey(food.id),

                direction:
                    DismissDirection.horizontal,

                // =========================
                // SWIPE RIGHT = EDIT
                // =========================
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    left: 20,
                  ),
                  color: Colors.green,
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),

                // =========================
                // SWIPE LEFT = DELETE
                // =========================
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(
                    right: 20,
                  ),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),

                confirmDismiss: (direction) {
                  return handleDismiss(
                    direction,
                    food,
                    expiry,
                  );
                },

                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  elevation: 3,

                  child: ListTile(
                    // =========================
                    // ICON
                    // =========================
                    leading: CircleAvatar(
                      backgroundColor:
                          getStatusColor(days),
                      child: const Icon(
                        Icons.fastfood,
                        color: Colors.white,
                      ),
                    ),

                    // =========================
                    // FOOD NAME
                    // =========================
                    title: Text(
                      food["name"].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // =========================
                    // DETAILS
                    // =========================
                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          food["category"].toString(),
                        ),

                        Text(
                          "Expires: ${expiry.toDate().toString().split(" ")[0]}",
                        ),

                        Text(
                          days < 0
                              ? "${days.abs()} days expired"
                              : days == 0
                                  ? "Expires today"
                                  : "$days days remaining",
                          style: TextStyle(
                            color:
                                getStatusColor(days),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // =========================
                    // STATUS
                    // =========================
                    trailing: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            getStatusColor(days),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        getStatus(days),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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