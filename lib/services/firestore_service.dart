import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

import '../models/job_model.dart';
import '../models/worker_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveWorkerProfile(
    WorkerModel worker,
    List<JobModel> jobs,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final geopoint = GeoPoint(worker.latitude, worker.longitude);
    final geo = GeoFirePoint(geopoint);

    /// NEW: extract job types from jobs list
    final jobTypes = jobs
        .map((job) => job.jobType.toLowerCase())
        .toSet()
        .toList();

    /// SAVE WORKER
    await _db.collection("workers").doc(uid).set({
      ...worker.toMap(),

      /// NEW FIELD
      "jobTypes": jobTypes,

      /// GEO FIELD (for distance search later)
      "geo": geo.data,
    }, SetOptions(merge: true));

    /// DELETE OLD JOBS
    final oldJobs = await _db
        .collection("jobs")
        .where("workerId", isEqualTo: uid)
        .get();

    for (var doc in oldJobs.docs) {
      await doc.reference.delete();
    }

    /// ADD JOBS
    for (var job in jobs) {
      await _db.collection("jobs").add({
        ...job.toMap(),

        "workerId": uid,

        /// optional safety (useful later)
        "jobTypeLower": job.jobType.toLowerCase(),
      });
    }
  }
}
