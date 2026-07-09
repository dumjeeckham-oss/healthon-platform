class Badge {

  final String id;

  final String title;

  final String description;

  final double targetDistance;

  final String icon;

  final bool achieved;

  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDistance,
    required this.icon,
    required this.achieved,
  });

}

class BadgeService {

  BadgeService._();

  static final BadgeService instance = BadgeService._();

  List<Badge> calculateBadges(
    double totalDistance,
  ) {

    return [

      Badge(
        id: "badge_10",
        title: "첫걸음",
        description: "10km 달성",
        targetDistance: 10,
        icon: "🥉",
        achieved: totalDistance >= 10,
      ),

      Badge(
        id: "badge_30",
        title: "산책러",
        description: "30km 달성",
        targetDistance: 30,
        icon: "🥈",
        achieved: totalDistance >= 30,
      ),

      Badge(
        id: "badge_50",
        title: "건강러",
        description: "50km 달성",
        targetDistance: 50,
        icon: "🥇",
        achieved: totalDistance >= 50,
      ),

      Badge(
        id: "badge_75",
        title: "숲지기",
        description: "75km 달성",
        targetDistance: 75,
        icon: "🌳",
        achieved: totalDistance >= 75,
      ),

      Badge(
        id: "badge_100",
        title: "100K 완주",
        description: "100km 달성",
        targetDistance: 100,
        icon: "👑",
        achieved: totalDistance >= 100,
      ),
    ];
  }

  Badge? nextBadge(
    double totalDistance,
  ) {

    final badges = calculateBadges(totalDistance);

    try {
      return badges.firstWhere(
        (e) => !e.achieved,
      );
    } catch (_) {
      return null;
    }
  }
}
