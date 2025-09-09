import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton wrapper that initializes Supabase exactly once.
class SupabaseService {
  SupabaseService._privateConstructor();
  static final SupabaseService instance = SupabaseService._privateConstructor();

  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Initialize from an asset JSON file (default 'env.json').
  /// The JSON must contain keys: SUPABASE_URL and SUPABASE_ANON_KEY.
  Future<void> initFromAsset({String assetPath = 'env.json'}) async {
    if (_initialized) return;

    final envString = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> env = json.decode(envString);

    await Supabase.initialize(
      url: env['SUPABASE_URL'] as String,
      anonKey: env['SUPABASE_ANON_KEY'] as String,
    );

    _initialized = true;
  }

  /// Direct initialize with explicit values.
  Future<void> init({required String url, required String anonKey}) async {
    if (_initialized) return;
    await Supabase.initialize(url: url, anonKey: anonKey);
    _initialized = true;
  }

  SupabaseClient get client {
    if (!_initialized) {
      throw StateError('SupabaseService not initialized. Call init() first.');
    }
    return Supabase.instance.client;
  }
}
