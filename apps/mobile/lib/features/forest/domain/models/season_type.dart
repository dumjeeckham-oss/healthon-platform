enum SeasonType {
  spring,
  summer,
  autumn,
  winter,
}

extension SeasonExtension on SeasonType {
  String get title {
    switch (this) {
      case SeasonType.spring:
        return "봄";
      case SeasonType.summer:
        return "여름";
      case SeasonType.autumn:
        return "가을";
      case SeasonType.winter:
        return "겨울";
    }
  }

  String get backgroundAsset {
    switch (this) {
      case SeasonType.spring:
        return "assets/illustrations/forest/bg_spring.svg";

      case SeasonType.summer:
        return "assets/illustrations/forest/bg_summer.svg";

      case SeasonType.autumn:
        return "assets/illustrations/forest/bg_autumn.svg";

      case SeasonType.winter:
        return "assets/illustrations/forest/bg_winter.svg";
    }
  }
}
