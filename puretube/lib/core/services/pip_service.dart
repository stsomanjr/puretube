import 'dart:async';

import 'package:flutter/services.dart';

/// Talks to MainActivity over the `pure_tube/pip` channel.
/// All calls degrade to `false` on platforms without PiP (iOS, old Android).
class PipService {
  static const _channel = MethodChannel('pure_tube/pip');

  final _controller = StreamController<bool>.broadcast();
  bool _initialized = false;

  /// Emits true/false as the activity enters/exits PiP mode.
  Stream<bool> get onPipChanged => _controller.stream;

  void init() {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onPipChanged') {
        _controller.add((call.arguments as bool?) ?? false);
      }
    });
  }

  Future<bool> get isPipSupported async {
    try {
      return await _channel.invokeMethod<bool>('isPipSupported') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> get isInPip async {
    try {
      return await _channel.invokeMethod<bool>('isInPip') ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> enterPip() async {
    try {
      return await _channel.invokeMethod<bool>('enterPip') ?? false;
    } on PlatformException {
      return false;
    }
  }

  void dispose() => _controller.close();
}
