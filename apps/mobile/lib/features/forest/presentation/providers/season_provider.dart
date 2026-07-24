import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/season_repository.dart';
import '../../domain/models/season_type.dart';

final seasonProvider = Provider<SeasonType>((ref) {

  return SeasonRepository().getCurrentSeason();

});
