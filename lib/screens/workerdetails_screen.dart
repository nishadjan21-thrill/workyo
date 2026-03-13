import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workyo/widgets/app_page.dart';
import '../../theme/app_textstyles.dart';
import '../../widgets/app_card.dart';

class WorkerDetailsScreen extends StatelessWidget {
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

  double calculateDistance() {
    if (userLat == null || userLng == null) return 0.0;
    final lat = worker["latitude"];
    final lng = worker["longitude"];
    if (lat != null && lng != null) {
      return Geolocator.distanceBetween(userLat!, userLng!, lat, lng) / 1000;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final distance = calculateDistance();

    return AppPage(
      child: SizedBox.expand(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile card
                    AppCard(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: worker["profileImage"] != null
                                ? NetworkImage(worker["profileImage"])
                                : null,
                            child: worker["profileImage"] == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            worker["name"] ?? "",
                            style: AppTextStyles.title,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            worker["locationName"] ?? "",
                            style: AppTextStyles.subtitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${distance.toStringAsFixed(1)} km away • ⭐ ${worker["rating"] ?? 0}",
                            style: AppTextStyles.subtitle,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Jobs list
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Jobs Offered", style: AppTextStyles.title),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: jobs.map((job) {
                              final salaryType = job['salaryType'] ?? '';
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
                                  "${job['jobType']} • ₹${job['expectedSalary'] ?? 'N/A'} / $salaryType",
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

                    const SizedBox(height: 16),

                    // Contact buttons
                    AppCard(
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              final phone = worker["phone"] ?? "";
                              if (phone.isNotEmpty) {
                                // launchUrl(Uri.parse("tel:$phone"));
                              }
                            },
                            icon: const Icon(Icons.call),
                            label: const Text("Call Worker"),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              final phone = worker["phone"] ?? "";
                              if (phone.isNotEmpty) {
                                // launchUrl(Uri.parse("sms:$phone"));
                              }
                            },
                            icon: const Icon(Icons.message),
                            label: const Text("Send Message"),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Reviews (optional)
                    if (worker["reviewCount"] != null &&
                        worker["reviewCount"] > 0)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Reviews", style: AppTextStyles.title),
                            const SizedBox(height: 8),
                            Text(
                              "${worker['reviewCount']} reviews • ⭐ ${worker['rating'] ?? 0}",
                              style: AppTextStyles.subtitle,
                            ),
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
