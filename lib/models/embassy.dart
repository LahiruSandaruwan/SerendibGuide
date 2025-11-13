/// Embassy information model
class Embassy {
  final String country;
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String? website;
  final String? emergencyPhone;
  final List<String> services;

  Embassy({
    required this.country,
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    this.website,
    this.emergencyPhone,
    required this.services,
  });
}

/// Static data for embassies in Sri Lanka
class EmbassiesData {
  static List<Embassy> getAllEmbassies() {
    return [
      Embassy(
        country: 'United States',
        name: 'Embassy of the United States',
        address: '210, Galle Road, Colombo 03',
        phone: '011-2494000',
        email: 'colomboacs@state.gov',
        website: 'lk.usembassy.gov',
        emergencyPhone: '011-2494444',
        services: ['Passport Services', 'Visa Services', 'Emergency Assistance'],
      ),
      Embassy(
        country: 'United Kingdom',
        name: 'British High Commission',
        address: '389, Bauddhaloka Mawatha, Colombo 07',
        phone: '011-5390639',
        email: 'colombo.consular@fcdo.gov.uk',
        website: 'gov.uk/world/sri-lanka',
        emergencyPhone: '011-5390639',
        services: ['Passport Services', 'Notarial Services', 'Emergency Help'],
      ),
      Embassy(
        country: 'Australia',
        name: 'Australian High Commission',
        address: '21, Gregory\'s Road, Colombo 07',
        phone: '011-2463200',
        email: 'colombo.consul@dfat.gov.au',
        website: 'srilanka.embassy.gov.au',
        emergencyPhone: '011-2463200',
        services: ['Passport Services', 'Consular Assistance', 'Emergency Services'],
      ),
      Embassy(
        country: 'Canada',
        name: 'Canadian High Commission',
        address: '33A, 5th Lane, Colombo 03',
        phone: '011-5227500',
        email: 'clmbo@international.gc.ca',
        website: 'canadainternational.gc.ca/sri-lanka',
        emergencyPhone: '011-5227500',
        services: ['Passport Services', 'Consular Services', 'Emergency Assistance'],
      ),
      Embassy(
        country: 'India',
        name: 'High Commission of India',
        address: '36-38, Galle Road, Colombo 03',
        phone: '011-2421605',
        email: 'hc.colombo@mea.gov.in',
        website: 'hcicolombo.gov.in',
        emergencyPhone: '011-2421605',
        services: ['Visa Services', 'Passport Services', 'Consular Services'],
      ),
      Embassy(
        country: 'China',
        name: 'Embassy of China',
        address: '381A, Bauddhaloka Mawatha, Colombo 07',
        phone: '011-2694491',
        email: 'chinaemb_lk@mfa.gov.cn',
        website: 'lk.chineseembassy.org',
        services: ['Visa Services', 'Passport Services', 'Consular Services'],
      ),
      Embassy(
        country: 'Germany',
        name: 'Embassy of Germany',
        address: '40, Alfred House Avenue, Colombo 03',
        phone: '011-2580431',
        email: 'info@colombo.diplo.de',
        website: 'colombo.diplo.de',
        emergencyPhone: '011-2580431',
        services: ['Passport Services', 'Visa Services', 'Consular Assistance'],
      ),
      Embassy(
        country: 'France',
        name: 'Embassy of France',
        address: '89, Rosmead Place, Colombo 07',
        phone: '011-2639400',
        email: 'consulat.colombo-amba@diplomatie.gouv.fr',
        website: 'lk.ambafrance.org',
        services: ['Passport Services', 'Visa Services', 'Consular Services'],
      ),
      Embassy(
        country: 'Japan',
        name: 'Embassy of Japan',
        address: '20, Gregory\'s Road, Colombo 07',
        phone: '011-2693831',
        email: 'infojap@cm.mofa.go.jp',
        website: 'lk.emb-japan.go.jp',
        emergencyPhone: '011-2693831',
        services: ['Passport Services', 'Visa Services', 'Emergency Assistance'],
      ),
      Embassy(
        country: 'Russia',
        name: 'Embassy of Russia',
        address: '62, Sir Ernest de Silva Mawatha, Colombo 07',
        phone: '011-2573555',
        email: 'rusemb.lk@mid.ru',
        website: 'srilanka.mid.ru',
        services: ['Consular Services', 'Visa Services'],
      ),
      Embassy(
        country: 'Netherlands',
        name: 'Embassy of the Netherlands',
        address: '25, Torrington Avenue, Colombo 07',
        phone: '011-2501514',
        email: 'colombo@minbuza.nl',
        website: 'netherlandsandyou.nl/countries/sri-lanka',
        services: ['Consular Services', 'Emergency Assistance'],
      ),
      Embassy(
        country: 'Italy',
        name: 'Embassy of Italy',
        address: '55, Jawatta Road, Colombo 05',
        phone: '011-2588388',
        email: 'ambasciata.colombo@esteri.it',
        website: 'ambcolombo.esteri.it',
        services: ['Consular Services', 'Visa Services'],
      ),
      Embassy(
        country: 'South Korea',
        name: 'Embassy of South Korea',
        address: '46, Rheinland Place, Colombo 03',
        phone: '011-2699076',
        email: 'lkeembassy@mofa.go.kr',
        website: 'overseas.mofa.go.kr/lk-en',
        services: ['Visa Services', 'Consular Services'],
      ),
      Embassy(
        country: 'Pakistan',
        name: 'High Commission of Pakistan',
        address: '211, De Saram Place, Colombo 10',
        phone: '011-2696301',
        email: 'parepsl@sltnet.lk',
        services: ['Visa Services', 'Consular Services'],
      ),
      Embassy(
        country: 'Bangladesh',
        name: 'High Commission of Bangladesh',
        address: '62, Horton Place, Colombo 07',
        phone: '011-2691388',
        email: 'bdootcol@eureka.lk',
        services: ['Visa Services', 'Consular Services'],
      ),
      Embassy(
        country: 'Thailand',
        name: 'Embassy of Thailand',
        address: '43, Dr. C.W.W. Kannangara Mawatha, Colombo 07',
        phone: '011-2694831',
        email: 'thaicolo@sltnet.lk',
        services: ['Visa Services', 'Consular Services'],
      ),
      Embassy(
        country: 'Malaysia',
        name: 'High Commission of Malaysia',
        address: '46, Galle Road, Colombo 03',
        phone: '011-2341055',
        email: 'mwcolombo@kln.gov.my',
        services: ['Visa Services', 'Consular Services'],
      ),
      Embassy(
        country: 'Singapore',
        name: 'High Commission of Singapore',
        address: '115, Sir Ernest de Silva Mawatha, Colombo 07',
        phone: '011-2699959',
        email: 'singhc_col@mfa.sg',
        services: ['Visa Services', 'Consular Services'],
      ),
      Embassy(
        country: 'Maldives',
        name: 'High Commission of Maldives',
        address: '25, Melbourne Avenue, Colombo 04',
        phone: '011-2500943',
        email: 'colombo@foreign.gov.mv',
        services: ['Visa Services', 'Consular Services'],
      ),
      Embassy(
        country: 'Norway',
        name: 'Royal Norwegian Embassy',
        address: '34, Ward Place, Colombo 07',
        phone: '011-2555900',
        email: 'emb.colombo@mfa.no',
        services: ['Consular Services'],
      ),
    ];
  }

  static List<String> getAllCountries() {
    return getAllEmbassies()
        .map((e) => e.country)
        .toList()
      ..sort();
  }

  static Embassy? getEmbassyByCountry(String country) {
    try {
      return getAllEmbassies().firstWhere(
        (e) => e.country.toLowerCase() == country.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
