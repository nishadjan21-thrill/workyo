import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  Timer? debounce;

  double? userLat;
  double? userLng;

  final Map<String, double> distanceCache = {};
  Map<String, List<Map<String, dynamic>>> jobsByWorker = {};

  bool isJobsLoading = true;

  @override
  void initState() {
    super.initState();
    getLocation();
    loadAllJobs();
  }

  /// ✅ LOCATION
  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLat = pos.latitude;
        userLng = pos.longitude;
      });
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  /// ✅ LOAD JOBS
  Future<void> loadAllJobs() async {
    jobsByWorker.clear();

    final workersSnapshot = await db.collection("workers").get();

    for (var workerDoc in workersSnapshot.docs) {
      final workerId = workerDoc.id;

      final jobsSnapshot = await db
          .collection("jobs")
          .where("workerId", isEqualTo: workerId)
          .get();

      jobsByWorker[workerId] = jobsSnapshot.docs.map((e) => e.data()).toList();
    }

    setState(() {
      isJobsLoading = false;
    });
  }

  /// ✅ DEBOUNCE SEARCH
  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        searchQuery = value.toLowerCase();
      });
    });
  }

  /// ✅ DISTANCE
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          SizedBox(height: 20.h),

          /// ✅ SEARCH BAR
          WorkersSearchBar(
            onSearchChanged: onSearchChanged,
            onFilterPressed: () {},
          ),

          SizedBox(height: 20.h),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db.collection("workers").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    isJobsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No workers found",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  );
                }

                final workers = snapshot.data!.docs.map((e) {
                  final data = e.data() as Map<String, dynamic>;
                  data["uid"] = e.id;
                  return data;
                }).toList();

                List<Map<String, dynamic>> filteredWorkers = List.from(workers);

                /// SEARCH
                if (searchQuery.isNotEmpty) {
                  filteredWorkers = filteredWorkers.where((w) {
                    final name = (w["name"] ?? "").toString().toLowerCase();

                    final workerJobs = (jobsByWorker[w["uid"]] ?? [])
                        .map((j) => (j['jobType'] ?? "").toString())
                        .join(" ")
                        .toLowerCase();

                    return name.contains(searchQuery) ||
                        workerJobs.contains(searchQuery);
                  }).toList();
                }

                /// SORT BY DISTANCE
                filteredWorkers.sort(
                  (a, b) =>
                      calculateDistance(a).compareTo(calculateDistance(b)),
                );

                return ListView.builder(
                  itemCount: filteredWorkers.length,
                  itemBuilder: (context, index) {
                    final w = filteredWorkers[index];
                    final workerJobs = jobsByWorker[w["uid"]] ?? [];

                    String? image = w["profileImage"];
                    bool isValidImage =
                        image != null &&
                        image.isNotEmpty &&
                        image.startsWith("http");

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
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30.r,
                                  backgroundImage: isValidImage
                                      ? NetworkImage(image)
                                      : null,
                                  child: !isValidImage
                                      ? Icon(Icons.person, size: 24.sp)
                                      : null,
                                ),

                                SizedBox(width: 12.w),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        w["name"] ?? "",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      Text(
                                        w["locationName"] ?? "",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13.sp,
                                        ),
                                      ),

                                      Text(
                                        "${calculateDistance(w).toStringAsFixed(1)} km • ⭐ ${w["rating"] ?? 0}",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10.h),

                            ///  JOB TAGS
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 6.h,
                              children: workerJobs.map((job) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    "${job['jobType']} • ₹${job['expectedSalary'] ?? '-'} ${job['salaryType'] ?? ''}",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
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
    );
  }
}
