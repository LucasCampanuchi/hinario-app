import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase/supabase.dart';

class SupabaseService {
  final String _supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final String _supabaseKey = dotenv.env['SUPABASE_KEY']!;
  late final SupabaseClient _supabase;

  SupabaseService() {
    _supabase = SupabaseClient(_supabaseUrl, _supabaseKey);
  }

  Future<List<FileObject>> listFiles() async {
    return _supabase.storage.from('pdfs').list(
          searchOptions: const SearchOptions(
            limit: 100,
            offset: 0,
          ),
        );
  }

  String getPublicUrl(String name) {
    return _supabase.storage.from('pdfs').getPublicUrl(name);
  }
}
