import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add new food
  Future<void> addFood({
    required String name,
    required String category,
    required DateTime expiryDate,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await _db.collection("foods").add({
      "userId": user.uid,
      "name": name,
      "category": category,
      "expiryDate": Timestamp.fromDate(expiryDate),
      "createdAt": Timestamp.now(),
    });
  }

  /// Get current user's foods (Realtime)
  Stream<QuerySnapshot<Map<String, dynamic>>> getFoods() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _db
        .collection("foods")
        .where("userId", isEqualTo: user.uid)
        .snapshots();
  }

  /// Get current user's foods once
  Future<QuerySnapshot<Map<String, dynamic>>> getFoodsOnce() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    return await _db
        .collection("foods")
        .where("userId", isEqualTo: user.uid)
        .get();
  }

  /// Update food
  Future<void> updateFood({
    required String id,
    required String name,
    required String category,
    required DateTime expiryDate,
  }) async {
    await _db.collection("foods").doc(id).update({
      "name": name,
      "category": category,
      "expiryDate": Timestamp.fromDate(expiryDate),
    });
  }

  /// Delete food
  Future<void> deleteFood(String id) async {
    await _db.collection("foods").doc(id).delete();
  }
}