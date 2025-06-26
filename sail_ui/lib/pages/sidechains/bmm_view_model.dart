import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/providers/parentchain/bmm_provider.dart';
import 'package:stacked/stacked.dart';

class BMMViewModel extends BaseViewModel {
  final BMMProvider bmmProvider = GetIt.I.get<BMMProvider>();

  final TextEditingController bidAmountController;
  final TextEditingController intervalController;

  Timer? _syncTimer;

  BMMViewModel()
      : bidAmountController = TextEditingController(),
        intervalController = TextEditingController() {
    // Initialize controllers with provider values
    bidAmountController.text = bmmProvider.bidAmount.toString();
    intervalController.text = bmmProvider.interval.inSeconds.toString();

    // Listen for changes in the text fields
    bidAmountController.addListener(_onBidAmountChanged);
    intervalController.addListener(_onIntervalChanged);

    // Listen for changes in provider and update controllers
    bmmProvider.addListener(_syncControllers);

    // Optionally, keep controllers in sync every second
    _syncTimer = Timer.periodic(const Duration(seconds: 1), (_) => _syncControllers());
  }

  bool get isMining => bmmProvider.isMining;

  void _onBidAmountChanged() {
    final parsed = double.tryParse(bidAmountController.text);
    if (parsed != null && parsed != bmmProvider.bidAmount) {
      bmmProvider.setBidAmount(parsed);
    }
    notifyListeners();
  }

  void _onIntervalChanged() {
    final parsed = int.tryParse(intervalController.text);
    if (parsed != null && parsed != bmmProvider.interval.inSeconds) {
      bmmProvider.setInterval(Duration(seconds: parsed));
    }
    notifyListeners();
  }

  void _syncControllers() {
    if (bidAmountController.text != bmmProvider.bidAmount.toString()) {
      bidAmountController.text = bmmProvider.bidAmount.toString();
    }
    if (intervalController.text != bmmProvider.interval.inSeconds.toString()) {
      intervalController.text = bmmProvider.interval.inSeconds.toString();
    }
    notifyListeners();
  }

  List<BmmResult> get attempts => bmmProvider.attempts;

  @override
  void dispose() {
    bidAmountController.removeListener(_onBidAmountChanged);
    intervalController.removeListener(_onIntervalChanged);
    bidAmountController.dispose();
    intervalController.dispose();
    bmmProvider.removeListener(_syncControllers);
    _syncTimer?.cancel();
    super.dispose();
  }
}
