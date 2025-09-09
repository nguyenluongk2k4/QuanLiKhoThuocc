import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/users.dart';

class Authen {
  final SupabaseClient _supabase = Supabase.instance.client;

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
        phone: user.phone,
        data:{
          'fullname': user.fullName,
        }
      );

      return response.user != null;
    } catch (e) {
      print('Authen.sign error: $e');
      return false;
    }
  }


}
