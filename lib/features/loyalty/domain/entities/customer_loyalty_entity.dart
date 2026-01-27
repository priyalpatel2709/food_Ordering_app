/// Customer Loyalty Entity
class CustomerLoyaltyEntity {
  final String id;
  final String? userId;
  final String phone;
  final String? email;
  final String name;
  final DateTime? dateOfBirth;
  final DateTime? anniversary;
  final String loyaltyTier; // bronze, silver, gold, platinum, vip
  final LoyaltyPoints loyaltyPoints;
  final DateTime memberSince;
  final VisitStats visitStats;
  final CustomerPreferences? preferences;
  final MarketingPreferences? marketing;
  final List<String> tags;
  final List<String> segments;
  final ReferralInfo? referral;
  final String status; // active, inactive, blocked, dormant
  final List<CustomerNote> notes;
  final DateTime? lastActivity;

  const CustomerLoyaltyEntity({
    required this.id,
    this.userId,
    required this.phone,
    this.email,
    required this.name,
    this.dateOfBirth,
    this.anniversary,
    required this.loyaltyTier,
    required this.loyaltyPoints,
    required this.memberSince,
    required this.visitStats,
    this.preferences,
    this.marketing,
    this.tags = const [],
    this.segments = const [],
    this.referral,
    required this.status,
    this.notes = const [],
    this.lastActivity,
  });

  factory CustomerLoyaltyEntity.fromJson(Map<String, dynamic> json) {
    return CustomerLoyaltyEntity(
      id: json['_id'] as String,
      userId: json['userId'] as String?,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      anniversary: json['anniversary'] != null
          ? DateTime.parse(json['anniversary'] as String)
          : null,
      loyaltyTier: json['loyaltyTier'] as String? ?? 'bronze',
      loyaltyPoints: LoyaltyPoints.fromJson(
        json['loyaltyPoints'] as Map<String, dynamic>? ?? {},
      ),
      memberSince: json['memberSince'] != null
          ? DateTime.parse(json['memberSince'] as String)
          : DateTime.now(),
      visitStats: VisitStats.fromJson(
        json['visitStats'] as Map<String, dynamic>? ?? {},
      ),
      preferences: json['preferences'] != null
          ? CustomerPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>,
            )
          : null,
      marketing: json['marketing'] != null
          ? MarketingPreferences.fromJson(
              json['marketing'] as Map<String, dynamic>,
            )
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      segments: (json['segments'] as List<dynamic>?)?.cast<String>() ?? [],
      referral: json['referral'] != null
          ? ReferralInfo.fromJson(json['referral'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? 'active',
      notes:
          (json['notes'] as List<dynamic>?)
              ?.map(
                (note) => CustomerNote.fromJson(note as Map<String, dynamic>),
              )
              .toList() ??
          [],
      lastActivity: json['lastActivity'] != null
          ? DateTime.parse(json['lastActivity'] as String)
          : null,
    );
  }

  String get availableDiscount {
    final discountValue = loyaltyPoints.current / 100;
    return discountValue.toStringAsFixed(2);
  }

  String get tierEmoji {
    switch (loyaltyTier.toLowerCase()) {
      case 'bronze':
        return '🥉';
      case 'silver':
        return '🥈';
      case 'gold':
        return '🥇';
      case 'platinum':
        return '💎';
      case 'vip':
        return '👑';
      default:
        return '🏅';
    }
  }
}

/// Loyalty Points
class LoyaltyPoints {
  final int current;
  final int lifetime;
  final int redeemed;

  const LoyaltyPoints({
    required this.current,
    required this.lifetime,
    required this.redeemed,
  });

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) {
    return LoyaltyPoints(
      current: json['current'] as int? ?? 0,
      lifetime: json['lifetime'] as int? ?? 0,
      redeemed: json['redeemed'] as int? ?? 0,
    );
  }
}

/// Visit Statistics
class VisitStats {
  final int totalVisits;
  final DateTime? lastVisit;
  final DateTime? firstVisit;
  final double averageOrderValue;
  final double totalSpent;
  final double? averageVisitsPerMonth;

