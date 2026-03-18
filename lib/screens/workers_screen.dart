import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workyo/screens/workerdetails_screen.dart';
import 'package:workyo/widgets/worker_search.dart';


class WorkersListScreen extends StatefulWidget {
  const WorkersListScreen({super.key});

  @override
  State<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends State<WorkersListScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String searchQuery = "";
  String? selectedJob;
  String sortBy = "distance";
  Timer? debounce;

  double? userLat;
  double? userLng;

  final Map<String, double> distanceCache = {};
  Map<String, List<Map<String, dynamic>>> jobsByWorker = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLocation();
    });
    loadAllJobs(); // fetch jobs from subcollections
  }

  Future<void> getLocation() async {
    try {
      // 1️⃣ Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location services are disabled")));
        }
        return;
      }

      // 2️⃣ Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 3️⃣ Handle denied cases
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location permission denied")));
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location permission permanently denied")));
        }
        return;
      }

      // 4️⃣ Get location safely
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLat = pos.latitude;
        userLng = pos.longitude;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location error: $e")));
      }
    }
  }

  /// ✅ Fetch jobs from each worker's subcollection
  Future<void> loadAllJobs() async {
    jobsByWorker = {};

    final workersSnapshot = await db.collection("workers").get();

    for (var workerDoc in workersSnapshot.docs) {
      final workerId = workerDoc.id;

      final jobsSnapshot = await db
          .collection("workers")
          .doc(workerId)
          .collection("jobs")
          .get();

      final jobs = jobsSnapshot.docs.map((e) => e.data()).toList();

      jobsByWorker[workerId] = jobs;
    }

    setState(() {});
  }

  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = value.toLowerCase();
      });
    });
  }

  double calculateDistance(Map<String, dynamic> worker) {
    if (userLat == null || userLng == null) return 0.0;
    final id = worker["uid"];
    final lat = worker["latitude"];
    final lng = worker["longitude"];

    if (lat != null && lng != null && !distanceCache.containsKey(id)) {
      distanceCache[id] =
          Geolocator.distanceBetween(userLat!, userLng!, lat, lng) / 1000;
    }

    return distanceCache[id] ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Search field
           WorkersSearchBar(
  onSearchChanged: (query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  },
  onFilterPressed: () {
    // open filter modal or dropdown
  },
),
            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: db.collection("workers").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No workers found"));
                  }

                  final workers = snapshot.data!.docs.map((e) {
                    final data = e.data() as Map<String, dynamic>;
                    data["uid"] = e.id;
                    return data;
                  }).toList();

                  List<Map<String, dynamic>> filteredWorkers =
                      List.from(workers);

                  // 🚫 SEARCH (disabled for now)
                  /*
                  if (searchQuery.isNotEmpty) {
                    filteredWorkers = filteredWorkers.where((w) {
                      final name = (w["name"] ?? "").toLowerCase();
                      final workerJobs = (jobsByWorker[w["uid"]] ?? [])
                          .map((j) => j['jobType'])
                          .join(" ")
                          .toLowerCase();
                      return name.contains(searchQuery) ||
                          workerJobs.contains(searchQuery);
                    }).toList();
                  }
                  */

                  // 🚫 FILTER (disabled)
                  /*
                  if (selectedJob != null) {
                    filteredWorkers = filteredWorkers.where((w) {
                      final workerJobs = (jobsByWorker[w["uid"]] ?? [])
                          .map((j) => j['jobType'])
                          .toList();
                      return workerJobs
                          .map((e) => e.toLowerCase())
                          .contains(selectedJob!.toLowerCase());
                    }).toList();
                  }
                  */

                  // 🚫 SORT (disabled)
                  /*
                  if (sortBy == "distance") {
                    filteredWorkers.sort((a, b) =>
                        calculateDistance(a).compareTo(calculateDistance(b)));
                  }
                  */

                  return ListView.builder(
                    itemCount: filteredWorkers.length,
                    itemBuilder: (context, index) {
                      final w = filteredWorkers[index];
                      final workerJobs = jobsByWorker[w["uid"]] ?? [];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkerDetailsScreen(
                                worker: w,
                                jobs: workerJobs,
                                userLat: userLat,
                                userLng: userLng,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[700]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Worker info
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          w["profileImage"] != null
                                              ? NetworkImage(
                                                  w["profileImage"])
                                              : null,
                                      child: w["profileImage"] == null
                                          ? const Icon(Icons.person, size: 30)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            w["name"] ?? "",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            w["locationName"] ?? "",
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${calculateDistance(w).toStringAsFixed(1)} km away • ⭐ ${w["rating"] ?? 0}",
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Jobs
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: workerJobs.map((job) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "${job['jobType']} • ₹${job['expectedSalary'] ?? '-'} ${job['salaryType'] ?? ''}",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}