import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreOrderListener {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToOrder(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToOrdersForUser(String userId, String roleField) {
    return _firestore
        .collection('orders')
        .where(roleField, isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('created_at', descending: true)
        .snapshots();
  }
}
