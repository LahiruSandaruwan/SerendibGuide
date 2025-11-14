/// Daily fact or quote
class DailyFact {
  final String title;
  final String content;
  final String emoji;
  final String category;
  final DateTime date;

  DailyFact({
    required this.title,
    required this.content,
    required this.emoji,
    required this.category,
    required this.date,
  });

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// Sri Lanka facts and travel quotes
class SriLankaFactsLibrary {
  // Facts about Sri Lanka
  static const List<Map<String, String>> facts = [
    {
      'title': 'Ancient Civilization',
      'content': 'Sri Lanka has a recorded history spanning over 3,000 years, with the ancient city of Anuradhapura serving as the capital for over 1,400 years.',
      'emoji': '🏛️',
      'category': 'History',
    },
    {
      'title': 'Island of Gems',
      'content': 'Sri Lanka is known as "Ratna Dweepa" (Island of Gems). Some of the world\'s finest sapphires, rubies, and other precious stones come from here.',
      'emoji': '💎',
      'category': 'Culture',
    },
    {
      'title': 'Tea Paradise',
      'content': 'Sri Lanka is the world\'s 4th largest tea producer. Ceylon tea is famous worldwide for its quality and unique flavor profiles from different regions.',
      'emoji': '☕',
      'category': 'Economy',
    },
    {
      'title': 'Biodiversity Hotspot',
      'content': 'Despite its small size, Sri Lanka has one of the highest rates of biodiversity in the world, with many species found nowhere else on Earth.',
      'emoji': '🦎',
      'category': 'Nature',
    },
    {
      'title': 'Elephant Gathering',
      'content': 'The Minneriya Gathering is the largest known meeting of Asian elephants in the world, with up to 300 elephants congregating during dry season.',
      'emoji': '🐘',
      'category': 'Wildlife',
    },
    {
      'title': 'Blue Whale Capital',
      'content': 'The waters off Mirissa make Sri Lanka one of the best places in the world to see blue whales, the largest animals on Earth.',
      'emoji': '🐋',
      'category': 'Wildlife',
    },
    {
      'title': 'Sigiriya Rock Fortress',
      'content': 'Sigiriya is a 5th-century rock fortress built by King Kashyapa. The ancient frescoes and engineering are considered marvels of the ancient world.',
      'emoji': '⛰️',
      'category': 'Heritage',
    },
    {
      'title': 'Sacred Tooth Relic',
      'content': 'The Temple of the Tooth in Kandy houses what is believed to be the tooth relic of Buddha, making it one of Buddhism\'s most sacred sites.',
      'emoji': '🙏',
      'category': 'Religion',
    },
    {
      'title': 'Spice Island',
      'content': 'Sri Lanka has been a major exporter of cinnamon since ancient times. Ceylon cinnamon is considered the finest and most expensive variety in the world.',
      'emoji': '🌿',
      'category': 'Spices',
    },
    {
      'title': 'Rainforest Treasure',
      'content': 'Sinharaja Forest Reserve is a UNESCO World Heritage Site and one of the last viable areas of primary tropical rainforest in Sri Lanka.',
      'emoji': '🌳',
      'category': 'Nature',
    },
    {
      'title': 'Stilt Fishing',
      'content': 'The traditional stilt fishing method in southern Sri Lanka is unique to the island and has been practiced for generations.',
      'emoji': '🎣',
      'category': 'Tradition',
    },
    {
      'title': 'Cricket Passion',
      'content': 'Cricket is the most popular sport in Sri Lanka. The national team won the Cricket World Cup in 1996, uniting the nation.',
      'emoji': '🏏',
      'category': 'Sports',
    },
    {
      'title': 'Adam\'s Peak',
      'content': 'Sri Pada (Adam\'s Peak) is a 2,243m mountain sacred to four religions: Buddhism, Hinduism, Islam, and Christianity.',
      'emoji': '⛰️',
      'category': 'Religion',
    },
    {
      'title': 'Dutch Fort',
      'content': 'Galle Fort, built by the Portuguese and fortified by the Dutch, is one of the best-preserved colonial fortresses in Asia.',
      'emoji': '🏰',
      'category': 'Heritage',
    },
    {
      'title': 'Rice & Curry',
      'content': 'A traditional Sri Lankan meal can have up to 20 different curries served with rice, representing the diverse flavors of the island.',
      'emoji': '🍛',
      'category': 'Food',
    },
    {
      'title': 'Ayurveda Origin',
      'content': 'Sri Lanka has practiced Ayurveda for over 3,000 years. Many resorts offer authentic Ayurvedic treatments and wellness programs.',
      'emoji': '💆',
      'category': 'Wellness',
    },
    {
      'title': 'Tropical Paradise',
      'content': 'Sri Lanka has 1,340 km of coastline with some of the world\'s most beautiful beaches, from surfing spots to tranquil coves.',
      'emoji': '🏖️',
      'category': 'Geography',
    },
    {
      'title': 'Endemic Birds',
      'content': 'Sri Lanka has 34 endemic bird species, making it a prime destination for birdwatchers despite its small size.',
      'emoji': '🦜',
      'category': 'Wildlife',
    },
    {
      'title': 'First Female PM',
      'content': 'Sirimavo Bandaranaike became the world\'s first female Prime Minister in 1960, leading Sri Lanka three times.',
      'emoji': '👩‍💼',
      'category': 'History',
    },
    {
      'title': 'Leopard Density',
      'content': 'Yala National Park has one of the highest leopard densities in the world, offering excellent chances to spot these elusive cats.',
      'emoji': '🐆',
      'category': 'Wildlife',
    },
    {
      'title': 'Ancient Irrigation',
      'content': 'Sri Lanka\'s ancient kings built sophisticated irrigation systems. Some reservoirs from 300 BCE are still in use today.',
      'emoji': '💧',
      'category': 'Engineering',
    },
    {
      'title': 'Coconut Island',
      'content': 'Coconuts are used in almost every Sri Lankan dish. The island produces over 2.5 billion coconuts annually.',
      'emoji': '🥥',
      'category': 'Agriculture',
    },
    {
      'title': 'Surf Destination',
      'content': 'Arugam Bay is ranked as one of the top 10 surf points in the world, attracting surfers from across the globe.',
      'emoji': '🏄',
      'category': 'Sports',
    },
    {
      'title': 'Festival Island',
      'content': 'Sri Lanka celebrates over 25 public holidays annually, more than almost any other country, reflecting its multi-religious harmony.',
      'emoji': '🎉',
      'category': 'Culture',
    },
  ];

