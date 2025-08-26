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
    return _supabase.storage.from('leitura_diaria').list(
          searchOptions: const SearchOptions(
            limit: 100,
            offset: 0,
            sortBy: SortBy(column: 'created_at', order: 'asc'),
          ),
        );
  }

  Future<dynamic> listHyms(hymn) async {
    return _supabase
        .from('indice')
        .select(
          '*',
        )
        .eq(
          'hino',
          hymn,
        );
  }

  String getPublicUrlHymn(String name) {
    return _supabase.storage.from('cifras').getPublicUrl(name);
  }

  String getPublicUrl(String name) {
    return _supabase.storage.from('leitura_diaria').getPublicUrl(name);
  }
}
