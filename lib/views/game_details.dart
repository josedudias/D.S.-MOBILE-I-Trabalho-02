import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gamehub/models/game.dart';
import 'package:gamehub/repositories/game_repository.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GameDetails extends StatefulWidget {
  final int gameId;

  const GameDetails({super.key, required this.gameId});

  @override
  State<GameDetails> createState() => _GameDetailsState();
}

class _GameDetailsState extends State<GameDetails> {
  Game? game;
  bool isLoading = true;
  String? errorMessage;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadGameDetails();
  }

  Future<void> _loadGameDetails() async {
    try {
      final repository = context.read<GameRepository>();
      final gameData = await repository.getGameDetails(widget.gameId);
      final favoriteStatus = await repository.isFavorite(widget.gameId);
      
      setState(() {
        game = gameData;
        isFavorite = favoriteStatus;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }
  Future<void> _toggleFavorite() async {
    if (game == null) return;

    try {
      final repository = context.read<GameRepository>();
      
      if (isFavorite) {
        await repository.removeFromFavorites(game!.id);
      } else {
        await repository.addToFavorites(game!);
      }
      
      setState(() {
        isFavorite = !isFavorite;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorite 
                ? 'Jogo adicionado aos favoritos!' 
                : 'Jogo removido dos favoritos!',
            ),
            backgroundColor: Colors.deepPurple,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar favoritos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _openWebsite() async {
    if (game?.website != null && game!.website!.isNotEmpty) {
      final uri = Uri.parse(game!.website!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o site'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getGenreColor(String genreSlug) {
    return genreColors[genreSlug.toLowerCase()] ?? Colors.grey;
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando detalhes do jogo...'),
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
              'Erro ao carregar detalhes',
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
                _loadGameDetails();
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

  Widget _buildGameImage() {
    final imageUrl = game?.backgroundImage ?? '';
    
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.deepPurple,
      flexibleSpace: FlexibleSpaceBar(
        background: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, _, _) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.videogame_asset, size: 80, color: Colors.grey),
                  ),
                ),
              )
            : Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.videogame_asset, size: 80, color: Colors.grey),
                ),
              ),
      ),
      actions: [
        IconButton(
          onPressed: _toggleFavorite,
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildGameInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              game!.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Rating e Metacritic
            Row(
              children: [
                if (game!.rating != null) ...[
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    game!.formattedRating,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                ],
                if (game!.metacriticScore != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMetacriticColor(game!.metacriticScore!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Metacritic: ${game!.metacriticScore}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Data de lançamento
            if (game!.released != null) ...[
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Lançamento: ${game!.formattedReleaseDate}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Gêneros
            if (game!.genres.isNotEmpty) ...[
              const Text(
                'Gêneros',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: game!.genres.map((genre) {
                  return Chip(
                    label: Text(genre.name),
                    backgroundColor: _getGenreColor(genre.slug ?? '').withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Plataformas
            if (game!.platforms.isNotEmpty) ...[
              const Text(
                'Plataformas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: game!.platforms.map((platform) {
                  return Chip(
                    label: Text(platform.name),
                    backgroundColor: Colors.blue.withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Descrição
            if (game!.description != null && game!.description!.isNotEmpty) ...[
              const Text(
                'Descrição',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                game!.description!,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
            ],
            
            // Screenshots
            if (game!.screenshots.isNotEmpty) ...[
              const Text(
                'Screenshots',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: game!.screenshots.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: game!.screenshots[index],
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Website
            if (game!.website != null && game!.website!.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: _openWebsite,
                icon: const Icon(Icons.public),
                label: const Text('Visitar Site Oficial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getMetacriticColor(int score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text('Carregando...'),
        ),
        body: _buildLoadingState(),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text('Erro'),
        ),
        body: _buildErrorState(),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildGameImage(),
          _buildGameInfo(),
        ],
      ),
    );
  }
}
