import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mighty_fitness/utils/app_colors.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../extensions/app_text_field.dart';
import '../extensions/constants.dart';
import '../extensions/decorations.dart';
import '../extensions/extension_util/int_extensions.dart';
import '../extensions/shared_pref.dart';
import '../extensions/system_utils.dart';
import '../main.dart';
import '../network/rest_api.dart';
import '../screens/chatting_image_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/verify_otp_screen.dart';
import '../utils/app_common.dart';
import '../utils/app_constants.dart';
import '../utils/app_images.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<User> signInWithGoogle() async {
  GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

  if (googleSignInAccount != null) {
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user!;

    assert(!user.isAnonymous);
    //assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser!;
    assert(user.uid == currentUser.uid);

    signOutGoogle();

    String firstName = '';
    String lastName = '';

    firstName = googleSignInAccount.displayName?.split(' ').first ?? '';
    lastName = googleSignInAccount.displayName?.split(' ').last ?? '';

    print("First Name: $firstName");
    print("Last Name: $lastName");

    //if (currentUser.displayName.validate().split(' ').length >= 1) firstName = currentUser.displayName.splitBefore(' ');
    //if (currentUser.displayName.validate().split(' ').length >= 2) lastName = currentUser.displayName.splitAfter(' ');

    // print("------------------49>>>${firstName}");
    //print("------------------50>>>${lastName}");

    await userStore.setUserImage(currentUser.photoURL.validate());

    Map req = {
      "email": currentUser.email,
      "username": currentUser.email,
      "first_name": firstName,
      "last_name": lastName,
      "login_type": LoginTypeGoogle,
      "user_type": LoginUser,
      'status': statusActive,
      'player_id': getStringAsync(PLAYER_ID).validate(),
      "accessToken": googleSignInAuthentication.accessToken,
      if (!currentUser.phoneNumber.isEmptyOrNull) "phone_number": currentUser.phoneNumber.validate(),
    };

    return await socialLogInApi(req).then((value) async {
      await userStore.setToken(value.data!.apiToken.validate());
      await userStore.setUserID(value.data!.id.validate());
      await userStore.setFirstName(value.data!.firstName.validate());
      await userStore.setLastName(value.data!.lastName.validate());
      await userStore.setGender(value.data!.gender.validate());
      await userStore.setLogin(true);

      return currentUser;
    }).catchError((e) {
      log("e->" + e);
      throw e;
    });
  } else {
    throw errorSomethingWentWrong;
  }
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();
}

Future<void> loginWithOTP(BuildContext context, String phoneNumber, String mobileNo) async {
  appStore.setLoading(true);
  return await _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {},
    verificationFailed: (FirebaseAuthException e) {
      appStore.setLoading(false);
      if (e.code == 'invalid-phone-number') {
        toast('The provided phone number is not valid.');
        throw 'The provided phone number is not valid.';
      } else {
        toast(e.toString());
        throw e.toString();
      }
    },
    timeout: Duration(minutes: 1),
    codeSent: (String verificationId, int? resendToken) async {
      finish(context);
      VerifyOTPScreen(
        verificationId: verificationId,
        isCodeSent: true,
        phoneNumber: phoneNumber,
        mobileNo: mobileNo,
      ).launch(context);
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      //
    },
  );
}

Future<UserCredential?> appleLogIn(BuildContext context) async {
  try {
    final rawNonce = generateNonceData();
    final nonce = sha256ofString(rawNonce);

    final appleCred = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCred.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCred.authorizationCode,
    );

    final result = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

    debugPrint("APPLE EMAIL: ${appleCred.email}");
    debugPrint("APPLE USER ID: ${appleCred.userIdentifier}");
    debugPrint("APPLE USER fname: ${appleCred.givenName}");
    if (getStringAsync('appleGivenName').isEmptyOrNull) {
      await setValue('appleGivenName', appleCred.givenName);
    }

// FIRST TIME → Apple gives email
    if (!appleCred.email.isEmptyOrNull && !appleCred.givenName.isEmptyOrNull) {
      await saveAppleData(result, context, appleCred: appleCred);
      return result;
    } else if (appleCred.email.isEmptyOrNull && !getStringAsync('appleGivenName').isEmptyOrNull && getStringAsync('appleEmail').isEmptyOrNull) {
      askUserForEmail(context, result, appleCred);
    }else if (appleCred.email.isEmptyOrNull && appleCred.givenName.isEmptyOrNull) {
      final req = {
        'apple_user_identifier': appleCred.userIdentifier,
        'login_type': 'apple',
        'user_type': 'user',
      };

      socialLogin(req,context);
    }
  } catch (e) {
    debugPrint("Apple Login Error: $e");
    rethrow;
  }
}

