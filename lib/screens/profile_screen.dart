import 'dart:io';
import 'package:flutter/material.dart';
import 'package:workyo/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:workyo/theme/app_buttons.dart';
import 'package:workyo/theme/app_textstyles.dart';

import '../../models/job_model.dart';
import '../../models/worker_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/text_field.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final whatsappController = TextEditingController();
  final locationController = TextEditingController();
  final salaryController = TextEditingController();

  final String cloudName = "dqek7pze3";
  final String uploadPreset = "workyo_upload";

  bool availableToday = false;

  File? profileImageFile;
  String profileImageUrl = "";

  String? selectedJob;
  String salaryType = "Per Day";
  bool profileExists = false;

  final List<JobModel> jobs = [];

  double? latitude;
  double? longitude;

  final jobOptions = [
    "Plumber",
    "Electrician",
    "Carpenter",
    "Cleaner",
    "Driver",
  ];

  final firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    loadProfile();
    loadJobs();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    locationController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  /// PICK IMAGE
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        profileImageFile = File(picked.path);
      });
    }
  }

  /// UPLOAD IMAGE
  Future<String> uploadToCloudinary(File imageFile) async {
    final compressed = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: 300,
      minHeight: 300,
      quality: 70,
    );

    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri);
    request.fields['upload_preset'] = uploadPreset;

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        compressed!,
        filename: "${DateTime.now().millisecondsSinceEpoch}.jpg",
      ),
    );

    final response = await request.send();
    final res = await response.stream.bytesToString();
    final data = json.decode(res);

    return data["secure_url"];
  }

  /// DETECT LOCATION
  Future<void> detectLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    latitude = position.latitude;
    longitude = position.longitude;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.locationDetected)),
    );
  }

  /// LOAD PROFILE
  Future<void> loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("workers")
        .doc(uid)
        .get();

    if (!doc.exists) {
      profileExists = false;
      return;
    }

    profileExists = true;

    final data = doc.data()!;

    nameController.text = data["name"] ?? "";
    phoneController.text = data["phone"] ?? "";
    whatsappController.text = data["whatsapp"] ?? "";
    locationController.text = data["locationName"] ?? "";
    availableToday = data["availableToday"] ?? false;
    profileImageUrl = data["profileImage"] ?? "";

    latitude = data["latitude"];
    longitude = data["longitude"];

    setState(() {});
  }

  /// LOAD JOBS
  Future<void> loadJobs() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection("workers")
        .doc(uid)
        .collection("jobs")
        .get();

    jobs.clear();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      jobs.add(
        JobModel(
          jobType: data["jobType"],
          expectedSalary: data["expectedSalary"],
          salaryType: data["salaryType"],
        ),
      );
    }

    setState(() {});
  }

  /// ADD JOB
  void addJob() {
    if (selectedJob == null || salaryController.text.isEmpty) return;

    bool exists = jobs.any((job) => job.jobType == selectedJob);

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.jobAlreadyAdded)),
      );
      return;
    }

    setState(() {
      jobs.add(
        JobModel(
          jobType: selectedJob!,
          expectedSalary: salaryController.text,
          salaryType: salaryType,
        ),
      );

      salaryController.clear();
      selectedJob = null;
    });
  }

  /// SAVE PROFILE
  Future<void> saveProfile() async {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.detectLocationFirst),
        ),
      );
      return;
    }

    String imageUrl = profileImageUrl;

    if (profileImageFile != null) {
      imageUrl = await uploadToCloudinary(profileImageFile!);
    }

    final worker = WorkerModel(
      name: nameController.text,
      phone: phoneController.text,
      whatsapp: whatsappController.text,
      locationName: locationController.text,
      profileImage: imageUrl,
      availableToday: availableToday,
      latitude: latitude!,
      longitude: longitude!,
      jobTypes: jobs.map((e) => e.jobType.toLowerCase()).toList(),
    );

    await firestoreService.saveWorkerProfile(worker, jobs);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.profileSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.05),

              // Header
              Center(
                child: Text(
                  profileExists
                      ? AppLocalizations.of(context)!.editProfile
                      : AppLocalizations.of(context)!.setupProfile,
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: height * 0.04),

              // Profile image
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: profileImageFile != null
                        ? FileImage(profileImageFile!)
                        : (profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : null)
                            as ImageProvider?,
                    backgroundColor: Colors.white24,
                    child: profileImageFile == null && profileImageUrl.isEmpty
                        ? const Icon(Icons.camera_alt,
                            size: 30, color: Colors.white)
                        : null,
                  ),
                ),
              ),

              SizedBox(height: height * 0.04),

              // Replace all text fields with PremiumTextField
              PremiumTextField(
                hint: AppLocalizations.of(context)!.name,
                controller: nameController,
              ),
              PremiumTextField(
                hint: "phone",
                controller: phoneController,
                icon: Icons.phone,
              ),
              PremiumTextField(
                hint: "whatsapp",
                controller: whatsappController,
                icon: Icons.phone_android,
              ),
              PremiumTextField(
                hint: AppLocalizations.of(context)!.location,
                controller: locationController,
                icon: Icons.location_on,
              ),

              SizedBox(height: height * 0.02),

              AppCard(
                child: ListTile(
                  leading: const Icon(Icons.my_location, color: Colors.white),
                  title: Text(
                    AppLocalizations.of(context)!.detectMyLocation,
                    style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                  onTap: detectLocation,
                ),
              ),

              SizedBox(height: height * 0.04),

              // Job selection
              DropdownButtonFormField(
                style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                dropdownColor: Colors.black87,
                hint: Text(
                  AppLocalizations.of(context)!.selectJob,
                  style: AppTextStyles.subtitle.copyWith(color: Colors.white70),
                ),
                items: jobOptions.map((job) {
                  return DropdownMenuItem(
                      value: job,
                      child: Text(job, style: const TextStyle(color: Colors.white)));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedJob = value;
                  });
                },
              ),

              SizedBox(height: height * 0.02),

               PremiumTextField(
                      hint: AppLocalizations.of(context)!.expectedSalary,
                      controller: salaryController,
                      icon: Icons.attach_money,
                    ),
                  
                  const SizedBox(width: 12),
                  
                     DropdownButtonFormField<String>(
                      dropdownColor: Colors.black54,
                      hint: Text(
                        "Pay type",
                        style: AppTextStyles.subtitle.copyWith(color: Colors.white70),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Per Day", child: Text("Per Day",style: TextStyle(color: Colors.white70),)),
                        DropdownMenuItem(value: "Per Hour", child: Text("Per Hour",style: TextStyle(color: Colors.white70),)),
                        DropdownMenuItem(value: "Monthly", child: Text("Monthly",style: TextStyle(color: Colors.white70),)),
                        DropdownMenuItem(value: "Contract", child: Text("Contract",style: TextStyle(color: Colors.white70),)),
                      ],
                      onChanged: (value) {
                        setState(() {
                          salaryType = value!;
                        });
                      },
                    ),
                  
                
              

              SizedBox(height: height * 0.02),

              Center(
                child: ElevatedButton(style: AppButtons.primary,
                  onPressed: addJob,
                  child: Text(AppLocalizations.of(context)!.addJob),
                ),
              ),

              SizedBox(height: height * 0.02),

              Wrap(
                spacing: 8,
                children: jobs.map((job) {
                  return Chip(backgroundColor: Colors.yellow,
                    label: Text(
                      "${job.jobType} • ₹${job.expectedSalary}/${job.salaryType}",
                      style: const TextStyle(color: Colors.black),
                    ),
                    onDeleted: () {
                      setState(() {
                        jobs.remove(job);
                      });
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: height * 0.03),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.available,
                      style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
                  Switch(
                    value: availableToday,
                    onChanged: (value) {
                      setState(() {
                        availableToday = value;
                      });
                    },
                  ),
                ],
              ),

              ElevatedButton.icon(style: AppButtons.primary,
                onPressed: saveProfile,
                icon: const Icon(Icons.save),
                label: Text(AppLocalizations.of(context)!.saveProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}