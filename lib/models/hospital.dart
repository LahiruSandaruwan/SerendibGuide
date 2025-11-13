/// Hospital and medical facility information model
class Hospital {
  final String name;
  final String address;
  final String city;
  final String phone;
  final String? emergencyPhone;
  final HospitalType type;
  final List<String> services;
  final bool has24HourEmergency;
  final double? latitude;
  final double? longitude;

  Hospital({
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    this.emergencyPhone,
    required this.type,
    required this.services,
    required this.has24HourEmergency,
    this.latitude,
    this.longitude,
  });
}

enum HospitalType {
  government,
  private,
  clinic,
  pharmacy,
}

extension HospitalTypeExtension on HospitalType {
  String get displayName {
    switch (this) {
      case HospitalType.government:
        return 'Government Hospital';
      case HospitalType.private:
        return 'Private Hospital';
      case HospitalType.clinic:
        return 'Clinic';
      case HospitalType.pharmacy:
        return 'Pharmacy';
    }
  }

  String get icon {
    switch (this) {
      case HospitalType.government:
        return '🏥';
      case HospitalType.private:
        return '🏥';
      case HospitalType.clinic:
        return '⚕️';
      case HospitalType.pharmacy:
        return '💊';
    }
  }
}

/// Static data for major hospitals in Sri Lanka
class HospitalsData {
  static List<Hospital> getAllHospitals() {
    return [
      // Colombo
      Hospital(
        name: 'National Hospital of Sri Lanka',
        address: 'Regent Street, Colombo 07',
        city: 'Colombo',
        phone: '011-2691111',
        emergencyPhone: '011-2691111',
        type: HospitalType.government,
        services: [
          'Emergency Care',
          'Surgery',
          'ICU',
          'Trauma Center',
          'All Specialties',
        ],
        has24HourEmergency: true,
        latitude: 6.9271,
        longitude: 79.8612,
      ),
      Hospital(
        name: 'Asiri Central Hospital',
        address: '114, Norris Canal Road, Colombo 10',
        city: 'Colombo',
        phone: '011-4665500',
        emergencyPhone: '011-4665500',
        type: HospitalType.private,
        services: [
          '24/7 Emergency',
          'ICU',
          'Surgery',
          'Cardiology',
          'Neurology',
        ],
        has24HourEmergency: true,
        latitude: 6.9167,
        longitude: 79.8745,
      ),
      Hospital(
        name: 'Nawaloka Hospital',
        address: '23, Deshamanya H.K. Dharmadasa Mawatha, Colombo 02',
        city: 'Colombo',
        phone: '011-5577111',
        emergencyPhone: '011-5577111',
        type: HospitalType.private,
        services: [
          'Emergency Services',
          'Surgery',
          'Cardiology',
          'Oncology',
          'Pediatrics',
        ],
        has24HourEmergency: true,
        latitude: 6.9214,
        longitude: 79.8588,
      ),
      Hospital(
        name: 'Durdans Hospital',
        address: '3, Alfred Place, Colombo 03',
        city: 'Colombo',
        phone: '011-2140000',
        emergencyPhone: '011-2140000',
        type: HospitalType.private,
        services: [
          '24/7 Emergency',
          'Surgery',
          'Diagnostics',
          'Critical Care',
        ],
        has24HourEmergency: true,
        latitude: 6.9132,
        longitude: 79.8528,
      ),

      // Kandy
      Hospital(
        name: 'Teaching Hospital Kandy',
        address: 'William Gopallawa Mawatha, Kandy',
        city: 'Kandy',
        phone: '081-2223337',
        emergencyPhone: '081-2234567',
        type: HospitalType.government,
        services: [
          'Emergency Care',
          'Surgery',
          'Trauma',
          'General Medicine',
        ],
        has24HourEmergency: true,
        latitude: 7.2906,
        longitude: 80.6337,
      ),
      Hospital(
        name: 'Central Hospital Kandy',
        address: 'No. 64, Sirimavo Bandaranaike Mawatha, Kandy',
        city: 'Kandy',
        phone: '081-2205090',
        emergencyPhone: '081-2205090',
        type: HospitalType.private,
        services: [
          'Emergency Care',
          'ICU',
          'Surgery',
          'Cardiology',
        ],
        has24HourEmergency: true,
        latitude: 7.2955,
        longitude: 80.6354,
      ),

      // Galle
      Hospital(
        name: 'Teaching Hospital Karapitiya',
        address: 'Karapitiya, Galle',
        city: 'Galle',
        phone: '091-2232261',
        emergencyPhone: '091-2232261',
        type: HospitalType.government,
        services: [
          'Emergency Services',
          'Surgery',
          'ICU',
          'Trauma Center',
        ],
        has24HourEmergency: true,
        latitude: 6.0535,
        longitude: 80.2210,
      ),
      Hospital(
        name: 'Ruhunu Hospital',
        address: 'Labuduwa, Galle',
        city: 'Galle',
        phone: '091-2234700',
        emergencyPhone: '091-2234700',
        type: HospitalType.private,
        services: [
          '24/7 Emergency',
          'Surgery',
          'Cardiology',
          'Diagnostics',
        ],
        has24HourEmergency: true,
      ),

      // Negombo
      Hospital(
        name: 'District General Hospital Negombo',
        address: 'Hospital Road, Negombo',
        city: 'Negombo',
        phone: '031-2222261',
        emergencyPhone: '031-2222261',
        type: HospitalType.government,
        services: [
          'Emergency Care',
          'Surgery',
          'General Medicine',
        ],
        has24HourEmergency: true,
      ),

      // Jaffna
      Hospital(
        name: 'Teaching Hospital Jaffna',
        address: 'Hospital Road, Jaffna',
        city: 'Jaffna',
        phone: '021-2222261',
        emergencyPhone: '021-2222261',
        type: HospitalType.government,
        services: [
          'Emergency Services',
          'Surgery',
          'General Medicine',
          'Pediatrics',
        ],
        has24HourEmergency: true,
      ),

      // Anuradhapura
      Hospital(
        name: 'Teaching Hospital Anuradhapura',
        address: 'Hospital Road, Anuradhapura',
        city: 'Anuradhapura',
        phone: '025-2222261',
        emergencyPhone: '025-2222261',
        type: HospitalType.government,
        services: [
          'Emergency Care',
          'Surgery',
          'ICU',
        ],
        has24HourEmergency: true,
      ),

      // Nuwara Eliya
      Hospital(
        name: 'District General Hospital Nuwara Eliya',
        address: 'Hospital Road, Nuwara Eliya',
        city: 'Nuwara Eliya',
        phone: '052-2222261',
        emergencyPhone: '052-2222261',
        type: HospitalType.government,
        services: [
          'Emergency Services',
          'General Medicine',
          'Surgery',
        ],
        has24HourEmergency: true,
      ),

      // 24/7 Pharmacies in Colombo
      Hospital(
        name: 'Osu Sala - Rajagiriya',
        address: 'Rajagiriya',
        city: 'Colombo',
        phone: '011-2888888',
        type: HospitalType.pharmacy,
        services: ['Prescription Medicines', 'OTC Drugs', 'Medical Supplies'],
        has24HourEmergency: true,
      ),
      Hospital(
        name: 'Osu Sala - Nugegoda',
        address: 'High Level Road, Nugegoda',
        city: 'Colombo',
        phone: '011-2820000',
        type: HospitalType.pharmacy,
        services: ['Prescription Medicines', 'OTC Drugs', 'Medical Supplies'],
        has24HourEmergency: true,
      ),
    ];
  }

  static List<Hospital> getHospitalsByCity(String city) {
    return getAllHospitals()
        .where((h) => h.city.toLowerCase() == city.toLowerCase())
        .toList();
  }

  static List<Hospital> getHospitalsByType(HospitalType type) {
    return getAllHospitals().where((h) => h.type == type).toList();
  }

  static List<Hospital> get24HourHospitals() {
    return getAllHospitals().where((h) => h.has24HourEmergency).toList();
  }

  static List<String> getAllCities() {
    return getAllHospitals()
        .map((h) => h.city)
        .toSet()
        .toList()
      ..sort();
  }
}
