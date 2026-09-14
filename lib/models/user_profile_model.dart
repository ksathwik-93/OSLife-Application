class UserProfileModel {
  final String uid;
  final String name;
  final String email;
  final String avatarUrl;
  final String tier;
  final int streakDays;
  final int tasksCompleted;
  final int focusHours;
  final double productivityScore;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.tier = 'Pro Member',
    this.streakDays = 14,
    this.tasksCompleted = 342,
    this.focusHours = 128,
    this.productivityScore = 0.85,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'tier': tier,
      'streakDays': streakDays,
      'tasksCompleted': tasksCompleted,
      'focusHours': focusHours,
      'productivityScore': productivityScore,
    };
  }

  factory UserProfileModel.fromMap(Map<dynamic, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      tier: map['tier'] ?? 'Pro Member',
      streakDays: map['streakDays'] ?? 0,
      tasksCompleted: map['tasksCompleted'] ?? 0,
      focusHours: map['focusHours'] ?? 0,
      productivityScore: map['productivityScore']?.toDouble() ?? 0.0,
    );
  }
}
