import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../subscription/model/subscription_plan_model.dart';
import '../model/login_response.dart';

//region FIREBASE AUTH
final FirebaseAuth auth = FirebaseAuth.instance;
//endregion

class GoogleSignInAuthService {
  GoogleSignIn googleSignIn = GoogleSignIn.instance;

  Future<UserData?> signInWithGoogle() async {
    await googleSignIn.initialize(serverClientId: FIREBASE_SERVER_CLIENT_ID);

    // Sign out and disconnect any previous session to avoid "Account reauth failed" / canceled.
    try {
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
    } catch (_) {}

    final GoogleSignInAccount account = await googleSignIn.authenticate();
    final authTokens = account.authentication;
    final String? idToken = authTokens.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google Sign-In: No ID token received. Please try again.');
    }

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );

    final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
    final User user = authResult.user!;
    if (user.isAnonymous) throw Exception('Google Sign-In failed.');

    final User currentUser = FirebaseAuth.instance.currentUser!;
    if (user.uid != currentUser.uid) throw Exception('Google Sign-In failed.');

    // Optional: link email/password for backend. If it fails (e.g. already linked), we still use the user.
    try {
      if (user.email != null && user.email!.isNotEmpty) {
        final AuthCredential emailCred = EmailAuthProvider.credential(
          email: user.email!,
          password: Constants.DEFAULT_PASS,
        );
        await user.linkWithCredential(emailCred);
      }
    } catch (e) {
      log('Google linkWithCredential (optional): $e');
    }

    try {
      await googleSignIn.signOut();
    } catch (_) {}

    String firstName = '';
    String lastName = '';
    final String? displayName = currentUser.displayName?.validate();
    if (displayName != null && displayName.isNotEmpty) {
      final parts = displayName.split(' ');
      if (parts.isNotEmpty) firstName = parts.first;
      if (parts.length >= 2) lastName = parts.sublist(1).join(' ');
    }

    final UserData tempUserData = UserData(planDetails: SubscriptionPlanModel())
      ..mobile = currentUser.phoneNumber.validate()
      ..email = currentUser.email.validate()
      ..firstName = firstName.validate()
      ..lastName = lastName.validate()
      ..profileImage = currentUser.photoURL.validate()
      ..loginType = LoginTypeConst.LOGIN_TYPE_GOOGLE
      ..fullName = currentUser.displayName.validate();

    return tempUserData;
  }

  // region Apple Sign
  Future<UserData> signInWithApple() async {
    if (await TheAppleSignIn.isAvailable()) {
      final AuthorizationResult result = await TheAppleSignIn.performRequests([
        const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName]),
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:
          final appleIdCredential = result.credential!;
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken!),
            accessToken: String.fromCharCodes(appleIdCredential.authorizationCode!),
          );

          final authResult = await auth.signInWithCredential(credential);
          final User user = authResult.user!;
          assert(!user.isAnonymous);

          final User currentUser = auth.currentUser!;
          assert(user.uid == currentUser.uid);

          log('CURRENTUSER: $currentUser');

          // await googleSignIn.signOut();

          String firstName = '';
          String lastName = '';
          log('result.credential ==> ${result.credential?.toMap()}');
          log('result.credential!.fullName ==> ${result.credential!.fullName!.toMap()}');

          if (result.credential != null && result.credential!.fullName != null) {
            firstName = result.credential!.fullName!.givenName.validate();
            lastName = result.credential!.fullName!.familyName.validate();
          }

          /// Create a temporary request to send
          final UserData tempUserData = UserData(planDetails: SubscriptionPlanModel())
            ..mobile = currentUser.phoneNumber.validate()
            ..email = currentUser.email.validate()
            ..firstName = firstName.validate()
            ..lastName = lastName.validate()
            ..profileImage = currentUser.photoURL.validate()
            ..loginType = LoginTypeConst.LOGIN_TYPE_APPLE
            ..fullName = "${firstName.validate()} ${lastName.validate()}";

          return tempUserData;
        case AuthorizationStatus.error:
          throw "${locale.value.signInFailed}: ${result.error!.localizedDescription}";
        case AuthorizationStatus.cancelled:
          throw locale.value.userCancelled;
      }
    } else {
      throw locale.value.appleSigninIsNot;
    }
  }
}