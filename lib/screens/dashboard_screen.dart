import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workyo/l10n/app_localizations.dart';
import 'package:workyo/providers/languageprovider.dart';

import '../widgets/app_card.dart';
import '../theme/app_textstyles.dart';
import '../theme/app_colors.dart';
import '../theme/app_buttons.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onGoProfile;
  const DashboardScreen({super.key, this.onGoProfile});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool availableToday = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Future.microtask(() {
        if (!mounted) return;
        context.go('/login');
      });
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final uid = user.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("workers")
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppCard(
                    child: Column(
                      children: [
                        Icon(Icons.person, size: 60.sp, color: Colors.white),
                        SizedBox(height: 8.h),
                        Text(
                          user.email ?? "User",
                          style: AppTextStyles.subtitle.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => context.go('/profile'),
                          child: Text(l10n.registerasaworker),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      context.go('/login');
                    },
                    icon: Icon(Icons.logout, size: 20.sp),
                    label: Text(l10n.logout),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data["name"] ?? "";
        final profileImage = data["profileImage"] ?? "";
        availableToday = data["availableToday"] ?? false;

        final rating = (data["rating"] ?? 0).toDouble();
        final ratingCount = data["ratingCount"] ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("jobs")
              .where("workerId", isEqualTo: uid)
              .snapshots(),
          builder: (context, jobSnapshot) {
            final jobs = jobSnapshot.hasData ? jobSnapshot.data!.docs : [];

            Future<void> toggleAvailability(bool value) async {
              await FirebaseFirestore.instance
                  .collection("workers")
                  .doc(uid)
                  .update({"availableToday": value});
              if (!mounted) return;
              setState(() => availableToday = value);
            }

            Future<void> logout() async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              context.go('/login');
            }

            Future<void> updateLocation() async {
              final pos = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );
              await FirebaseFirestore.instance
                  .collection("workers")
                  .doc(uid)
                  .update({
                    "latitude": pos.latitude,
                    "longitude": pos.longitude,
                  });
              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.locationUpdated)));
            }

            void showLanguagePicker() {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                builder: (context) {
                  Widget languageOption(String title, Locale locale) {
                    return ListTile(
                      leading: Icon(Icons.language, size: 20.sp),
                      title: Text(title, style: TextStyle(fontSize: 14.sp)),
                      onTap: () {
                        context.read<LanguageProvider>().setLocale(locale);
                        if (mounted) Navigator.pop(context);
                      },
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.selectLanguage,
                          style: AppTextStyles.title.copyWith(fontSize: 16.sp),
                        ),
                        SizedBox(height: 16.h),
                        languageOption(l10n.english, const Locale('en')),
                        languageOption(l10n.malayalam, const Locale('ml')),
                        languageOption(l10n.hindi, const Locale('hi')),
                      ],
                    ),
                  );
                },
              );
            }

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  AppCard(
                    child: Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 43.r,
                            backgroundImage: profileImage.isNotEmpty
                                ? NetworkImage(profileImage)
                                : null,
                            child: profileImage.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 30.sp,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            name,
                            style: AppTextStyles.subtitle.copyWith(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "${rating.toStringAsFixed(1)} ($ratingCount reviews)",
                                style: AppTextStyles.subtitle.copyWith(
                                  color: Colors.white70,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.available,
                          style: AppTextStyles.subtitle.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: availableToday,
                            onChanged: toggleAvailability,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Text(
                    "${l10n.myJobs} (${jobs.length})",
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  ...jobs.map((jobDoc) {
                    final job = jobDoc.data() as Map<String, dynamic>;

                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job["jobType"] ?? 'Unknown',
                            style: AppTextStyles.subtitle.copyWith(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "₹${job["expectedSalary"] ?? 0} / ${job["salaryType"] ?? 'N/A'}",
                            style: AppTextStyles.subtitle.copyWith(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: 12.h),

                  AppCard(
                    child: ListTile(
                      leading: Icon(
                        Icons.my_location,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                      title: Text(
                        l10n.updateLocation,
                        style: AppTextStyles.subtitle.copyWith(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                      onTap: updateLocation,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  AppCard(
                    child: ListTile(
                      leading: Icon(
                        Icons.language,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                      title: Text(
                        l10n.changeLanguage,
                        style: AppTextStyles.subtitle.copyWith(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                      onTap: showLanguagePicker,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: logout,
                      icon: Icon(Icons.logout, size: 20.sp),
                      label: Text(l10n.logout),
                      style: AppButtons.primary,
                    ),
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
