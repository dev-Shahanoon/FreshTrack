import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  int calculateDays(Timestamp expiry) {
    DateTime expiryDate = expiry.toDate();
    DateTime now = DateTime.now();

    return DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    ).difference(
      DateTime(
        now.year,
        now.month,
        now.day,
      ),
    ).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expiry Alerts"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService().getFoods(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("No data"),
            );
          }

          final foods = snapshot.data!.docs;

          final alertFoods = foods.where((food) {
            final days = calculateDays(food["expiryDate"]);
            return days <= 3;
          }).toList();

          if (alertFoods.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 70,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "No Expiry Alerts",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: alertFoods.length,
            itemBuilder: (context, index) {
              final food = alertFoods[index];

              final days = calculateDays(food["expiryDate"]);

              final expired = days < 0;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        expired ? Colors.red : Colors.orange,
                    child: Icon(
                      expired
                          ? Icons.error
                          : Icons.warning,
                      color: Colors.white,
                    ),
                  ),

                  title: Text(
                    food["name"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    "${food["category"]}\n"
                    "${expired ? "Expired" : "$days days remaining"}",
                  ),

                  trailing: Text(
                    expired ? "Expired" : "Soon",
                    style: TextStyle(
                      color:
                          expired ? Colors.red : Colors.orange,
                      fontWeight: FontWeight.bold,
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