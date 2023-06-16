import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  //Google Sign In
  signInWithGoogle() async {
    //interactive sign in
    final GoogleSignInAccount? googleAcc = await GoogleSignIn().signIn();

    //obtain auth details from request
    final GoogleSignInAuthentication? googleAuth =
        await googleAcc?.authentication;

    //create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    //let sign in
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
