import 'package:flutter/foundation.dart';

import '../../../../core/state/view_state.dart';
import '../../../../data/models/partner_data_request.dart';
import '../../../../domain/failures/app_failure.dart';
import '../../../../domain/repositories/i_partner_data_request_repository.dart';

/// Drives the data-access request form inside the About Dwaar sheet
/// (reachable from the login screen, before the visitor has an account).
class AboutDwaarViewModel extends ChangeNotifier {
  AboutDwaarViewModel({required IPartnerDataRequestRepository repository})
    : _repository = repository;

  final IPartnerDataRequestRepository _repository;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  ViewState<PartnerDataRequest> _state = const Idle();
  ViewState<PartnerDataRequest> get state => _state;

  /// Validates the form fields; returns per-field error messages (l10n keys
  /// are resolved by the caller, this returns field names only).
  Map<String, String> validate({
    required String companyName,
    required String contactName,
    required String email,
  }) {
    final errors = <String, String>{};
    if (companyName.trim().isEmpty) errors['companyName'] = 'required';
    if (contactName.trim().isEmpty) errors['contactName'] = 'required';
    if (email.trim().isEmpty) {
      errors['email'] = 'required';
    } else if (!_emailPattern.hasMatch(email.trim())) {
      errors['email'] = 'invalid';
    }
    return errors;
  }

  Future<void> submit({
    required String companyName,
    required String contactName,
    required String email,
    String? phone,
    required String message,
  }) async {
    final fieldErrors = validate(
      companyName: companyName,
      contactName: contactName,
      email: email,
    );
    if (fieldErrors.isNotEmpty) {
      _state = Failed(
        ValidationFailure(message: 'validation', fieldErrors: fieldErrors),
      );
      notifyListeners();
      return;
    }

    _state = const Loading();
    notifyListeners();

    final result = await _repository.submitRequest(
      companyName: companyName.trim(),
      contactName: contactName.trim(),
      email: email.trim(),
      phone: (phone == null || phone.trim().isEmpty) ? null : phone.trim(),
      message: message.trim(),
    );

    _state = result.fold(
      onSuccess: (request) => Loaded(request),
      onFailure: (failure) => Failed(failure),
    );
    notifyListeners();
  }

  void reset() {
    _state = const Idle();
    notifyListeners();
  }
}
