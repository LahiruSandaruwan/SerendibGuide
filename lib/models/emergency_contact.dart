/// Emergency contact information model
class EmergencyContact {
  final String name;
  final String number;
  final String description;
  final EmergencyType type;
  final String? region; // null means nationwide

  EmergencyContact({
    required this.name,
    required this.number,
    required this.description,
    required this.type,
    this.region,
  });
}

enum EmergencyType {
  police,
  ambulance,
  fire,
  touristPolice,
  helpline,
  other,
}

extension EmergencyTypeExtension on EmergencyType {
  String get displayName {
    switch (this) {
      case EmergencyType.police:
        return 'Police';
      case EmergencyType.ambulance:
        return 'Ambulance';
      case EmergencyType.fire:
        return 'Fire Service';
      case EmergencyType.touristPolice:
        return 'Tourist Police';
      case EmergencyType.helpline:
        return 'Helpline';
      case EmergencyType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case EmergencyType.police:
        return '👮';
      case EmergencyType.ambulance:
        return '🚑';
      case EmergencyType.fire:
        return '🚒';
      case EmergencyType.touristPolice:
        return '🛂';
      case EmergencyType.helpline:
        return '📞';
      case EmergencyType.other:
        return '📋';
    }
  }
}

/// Static data for emergency contacts in Sri Lanka
class EmergencyContactsData {
  static List<EmergencyContact> getAllContacts() {
    return [
      // National Emergency Numbers
      EmergencyContact(
        name: 'Emergency Police',
        number: '119',
        description: 'National emergency police hotline',
        type: EmergencyType.police,
      ),
      EmergencyContact(
        name: 'Emergency Ambulance',
        number: '1990',
        description: 'National ambulance service',
        type: EmergencyType.ambulance,
      ),
      EmergencyContact(
        name: 'Fire & Rescue',
        number: '110',
        description: 'Fire and rescue services',
        type: EmergencyType.fire,
      ),
      EmergencyContact(
        name: 'Tourist Police - Colombo',
        number: '011-2421111',
        description: '24/7 tourist police assistance in Colombo',
        type: EmergencyType.touristPolice,
        region: 'Colombo',
      ),
      EmergencyContact(
        name: 'Tourist Police - Kandy',
        number: '081-2222222',
        description: 'Tourist police assistance in Kandy',
        type: EmergencyType.touristPolice,
        region: 'Kandy',
      ),
      EmergencyContact(
        name: 'Tourist Police - Galle',
        number: '091-2234063',
        description: 'Tourist police assistance in Galle',
        type: EmergencyType.touristPolice,
        region: 'Galle',
      ),
      EmergencyContact(
        name: 'Accident Service',
        number: '011-2691111',
        description: 'Colombo accident service hotline',
        type: EmergencyType.ambulance,
        region: 'Colombo',
      ),
      EmergencyContact(
        name: 'Sri Lanka Tourism Helpline',
        number: '1912',
        description: '24/7 tourism assistance and information',
        type: EmergencyType.helpline,
      ),
      EmergencyContact(
        name: 'Police Emergency Control',
        number: '011-2433333',
        description: 'Police headquarters emergency control',
        type: EmergencyType.police,
        region: 'Colombo',
      ),
      EmergencyContact(
        name: 'Suwa Sariya Ambulance',
        number: '1990',
        description: 'Pre-hospital emergency care ambulance service',
        type: EmergencyType.ambulance,
      ),
      EmergencyContact(
        name: 'Women & Children Helpline',
        number: '1938',
        description: 'Emergency helpline for women and children',
        type: EmergencyType.helpline,
      ),
      EmergencyContact(
        name: 'Disaster Management Center',
        number: '117',
        description: 'Natural disaster and emergency coordination',
        type: EmergencyType.other,
      ),
      EmergencyContact(
        name: 'Coast Guard',
        number: '011-2520150',
        description: 'Sri Lanka Coast Guard for maritime emergencies',
        type: EmergencyType.other,
      ),
      EmergencyContact(
        name: 'National Hospital - Colombo',
        number: '011-2691111',
        description: 'Main emergency hospital in Colombo',
        type: EmergencyType.ambulance,
        region: 'Colombo',
      ),
      EmergencyContact(
        name: 'Traffic Police',
        number: '011-2433333',
        description: 'Traffic accidents and road emergencies',
        type: EmergencyType.police,
      ),
    ];
  }

  static List<EmergencyContact> getContactsByType(EmergencyType type) {
    return getAllContacts().where((contact) => contact.type == type).toList();
  }

  static List<EmergencyContact> getContactsByRegion(String region) {
    return getAllContacts()
        .where((contact) =>
            contact.region == null ||
            contact.region!.toLowerCase() == region.toLowerCase())
        .toList();
  }
}
