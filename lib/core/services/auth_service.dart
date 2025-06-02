import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _currentUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _init();
  }

  void _init() {
    _currentUser = _auth.currentUser;
    _auth.authStateChanges().listen(_onAuthStateChanged);
    if (_currentUser != null) {
      _loadUserData();
    }
  }

  void _onAuthStateChanged(User? user) {
    _currentUser = user;
    if (user != null) {
      _loadUserData();
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Register with email and password
  Future<bool> registerWithEmailPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _createUserDocument(
          credential.user!,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
        );

        await credential.user!.sendEmailVerification();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Произошла неожиданная ошибка');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Произошла неожиданная ошибка');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userDataKey);
      
    } catch (e) {
      _setError('Ошибка при выходе из аккаунта');
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Произошла неожиданная ошибка');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
    User user, {
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email!,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      profileImageUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEmailVerified: user.emailVerified,
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(userModel.toJson());

    _userModel = userModel;
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_currentUser!.uid)
          .get();

      if (doc.exists) {
        _userModel = UserModel.fromJson(doc.data()!);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.userDataKey,
          _userModel!.toJson().toString(),
        );
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null || _userModel == null) return false;

    try {
      _setLoading(true);
      _setError(null);

      final updatedData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (firstName != null) updatedData['firstName'] = firstName;
      if (lastName != null) updatedData['lastName'] = lastName;
      if (phoneNumber != null) updatedData['phoneNumber'] = phoneNumber;
      if (profileImageUrl != null) updatedData['profileImageUrl'] = profileImageUrl;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_currentUser!.uid)
          .update(updatedData);

      _userModel = _userModel!.copyWith(
        firstName: firstName ?? _userModel!.firstName,
        lastName: lastName ?? _userModel!.lastName,
        phoneNumber: phoneNumber ?? _userModel!.phoneNumber,
        profileImageUrl: profileImageUrl ?? _userModel!.profileImageUrl,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка при обновлении профиля');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    if (_currentUser == null) return false;

    try {
      await _currentUser!.sendEmailVerification();
      return true;
    } catch (e) {
      _setError('Ошибка при отправке письма подтверждения');
      return false;
    }
  }

  // Reload user and check email verification
  Future<void> reloadUser() async {
    if (_currentUser != null) {
      await _currentUser!.reload();
      _currentUser = _auth.currentUser;
      
      if (_userModel != null && _currentUser!.emailVerified != _userModel!.isEmailVerified) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(_currentUser!.uid)
            .update({
          'isEmailVerified': _currentUser!.emailVerified,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        _userModel = _userModel!.copyWith(
          isEmailVerified: _currentUser!.emailVerified,
          updatedAt: DateTime.now(),
        );
      }
      
      notifyListeners();
    }
  }

  // Get error message in Russian
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Пользователь с таким email не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'email-already-in-use':
        return 'Пользователь с таким email уже существует';
      case 'weak-password':
        return 'Пароль слишком слабый';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-disabled':
        return 'Аккаунт заблокирован';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'operation-not-allowed':
        return 'Операция не разрешена';
      case 'requires-recent-login':
        return 'Требуется повторная авторизация';
      default:
        return 'Ошибка авторизации';
    }
  }

  void clearError() {
    _setError(null);
  }
}
