import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gamehub/models/game.dart';

class GameApiService {
  static const String _baseUrl = 'https://api.rawg.io/api';
  static const String _apiKey = '29dee52089b846e6a4d27c6516219515'; // API key pública do RAWG

  Future<List<Game>> getGames({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? genres,
    String? platforms,
  }) async {
    final queryParams = <String, String>{
      'key': _apiKey,
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (genres != null && genres.isNotEmpty) {
      queryParams['genres'] = genres;
    }
    if (platforms != null && platforms.isNotEmpty) {
      queryParams['platforms'] = platforms;
    }

    final uri = Uri.parse('$_baseUrl/games').replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> gamesJson = data['results'] ?? [];
        
        return gamesJson.map((json) => Game.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar jogos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Game> getGameDetails(int gameId) async {
    final uri = Uri.parse('$_baseUrl/games/$gameId').replace(
      queryParameters: {'key': _apiKey},
    );
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Game.fromJson(data);
      } else {
        throw Exception('Erro ao carregar detalhes do jogo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<Genre>> getGenres() async {
    final uri = Uri.parse('$_baseUrl/genres').replace(
      queryParameters: {'key': _apiKey},
    );
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> genresJson = data['results'] ?? [];
        
        return genresJson.map((json) => Genre.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar gêneros: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<Platform>> getPlatforms() async {
    final uri = Uri.parse('$_baseUrl/platforms').replace(
      queryParameters: {'key': _apiKey},
    );
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> platformsJson = data['results'] ?? [];
        
        return platformsJson.map((json) => Platform.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar plataformas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