  const VisitStats({
    required this.totalVisits,
    this.lastVisit,
    this.firstVisit,
    required this.averageOrderValue,
    required this.totalSpent,
    this.averageVisitsPerMonth,
  });

  factory VisitStats.fromJson(Map<String, dynamic> json) {
    return VisitStats(
      totalVisits: json['totalVisits'] as int? ?? 0,
      lastVisit: json['lastVisit'] != null
          ? DateTime.parse(json['lastVisit'] as String)
          : null,
      firstVisit: json['firstVisit'] != null
          ? DateTime.parse(json['firstVisit'] as String)
          : null,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      averageVisitsPerMonth: (json['averageVisitsPerMonth'] as num?)
          ?.toDouble(),
    );
  }
}

/// Customer Preferences
class CustomerPreferences {
  final List<FavoriteItem> favoriteItems;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final String? spiceLevel;
  final String? preferredSeating;

  const CustomerPreferences({
    this.favoriteItems = const [],
    this.dietaryRestrictions = const [],
    this.allergies = const [],
    this.spiceLevel,
    this.preferredSeating,
  });

  factory CustomerPreferences.fromJson(Map<String, dynamic> json) {
    return CustomerPreferences(
      favoriteItems:
          (json['favoriteItems'] as List<dynamic>?)
              ?.map(
                (item) => FavoriteItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      dietaryRestrictions:
          (json['dietaryRestrictions'] as List<dynamic>?)?.cast<String>() ?? [],
      allergies: (json['allergies'] as List<dynamic>?)?.cast<String>() ?? [],
      spiceLevel: json['spiceLevel'] as String?,
      preferredSeating: json['preferredSeating'] as String?,
    );
  }
}

/// Favorite Item
class FavoriteItem {
  final String itemId;
  final int orderCount;

  const FavoriteItem({required this.itemId, required this.orderCount});

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      itemId: json['itemId'] as String,
      orderCount: json['orderCount'] as int? ?? 0,
    );
  }
}

/// Marketing Preferences
class MarketingPreferences {
  final bool emailOptIn;
  final bool smsOptIn;
  final bool pushNotifications;
  final bool specialOffers;
  final bool birthdayOffers;
  final bool anniversaryOffers;

  const MarketingPreferences({
    this.emailOptIn = false,
    this.smsOptIn = false,
    this.pushNotifications = false,
    this.specialOffers = false,
    this.birthdayOffers = false,
    this.anniversaryOffers = false,
  });

  factory MarketingPreferences.fromJson(Map<String, dynamic> json) {
    return MarketingPreferences(
      emailOptIn: json['emailOptIn'] as bool? ?? false,
      smsOptIn: json['smsOptIn'] as bool? ?? false,
      pushNotifications: json['pushNotifications'] as bool? ?? false,
      specialOffers: json['specialOffers'] as bool? ?? false,
      birthdayOffers: json['birthdayOffers'] as bool? ?? false,
      anniversaryOffers: json['anniversaryOffers'] as bool? ?? false,
    );
  }
}

/// Referral Information
class ReferralInfo {
  final String referralCode;
  final String? referredBy;
  final int referralsCount;
  final int referralRewards;

  const ReferralInfo({
    required this.referralCode,
    this.referredBy,
    required this.referralsCount,
    required this.referralRewards,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      referralCode: json['referralCode'] as String? ?? '',
      referredBy: json['referredBy'] as String?,
      referralsCount: json['referralsCount'] as int? ?? 0,
      referralRewards: json['referralRewards'] as int? ?? 0,
    );
  }
}

/// Customer Note
class CustomerNote {
  final String note;
  final String? addedBy;
  final DateTime addedAt;

  const CustomerNote({required this.note, this.addedBy, required this.addedAt});

  factory CustomerNote.fromJson(Map<String, dynamic> json) {
    return CustomerNote(
      note: json['note'] as String,
      addedBy: json['addedBy'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}
