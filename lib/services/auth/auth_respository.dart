import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/users.dart';
import '../../services/supabase_service.dart';

class AuthRepository {
  SupabaseClient get _supabase => SupabaseService.instance.client;

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.user != null;
    } catch (e) {
      print('Authen.sign error: $e');
      return false;
    }
  }

  Future<bool> signUp(Users user, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: user.email,
        password: password,
      );

      return response.user != null;
    } catch (e) {
      print('Authen.sign error: $e');
      return false;
    }
  }


}
