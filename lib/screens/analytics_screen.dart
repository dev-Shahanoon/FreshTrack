import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please login first"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("foods")
            .where("userId", isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          int fresh = 0;
          int expiring = 0;
          int expired = 0;

          for (var food in snapshot.data!.docs) {
            int days = calculateDays(food["expiryDate"]);

            if (days < 0) {
              expired++;
            } else if (days <= 3) {
              expiring++;
            } else {
              fresh++;
            }
          }

          int total = fresh + expiring + expired;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Food Status",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        total == 0
                            ? const SizedBox(
                                height: 220,
                                child: Center(
                                  child: Text(
                                    "No food data available",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 250,
                                child: PieChart(
                                  PieChartData(
                                    centerSpaceRadius: 50,
                                    sections: [
                                      PieChartSectionData(
                                        value: fresh.toDouble(),
                                        title: "Fresh\n$fresh",
                                        color: Colors.green,
                                        radius: 80,
                                      ),
                                      PieChartSectionData(
                                        value: expiring.toDouble(),
                                        title: "Soon\n$expiring",
                                        color: Colors.orange,
                                        radius: 80,
                                      ),
                                      PieChartSectionData(
                                        value: expired.toDouble(),
                                        title: "Expired\n$expired",
                                        color: Colors.red,
                                        radius: 80,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    analyticsCard(
                      "Fresh",
                      fresh,
                      Colors.green,
                    ),
                    analyticsCard(
                      "Expiring",
                      expiring,
                      Colors.orange,
                    ),
                    analyticsCard(
                      "Expired",
                      expired,
                      Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
    Widget analyticsCard(
    String title,
    int count,
    Color color,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}