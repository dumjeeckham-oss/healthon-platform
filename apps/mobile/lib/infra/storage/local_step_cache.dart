class LocalStepCache {
  int _steps = 0;

  Future<void> addSteps(int steps) async {
    _steps += steps;
  }

  Future<int> getTodaySteps() async {
    return _steps;
  }

  Future<void> reset() async {
    _steps = 0;
  }
}
