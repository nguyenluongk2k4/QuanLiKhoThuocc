import 'package:pharmastock_manager/core/app_export.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserResponsitory {
  SupabaseClient get _supabase => SupabaseService.instance.client;
  Future<bool> updateUser(Users user) async {
    try {
      final attrs = UserAttributes(
        phone: user.phone,
        data: user.fullName != null ? {'full_name': user.fullName} : null,
      );

      final response = await _supabase.auth.updateUser(attrs);
      return response.user != null;
    } catch (e) {
      print('Authen.sign error: $e');
      return false;
    }
  }
}
