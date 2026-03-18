class WorkerModel {

  String name;
  String phone;
  String whatsapp;
  String locationName;
  String profileImage;

  bool availableToday;

  double latitude;
  double longitude;

  List<String> jobTypes;

  WorkerModel({
    required this.name,
    required this.phone,
    required this.whatsapp,
    required this.locationName,
    required this.profileImage,
    required this.availableToday,
    required this.latitude,
    required this.longitude,
    required this.jobTypes,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "phone": phone,
      "whatsapp": whatsapp,
      "locationName": locationName,
      "profileImage": profileImage,
      "availableToday": availableToday,
      "latitude": latitude,
      "longitude": longitude,
      "jobTypes": jobTypes,
      "rating": 0,
      "createdAt": DateTime.now()
    };
    
  }
  factory WorkerModel.fromMap(Map<String, dynamic> data) {
  return WorkerModel(
    name: data["name"] ?? "",
    phone: data["phone"] ?? "",
    whatsapp: data["whatsapp"] ?? "",
    locationName: data["locationName"] ?? "",
    profileImage: data["profileImage"] ?? "",

    // ✅ FIXED BOOLEAN
    availableToday: (data["availableToday"] ?? false) == true,

    // ✅ SAFE DOUBLE CONVERSION
    latitude: (data["latitude"] ?? 0).toDouble(),
    longitude: (data["longitude"] ?? 0).toDouble(),

    // ✅ SAFE LIST
    jobTypes: List<String>.from(data["jobTypes"] ?? []),
  );
}
}