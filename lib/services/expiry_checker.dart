import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

class ExpiryChecker {
  static Future<void> checkExpiry() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();

    final today =
        DateTime.now().toIso8601String().substring(0, 10);

    final lastCheck =
        prefs.getString("last_notification_date");

    // Already checked today
    if (lastCheck == today) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("foods")
        .where("userId", isEqualTo: user.uid)
        .get();

    final now = DateTime.now();

    for (final food in snapshot.docs) {
      final expiry =
          (food["expiryDate"] as Timestamp).toDate();

      final daysLeft = DateTime(
        expiry.year,
        expiry.month,
        expiry.day,
      ).difference(
        DateTime(
          now.year,
          now.month,
          now.day,
        ),
      ).inDays;

      if (daysLeft < 0 || daysLeft > 3) continue;

      String body;

      if (daysLeft == 0) {
        body = "${food["name"]} expires today";
      } else if (daysLeft == 1) {
        body = "${food["name"]} expires tomorrow";
      } else {
        body =
            "${food["name"]} expires in $daysLeft days";
      }

      await NotificationService.showNotification(
        title: "FreshTrack Alert 🔔",
        body: body,
      );
    }

    await prefs.setString(
      "last_notification_date",
      today,
    );
  }
}