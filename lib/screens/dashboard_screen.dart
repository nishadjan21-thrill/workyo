import 'package:flutter/material.dart';
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
                        const Icon(Icons.person, size: 60, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          user.email ?? "User",
                          style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.go('/profile'),
                          child: const Text("Register as Worker"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data["name"] ?? "";
        final profileImage = data["profileImage"] ?? "";
        availableToday = data["availableToday"] ?? false;

        // ✅ FIXED HERE
        final rating = (data["rating"] ?? 0).toDouble();
        final ratingCount = data["ratingCount"] ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("workers")
              .doc(uid)
              .collection("jobs")
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
                  desiredAccuracy: LocationAccuracy.high);
              await FirebaseFirestore.instance
                  .collection("workers")
                  .doc(uid)
                  .update({
                "latitude": pos.latitude,
                "longitude": pos.longitude,
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.locationUpdated),
                ),
              );
            }

            void showLanguagePicker() {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) {
                  Widget languageOption(String title, Locale locale) {
                    return ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(title),
                      onTap: () {
                        context
                            .read<LanguageProvider>()
                            .setLocale(locale);
                        if (mounted) Navigator.pop(context);
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
                        const SizedBox(height: 16),
                        languageOption(
                            AppLocalizations.of(context)!.english,
                            const Locale('en')),
                        languageOption(
                            AppLocalizations.of(context)!.malayalam,
                            const Locale('ml')),
                        languageOption(
                            AppLocalizations.of(context)!.hindi,
                            const Locale('hi')),
                      ],
                    ),
                  );
                },
              );
            }

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Profile card
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
                                ? const Icon(Icons.person,
                                    size: 30, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(name,
                              style: AppTextStyles.subtitle
                                  .copyWith(color: Colors.white)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                "${rating.toStringAsFixed(1)} ($ratingCount reviews)",
                                style: AppTextStyles.subtitle
                                    .copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Availability card
                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.available,
                          style: AppTextStyles.subtitle
                              .copyWith(color: Colors.white),
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

                  const SizedBox(height: 12),

                  // Jobs list
                  Text("My Jobs (${jobs.length})",
                      style: AppTextStyles.subtitle
                          .copyWith(color: Colors.white)),
                  const SizedBox(height: 8),

                  ...jobs.map((jobDoc) {
                    final job =
                        jobDoc.data() as Map<String, dynamic>;

                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job["jobType"] ?? 'Unknown',
                              style: AppTextStyles.subtitle
                                  .copyWith(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            "₹${job["expectedSalary"] ?? 0} / ${job["salaryType"] ?? 'N/A'}",
                            style: AppTextStyles.subtitle
                                .copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Update location
                  AppCard(
                    child: ListTile(
                      leading: const Icon(Icons.my_location,
                          color: Colors.white),
                      title: Text(
                        AppLocalizations.of(context)!.updateLocation,
                        style: AppTextStyles.subtitle
                            .copyWith(color: Colors.white),
                      ),
                      trailing:
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                      onTap: updateLocation,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Change language
                  AppCard(
                    child: ListTile(
                      leading: const Icon(Icons.language,
                          color: Colors.white),
                      title: Text(
                        AppLocalizations.of(context)!.changeLanguage,
                        style: AppTextStyles.subtitle
                            .copyWith(color: Colors.white),
                      ),
                      trailing:
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                      onTap: showLanguagePicker,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout),
                      label: Text(AppLocalizations.of(context)!.logout),
                      style: AppButtons.primary,
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}