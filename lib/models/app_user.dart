class AppUser {
  final String uid;
  final String name;
  final String email;
  final String provider;
  final String joinDate;
  final String bestTime;
  final String spiritualLevel;
  final bool isGuest;
  final bool smartModeEnabled;
  final int streakDays;
  final int totalAzkar;
  final int dailyGoal;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.provider,
    required this.joinDate,
    required this.bestTime,
    required this.spiritualLevel,
    required this.isGuest,
    required this.smartModeEnabled,
    required this.streakDays,
    required this.totalAzkar,
    required this.dailyGoal,
  });

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? provider,
    String? joinDate,
    String? bestTime,
    String? spiritualLevel,
    bool? isGuest,
    bool? smartModeEnabled,
    int? streakDays,
    int? totalAzkar,
    int? dailyGoal,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      provider: provider ?? this.provider,
      joinDate: joinDate ?? this.joinDate,
      bestTime: bestTime ?? this.bestTime,
      spiritualLevel: spiritualLevel ?? this.spiritualLevel,
      isGuest: isGuest ?? this.isGuest,
      smartModeEnabled: smartModeEnabled ?? this.smartModeEnabled,
      streakDays: streakDays ?? this.streakDays,
      totalAzkar: totalAzkar ?? this.totalAzkar,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'provider': provider,
    'joinDate': joinDate,
    'bestTime': bestTime,
    'spiritualLevel': spiritualLevel,
    'isGuest': isGuest,
    'smartModeEnabled': smartModeEnabled,
    'streakDays': streakDays,
    'totalAzkar': totalAzkar,
    'dailyGoal': dailyGoal,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      provider: json['provider'] ?? 'Guest',
      joinDate: json['joinDate'] ?? DateTime.now().toIso8601String(),
      bestTime: json['bestTime'] ?? 'لا يوجد',
      spiritualLevel: json['spiritualLevel'] ?? 'مبتدئ بنور الله',
      isGuest: json['isGuest'] ?? true,
      smartModeEnabled: json['smartModeEnabled'] ?? true,
      streakDays: json['streakDays'] ?? 0,
      totalAzkar: json['totalAzkar'] ?? 0,
      dailyGoal: json['dailyGoal'] ?? 100,
    );
  }
}