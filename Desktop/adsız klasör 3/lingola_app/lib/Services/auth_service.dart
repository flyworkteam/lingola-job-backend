import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Backend isteklerinde kullanmak için Firebase ID token'ı sağlar.
/// Google ile giriş ve token alma bu serviste.
class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Google ile giriş. Başarılı olursa [null], hata olursa hata mesajı döner.
  Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Kullanıcı iptal etti

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Giriş hatası';
    } catch (e) {
      return e.toString();
    }
  }

  /// Çıkış (Firebase + Google Sign-In).
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// Giriş yapmış kullanıcının ID token'ını döner.
  /// Kullanıcı yoksa veya token alınamazsa `null`.
  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken();
    } catch (_) {
      return null;
    }
  }

  /// Giriş yapmış kullanıcı var mı?
  bool get isSignedIn => _auth.currentUser != null;

  User? get currentUser => _auth.currentUser;
}

