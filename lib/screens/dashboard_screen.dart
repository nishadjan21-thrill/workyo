import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:workyo/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:workyo/providers/languageprovider.dart';
import 'package:workyo/theme/app_buttons.dart';

import '../widgets/app_page.dart';
import '../widgets/app_card.dart';
import '../theme/app_spacing.dart';
import '../theme/app_textstyles.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onGoProfile;

  const DashboardScreen({super.key, this.onGoProfile});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool availableToday = false;
  bool isWorker = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Future.microtask(() => context.go('/login'));
      return const Scaffold(
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
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        // USER IS NOT A WORKER
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return AppPage(
            child: SizedBox.expand(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppCard(
                      child: Column(
                        children: [
                          const Icon(Icons.person, size: 60),
                          AppSpacing.small,
                          Text(
                            user.email ?? "User",
                            style: AppTextStyles.title,
                          ),
                          AppSpacing.section,
                          ElevatedButton(
                            onPressed: () => context.go('/home/profile'),
                            child: const Text("Register as Worker"),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.section,
                    ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // USER IS A WORKER
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data["name"] ?? "";
        final location = data["location"] ?? "";
        final profileImage = data["profileImage"] ?? "";
        availableToday = data["availableToday"] ?? false;
        final rating = (data["rating"] ?? 0).toDouble();
        final reviewCount = data["reviewCount"] ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("jobs")
              .where("workerId", isEqualTo: uid)
              .snapshots(),
          builder: (context, jobSnapshot) {
            final jobs = jobSnapshot.hasData ? jobSnapshot.data!.docs : [];

            void showLanguagePicker() {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  Widget languageOption(String title, Locale locale) {
                    return ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(title),
                      onTap: () {
                        context.read<LanguageProvider>().setLocale(locale);
                        Navigator.pop(context);
                      },
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.selectLanguage,
                          style: AppTextStyles.title,
                        ),
                        AppSpacing.section,
                        languageOption(
                          AppLocalizations.of(context)!.english,
                          const Locale('en'),
                        ),
                        languageOption(
                          AppLocalizations.of(context)!.malayalam,
                          const Locale('ml'),
                        ),
                        languageOption(
                          AppLocalizations.of(context)!.hindi,
                          const Locale('hi'),
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            Future<void> updateLocation() async {
              Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );

              await FirebaseFirestore.instance
                  .collection("workers")
                  .doc(uid)
                  .update({
                    "latitude": position.latitude,
                    "longitude": position.longitude,
                  });

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.locationUpdated),
                ),
              );
            }

            Future<void> toggleAvailability(bool value) async {
              await FirebaseFirestore.instance
                  .collection("workers")
                  .doc(uid)
                  .update({"availableToday": value});
              if (!mounted) return;
              setState(() {
                availableToday = value;
              });
            }

            Future<void> logout() async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              context.go('/login');
            }

            return AppPage(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// PROFILE CARD
                    AppCard(
                      child: Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 43,
                              backgroundImage: profileImage.isNotEmpty
                                  ? NetworkImage(profileImage)
                                  : null,
                              child: profileImage.isEmpty
                                  ? const Icon(Icons.person, size: 30)
                                  : null,
                            ),
                            AppSpacing.small,
                            Text(name, style: AppTextStyles.title),
                            AppSpacing.small,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "$rating ($reviewCount reviews)",
                                  style: AppTextStyles.subtitle,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// AVAILABILITY
                    AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.available,
                            style: AppTextStyles.subtitle,
                          ),
                          Transform.scale(
                            scale: 0.7,
                            child: Switch(
                              inactiveThumbColor: Colors.red,
                              activeThumbColor: Colors.green,
                              value: availableToday,
                              onChanged: toggleAvailability,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// JOB COUNT
                    Text(
                      "My Jobs (${jobs.length})",
                      style: AppTextStyles.title,
                    ),
                    AppSpacing.small,

                    /// JOB LIST
                    ...jobs.map((job) {
                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job["jobType"], style: AppTextStyles.title),
                            const SizedBox(height: 4),
                            Text(
                              "₹${job["expectedSalary"]} / ${job["salaryType"]}",
                              style: AppTextStyles.subtitle,
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    AppCard(
                      child: ListTile(
                        leading: const Icon(Icons.my_location),
                        title: Text(
                          AppLocalizations.of(context)!.updateLocation,
                          style: AppTextStyles.subtitle,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: updateLocation,
                      ),
                    ),

                    AppSpacing.small,

                    /// LANGUAGE
                    AppCard(
                      child: ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(
                          AppLocalizations.of(context)!.changeLanguage,
                          style: AppTextStyles.subtitle,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: showLanguagePicker,
                      ),
                    ),

                    AppSpacing.section,

                    /// LOGOUT
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout),
                        label: Text(AppLocalizations.of(context)!.logout),
                        style: AppButtons.primary,
                      ),
                    ),

                    AppSpacing.section,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
