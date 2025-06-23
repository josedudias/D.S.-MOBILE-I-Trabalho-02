import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gamehub/models/game.dart';
import 'package:gamehub/viewmodels/home_view_model.dart';
import 'package:gamehub/views/game_details.dart';
import 'package:gamehub/views/favorites_screen.dart';
import 'package:gamehub/services/auth_service.dart';
import 'package:provider/provider.dart';

class GameHubHome extends StatefulWidget {
  const GameHubHome({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _GameHubHomeState();
}

class _GameHubHomeState extends State<GameHubHome> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingMore = false;
  final ValueNotifier<bool> _showBackToTopButton = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore) {
        setState(() {
          _isLoadingMore = true;
        });

        context.read<HomeViewModel>().loadMore().whenComplete(() {
          setState(() {
            _isLoadingMore = false;
          });
        });
      }

      final shouldShowButton = _scrollController.position.pixels > 200;
      if (_showBackToTopButton.value != shouldShowButton) {
        _showBackToTopButton.value = shouldShowButton;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchField(HomeViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: viewModel.onSearchChanged,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Buscar jogos...',
          prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    viewModel.onSearchChanged('');
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Nenhum jogo encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tente um termo de busca diferente',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              context.read<HomeViewModel>().onSearchChanged('');
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Limpar Busca'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(HomeViewModel viewModel) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _buildSearchField(viewModel),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showFilterDialog(context, viewModel),
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtros'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGridView(
    List<Game> games,
    HomeViewModel viewModel,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];        return GameGridItem(
          key: ValueKey(game.id),
          game: game,
          viewModel: viewModel,
        );
      },
    );
  }

  Widget _buildActiveFilters(HomeViewModel viewModel) {
    if (viewModel.selectedGenres.isEmpty && viewModel.selectedPlatforms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.selectedGenres.isNotEmpty) ...[
            const Text(
              'Gêneros:',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: viewModel.selectedGenres
                  .map((genreSlug) => Chip(
                        label: Text(genreSlug),
                        onDeleted: () => viewModel.toggleGenreFilter(genreSlug),
                        backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                      ))
                  .toList(),
            ),
          ],
          if (viewModel.selectedPlatforms.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Plataformas:',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: viewModel.selectedPlatforms
                  .map((platformSlug) => Chip(
                        label: Text(platformSlug),
                        onDeleted: () => viewModel.togglePlatformFilter(platformSlug),
                        backgroundColor: Colors.purple.withValues(alpha: 0.1),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 8),
          if (viewModel.selectedGenres.isNotEmpty || viewModel.selectedPlatforms.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => viewModel.clearFilters(),
                icon: const Icon(Icons.clear),
                label: const Text('Limpar Filtros'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorMsg(HomeViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.deepPurple[300]),
            const SizedBox(height: 24),
            const Text(
              'Algo deu errado!',
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMsg!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => viewModel.init(),
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

  void _showFilterDialog(BuildContext context, HomeViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthService>().signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sair'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Consumer<HomeViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando jogos...'),
                  ],
                ),
              );
            }

            if (viewModel.errorMsg != null) {
              return _buildErrorMsg(viewModel);
            }

            return RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(viewModel)),
                  SliverToBoxAdapter(child: _buildActiveFilters(viewModel)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: viewModel.games.isEmpty
                          ? _buildEmptyState()
                          : _buildGameGridView(viewModel.games, viewModel),
                    ),
                  ),
                  if (_isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTopButton,
        builder: (context, shouldShow, child) {
          return shouldShow
              ? FloatingActionButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Icon(Icons.keyboard_arrow_up),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

class GameGridItem extends StatelessWidget {
  final Game game;
  final HomeViewModel viewModel;

  const GameGridItem({
    super.key,
    required this.game,
    required this.viewModel,
  });

  Color _getGenreColor(String genreSlug) {
    return genreColors[genreSlug.toLowerCase()] ?? Colors.grey;
  }
  Widget _buildGameCard(BuildContext context) {
    final primaryGenre = game.genres.isNotEmpty ? game.genres[0].slug : 'indie';
    final cardColor = _getGenreColor(primaryGenre ?? 'indie').withValues(alpha: 0.2);
    final imageUrl = game.backgroundImage ?? '';

    return Material(
      color: Colors.transparent,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [cardColor, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetails(gameId: game.id),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: _buildGameImage(imageUrl),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (game.genres.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            children: game.genres
                                .take(2)
                                .map((genre) => _buildGenreChip(genre.name))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenreChip(String genre) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        genre,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGameImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.videogame_asset, size: 50, color: Colors.black26),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (_, _, _) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.broken_image, size: 30, color: Colors.grey),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return _buildGameCard(context);
  }
}

class FilterDialog extends StatefulWidget {
  final HomeViewModel viewModel;

  const FilterDialog({super.key, required this.viewModel});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtros'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Gêneros',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.viewModel.genres.take(10).map((genre) {
                final isSelected = widget.viewModel.selectedGenres.contains(genre.slug);
                return FilterChip(
                  label: Text(genre.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      widget.viewModel.toggleGenreFilter(genre.slug ?? '');
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
