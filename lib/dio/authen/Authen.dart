import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signIn(String email, String password) async {
  final supabase = Supabase.instance.client;

  final response = await supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );

  if (response.user != null) {
    print("Đăng nhập thành công: ${response.user!.email}");
  } else {
    print("Đăng nhập thất bại");
  }
}