Future<void> saveAppleDataManualEmail(
  UserCredential result,
  String email,
  AuthorizationCredentialAppleID appleCred,
  BuildContext context,
) async {
  await setValue('appleEmail', email);
  await setValue('appleUserId', appleCred.userIdentifier);
  if (getStringAsync('appleGivenName').isEmptyOrNull) {
    await setValue('appleGivenName', appleCred.givenName ?? "");
  }
  await setValue('appleFamilyName', appleCred.familyName ?? "");

  final req = {
    'email': email,
    'username': email,
    'first_name': appleCred.givenName,
    'last_name': appleCred.familyName,
    'login_type': LoginTypeApple,
    'user_type': LoginUser,
    'status': statusActive,
    'player_id': getStringAsync(PLAYER_ID),
    'accessToken': appleCred.authorizationCode ?? "",
    'apple_user_identifier': appleCred.userIdentifier,
  };
  socialLogin(req, context,isFromPopup: true);
}

Future<void> loginWithStoredAppleEmail(
  UserCredential result,
  String email,
  AuthorizationCredentialAppleID appleCred,
  BuildContext context,
) async {
  final req = {
    'email': email,
    'username': email,
    'first_name': getStringAsync('appleGivenName'),
    'last_name': getStringAsync('appleFamilyName'),
    'login_type': LoginTypeApple,
    'user_type': LoginUser,
    'status': statusActive,
    'player_id': getStringAsync(PLAYER_ID),
    'accessToken': appleCred.authorizationCode ?? "",
  };

  socialLogin(req,context);
}

