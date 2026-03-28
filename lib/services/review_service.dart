import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  /// ⭐ Submit or Update Review
  Future<void> submitReview({
    required String workerId,
    required String userId,
    required double rating,
  }) async {
    // 🚫 Prevent self rating
    if (workerId == userId) {
      throw Exception("You cannot rate yourself");
    }

    // 🔍 Check if review already exists
    final existingReview = await db
        .collection("reviews")
        .where("workerId", isEqualTo: workerId)
        .where("userId", isEqualTo: userId)
        .get();

    if (existingReview.docs.isNotEmpty) {
      // 🔁 UPDATE existing review
      final reviewDocId = existingReview.docs.first.id;

      await db.collection("reviews").doc(reviewDocId).update({
        "rating": rating,

        "updatedAt": FieldValue.serverTimestamp(),
      });
    } else {
      // ➕ ADD new review
      await db.collection("reviews").add({
        "workerId": workerId,
        "userId": userId,
        "rating": rating,

        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    // 🔄 Recalculate rating after add/update
    await recalculateRating(workerId);
  }

  /// ⭐ Recalculate average rating
  Future<void> recalculateRating(String workerId) async {
    final reviewsSnapshot = await db
        .collection("reviews")
        .where("workerId", isEqualTo: workerId)
        .get();

    double total = 0;

    for (var doc in reviewsSnapshot.docs) {
      total += (doc["rating"] as num).toDouble();
    }

    double avg = reviewsSnapshot.docs.isEmpty
        ? 0
        : total / reviewsSnapshot.docs.length;

    await db.collection("workers").doc(workerId).update({
      "rating": avg,
      "totalRating": reviewsSnapshot.docs.length,
    });
  }
}
