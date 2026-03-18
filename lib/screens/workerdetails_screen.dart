import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../theme/app_textstyles.dart';
import '../../widgets/app_card.dart';

class WorkerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> worker;
  final List<Map<String, dynamic>> jobs;
  final double? userLat;
  final double? userLng;

  const WorkerDetailsScreen({
    super.key,
    required this.worker,
    required this.jobs,
    this.userLat,
    this.userLng,
  });

  @override
  State<WorkerDetailsScreen> createState() => _WorkerDetailsScreenState();
}

class _WorkerDetailsScreenState extends State<WorkerDetailsScreen> {
  int selectedRating = 0;

  StreamSubscription<DocumentSnapshot>? _workerSubscription;
  Map<String, dynamic> _liveWorkerData = {};

  @override
  void initState() {
    super.initState();
    _liveWorkerData = Map.from(widget.worker);
    _startListeningToWorkerUpdates();
  }

  @override
  void dispose() {
    _workerSubscription?.cancel();
    super.dispose();
  }

  void _startListeningToWorkerUpdates() {
    final workerId = widget.worker["uid"];
    if (workerId != null) {
      _workerSubscription = FirebaseFirestore.instance
          .collection('workers')
          .doc(workerId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          setState(() {
            _liveWorkerData =
                snapshot.data() ??
                    _liveWorkerData;
          });
        }
      });
    }
  }

  // ✅ FIXED RATING SYSTEM
  Future<void> _submitRating(int rating) async {
    if (rating == 0) return;

    try {
      final workerId = widget.worker["uid"];
      if (workerId == null) return;

      final docRef =
          FirebaseFirestore.instance.collection('workers').doc(workerId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final currentRating = (data["rating"] ?? 0).toDouble();
        final ratingCount = (data["ratingCount"] ?? 0);

        final newRating =
            ((currentRating * ratingCount) + rating) /
                (ratingCount + 1);

        transaction.update(docRef, {
          "rating": newRating,
          "ratingCount": ratingCount + 1,
        });
      });

      setState(() {
        selectedRating = 0; // reset
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully!')),
      );
    } catch (e) {
      print('Error submitting rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit rating')),
      );
    }
  }

  double calculateDistance() {
    if (widget.userLat == null || widget.userLng == null) return 0.0;
    final lat = _liveWorkerData["latitude"];
    final lng = _liveWorkerData["longitude"];
    if (lat != null && lng != null) {
      return Geolocator.distanceBetween(
              widget.userLat!, widget.userLng!, lat, lng) /
          1000;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final distance = calculateDistance();
    final rating = (_liveWorkerData["rating"] ?? 0).toDouble();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile
                    AppCard(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                _liveWorkerData["profileImage"] != null
                                    ? NetworkImage(
                                        _liveWorkerData["profileImage"])
                                    : null,
                            child:
                                _liveWorkerData["profileImage"] == null
                                    ? const Icon(Icons.person, size: 40)
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _liveWorkerData["name"] ?? "",
                            style: AppTextStyles.title,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _liveWorkerData["locationName"] ?? "",
                            style: AppTextStyles.title,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${distance.toStringAsFixed(1)} km away • ⭐ ${rating.toStringAsFixed(1)}",
                            style: AppTextStyles.title,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Jobs
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Jobs Offered",
                              style: AppTextStyles.title),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: widget.jobs.map((job) {
                              final salaryType =
                                  job['salaryType'] ?? '';
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${job['jobType']} • ₹${job['expectedSalary'] ?? 'N/A'} / $salaryType",
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Rating
                    AppCard(
                      child: Column(
                        children: [
                          Text("Rate this worker",
                              style: AppTextStyles.title),
                          const SizedBox(height: 8),

                          // ⭐ Current rating display
                          
                          
                          const Text("Rate Worker",
                              style: TextStyle(
                                  color: Colors.yellowAccent)),

                          const SizedBox(height: 8),

                          // ⭐ User selection
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final star = index + 1;
                              return IconButton(
                                iconSize: 30,
                                icon: Icon(
                                  star <= selectedRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.yellow,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedRating = star;
                                  });
                                },
                              );
                            }),
                          ),

                          if (selectedRating > 0) ...[
                            Text("You selected: $selectedRating stars"),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () =>
                                  _submitRating(selectedRating),
                              child: const Text("Submit Rating"),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}