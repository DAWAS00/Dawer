import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/reservation.dart';
import '../../../domain/repositories/i_reservation_repository.dart';

class ReservationViewModel extends ChangeNotifier {
  ReservationViewModel({required IReservationRepository repository})
    : _repository = repository;

  final IReservationRepository _repository;

  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _error;
  Timer? _tickTimer;

  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Reservations where the given [userId] is the buyer and action is pending.
  List<Reservation> incomingFor(String userId) => _reservations
      .where((r) => r.buyerId == userId && r.status.isOpen)
      .toList();

  /// Reservations the given [userId] created as the seller.
  List<Reservation> createdBy(String userId) =>
      _reservations.where((r) => r.sellerId == userId).toList();

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  /// Ticks every second so countdowns in the UI stay live without a manual refresh.
  void startCountdownTicker() {
    _tickTimer ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => notifyListeners(),
    );
  }

  static String normalizePhone(String raw) {
    final clean = raw.trim().replaceAll(RegExp(r'[\s\-]'), '');
    final local = clean.length == 9 && clean.startsWith('7')
        ? '0$clean'
        : clean;
    if (local.length == 10 && local.startsWith('0')) {
      return '+962${local.substring(1)}';
    }
    return local;
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.fetchForCurrentUser();
    result.fold(
      onSuccess: (list) => _reservations = list,
      onFailure: (f) => _error = f.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> lookupBuyerName(String phone) async {
    final result = await _repository.findUserNameByPhone(normalizePhone(phone));
    return result.valueOrNull;
  }

  /// Returns null on success, or an error message.
  Future<String?> createReservation({
    required String buyerPhone,
    required String itemTitle,
    required double invoiceTotal,
    required int durationMinutes,
  }) async {
    final result = await _repository.createReservation(
      buyerPhone: normalizePhone(buyerPhone),
      itemTitle: itemTitle,
      invoiceTotal: invoiceTotal,
      durationMinutes: durationMinutes,
    );
    if (result.isSuccess) await refresh();
    return result.failureOrNull?.message;
  }

  Future<String?> approve(String reservationId) async {
    final result = await _repository.approveReservation(reservationId);
    if (result.isSuccess) await refresh();
    return result.failureOrNull?.message;
  }

  Future<String?> complete(String reservationId) async {
    final result = await _repository.completeReservation(reservationId);
    if (result.isSuccess) await refresh();
    return result.failureOrNull?.message;
  }

  Future<String?> cancel(String reservationId, String reason) async {
    final result = await _repository.cancelReservation(reservationId, reason);
    if (result.isSuccess) await refresh();
    return result.failureOrNull?.message;
  }
}
