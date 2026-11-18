/// One quality sample of the media link (from `getStats`).
class CallQualitySample {
  const CallQualitySample({this.rttMs, this.lossPercent, this.jitterMs});

  final double? rttMs;
  final double? lossPercent;
  final double? jitterMs;

  bool get isEmpty => rttMs == null && lossPercent == null && jitterMs == null;

  @override
  String toString() =>
      'rtt=${rttMs?.toStringAsFixed(0)}ms loss=${lossPercent?.toStringAsFixed(1)}% '
      'jitter=${jitterMs?.toStringAsFixed(0)}ms';
}

/// Turns raw WebRTC stats into [CallQualitySample]s. Packet loss is computed
/// from the change since the previous call (the counters are cumulative).
class CallStatsReader {
  int _lastLost = 0;
  int _lastReceived = 0;

  /// [reports]: `type` + `values` of each `StatsReport`.
  CallQualitySample read(Iterable<MapEntry<String, Map<dynamic, dynamic>>> reports) {
    double? rtt;
    double? jitter;
    int lost = 0;
    int received = 0;
    bool sawInbound = false;

    for (final MapEntry<String, Map<dynamic, dynamic>> r in reports) {
      final Map<dynamic, dynamic> v = r.value;
      if (r.key == 'candidate-pair') {
        final bool active = v['nominated'] == true ||
            v['nominated'] == 'true' ||
            v['state'] == 'succeeded';
        final double? t = _num(v['currentRoundTripTime']);
        if (active && t != null) rtt = t * 1000;
      } else if (r.key == 'inbound-rtp' &&
          (v['kind'] == 'audio' || v['mediaType'] == 'audio')) {
        sawInbound = true;
        lost += _num(v['packetsLost'])?.toInt() ?? 0;
        received += _num(v['packetsReceived'])?.toInt() ?? 0;
        final double? j = _num(v['jitter']);
        if (j != null) jitter = j * 1000;
      } else if (r.key == 'remote-inbound-rtp') {
        final double? t = _num(v['roundTripTime']);
        if (rtt == null && t != null) rtt = t * 1000;
      }
    }

    double? loss;
    if (sawInbound) {
      final int dLost = lost - _lastLost;
      final int dRecv = received - _lastReceived;
      _lastLost = lost;
      _lastReceived = received;
      final int total = dLost + dRecv;
      if (total > 0 && dLost >= 0) loss = dLost * 100 / total;
    }
    return CallQualitySample(rttMs: rtt, lossPercent: loss, jitterMs: jitter);
  }

  static double? _num(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

/// "Poor connection" with hysteresis: two poor samples in a row to show it,
/// two good ones to hide it. After [suggestCameraOffAfter] poor samples in
/// a row on a video call, suggest turning the camera off once (IMO-like
/// voice on a weak network).
class CallQualityEvaluator {
  CallQualityEvaluator({
    this.maxRttMs = 400,
    this.maxLossPercent = 8,
    this.maxJitterMs = 60,
    this.samplesToFlip = 2,
    this.suggestCameraOffAfter = 4,
  });

  final double maxRttMs;
  final double maxLossPercent;
  final double maxJitterMs;
  final int samplesToFlip;
  final int suggestCameraOffAfter;

  bool _poor = false;
  int _poorRun = 0;
  int _goodRun = 0;
  bool _suggested = false;

  bool get isPoor => _poor;

  bool isPoorSample(CallQualitySample s) =>
      (s.rttMs ?? 0) > maxRttMs ||
      (s.lossPercent ?? 0) > maxLossPercent ||
      (s.jitterMs ?? 0) > maxJitterMs;

  /// Feeds one sample. Returns true when [isPoor] changed.
  bool add(CallQualitySample s) {
    if (s.isEmpty) return false;
    if (isPoorSample(s)) {
      _poorRun++;
      _goodRun = 0;
    } else {
      _goodRun++;
      _poorRun = 0;
    }
    if (!_poor && _poorRun >= samplesToFlip) {
      _poor = true;
      return true;
    }
    if (_poor && _goodRun >= samplesToFlip) {
      _poor = false;
      return true;
    }
    return false;
  }

  /// True once per call, when the link stayed poor long enough.
  bool takeCameraOffSuggestion({required bool videoOn}) {
    if (_suggested || !videoOn || _poorRun < suggestCameraOffAfter) {
      return false;
    }
    _suggested = true;
    return true;
  }
}
