import 'package:flutter/foundation.dart';

import '../spinner_wheel.dart';

class SpinnerController {
  SpinnerWheelState? _state;

  void attachState(SpinnerWheelState state) {
    _state = state;
  }

  Future<void> startSpin() async {
    if (_state != null) {
      await _state!.startSpin();
    } else {
      if (kDebugMode) {
        print("Error: SpinnerWheelState is not attached to the controller!");
      }
    }
  }

  void startLoadingSpin() {
    if (_state != null) {
      _state!.startLoadingSpin();
    } else {
      if (kDebugMode) {
        print("Error: SpinnerWheelState is not attached to the controller!");
      }
    }
  }

  Future<void> spinToIndex(int index) async {
    if (_state != null) {
      await _state!.spinToIndex(index);
    } else {
      if (kDebugMode) {
        print("Error: SpinnerWheelState is not attached to the controller!");
      }
    }
  }
}
