import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gamehub/services/game_api_service.dart';
import 'package:gamehub/models/game.dart';
import 'package:gamehub/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  final GameApiService _apiService;
  static const String _favoritesKey = 'favorite_games';

  GameRepositoryImpl(this._apiService);

  @override
  Future<List<Game>> getGames({
    int page = 1,
    String? search,
    List<String>? genres,
    List<String>? platforms,
  }) async {
    try {
      return await _apiService.getGames(
        page: page,
        search: search,
        genres: genres?.join(','),
        platforms: platforms?.join(','),
      );
    } catch (e) {
      throw Exception('Erro ao buscar jogos: $e');
    }
  }

  @override
  Future<Game> getGameDetails(int gameId) async {
    try {
      return await _apiService.getGameDetails(gameId);
    } catch (e) {
      throw Exception('Erro ao buscar detalhes do jogo: $e');
    }
  }

  @override
  Future<List<Genre>> getGenres() async {
    try {
      return await _apiService.getGenres();
    } catch (e) {
      throw Exception('Erro ao buscar gêneros: $e');
    }
  }

  @override
  Future<List<Platform>> getPlatforms() async {
    try {
      return await _apiService.getPlatforms();
    } catch (e) {
      throw Exception('Erro ao buscar plataformas: $e');
    }
  }

  @override
  Future<List<Game>> getFavoriteGames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      return favoritesJson
          .map((jsonStr) => Game.fromJson(json.decode(jsonStr)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addToFavorites(Game game) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteGames();
      
      // Verifica se já não está nos favoritos
      if (!favorites.any((g) => g.id == game.id)) {
        favorites.add(game);
        final favoritesJson = favorites
            .map((g) => json.encode(g.toJson()))
            .toList();
        
        await prefs.setStringList(_favoritesKey, favoritesJson);
      }
    } catch (e) {
      throw Exception('Erro ao adicionar aos favoritos: $e');
    }
  }

  @override
  Future<void> removeFromFavorites(int gameId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteGames();
      
      favorites.removeWhere((game) => game.id == gameId);
      
      final favoritesJson = favorites
          .map((g) => json.encode(g.toJson()))
          .toList();
      
      await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      throw Exception('Erro ao remover dos favoritos: $e');
    }
  }

  @override
  Future<bool> isFavorite(int gameId) async {
    try {
      final favorites = await getFavoriteGames();
      return favorites.any((game) => game.id == gameId);
    } catch (e) {
      return false;
    }
  }
}
