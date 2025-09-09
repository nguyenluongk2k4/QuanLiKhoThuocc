import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

abstract class BaseService {
  SupabaseClient get client => SupabaseService.instance.client;
}
