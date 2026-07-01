import '../../core/result/result.dart';
import '../../data/models/reservation.dart';

abstract interface class IReservationRepository {
  /// Resolves a buyer's display name by phone (e.g. '+9627XXXXXXXX'), without
  /// exposing the rest of their profile. Returns null if no user has that phone.
  Future<AppResult<String?>> findUserNameByPhone(String phone);

  /// Seller creates a reservation for the buyer at [buyerPhone]. Returns the
  /// new reservation's id.
  Future<AppResult<String>> createReservation({
    required String buyerPhone,
    required String itemTitle,
    required double invoiceTotal,
    required int durationMinutes,
  });

  /// Buyer locks in a pending reservation — starts the completion countdown.
  Future<AppResult<void>> approveReservation(String reservationId);

  /// Either party marks the reservation as fulfilled before the deadline.
  Future<AppResult<void>> completeReservation(String reservationId);

  /// Seller cancels. [reason] == 'sold_elsewhere' on an active reservation
  /// immediately applies the 10% seller-fraud penalty server-side.
  Future<AppResult<void>> cancelReservation(String reservationId, String reason);

  /// All reservations where the current user is either the seller or buyer.
  Future<AppResult<List<Reservation>>> fetchForCurrentUser();
}

final class NoOpReservationRepository implements IReservationRepository {
  const NoOpReservationRepository();

  @override
  Future<AppResult<String?>> findUserNameByPhone(String phone) async =>
      const Success(null);

  @override
  Future<AppResult<String>> createReservation({
    required String buyerPhone,
    required String itemTitle,
    required double invoiceTotal,
    required int durationMinutes,
  }) async =>
      const Success('');

  @override
  Future<AppResult<void>> approveReservation(String reservationId) async =>
      const Success(null);

  @override
  Future<AppResult<void>> completeReservation(String reservationId) async =>
      const Success(null);

  @override
  Future<AppResult<void>> cancelReservation(String reservationId, String reason) async =>
      const Success(null);

  @override
  Future<AppResult<List<Reservation>>> fetchForCurrentUser() async =>
      const Success([]);
}
