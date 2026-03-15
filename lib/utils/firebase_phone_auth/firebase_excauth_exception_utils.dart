import 'package:firebase_auth/firebase_auth.dart';

import '../../main.dart';

class FirebaseAuthHandleExceptionsUtils {
  String handleException(FirebaseAuthException firebaseAuthException) {
    String message = '';
    final String msg = firebaseAuthException.message ?? '';
    switch (firebaseAuthException.code) {
      case 'network-request-failed':
        message = locale.value.pleaseCheckYourMobileInternetConnection;
        break;
      case 'invalid-verification-code':
        message = locale.value.pleaseEnterAValidCode;
        break;
      case 'too-many-requests':
        message = locale.value.pleaseTryAgainAfterSomeTime;
        break;
      case 'invalid-phone-number':
        message = locale.value.pleaseEnterAValidMobileNo;
        break;
      case 'invalid-api-key':
      case 'api-key-not-valid':
        message = 'Firebase API key issue. Please contact support or try again later.';
        break;
      case 'internal-error':
        if (msg.toLowerCase().contains('suspended') || msg.contains('403')) {
          message = 'Firebase service temporarily unavailable. Please try again later or contact support.';
        } else {
          message = msg.isNotEmpty ? msg : 'An error occurred. Please try again.';
        }
        break;
      default:
        if (msg.toLowerCase().contains('suspended') || msg.contains('PERMISSION_DENIED') || msg.contains('403')) {
          message = 'Firebase service temporarily unavailable. Please try again later.';
        } else {
          message = msg.isNotEmpty ? msg : 'Please try again.';
        }
    }
    return message;
  }
}