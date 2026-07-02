import '../../core/result/result.dart';
import '../../data/models/driver_wallet.dart';

abstract interface class IWalletRepository {
  /// Current balance + held amount for the authenticated driver.
  Future<AppResult<DriverWallet>> getWallet();

  /// Hold [amount] JD against [orderId] when driver accepts.
  Future<AppResult<void>> holdForOrder(String orderId, double amount);

  /// Move held [amount] to spendable balance when order completes.
  Future<AppResult<void>> releaseForOrder(String orderId, double amount);
}

final class NoOpWalletRepository implements IWalletRepository {
  const NoOpWalletRepository();

  @override
  Future<AppResult<DriverWallet>> getWallet() async =>
      const Success(DriverWallet.zero);

  @override
  Future<AppResult<void>> holdForOrder(String orderId, double amount) async =>
      const Success(null);

  @override
  Future<AppResult<void>> releaseForOrder(
    String orderId,
    double amount,
  ) async => const Success(null);
}