Future<String?> askUserForEmail(BuildContext contexts, UserCredential result,
    AuthorizationCredentialAppleID appleCred,) async {
  final controller = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  return await showDialog<String>(
    context: contexts,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(ic_mail, height: 32, width: 32, color: primaryColor)
              ),
              SizedBox(height: 20),
              Text(
                languages.lblEnterEmail,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24),
              Form(
                key: formKey,
                child: AppTextField(
                  controller: controller,
                  textFieldType: TextFieldType.EMAIL,
                  keyboardType: TextInputType.emailAddress,
                  suffix: mSuffixTextFieldIconWidget(ic_mail),
                  decoration: defaultInputDecoration(context, label: languages.lblEnterEmail),
                  isValidationRequired: true,
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(contexts, null);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        languages.lblCancel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          FocusScope.of(context).unfocus();
                          await saveAppleDataManualEmail(result, controller.text.trim(), appleCred, contexts);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: primaryColor,
                        elevation: 0,
                      ),
                      child: Text(
                        languages.lblContinue,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}


Future<void> saveAppleData(
  UserCredential result,
  BuildContext context, {
  required AuthorizationCredentialAppleID appleCred,
}) async {
  final email = appleCred.email!;
  final firstName = appleCred.givenName ?? '';
  final lastName = appleCred.familyName ?? '';

  // STORE VALUES FOR FUTURE LOGINS
  await setValue('appleEmail', email);
  await setValue('appleGivenName', firstName);
  await setValue('appleFamilyName', lastName);
  await setValue('appleUserId', appleCred.userIdentifier);

  final req = {
    'email': email,
    'username': email,
    'first_name': firstName,
    'last_name': lastName,
    'login_type': LoginTypeApple,
    'user_type': LoginUser,
    'status': statusActive,
    'player_id': getStringAsync(PLAYER_ID),
    'accessToken': appleCred.authorizationCode,
    'apple_user_identifier': appleCred.userIdentifier,
  };

  socialLogin(req,context);
}

Future<void> socialLogin(req,  BuildContext context, {bool isFromPopup = false}) async {
  appStore.setLoading(true);
  return await socialLogInApi(req).then((res) async {
    appStore.setLoading(false);
    if (isFromPopup) {
      Navigator.pop(context);
    }
    await userStore.setUserID(res.data!.id.validate());
    await userStore.setFirstName(res.data!.firstName.validate());
    await userStore.setLastName(res.data!.lastName.validate());
    await userStore.setGender(res.data!.gender.validate());
    await userStore.setToken(res.data!.apiToken.validate());
    await userStore.setLogin(true);
    await userStore.setUserEmail(res.data!.email.validate());
    await userStore.setUsername(res.data!.email.validate());
    await userStore.setUserImage(res.data!.profileImage.validate());
    await userStore.setDisplayName(res.data!.displayName.validate());
    await userStore.setPhoneNo(res.data!.phoneNumber.validate());
    getUSerDetail(context, res.data!.id.validate()).then((value) {
      DashboardScreen().launch(context, isNewTask: true);
    }).catchError((e) {
      print("error=>" + e.toString());
    });
  }).catchError((error) {
    appStore.setLoading(false);
    if(isFromPopup){
      removeKey('appleEmail');
    }
    toast(error.toString());
  });
}

Future deleteUser() async {
  if (FirebaseAuth.instance.currentUser != null) {
    FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
  }
}

Future<void> saveAppleDataWithoutEmail(AuthorizationResult result, String? accessToken, BuildContext context) async {
  var req = {
    'email': getStringAsync('appleEmail'),
    "username": getStringAsync('appleEmail'),
    'first_name': getStringAsync('appleGivenName'),
    'last_name': getStringAsync('appleFamilyName'),
    "user_type": LoginUser,
    'status': statusActive,
    'player_id': getStringAsync(PLAYER_ID).validate(),
    'accessToken': accessToken,
    // 'photoURL': '',
    'login_type': LoginTypeApple,
  };

  return await socialLogInApi(req).then((value) async {
    await userStore.setUserID(value.data!.id.validate());
    await userStore.setFirstName(value.data!.firstName.validate());
    await userStore.setLastName(value.data!.lastName.validate());
    await userStore.setGender(value.data!.gender.validate());
    await userStore.setLogin(true);
    await userStore.setToken(value.data!.apiToken.validate());
    await userStore.setUserEmail(value.data!.email.validate());
    await userStore.setUsername(value.data!.email.validate());
    await userStore.setUserImage(value.data!.profileImage.validate());
    await userStore.setDisplayName(value.data!.displayName.validate());
    await userStore.setPhoneNo(value.data!.phoneNumber.validate());
    getUSerDetail(context, value.data!.id.validate()).then((value) {
      DashboardScreen().launch(context, isNewTask: true);
    }).catchError((e) {
      print("error=>" + e.toString());
    });
  }).catchError((e) {
    log("e->" + e);
    throw e;
  });
}

Future deleteUserFirebase() async {
  if (FirebaseAuth.instance.currentUser != null) {
    FirebaseAuth.instance.currentUser?.delete();
    await FirebaseAuth.instance.signOut();
  }
}

Future<void> logout(BuildContext context, {Function? onLogout}) async {
  await removeKey(IS_LOGIN);
  await removeKey(USER_ID);
  await removeKey(FIRSTNAME);
  await removeKey(LASTNAME);
  await removeKey(USER_PROFILE_IMG);
  await removeKey(DISPLAY_NAME);
  await removeKey(PHONE_NUMBER);
  await removeKey(GENDER);
  await removeKey(AGE);
  await removeKey(HEIGHT);
  await removeKey(HEIGHT_UNIT);
  await removeKey(IS_OTP);
  await removeKey(IS_SOCIAL);
  await removeKey(WEIGHT);
  await removeKey(WEIGHT_UNIT);
  userStore.clearUserData();
  questionAnswers.clear();
  myMessages.clear();
  if (getBoolAsync(IS_SOCIAL) || !getBoolAsync(IS_REMEMBER) || getBoolAsync(IS_OTP) == true) {
    await removeKey(PASSWORD);
    await removeKey(EMAIL);
  }
  userStore.setLogin(false);
  onLogout?.call();
}
