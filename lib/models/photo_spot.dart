/// Photo spot model for best photography locations
class PhotoSpot {
  final String attractionName;
  final String spotName;
  final String description;
  final String bestTimeOfDay;
  final String equipment;
  final List<String> tips;
  final PhotoDifficulty difficulty;

  const PhotoSpot({
    required this.attractionName,
    required this.spotName,
    required this.description,
    required this.bestTimeOfDay,
    required this.equipment,
    required this.tips,
    required this.difficulty,
  });
}

enum PhotoDifficulty {
  easy,
  moderate,
  challenging,
}

/// Photo spots database
class PhotoSpotsData {
  static const Map<PhotoDifficulty, String> difficultyNames = {
    PhotoDifficulty.easy: 'Easy',
    PhotoDifficulty.moderate: 'Moderate',
    PhotoDifficulty.challenging: 'Challenging',
  };

  static List<PhotoSpot> getAllPhotoSpots() {
    return [
      // Sigiriya
      const PhotoSpot(
        attractionName: 'Sigiriya Rock Fortress',
        spotName: 'Main Viewpoint (Top)',
        description: 'Panoramic 360° view of jungle and surrounding landscape from the summit.',
        bestTimeOfDay: 'Sunrise (6-7 AM) or Late Afternoon (4-5 PM)',
        equipment: 'Wide-angle lens (16-35mm), Tripod optional',
        difficulty: PhotoDifficulty.challenging,
        tips: [
          'Climb early to avoid crowds and heat',
          'Capture the view looking down at the gardens',
          'Use graduated ND filter for sky/land balance',
          'Bring plenty of water - it\'s a strenuous climb',
        ],
      ),
      const PhotoSpot(
        attractionName: 'Sigiriya Rock Fortress',
        spotName: 'Base Gardens View',
        description: 'Classic shot of the full rock formation with manicured gardens in foreground.',
        bestTimeOfDay: 'Early Morning (7-8 AM)',
        equipment: 'Standard zoom (24-70mm)',
        difficulty: PhotoDifficulty.easy,
        tips: [
          'Position yourself at the garden entrance',
          'Include the water fountains for symmetry',
          'Overcast days reduce harsh shadows on the rock',
        ],
      ),

      // Ella
      const PhotoSpot(
        attractionName: 'Nine Arch Bridge',
        spotName: 'Tea Plantation Viewpoint',
        description: 'Elevated view of the iconic bridge with lush green tea plantations.',
        bestTimeOfDay: 'Morning Golden Hour (8-9 AM)',
        equipment: 'Standard zoom (24-70mm)',
        difficulty: PhotoDifficulty.moderate,
        tips: [
          'Arrive before 8 AM to catch the morning train',
          'Trains pass around 9 AM and 12 PM',
          'Use continuous shooting mode for train shots',
          'Watch for local guides showing the best spots',
        ],
      ),
      const PhotoSpot(
        attractionName: 'Nine Arch Bridge',
        spotName: 'Bridge Level',
        description: 'Stand on the bridge for dramatic arch perspective.',
        bestTimeOfDay: 'Mid-morning (9-10 AM)',
        equipment: 'Wide-angle lens (16-24mm)',
        difficulty: PhotoDifficulty.easy,
        tips: [
          'Symmetry is key - center yourself between arches',
          'Include people for scale',
          'Be cautious when trains approach',
        ],
      ),
      const PhotoSpot(
        attractionName: 'Little Adam\'s Peak',
        spotName: 'Summit View',
        description: 'Sweeping views of Ella Gap and surrounding hill country.',
        bestTimeOfDay: 'Sunrise (6-7 AM)',
        equipment: 'Wide-angle lens, Tripod',
        difficulty: PhotoDifficulty.easy,
        tips: [
          'Easy 30-minute hike from Ella town',
          'Arrive 30 min before sunrise',
          'Capture layers of misty mountains',
          'Bring a headlamp for pre-dawn hike',
        ],
      ),

      // Galle Fort
      const PhotoSpot(
        attractionName: 'Galle Fort',
        spotName: 'Lighthouse at Sunset',
        description: 'Iconic white lighthouse with ocean backdrop during golden hour.',
        bestTimeOfDay: 'Sunset (5:30-6:30 PM)',
        equipment: 'Standard zoom (24-70mm)',
        difficulty: PhotoDifficulty.easy,
        tips: [
          'Walk along the fort walls to the lighthouse',
          'Include locals and tourists for atmosphere',
          'Capture silhouettes during the blue hour',
          'Very crowded on weekends',
        ],
      ),
      const PhotoSpot(
        attractionName: 'Galle Fort',
        spotName: 'Fort Ramparts',
        description: 'Colonial architecture and ocean views from the fort walls.',
        bestTimeOfDay: 'Early Morning (7-8 AM) or Late Afternoon',
        equipment: 'Standard zoom (24-70mm)',
        difficulty: PhotoDifficulty.easy,
        tips: [
          'Photograph the Dutch colonial buildings',
          'Capture waves crashing against the walls',
          'Monsoon season (May-Sep) has dramatic waves',
        ],
      ),

      // Kandy
      const PhotoSpot(
        attractionName: 'Temple of the Sacred Tooth Relic',
        spotName: 'Kandy Lake Reflection',
        description: 'Temple reflected in the calm waters of Kandy Lake.',
        bestTimeOfDay: 'Early Morning (6-7 AM) or Blue Hour',
        equipment: 'Standard zoom (24-70mm), Tripod',
        difficulty: PhotoDifficulty.moderate,
        tips: [
          'Shoot from the lake walkway',
          'Calm mornings offer best reflections',
          'Include traditional boats in frame',
          'Evening lights create magical atmosphere',
        ],
      ),
      const PhotoSpot(
        attractionName: 'Temple of the Sacred Tooth Relic',
        spotName: 'Temple Evening Ceremony',
        description: 'Devotees during evening puja with oil lamps.',
        bestTimeOfDay: 'Evening (6:30-7:30 PM)',
        equipment: 'Fast lens (f/2.8 or faster), High ISO capability',
        difficulty: PhotoDifficulty.challenging,
        tips: [
          'Respect the sacred space - ask permission',
          'Use high ISO (1600-3200) for low light',
          'Capture candid moments of devotion',
          'No flash photography allowed',
        ],
      ),

      // Adam\'s Peak
      const PhotoSpot(
        attractionName: 'Adam\'s Peak',
        spotName: 'Summit at Sunrise',
        description: 'Legendary shadow of the peak cast on clouds at dawn.',
        bestTimeOfDay: 'Sunrise (6-6:30 AM)',
        equipment: 'Wide-angle lens, Tripod essential',
        difficulty: PhotoDifficulty.challenging,
        tips: [
          'Start climb at 2-3 AM to reach summit by sunrise',
          'Bring headlamp and warm clothes',
          'Triangle shadow appears for 15-20 minutes only',
          'Best season: Dec-May (pilgrimage season)',
          'Very crowded - arrive early for good spot',
        ],
      ),

      // Yala National Park
      const PhotoSpot(
        attractionName: 'Yala National Park',
        spotName: 'Safari Jeep Wildlife',
        description: 'Leopards, elephants, and diverse wildlife in natural habitat.',
        bestTimeOfDay: 'Early Morning (6-9 AM) or Late Afternoon (3-6 PM)',
        equipment: 'Telephoto lens (200-400mm+), Fast shutter speed',
        difficulty: PhotoDifficulty.challenging,
        tips: [
          'Book experienced driver who knows leopard spots',
          'Use minimum 1/500s shutter speed for animals',
          'Shoot from the jeep - stay inside',
          'Bring dust cover for equipment',
          'Best leopard sightings: Feb-July',
        ],
      ),

      // Nuwara Eliya
      const PhotoSpot(
        attractionName: 'Nuwara Eliya Tea Plantations',
        spotName: 'Tea Pickers in Rows',
        description: 'Tea pluckers working among bright green tea bushes.',
        bestTimeOfDay: 'Morning (8-10 AM)',
        equipment: 'Standard zoom (24-70mm)',
        difficulty: PhotoDifficulty.easy,
        tips: [
          'Ask permission before photographing workers',
          'Offer small payment (100-200 LKR) as courtesy',
          'Capture the rolling hills and tea rows',
          'Visit a tea factory for interior shots',
        ],
      ),

      // Mirissa
      const PhotoSpot(
        attractionName: 'Mirissa Beach',
        spotName: 'Coconut Tree Hill',
        description: 'Coconut palms with turquoise ocean backdrop.',
        bestTimeOfDay: 'Sunset (5:30-6 PM)',
        equipment: 'Wide-angle lens (16-35mm)',
        difficulty: PhotoDifficulty.easy,
        tips: [
          'Popular Instagram spot - arrive early',
          'Climb the small hill for elevated view',
          'Include the curve of the bay',
          'Beautiful silhouettes during golden hour',
        ],
      ),
      const PhotoSpot(
        attractionName: 'Mirissa Beach',
        spotName: 'Whale Watching',
        description: 'Blue whales and dolphins in their natural habitat.',
        bestTimeOfDay: 'Morning (6 AM departure)',
        equipment: 'Telephoto lens (70-200mm+), Fast shutter speed',
        difficulty: PhotoDifficulty.challenging,
        tips: [
          'Book whale watching tour (Nov-Apr best season)',
          'Use 1/1000s+ shutter for whale breaches',
          'Take motion sickness pills if needed',
          'Protect gear from ocean spray',
        ],
      ),

      // Dambulla
      const PhotoSpot(
        attractionName: 'Dambulla Cave Temple',
        spotName: 'Golden Temple Entrance',
        description: 'Massive golden Buddha statue at temple entrance.',
        bestTimeOfDay: 'Morning (8-9 AM)',
        equipment: 'Wide-angle lens (16-24mm)',
        difficulty: PhotoDifficulty.easy,
        tips: [
          'Arrive early before tour groups',
          'Photograph the golden Buddha from below',
          'Remove shoes before entering caves',
        ],
      ),
      const PhotoSpot(
        attractionName: 'Dambulla Cave Temple',
        spotName: 'Cave Buddha Statues',
        description: 'Ancient painted Buddha statues inside the caves.',
        bestTimeOfDay: 'Mid-morning (9-11 AM) when light enters',
        equipment: 'Fast lens (f/2.8), High ISO',
        difficulty: PhotoDifficulty.moderate,
        tips: [
          'No flash photography - use high ISO',
          'Wait for natural light from cave openings',
          'Capture the painted ceiling details',
          'Tripod not practical due to crowds',
        ],
      ),

      // General Tips
      const PhotoSpot(
        attractionName: 'Wildlife Photography (General)',
        spotName: 'Safari Best Practices',
        description: 'Tips for capturing Sri Lanka\'s incredible wildlife.',
        bestTimeOfDay: 'Dawn and Dusk',
        equipment: 'Telephoto 200mm+, Monopod',
        difficulty: PhotoDifficulty.challenging,
        tips: [
          'Patience is key - wait for the shot',
          'Focus on the eyes for sharp animal portraits',
          'Use continuous autofocus mode',
          'Bring extra batteries and memory cards',
          'Respect animal space - never disturb wildlife',
        ],
      ),
    ];
  }

  static List<PhotoSpot> getPhotoSpotsByAttraction(String attractionName) {
    return getAllPhotoSpots()
        .where((spot) => spot.attractionName.toLowerCase().contains(attractionName.toLowerCase()))
        .toList();
  }
}
