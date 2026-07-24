class DailyMission {
  final String id;

  final String missionKey;

  final String title;

  final String description;

  final String icon;

  final String missionType;

  final int goal;

  final int progress;

  final bool completed;

  final bool claimed;

  final String rewardType;

  final int rewardValue;

  const DailyMission({
    required this.id,
    required this.missionKey,
    required this.title,
    required this.description,
    required this.icon,
    required this.missionType,
    required this.goal,
    required this.progress,
    required this.completed,
    required this.claimed,
    required this.rewardType,
    required this.rewardValue,
  });

  //----------------------------------------------------------
  // 진행률
  //----------------------------------------------------------

  double get percent {
    if (goal == 0) return 0;

    return (progress / goal).clamp(0.0, 1.0);
  }

  //----------------------------------------------------------
  // 완료 여부
  //----------------------------------------------------------

  bool get canClaim {
    return completed && !claimed;
  }

  //----------------------------------------------------------
  // Empty
  //----------------------------------------------------------

  factory DailyMission.empty() {
    return const DailyMission(
      id: "",
      missionKey: "",
      title: "",
      description: "",
      icon: "🌱",
      missionType: "",
      goal: 0,
      progress: 0,
      completed: false,
      claimed: false,
      rewardType: "",
      rewardValue: 0,
    );
  }

  //----------------------------------------------------------
  // Supabase -> Model
  //----------------------------------------------------------

  factory DailyMission.fromMap(Map<String, dynamic> map) {
    return DailyMission(
      id: map["id"]?.toString() ?? "",

      missionKey: map["mission_key"] ?? "",

      title: map["title"] ?? "",

      description: map["description"] ?? "",

      icon: map["icon"] ?? "🌱",

      missionType: map["mission_type"] ?? "",

      goal: (map["goal"] ?? 0) as int,

      progress: (map["progress"] ?? 0) as int,

      completed: map["completed"] ?? false,

      claimed: map["claimed"] ?? false,

      rewardType: map["reward_type"] ?? "",

      rewardValue: (map["reward_value"] ?? 0) as int,
    );
  }

  //----------------------------------------------------------
  // Model -> Supabase
  //----------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "mission_key": missionKey,
      "title": title,
      "description": description,
      "icon": icon,
      "mission_type": missionType,
      "goal": goal,
      "progress": progress,
      "completed": completed,
      "claimed": claimed,
      "reward_type": rewardType,
      "reward_value": rewardValue,
    };
  }

  //----------------------------------------------------------
  // copyWith
  //----------------------------------------------------------

  DailyMission copyWith({
    String? id,
    String? missionKey,
    String? title,
    String? description,
    String? icon,
    String? missionType,
    int? goal,
    int? progress,
    bool? completed,
    bool? claimed,
    String? rewardType,
    int? rewardValue,
  }) {
    return DailyMission(
      id: id ?? this.id,
      missionKey: missionKey ?? this.missionKey,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      missionType: missionType ?? this.missionType,
      goal: goal ?? this.goal,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      claimed: claimed ?? this.claimed,
      rewardType: rewardType ?? this.rewardType,
      rewardValue: rewardValue ?? this.rewardValue,
    );
  }
}
