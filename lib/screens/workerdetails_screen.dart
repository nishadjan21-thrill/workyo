import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workyo/l10n/app_localizations.dart';
import 'package:workyo/widgets/review.dart';

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

  Future<void> _callWorker() async {
    final phone = _liveWorkerData["phone"];

    if (phone == null || phone.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number not available")),
      );
      return;
    }

    final Uri url = Uri.parse("tel:$phone");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
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
                _liveWorkerData = snapshot.data() ?? _liveWorkerData;
              });
            }
          });
    }
  }

  double calculateDistance() {
    if (widget.userLat == null || widget.userLng == null) return 0;

    final lat = _liveWorkerData["latitude"];
    final lng = _liveWorkerData["longitude"];

    if (lat != null && lng != null) {
      return Geolocator.distanceBetween(
            widget.userLat!,
            widget.userLng!,
            lat,
            lng,
          ) /
          1000;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final distance = calculateDistance();
    final rating = (_liveWorkerData["rating"] ?? 0).toDouble();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// PROFILE CARD
                    AppCard(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50.r,
                            backgroundImage:
                                _liveWorkerData["profileImage"] != null
                                ? NetworkImage(_liveWorkerData["profileImage"])
                                : null,
                            child: _liveWorkerData["profileImage"] == null
                                ? Icon(Icons.person, size: 40.sp)
                                : null,
                          ),

                          SizedBox(height: 12.h),

                          Text(
                            _liveWorkerData["name"] ?? "",
                            style: AppTextStyles.title.copyWith(
                              fontSize: 18.sp,
                            ),
                          ),

                          SizedBox(height: 4.h),

                          Text(
                            _liveWorkerData["locationName"] ?? "",
                            style: AppTextStyles.title.copyWith(
                              fontSize: 14.sp,
                            ),
                          ),

                          SizedBox(height: 4.h),

                          Text(
                            "${distance.toStringAsFixed(1)} km • ⭐ ${rating.toStringAsFixed(1)}",
                            style: AppTextStyles.title.copyWith(
                              fontSize: 13.sp,
                            ),
                          ),

                          SizedBox(height: 12.h),

                          ElevatedButton.icon(
                            onPressed: _callWorker,
                            icon: Icon(Icons.call, size: 18.sp),
                            label: Text(
                              "Call",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 10.h,
                              ),
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    /// JOBS
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.jobsOffered,
                            style: AppTextStyles.title.copyWith(
                              fontSize: 16.sp,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          Wrap(
                            spacing: 8.w,
                            runSpacing: 6.h,
                            children: widget.jobs.map((job) {
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
                                  "${job['jobType']} • ₹${job['expectedSalary']} / ${job['salaryType']}",
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

                    SizedBox(height: 16.h),

                    /// REVIEW
                    AppCard(
                      child: ReviewSection(workerId: widget.worker["uid"]),
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