  // Travel quotes
  static const List<Map<String, String>> quotes = [
    {
      'quote': 'Travel is the only thing you buy that makes you richer.',
      'author': 'Anonymous',
      'emoji': '✈️',
    },
    {
      'quote': 'Not all those who wander are lost.',
      'author': 'J.R.R. Tolkien',
      'emoji': '🧭',
    },
    {
      'quote': 'Adventure is worthwhile in itself.',
      'author': 'Amelia Earhart',
      'emoji': '🗺️',
    },
    {
      'quote': 'To travel is to live.',
      'author': 'Hans Christian Andersen',
      'emoji': '🌍',
    },
    {
      'quote': 'Life is either a daring adventure or nothing at all.',
      'author': 'Helen Keller',
      'emoji': '⛰️',
    },
    {
      'quote': 'The world is a book, and those who do not travel read only one page.',
      'author': 'Saint Augustine',
      'emoji': '📖',
    },
    {
      'quote': 'Travel makes one modest. You see what a tiny place you occupy in the world.',
      'author': 'Gustave Flaubert',
      'emoji': '🌏',
    },
    {
      'quote': 'We travel not to escape life, but for life not to escape us.',
      'author': 'Anonymous',
      'emoji': '🎒',
    },
    {
      'quote': 'Jobs fill your pocket, but adventures fill your soul.',
      'author': 'Jamie Lyn Beatty',
      'emoji': '💫',
    },
    {
      'quote': 'Travel is fatal to prejudice, bigotry, and narrow-mindedness.',
      'author': 'Mark Twain',
      'emoji': '🤝',
    },
    {
      'quote': 'The journey of a thousand miles begins with a single step.',
      'author': 'Lao Tzu',
      'emoji': '👣',
    },
    {
      'quote': 'Take only memories, leave only footprints.',
      'author': 'Chief Seattle',
      'emoji': '🏝️',
    },
  ];

  /// Get fact of the day (based on day of year)
  static DailyFact getFactOfTheDay() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final factIndex = dayOfYear % facts.length;
    final fact = facts[factIndex];

    return DailyFact(
      title: fact['title']!,
      content: fact['content']!,
      emoji: fact['emoji']!,
      category: fact['category']!,
      date: now,
    );
  }

  /// Get quote of the day (based on day of year)
  static Map<String, String> getQuoteOfTheDay() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final quoteIndex = dayOfYear % quotes.length;
    return quotes[quoteIndex];
  }

  /// Get random fact
  static DailyFact getRandomFact() {
    final now = DateTime.now();
    final randomIndex = now.millisecond % facts.length;
    final fact = facts[randomIndex];

    return DailyFact(
      title: fact['title']!,
      content: fact['content']!,
      emoji: fact['emoji']!,
      category: fact['category']!,
      date: now,
    );
  }

  /// Get random quote
  static Map<String, String> getRandomQuote() {
    final now = DateTime.now();
    final randomIndex = now.millisecond % quotes.length;
    return quotes[randomIndex];
  }

  /// Get facts by category
  static List<DailyFact> getFactsByCategory(String category) {
    final now = DateTime.now();
    return facts
        .where((f) => f['category'] == category)
        .map((fact) => DailyFact(
              title: fact['title']!,
              content: fact['content']!,
              emoji: fact['emoji']!,
              category: fact['category']!,
              date: now,
            ))
        .toList();
  }

  /// Get all categories
  static List<String> getCategories() {
    return facts.map((f) => f['category']!).toSet().toList()..sort();
  }
}
