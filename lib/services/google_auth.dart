import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleUserInfo {
  final String name;
  final String email;
  final String photoUrl;

  GoogleUserInfo({
    required this.name,
    required this.email,
    required this.photoUrl,
  });
}

class GoogleAuth {
  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    // Interactive sign in
    final GoogleSignInAccount? googleAcc = await GoogleSignIn().signIn();

    if (googleAcc == null) {
      // User canceled the sign-in process
      return null;
    }

    // Obtain auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleAcc.authentication;

    // Create a new credential for the user
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Sign in with the credential
    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Save user data to Firestore
    await saveUserData(userCredential);

    return userCredential;
  }

  // Save user data to Firestore
  Future<void> saveUserData(UserCredential? userCredential) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(currentUser?.uid);

    final googleProvider = userCredential?.additionalUserInfo?.profile;

    if (currentUser != null && googleProvider != null) {
      final userData = {
        'username': googleProvider['name'],
        'email': googleProvider['email'],
        'photoUrl': googleProvider['picture'],
        'bio': ""
      };

      await userDocRef.set(userData, SetOptions(merge: true));
    }
  }

  // Check if the user logged in with Google
  bool isSignedInWithGoogle() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null &&
        currentUser.providerData.any((info) {
          return info.providerId == GoogleAuthProvider.GOOGLE_SIGN_IN_METHOD;
        });
  }

  // Get the user information from the Google sign-in
  Future<GoogleUserInfo?> getUserInfo() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final googleProvider = currentUser.providerData.firstWhere(
        (info) => info.providerId == GoogleAuthProvider.GOOGLE_SIGN_IN_METHOD,
      );

      if (googleProvider != null) {
        return GoogleUserInfo(
          name: googleProvider.displayName ?? '',
          email: googleProvider.email ?? '',
          photoUrl: googleProvider.photoURL ?? '',
        );
      }
    }
    return null;
  }
}
