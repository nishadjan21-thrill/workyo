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
import 'package:workyo/models/jobtype_model.dart';
import 'package:workyo/theme/app_buttons.dart';
import 'package:workyo/theme/app_textstyles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  final locationController = TextEditingController();
  final salaryController = TextEditingController();
  bool isValidNetworkImage(String? url) {
    if (url == null) return false;

    final trimmed = url.trim();

    if (trimmed.isEmpty) return false;
    if (trimmed == "file:///") return false;

    return trimmed.startsWith("http");
  }

  final String cloudName = "dqek7pze3";
  final String uploadPreset = "workyo_upload";

  bool availableToday = false;

  File? profileImageFile;
  String profileImageUrl = "";

  JobTypeModel? selectedJob;
  String salaryType = "Per Day";
  bool profileExists = false;

  final List<JobModel> jobs = [];

  double? latitude;
  double? longitude;

  final firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    loadProfile();
    loadJobs();
    loadJobsMaster();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();

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

  Future<void> uploadAllJobs() async {
    final jobtype = {
      ///  CONSTRUCTION
      "mason": {
        "category": "construction",
        "name": {"en": "Mason", "ml": "കല്ല് പണി", "hi": "राज मिस्त्री"},
        "keywords": ["mason", "kallu pani", "kallupani", "construction"],
      },
      "kinar_pani": {
        "category": "construction",
        "name": {"en": "Well Work", "ml": "കിണർ പണി", "hi": "कुआं कार्य"},
        "keywords": ["kinar", "well work"],
      },
      "kettupani": {
        "category": "construction",
        "name": {"en": "Construction Work", "ml": "കെട്ടുപണി", "hi": "निर्माण"},
        "keywords": ["kettupani"],
      },
      "painter": {
        "category": "construction",
        "name": {"en": "Painter", "ml": "പെയിന്റിംഗ്", "hi": "पेंटर"},
        "keywords": ["painting"],
      },
      "carpenter": {
        "category": "construction",
        "name": {"en": "Carpenter", "ml": "ആശാരി", "hi": "बढ़ई"},
        "keywords": ["wood"],
      },
      "plumber": {
        "category": "construction",
        "name": {"en": "Plumber", "ml": "പ്ലംബർ", "hi": "प्लंबर"},
        "keywords": ["pipe"],
      },
      "electrician": {
        "category": "construction",
        "name": {
          "en": "Electrician",
          "ml": "ഇലക്ട്രീഷ്യൻ",
          "hi": "इलेक्ट्रीशियन",
        },
        "keywords": ["electric"],
      },
      "welder": {
        "category": "construction",
        "name": {"en": "Welder", "ml": "വെൽഡിംഗ്", "hi": "वेल्डर"},
        "keywords": ["welding"],
      },
      "tile_worker": {
        "category": "construction",
        "name": {"en": "Tile Worker", "ml": "ടൈൽ പണി", "hi": "टाइल"},
        "keywords": ["tiles"],
      },

      /// 🔧 REPAIR
      "mobile_repair": {
        "category": "repair",
        "name": {
          "en": "Mobile Repair",
          "ml": "മൊബൈൽ റിപ്പയർ",
          "hi": "मोबाइल रिपेयर",
        },
        "keywords": ["phone"],
      },
      "ac_technician": {
        "category": "repair",
        "name": {"en": "AC Technician", "ml": "എസി ടെക്നീഷ്യൻ", "hi": "एसी"},
        "keywords": ["ac"],
      },
      "mechanic": {
        "category": "repair",
        "name": {"en": "Mechanic", "ml": "മെക്കാനിക്", "hi": "मिस्त्री"},
        "keywords": ["vehicle"],
      },
      "cctv_technician": {
        "category": "repair",
        "name": {"en": "CCTV Technician", "ml": "സിസിടിവി", "hi": "सीसीटीवी"},
        "keywords": ["camera"],
      },

      /// 🎨 CREATIVE
      "graphic_designer": {
        "category": "creative",
        "name": {
          "en": "Graphic Designer",
          "ml": "ഗ്രാഫിക് ഡിസൈനർ",
          "hi": "डिजाइनर",
        },
        "keywords": ["design"],
      },
      "video_editor": {
        "category": "creative",
        "name": {"en": "Video Editor", "ml": "വീഡിയോ എഡിറ്റർ", "hi": "वीडियो"},
        "keywords": ["editing"],
      },
      "photographer": {
        "category": "creative",
        "name": {"en": "Photographer", "ml": "ഫോട്ടോഗ്രാഫർ", "hi": "फोटो"},
        "keywords": ["camera"],
      },
      "content_creator": {
        "category": "creative",
        "name": {
          "en": "Content Creator",
          "ml": "കണ്ടന്റ് ക്രിയേറ്റർ",
          "hi": "कंटेंट",
        },
        "keywords": ["youtube", "instagram"],
      },

      /// 🎤 PERFORMERS
      "singer": {
        "category": "performer",
        "name": {"en": "Singer", "ml": "ഗായകൻ", "hi": "गायक"},
        "keywords": ["music"],
      },
      "dancer": {
        "category": "performer",
        "name": {"en": "Dancer", "ml": "നർത്തകൻ", "hi": "नर्तक"},
        "keywords": ["dance"],
      },
      "dj": {
        "category": "performer",
        "name": {"en": "DJ", "ml": "ഡിജെ", "hi": "डीजे"},
        "keywords": ["dj"],
      },
      "event_manager": {
        "category": "performer",
        "name": {"en": "Event Manager", "ml": "ഇവന്റ് മാനേജർ", "hi": "इवेंट"},
        "keywords": ["event"],
      },

      /// 💻 IT
      "flutter_dev": {
        "category": "it",
        "name": {
          "en": "Flutter Developer",
          "ml": "ഫ്ലട്ടർ ഡെവലപ്പർ",
          "hi": "फ्लटर",
        },
        "keywords": ["flutter"],
      },
      "web_dev": {
        "category": "it",
        "name": {"en": "Web Developer", "ml": "വെബ് ഡെവലപ്പർ", "hi": "वेब"},
        "keywords": ["web"],
      },
      "android_dev": {
        "category": "it",
        "name": {
          "en": "Android Developer",
          "ml": "ആൻഡ്രോയിഡ്",
          "hi": "एंड्रॉइड",
        },
        "keywords": ["android"],
      },
      "backend_dev": {
        "category": "it",
        "name": {"en": "Backend Developer", "ml": "ബാക്ക്എൻഡ്", "hi": "बैकएंड"},
        "keywords": ["api"],
      },
      "fullstack_dev": {
        "category": "it",
        "name": {
          "en": "Full Stack Developer",
          "ml": "ഫുൾ സ്റ്റാക്ക്",
          "hi": "फुल स्टैक",
        },
        "keywords": ["fullstack"],
      },

      /// 🚗 TRANSPORT
      "driver": {
        "category": "transport",
        "name": {"en": "Driver", "ml": "ഡ്രൈവർ", "hi": "ड्राइवर"},
        "keywords": ["car"],
      },
      "delivery": {
        "category": "transport",
        "name": {"en": "Delivery Partner", "ml": "ഡെലിവറി", "hi": "डिलीवरी"},
        "keywords": ["delivery"],
      },

      /// 🏠 DOMESTIC
      "maid": {
        "category": "domestic",
        "name": {"en": "Maid", "ml": "വീട് ജോലി", "hi": "कामवाली"},
        "keywords": ["cleaning"],
      },
      "cook": {
        "category": "domestic",
        "name": {"en": "Cook", "ml": "അടുക്കള ജോലി", "hi": "रसोइया"},
        "keywords": ["cooking"],
      },

      /// 🌾 TRADITIONAL
      "farmer": {
        "category": "traditional",
        "name": {"en": "Farmer", "ml": "കർഷകൻ", "hi": "किसान"},
        "keywords": ["farming"],
      },
      "coconut_climber": {
        "category": "traditional",
        "name": {"en": "Coconut Climber", "ml": "തേങ്ങുകയറ്റം", "hi": "नारियल"},
        "keywords": ["tree climbing"],
      },

      /// 🏗️ ADVANCED CONSTRUCTION
      "architect": {
        "category": "construction",
        "name": {"en": "Architect", "ml": "ആർക്കിടെക്റ്റ്", "hi": "आर्किटेक्ट"},
        "keywords": ["design building"],
      },
      "civil_engineer": {
        "category": "construction",
        "name": {
          "en": "Civil Engineer",
          "ml": "സിവിൽ എഞ്ചിനീയർ",
          "hi": "सिविल इंजीनियर",
        },
        "keywords": ["construction engineer"],
      },
      "site_supervisor": {
        "category": "construction",
        "name": {
          "en": "Site Supervisor",
          "ml": "സൈറ്റ് സൂപ്പർവൈസർ",
          "hi": "साइट सुपरवाइजर",
        },
        "keywords": ["site"],
      },

      /// 🔧 ELECTRICAL & TECH
      "solar_technician": {
        "category": "repair",
        "name": {
          "en": "Solar Technician",
          "ml": "സോളാർ ടെക്",
          "hi": "सोलर तकनीशियन",
        },
        "keywords": ["solar"],
      },
      "generator_technician": {
        "category": "repair",
        "name": {
          "en": "Generator Technician",
          "ml": "ജനറേറ്റർ ടെക്",
          "hi": "जनरेटर",
        },
        "keywords": ["generator"],
      },
      "elevator_technician": {
        "category": "repair",
        "name": {
          "en": "Elevator Technician",
          "ml": "ലിഫ്റ്റ് ടെക്",
          "hi": "लिफ्ट",
        },
        "keywords": ["lift"],
      },

      /// 💻 IT GLOBAL ROLES
      "ios_dev": {
        "category": "it",
        "name": {"en": "iOS Developer", "ml": "ഐഒഎസ് ഡെവലപ്പർ", "hi": "आईओएस"},
        "keywords": ["ios"],
      },
      "devops_engineer": {
        "category": "it",
        "name": {"en": "DevOps Engineer", "ml": "ഡെവ്‌ഓപ്സ്", "hi": "डेवऑप्स"},
        "keywords": ["devops"],
      },
      "cloud_engineer": {
        "category": "it",
        "name": {
          "en": "Cloud Engineer",
          "ml": "ക്ലൗഡ് എഞ്ചിനീയർ",
          "hi": "क्लाउड",
        },
        "keywords": ["aws", "cloud"],
      },
      "game_developer": {
        "category": "it",
        "name": {"en": "Game Developer", "ml": "ഗെയിം ഡെവലപ്പർ", "hi": "गेम"},
        "keywords": ["game dev"],
      },
      "blockchain_dev": {
        "category": "it",
        "name": {
          "en": "Blockchain Developer",
          "ml": "ബ്ലോക്ക്ചെയിൻ",
          "hi": "ब्लॉकचेन",
        },
        "keywords": ["crypto"],
      },

      /// 🎨 DESIGN & MEDIA
      "fashion_designer": {
        "category": "creative",
        "name": {"en": "Fashion Designer", "ml": "ഫാഷൻ ഡിസൈനർ", "hi": "फैशन"},
        "keywords": ["clothes"],
      },
      "interior_designer": {
        "category": "creative",
        "name": {
          "en": "Interior Designer",
          "ml": "ഇന്റീരിയർ",
          "hi": "इंटीरियर",
        },
        "keywords": ["home design"],
      },
      "3d_artist": {
        "category": "creative",
        "name": {"en": "3D Artist", "ml": "3D ആർട്ടിസ്റ്റ്", "hi": "3D कलाकार"},
        "keywords": ["3d"],
      },
      "vfx_artist": {
        "category": "creative",
        "name": {"en": "VFX Artist", "ml": "വിഎഫ്എക്സ്", "hi": "वीएफएक्स"},
        "keywords": ["effects"],
      },

      /// 🎤 ENTERTAINMENT PRO
      "comedian": {
        "category": "performer",
        "name": {"en": "Comedian", "ml": "ഹാസ്യകലാകാരൻ", "hi": "कॉमेडियन"},
        "keywords": ["comedy"],
      },
      "magician": {
        "category": "performer",
        "name": {"en": "Magician", "ml": "മാജീഷ്യൻ", "hi": "जादूगर"},
        "keywords": ["magic"],
      },
      "model": {
        "category": "performer",
        "name": {"en": "Model", "ml": "മോഡൽ", "hi": "मॉडल"},
        "keywords": ["fashion"],
      },

      /// 🚗 LOGISTICS ADVANCED
      "logistics_manager": {
        "category": "transport",
        "name": {
          "en": "Logistics Manager",
          "ml": "ലോജിസ്റ്റിക്സ്",
          "hi": "लॉजिस्टिक्स",
        },
        "keywords": ["supply"],
      },
      "warehouse_worker": {
        "category": "transport",
        "name": {"en": "Warehouse Worker", "ml": "ഗോഡൗൺ ജോലി", "hi": "गोदाम"},
        "keywords": ["warehouse"],
      },

      /// 🏥 MEDICAL EXPANDED
      "doctor": {
        "category": "health",
        "name": {"en": "Doctor", "ml": "ഡോക്ടർ", "hi": "डॉक्टर"},
        "keywords": ["medical"],
      },
      "pharmacist": {
        "category": "health",
        "name": {"en": "Pharmacist", "ml": "ഫാർമസിസ്റ്റ്", "hi": "फार्मासिस्ट"},
        "keywords": ["medicine"],
      },
      "lab_technician": {
        "category": "health",
        "name": {"en": "Lab Technician", "ml": "ലാബ് ടെക്", "hi": "लैब"},
        "keywords": ["lab"],
      },

      /// 🧑‍🏫 EDUCATION GLOBAL
      "professor": {
        "category": "education",
        "name": {"en": "Professor", "ml": "പ്രൊഫസർ", "hi": "प्रोफेसर"},
        "keywords": ["college"],
      },
      "online_tutor": {
        "category": "education",
        "name": {"en": "Online Tutor", "ml": "ഓൺലൈൻ ട്യൂട്ടർ", "hi": "ऑनलाइन"},
        "keywords": ["teaching online"],
      },

      /// 🛍️ BUSINESS GLOBAL
      "entrepreneur": {
        "category": "business",
        "name": {"en": "Entrepreneur", "ml": "ഉദ്യമി", "hi": "उद्यमी"},
        "keywords": ["business"],
      },
      "accountant": {
        "category": "business",
        "name": {"en": "Accountant", "ml": "അക്കൗണ്ടന്റ്", "hi": "लेखाकार"},
        "keywords": ["finance"],
      },
      "hr_manager": {
        "category": "business",
        "name": {"en": "HR Manager", "ml": "എച്ച്ആർ", "hi": "एचआर"},
        "keywords": ["hr"],
      },

      /// 🌾 AGRICULTURE GLOBAL
      "organic_farmer": {
        "category": "traditional",
        "name": {
          "en": "Organic Farmer",
          "ml": "ഓർഗാനിക് കർഷകൻ",
          "hi": "जैविक किसान",
        },
        "keywords": ["organic"],
      },
      "fish_farmer": {
        "category": "traditional",
        "name": {"en": "Fish Farmer", "ml": "മത്സ്യ കർഷകൻ", "hi": "मछली"},
        "keywords": ["fish"],
      },

      /// 🏠 DOMESTIC ADVANCED
      "security_guard": {
        "category": "domestic",
        "name": {"en": "Security Guard", "ml": "സുരക്ഷാ ഗാർഡ്", "hi": "गार्ड"},
        "keywords": ["security"],
      },
      "driver_personal": {
        "category": "domestic",
        "name": {
          "en": "Personal Driver",
          "ml": "സ്വകാര്യ ഡ്രൈവർ",
          "hi": "ड्राइवर",
        },
        "keywords": ["driver"],
      },

      /// ⚡ FREELANCE GLOBAL
      "freelancer": {
        "category": "business",
        "name": {"en": "Freelancer", "ml": "ഫ്രീലാൻസർ", "hi": "फ्रीलांसर"},
        "keywords": ["remote"],
      },
      "virtual_assistant": {
        "category": "business",
        "name": {
          "en": "Virtual Assistant",
          "ml": "വിർച്വൽ അസിസ്റ്റന്റ്",
          "hi": "वर्चुअल",
        },
        "keywords": ["assistant"],
      },
      "seo_expert": {
        "category": "it",
        "name": {"en": "SEO Expert", "ml": "എസ്‌ഇഒ", "hi": "एसईओ"},
        "keywords": ["seo"],
      },
      "digital_marketer": {
        "category": "business",
        "name": {
          "en": "Digital Marketer",
          "ml": "ഡിജിറ്റൽ മാർക്കറ്റിംഗ്",
          "hi": "डिजिटल",
        },
        "keywords": ["ads"],
      },
    };

    final collection = FirebaseFirestore.instance.collection("jobtypes");

    for (var entry in jobtype.entries) {
      await collection.doc(entry.key).set(entry.value);
    }

    print("🔥 ALL JOBS UPLOADED SUCCESSFULLY");
  }

  List<JobTypeModel> allJobs = [];

  Future<void> loadJobsMaster() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("jobtypes")
        .get();

    allJobs = snapshot.docs
        .map((doc) => JobTypeModel.fromFirestore(doc.id, doc.data()))
        .toList();

    setState(() {});
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
    final l10n = AppLocalizations.of(context)!;

    String lang = Localizations.localeOf(context).languageCode;
    if (lang != "ml" && lang != "hi") lang = "en";

    void addJob() {
      if (selectedJob == null || salaryController.text.isEmpty) return;

      bool exists = jobs.any((job) => job.jobType == selectedJob);

      if (exists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.jobAlreadyAdded)));
        return;
      }

      setState(() {
        jobs.add(
          JobModel(
            jobType: selectedJob!.getName(lang),
            expectedSalary: salaryController.text,
            salaryType: salaryType,
          ),
        );

        salaryController.clear();
        selectedJob = null;
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50.h),

              /// 🔹 HEADER
              Center(
                child: Text(
                  profileExists ? l10n.editProfile : l10n.setupProfile,
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              /// 🔹 PROFILE IMAGE
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 55.r,
                    backgroundImage: profileImageFile != null
                        ? FileImage(profileImageFile!)
                        : (isValidNetworkImage(profileImageUrl)
                              ? NetworkImage(profileImageUrl)
                              : null),
                    backgroundColor: Colors.white24,
                    child:
                        profileImageFile == null &&
                            !isValidNetworkImage(profileImageUrl)
                        ? Icon(
                            Icons.camera_alt,
                            size: 28.sp,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              /// 🔹 INPUTS
              PremiumTextField(hint: l10n.name, controller: nameController),

              SizedBox(height: 12.h),

              PremiumTextField(
                hint: l10n.phone,
                controller: phoneController,
                icon: Icons.phone,
              ),

              SizedBox(height: 12.h),

              PremiumTextField(
                hint: l10n.location,
                controller: locationController,
                icon: Icons.location_on,
              ),

              SizedBox(height: 16.h),

              /// 🔹 LOCATION BUTTON
              AppCard(
                child: ListTile(
                  leading: Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  title: Text(
                    l10n.detectMyLocation,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 14.sp,
                    color: Colors.white,
                  ),
                  onTap: detectLocation,
                ),
              ),

              SizedBox(height: 30.h),

              /// 🔹 JOB DROPDOWN
              DropdownButtonFormField(
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 14.sp,
                  color: Colors.yellowAccent,
                ),
                dropdownColor: Colors.black87,
                hint: Text(
                  l10n.selectJob,
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                items: allJobs.map((job) {
                  return DropdownMenuItem(
                    value: job,
                    child: Text(
                      job.getName(lang),
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedJob = value);
                },
              ),

              SizedBox(height: 12.h),

              PremiumTextField(
                hint: l10n.expectedSalary,
                controller: salaryController,
                icon: Icons.attach_money,
              ),

              SizedBox(height: 12.h),

              DropdownButtonFormField<String>(
                dropdownColor: Colors.black54,
                hint: Text(
                  l10n.payType,
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: "Per Day",
                    child: Text(l10n.perDay, style: TextStyle(fontSize: 13.sp)),
                  ),
                  DropdownMenuItem(
                    value: "Per Hour",
                    child: Text(
                      l10n.perHour,
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Monthly",
                    child: Text(
                      l10n.monthly,
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Contract",
                    child: Text(
                      l10n.contract,
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => salaryType = value!),
              ),

              SizedBox(height: 16.h),

              /// 🔹 ADD JOB BUTTON
              Center(
                child: ElevatedButton(
                  style: AppButtons.primary,
                  onPressed: addJob,
                  child: Text(l10n.addJob, style: TextStyle(fontSize: 14.sp)),
                ),
              ),

              SizedBox(height: 12.h),

              /// 🔹 JOB CHIPS
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: jobs.map((job) {
                  return Chip(
                    backgroundColor: Colors.yellow,
                    label: Text(
                      "${job.jobType} • ₹${job.expectedSalary}/${job.salaryType}",
                      style: TextStyle(fontSize: 12.sp, color: Colors.black),
                    ),
                    onDeleted: () {
                      setState(() => jobs.remove(job));
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: 20.h),

              /// 🔹 AVAILABILITY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.available,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                  Switch(
                    value: availableToday,
                    onChanged: (v) => setState(() => availableToday = v),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              /// 🔹 SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: AppButtons.primary,
                  onPressed: saveProfile,
                  icon: Icon(Icons.save, size: 18.sp),
                  label: Text(
                    l10n.saveProfile,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
