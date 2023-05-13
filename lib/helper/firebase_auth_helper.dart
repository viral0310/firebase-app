import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthHelper {
  FirebaseAuthHelper._();

  static final FirebaseAuthHelper firebaseAuthHelper = FirebaseAuthHelper._();
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn googleSignIn = GoogleSignIn();

  //TODO : signInAnonymously
  Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await firebaseAuth.signInAnonymously();
      User? user = userCredential.user;
      return user;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case "admin-restricted-operation":
          print("------------------------------");
          print("this operation is restricted to administrators only");
          print("------------------------------");
          break;
        case "operation-not-allowed":
          print("------------------------------");
          print("this operation is not allowed");
          print("------------------------------");
          break;
      }
    }
    return null;
  }

//Todo: signUpUser
  Future<User?> signUpUser(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      return user;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'weak-password':
          print("------------------------------");
          print("password at least 6 character long.");
          print("------------------------------");
          break;
        case "email-already-in-use":
          print("------------------------------");
          print("this user is already exits");
          print("------------------------------");
          break;
      }
    }
  }

//Todo: signInUser
  signInUser({required String email, required String password}) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      return user;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'weak-password':
          print("------------------------------");
          print("password at least 6 character long.");
          print("------------------------------");
          break;
        case "user-not-found":
          print("------------------------------");
          print("this user is not created yet.");
          print("------------------------------");
          break;
      }
    }
  }

//Todo: signInWithGoogle

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    User? user = userCredential.user;
    return user;
  }

//Todo: signOut
  signOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }
}
