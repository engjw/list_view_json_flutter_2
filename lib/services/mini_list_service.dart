import 'package:http/http.dart' as http;
import '../repositories/mini_list_repository.dart';

class MiniListService implements MiniListRepository {
  @override
  Future<String?> loadFullContent() async {
    try {
      final response = await http.get(Uri.parse(
          'https://garagedreams.net/buyers-guide/first-gen-mini-r50-r52-r53-buyers-guide'));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to fetch HTML content');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}
