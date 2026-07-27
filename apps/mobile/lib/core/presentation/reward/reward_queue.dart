import 'dart:collection';

import '../../../features/daily_mission/domain/models/reward_result.dart';

class RewardQueue {

  RewardQueue._();

  static final instance = RewardQueue._();

  final Queue<RewardPresentationType> _queue = Queue();

  void clear(){

    _queue.clear();

  }

  void add(

    RewardPresentationType item,

  ){

    _queue.add(item);

  }

  bool get isEmpty => _queue.isEmpty;

  RewardPresentationType pop(){

    return _queue.removeFirst();

  }

}
