import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'secure_token_store.dart';

class CloudRunClient {
  final Dio dio;
  final SecureTokenStore tokenStore;

  CloudRunClient({required String baseUrl, required this.tokenStore})
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Retrieve fresh ID token from Firebase Auth if current user is active
        final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final token = await currentUser.getIdToken();
          if (token != null) {
            await tokenStore.saveToken(token);
            options.headers['Authorization'] = 'Bearer $token';
          }
        } else {
          final cachedToken = await tokenStore.getToken();
          if (cachedToken != null) {
            options.headers['Authorization'] = 'Bearer $cachedToken';
          }
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired, force-refresh ID token from Firebase
          final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            final token = await currentUser.getIdToken(true);
            if (token != null) {
              await tokenStore.saveToken(token);
              e.requestOptions.headers['Authorization'] = 'Bearer $token';
              // Retry cloned request
              try {
                final cloneReq = await dio.fetch(e.requestOptions);
                return handler.resolve(cloneReq);
              } catch (_) {}
            }
          }
        }
        return handler.next(e);
      },
    ));
  }
}
