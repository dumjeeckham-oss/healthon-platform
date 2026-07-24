import '../domain/models/season_type.dart';

class SeasonRepository {

  SeasonType getCurrentSeason() {

    final month = DateTime.now().month;

    if (month >= 3 && month <= 5) {
      return SeasonType.spring;
    }

    if (month >= 6 && month <= 8) {
      return SeasonType.summer;
    }

    if (month >= 9 && month <= 11) {
      return SeasonType.autumn;
    }

    return SeasonType.winter;
  }
}
