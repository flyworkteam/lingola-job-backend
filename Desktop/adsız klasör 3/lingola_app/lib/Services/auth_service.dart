import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Backend isteklerinde kullanmak için Firebase ID token'ı sağlar.
/// Google / Facebook ile giriş ve token alma bu serviste.
class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  /// İptal (Vazgeç) için dönen sabit; çağıran ileri gitmemeli.
  static const String signInCancelled = 'SIGN_IN_CANCELLED';

  /// Google ile giriş. Başarılı olursa [null], iptal ederse [signInCancelled], hata olursa hata mesajı döner.
  Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return signInCancelled; // Kullanıcı Vazgeç dedi

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

  /// Facebook ile giriş. Başarılı: null, iptal: [signInCancelled], hata: mesaj.
  Future<String?> signInWithFacebook() async {
    try {
      final result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) {
        return result.status == LoginStatus.cancelled ? signInCancelled : 'Facebook girişi iptal edildi.';
      }
      final token = result.accessToken;
      if (token == null) return signInCancelled;

      final credential = FacebookAuthProvider.credential(token.tokenString);
      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Facebook giriş hatası';
    } catch (e) {
      return e.toString();
    }
  }

  /// E-posta ile şifre sıfırlama linki gönderir (Firebase Auth).
  /// Başarılı: null, hata: mesaj string.
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Bu e-posta adresiyle kayıtlı hesap bulunamadı.';
        case 'invalid-email':
          return 'Geçersiz e-posta adresi.';
        case 'too-many-requests':
          return 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin.';
        default:
          return e.message ?? 'Şifre sıfırlama e-postası gönderilemedi.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  /// Çıkış (Firebase + Google + Facebook).
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await _facebookAuth.logOut();
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

