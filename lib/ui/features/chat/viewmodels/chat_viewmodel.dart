import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/state/view_state.dart';
import '../../../../data/models/order/order.dart';
import '../../../../data/models/user_role.dart';
import '../../../../domain/chat/entities/chat_message.dart';
import '../../../../domain/chat/repositories/i_chat_repository.dart';
import '../../../../domain/failures/app_failure.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({
    required IChatRepository repo,
    required this.orderId,
    this.currentUserId = 'guest',
    this.currentUserName = 'Guest',
    this.currentUserRole = UserRole.supplier,
    this.order,
  }) : _repo = repo;

  final IChatRepository _repo;
  final String orderId;
  final String currentUserId;
  final String currentUserName;
  final UserRole currentUserRole;
  final Order? order;

  // ── Message state ────────────────────────────────────────────────────────────

  ViewState<List<ChatMessage>> _state = const Idle();
  ViewState<List<ChatMessage>> get state => _state;

  // Real messages from the Realtime stream.
  List<ChatMessage> _realMessages = [];
  // Optimistic messages not yet confirmed by the server.
  final List<ChatMessage> _pending = [];
  // IDs of optimistic messages that failed to send.
  final Set<String> _failedIds = {};

  Set<String> get failedIds => UnmodifiableSetView(_failedIds);

  StreamSubscription<List<ChatMessage>>? _msgSub;

  // ── Typing state ─────────────────────────────────────────────────────────────

  bool _isOtherTyping = false;
  bool get isOtherTyping => _isOtherTyping;

  bool _isSendingLocation = false;
  bool get isSendingLocation => _isSendingLocation;

  Timer? _typingDismissTimer;
  Timer? _broadcastDebounce;
  StreamSubscription<void>? _typingSub;
  bool _disposed = false;

  // ── Derived helpers ──────────────────────────────────────────────────────────

  String? get otherPartyName {
    final o = order;
    if (o == null) return null;
    return switch (currentUserRole) {
      UserRole.driver => o.supplierName,
      UserRole.supplier || UserRole.recyclingCo => o.driverName,
    };
  }

  String? get otherPartyRoleLabel => switch (currentUserRole) {
    UserRole.driver => 'مورد',
    UserRole.supplier || UserRole.recyclingCo => 'سائق',
  };

  String? get orderStatusLabel => order?.status.label;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  void init() {
    _state = const Loading();
    notifyListeners();

    _msgSub = _repo
        .watchMessages(orderId)
        .listen(
          (msgs) {
            if (_disposed) return;
            _realMessages = msgs;
            // Reconcile: remove pending messages that have now appeared in the real list.
            _pending.removeWhere(
              (p) => msgs.any(
                (r) =>
                    r.senderId == p.senderId &&
                    r.content == p.content &&
                    r.sentAt.difference(p.sentAt).abs() <
                        const Duration(seconds: 15),
              ),
            );
            _state = Loaded([..._realMessages, ..._pending]);
            notifyListeners();
            final hasUnread = msgs.any(
              (m) => m.senderId != currentUserId && !m.isRead,
            );
            if (hasUnread) _repo.markRead(orderId, currentUserId);
          },
          onError: (_) {
            if (_disposed) return;
            _state = const Failed(
              UnknownFailure(message: 'تعذّر تحميل الرسائل'),
            );
            notifyListeners();
          },
        );

    _typingSub = _repo.watchTyping(orderId, currentUserId).listen((_) {
      if (_disposed) return;
      _isOtherTyping = true;
      notifyListeners();
      _typingDismissTimer?.cancel();
      _typingDismissTimer = Timer(const Duration(seconds: 4), () {
        if (_disposed) return;
        _isOtherTyping = false;
        notifyListeners();
      });
    });
  }

  // ── Text message send ────────────────────────────────────────────────────────

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final tempId = 'opt_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = ChatMessage(
      id: tempId,
      roomId: orderId,
      senderId: currentUserId,
      senderName: currentUserName,
      senderRole: currentUserRole,
      content: trimmed,
      sentAt: DateTime.now(),
    );

    _pending.add(optimistic);
    _state = Loaded([..._realMessages, ..._pending]);
    notifyListeners();

    final result = await _repo.sendMessage(
      orderId: orderId,
      senderId: currentUserId,
      senderName: currentUserName,
      senderRole: currentUserRole,
      content: trimmed,
    );

    if (result.isFailure) {
      _failedIds.add(tempId);
      notifyListeners();
    }
    // On success: Realtime stream delivers the real message → reconcile() removes
    // the optimistic one automatically in the stream listener above.
  }

  /// Retries a failed optimistic message.
  Future<void> retry(ChatMessage failed) async {
    _failedIds.remove(failed.id);
    _pending.remove(failed);
    _state = Loaded([..._realMessages, ..._pending]);
    notifyListeners();
    await send(failed.content);
  }

  // ── Typing broadcast ─────────────────────────────────────────────────────────

  /// Call from the input bar whenever the text field changes.
  /// Debounced at 800ms so we don't flood the channel.
  void onTyping() {
    _broadcastDebounce?.cancel();
    _broadcastDebounce = Timer(const Duration(milliseconds: 800), () {
      _repo.broadcastTyping(orderId, currentUserId);
    });
  }

  // ── Media sends ──────────────────────────────────────────────────────────────

  Future<String?> pickAndSendImage() async {
    final picker = ImagePicker();
    final XFile? xfile;
    try {
      xfile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
    } catch (e) {
      return 'تعذّر فتح المعرض';
    }
    if (xfile == null) return null;
    final result = await _repo.sendImage(
      orderId: orderId,
      senderId: currentUserId,
      senderName: currentUserName,
      senderRole: currentUserRole,
      image: File(xfile.path),
    );
    return result.isFailure ? 'فشل إرسال الصورة' : null;
  }

  Future<String?> sendCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return 'تم رفض إذن الموقع — فعّل الإذن من الإعدادات';
    }

    _isSendingLocation = true;
    notifyListeners();

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      String? label;
      try {
        final marks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
        if (marks.isNotEmpty) {
          final p = marks.first;
          label = [
            p.name,
            p.street,
            p.locality,
          ].where((x) => x != null && x.isNotEmpty).join('، ');
        }
      } catch (_) {}

      final result = await _repo.sendLocation(
        orderId: orderId,
        senderId: currentUserId,
        senderName: currentUserName,
        senderRole: currentUserRole,
        lat: pos.latitude,
        lng: pos.longitude,
        label: label?.isEmpty ?? true ? null : label,
      );
      return result.isFailure ? 'فشل إرسال الموقع' : null;
    } catch (e) {
      return 'تعذّر تحديد موقعك';
    } finally {
      _isSendingLocation = false;
      notifyListeners();
    }
  }

  // ── Dispose ──────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _disposed = true;
    _msgSub?.cancel();
    _typingSub?.cancel();
    _typingDismissTimer?.cancel();
    _broadcastDebounce?.cancel();
    super.dispose();
  }
}
