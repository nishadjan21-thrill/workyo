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
import 'package:workyo/theme/app_colors.dart';
import 'package:workyo/theme/app_textstyles.dart';
import 'package:workyo/widgets/locationfield.dart';

import '../../models/job_model.dart';
import '../../models/worker_model.dart';
import '../../services/firestore_service.dart';

import '../../widgets/responsivescreen.dart';
import '../../widgets/continuebutton.dart';
import '../../widgets/fullnamefield.dart';
import '../../widgets/phonefield.dart';
import '../../widgets/app_card.dart';

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
        .collection("jobs")
        .where("workerId", isEqualTo: uid)
        .get();

    jobs.clear();

    for (var doc in snapshot.docs) {
      jobs.add(
        JobModel(
          jobType: doc["jobType"],
          expectedSalary: doc["expectedSalary"],
          salaryType: doc["salaryType"],
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

    return ResponsiveScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: height * 0.05),

          Center(
            child: Text(
              profileExists
                  ? AppLocalizations.of(context)!.editProfile
                  : AppLocalizations.of(context)!.setupProfile,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: height * 0.04),

          /// PROFILE IMAGE
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
                    ? const Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ),

          SizedBox(height: height * 0.04),

          FullNameInputField(controller: nameController),
          SizedBox(height: height * 0.02),

          PhoneInputField(controller: phoneController),
          SizedBox(height: height * 0.02),

          PhoneInputField(controller: whatsappController),
          SizedBox(height: height * 0.02),

          Locationfield(controller: locationController),

          SizedBox(height: height * 0.02),

          AppCard(
            child: ListTile(
              leading: const Icon(Icons.my_location),
              title: Text(
                AppLocalizations.of(context)!.detectMyLocation,
                style: AppTextStyles.subtitle,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: detectLocation,
            ),
          ),

          SizedBox(height: height * 0.04),

          DropdownButtonFormField(
            style: AppTextStyles.subtitle,
            dropdownColor: Colors.black87,
            hint: Text(
              AppLocalizations.of(context)!.selectJob,
              style: AppTextStyles.subtitle,
            ),
            items: jobOptions.map((job) {
              return DropdownMenuItem(value: job, child: Text(job));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedJob = value;
              });
            },
          ),

          SizedBox(height: height * 0.02),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  style: AppTextStyles.subtitle,
                  controller: salaryController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefix: Text("₹"),
                    labelStyle: AppTextStyles.subtitle,
                    labelText: AppLocalizations.of(context)!.expectedSalary,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.black87,
                  style: AppTextStyles.subtitle,

                  decoration: InputDecoration(
                    labelText: "Type",
                    labelStyle: AppTextStyles.subtitle,
                  ),

                  items: [
                    DropdownMenuItem(
                      value: "Per Day",
                      child: Text(AppLocalizations.of(context)!.perDay),
                    ),
                    DropdownMenuItem(
                      value: "Per Hour",
                      child: Text(AppLocalizations.of(context)!.perHour),
                    ),
                    DropdownMenuItem(
                      value: "Monthly",
                      child: Text(AppLocalizations.of(context)!.monthly),
                    ),
                    DropdownMenuItem(
                      value: "Contract",
                      child: Text(AppLocalizations.of(context)!.contract),
                    ),
                  ],

                  onChanged: (value) {
                    setState(() {
                      salaryType = value!;
                    });
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: height * 0.02),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
            onPressed: addJob,
            child: Text(AppLocalizations.of(context)!.addJob),
          ),

          SizedBox(height: height * 0.02),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: jobs.map((job) {
              int index = jobs.indexOf(job);

              return Chip(
                backgroundColor: Colors.black87,
                label: Text(
                  style: AppTextStyles.subtitle,
                  "${job.jobType} • ₹${job.expectedSalary}/${job.salaryType}",
                ),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    jobs.removeAt(index);
                  });
                },
              );
            }).toList(),
          ),

          SizedBox(height: height * 0.03),

          Row(
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
                  onChanged: (value) {
                    setState(() {
                      availableToday = value;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: saveProfile,
              icon: const Icon(Icons.save),
              label: Text(AppLocalizations.of(context)!.saveProfile),
              style: AppButtons.primary,
            ),
          ),

          SizedBox(height: height * 0.02),
        ],
      ),
    );
  }
}
