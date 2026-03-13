import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workyo/screens/workerdetails_screen.dart';
import 'package:workyo/widgets/app_page.dart';
import '../../theme/app_textstyles.dart';
import '../../widgets/app_card.dart';

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
  List<Map<String, dynamic>> jobsList = [];
  Map<String, List<Map<String, dynamic>>> jobsByWorker = {};

  final jobOptions = [
    "Plumber",
    "Electrician",
    "Carpenter",
    "Cleaner",
    "Driver",
  ];

  @override
  void initState() {
    super.initState();
    getLocation();
    loadAllJobs(); // fetch all jobs once
  }

  Future<void> getLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    userLat = pos.latitude;
    userLng = pos.longitude;
    setState(() {}); // trigger rebuild
  }

  /// Fetch all jobs once and map them by workerId
  Future<void> loadAllJobs() async {
    final snapshot = await db.collection("jobs").get();
    jobsList = snapshot.docs.map((e) => e.data()).toList();
    jobsByWorker = {};
    for (var job in jobsList) {
      final workerId = job['workerId'];
      if (!jobsByWorker.containsKey(workerId)) jobsByWorker[workerId] = [];
      jobsByWorker[workerId]!.add(job);
    }
    setState(() {}); // trigger rebuild to include jobs
  }

  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = value.toLowerCase();
      });
    });
  }

  /// Calculate distance per worker if location available
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
    return AppPage(
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Search field
          TextField(
            style: AppTextStyles.subtitle,
            decoration: const InputDecoration(
              hintText: "Search worker or job",
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 15),

          // Filter + Sort
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.black87,
                  hint: const Text("Job Type"),
                  value: selectedJob,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("All Jobs"),
                    ),
                    ...jobOptions.map(
                      (job) => DropdownMenuItem(value: job, child: Text(job)),
                    ),
                  ],
                  onChanged: (value) => setState(() => selectedJob = value),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.black87,
                  value: sortBy,
                  items: const [
                    DropdownMenuItem(value: "distance", child: Text("Nearest")),
                    DropdownMenuItem(value: "rating", child: Text("Top Rated")),
                    DropdownMenuItem(
                      value: "salary",
                      child: Text("Lowest Salary"),
                    ),
                  ],
                  onChanged: (value) => setState(() => sortBy = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Workers list
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

                // Map snapshot to workers list
                final workers = snapshot.data!.docs.map((e) {
                  final data = e.data() as Map<String, dynamic>;
                  data["uid"] = e.id;
                  return data;
                }).toList();

                // Apply search, filter, sort locally
                List<Map<String, dynamic>> filteredWorkers = List.from(workers);

                // SEARCH
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

                // FILTER
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

                // SORT
                if (sortBy == "distance") {
                  filteredWorkers.sort(
                    (a, b) =>
                        calculateDistance(a).compareTo(calculateDistance(b)),
                  );
                } else if (sortBy == "rating") {
                  filteredWorkers.sort(
                    (a, b) => (b["rating"] ?? 0).compareTo(a["rating"] ?? 0),
                  );
                } else if (sortBy == "salary") {
                  filteredWorkers.sort((a, b) {
                    final aSalary = (jobsByWorker[a["uid"]] ?? [])
                        .map((j) => j['expectedSalary'] ?? 99999)
                        .fold<int>(99999, (prev, s) => prev < s ? prev : s);
                    final bSalary = (jobsByWorker[b["uid"]] ?? [])
                        .map((j) => j['expectedSalary'] ?? 99999)
                        .fold<int>(99999, (prev, s) => prev < s ? prev : s);
                    return aSalary.compareTo(bSalary);
                  });
                }

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
                              jobs: jobsByWorker[w["uid"]] ?? [],
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
                              color: Colors.black.withOpacity(0.3),
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
                                    backgroundImage: w["profileImage"] != null
                                        ? NetworkImage(w["profileImage"])
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

                              // Jobs & Salaries
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
                                      "${job['jobType']} ",
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
    );
  }
}
