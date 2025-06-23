import 'package:gamehub/models/game.dart';

abstract class GameRepository {
  Future<List<Game>> getGames({
    int page = 1,
    String? search,
    List<String>? genres,
    List<String>? platforms,
  });
  
  Future<Game> getGameDetails(int gameId);
  Future<List<Genre>> getGenres();
  Future<List<Platform>> getPlatforms();
  Future<List<Game>> getFavoriteGames();
  Future<void> addToFavorites(Game game);
  Future<void> removeFromFavorites(int gameId);
  Future<bool> isFavorite(int gameId);
}
