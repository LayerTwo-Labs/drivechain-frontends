/// Represents a single bandwidth data point for network traffic visualization
class BandwidthDataPoint {
  final DateTime time;
  final double totalRxBytes;
  final double totalTxBytes;

  // Calculated rates (bytes per second)
  final double rxBytesPerSec;
  final double txBytesPerSec;

  BandwidthDataPoint({
    required this.time,
    required this.totalRxBytes,
    required this.totalTxBytes,
    this.rxBytesPerSec = 0,
    this.txBytesPerSec = 0,
  });

  /// Creates a new data point with calculated rates based on a previous point
  factory BandwidthDataPoint.withRates({
    required DateTime time,
    required double totalRxBytes,
    required double totalTxBytes,
    required BandwidthDataPoint? previous,
  }) {
    double rxRate = 0;
    double txRate = 0;

    if (previous != null) {
      final elapsed = time.difference(previous.time).inMilliseconds / 1000.0;
      if (elapsed > 0) {
        rxRate = (totalRxBytes - previous.totalRxBytes) / elapsed;
        txRate = (totalTxBytes - previous.totalTxBytes) / elapsed;
        // Clamp negative rates (can happen if counter resets)
        if (rxRate < 0) rxRate = 0;
        if (txRate < 0) txRate = 0;
      }
    }

    return BandwidthDataPoint(
      time: time,
      totalRxBytes: totalRxBytes,
      totalTxBytes: totalTxBytes,
      rxBytesPerSec: rxRate,
      txBytesPerSec: txRate,
    );
  }
}
