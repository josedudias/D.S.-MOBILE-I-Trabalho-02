import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gamehub/models/game.dart';
import 'package:gamehub/repositories/game_repository.dart';
import 'package:gamehub/views/game_details.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Game> favoriteGames = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final repository = context.read<GameRepository>();
      final favorites = await repository.getFavoriteGames();
      
      setState(() {
        favoriteGames = favorites;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(Game game) async {
    try {
      final repository = context.read<GameRepository>();
      await repository.removeFromFavorites(game.id);
      
      setState(() {
        favoriteGames.removeWhere((g) => g.id == game.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${game.name} removido dos favoritos'),
          backgroundColor: Colors.deepPurple,
          action: SnackBarAction(
            label: 'Desfazer',
            textColor: Colors.white,
            onPressed: () async {
              await repository.addToFavorites(game);
              setState(() {
                favoriteGames.add(game);
              });
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover dos favoritos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum jogo favorito',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore jogos e adicione aos seus favoritos!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.explore),
            label: const Text('Explorar Jogos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            const Text(
              'Erro ao carregar favoritos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _loadFavorites();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoriteGames.length,
        itemBuilder: (context, index) {
          final game = favoriteGames[index];
          return FavoriteGameCard(
            game: game,
            onRemove: () => _removeFromFavorites(game),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Meus Favoritos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando favoritos...'),
                ],
              ),
            )
          : errorMessage != null
              ? _buildErrorState()
              : favoriteGames.isEmpty
                  ? _buildEmptyState()
                  : _buildFavoritesList(),
    );
  }
}

class FavoriteGameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onRemove;

  const FavoriteGameCard({
    super.key,
    required this.game,
    required this.onRemove,
  });

  Color _getGenreColor(String genreSlug) {
    return genreColors[genreSlug.toLowerCase()] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final primaryGenre = game.genres.isNotEmpty ? game.genres[0].slug : 'indie';
    final cardColor = _getGenreColor(primaryGenre ?? 'indie').withValues(alpha: 0.1);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: cardColor,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameDetails(gameId: game.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Imagem do jogo
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: game.backgroundImage != null
                        ? CachedNetworkImage(
                            imageUrl: game.backgroundImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.videogame_asset, color: Colors.grey),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.videogame_asset, color: Colors.grey),
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Informações do jogo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      if (game.rating != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              game.formattedRating,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      
                      if (game.released != null)
                        Text(
                          'Lançamento: ${game.formattedReleaseDate}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      if (game.genres.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: game.genres.take(2).map((genre) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getGenreColor(genre.slug ?? '').withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                genre.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                
                // Botão de remover
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  tooltip: 'Remover dos favoritos',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
