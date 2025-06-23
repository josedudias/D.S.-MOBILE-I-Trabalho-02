import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gamehub/models/game.dart';
import 'package:gamehub/repositories/game_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final GameRepository repository;

  HomeViewModel(this.repository);

  // Estado da tela
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMsg;
  
  // Dados
  List<Game> _games = [];
  List<Game> _filteredGames = [];
  List<Genre> _genres = [];
  List<Platform> _platforms = [];
  
  // Filtros
  String _searchQuery = '';
  List<String> _selectedGenres = [];
  List<String> _selectedPlatforms = [];
  
  // Paginação
  int _currentPage = 1;
  bool _hasMore = true;
  
  // Favoritos
  List<Game> _favoriteGames = [];
  
  // Timer para debounce da busca
  Timer? _debounceTimer;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMsg => _errorMsg;
  List<Game> get games => _filteredGames;
  List<Genre> get genres => _genres;
  List<Platform> get platforms => _platforms;
  String get searchQuery => _searchQuery;
  List<String> get selectedGenres => _selectedGenres;
  List<String> get selectedPlatforms => _selectedPlatforms;
  bool get hasMore => _hasMore;
  List<Game> get favoriteGames => _favoriteGames;

  Future<void> init() async {
    _isLoading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      // Carrega dados iniciais em paralelo
      await Future.wait([
        _loadGames(page: 1, reset: true),
        _loadGenres(),
        _loadPlatforms(),
        _loadFavorites(),
      ]);
    } catch (e) {
      _errorMsg = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadGames({int page = 1, bool reset = false}) async {
    try {
      final newGames = await repository.getGames(
        page: page,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        genres: _selectedGenres.isEmpty ? null : _selectedGenres,
        platforms: _selectedPlatforms.isEmpty ? null : _selectedPlatforms,
      );

      if (reset) {
        _games = newGames;
        _currentPage = 1;
      } else {
        _games.addAll(newGames);
      }

      _hasMore = newGames.length == 20; // RAWG API padrão retorna 20 items
      _filteredGames = List.from(_games);
      
      if (!reset) {
        _currentPage = page;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadGenres() async {
    try {
      _genres = await repository.getGenres();
    } catch (e) {
      // Não é crítico, pode continuar sem gêneros
      debugPrint('Erro ao carregar gêneros: $e');
    }
  }

  Future<void> _loadPlatforms() async {
    try {
      _platforms = await repository.getPlatforms();
    } catch (e) {
      // Não é crítico, pode continuar sem plataformas
      debugPrint('Erro ao carregar plataformas: $e');
    }
  }

  Future<void> _loadFavorites() async {
    try {
      _favoriteGames = await repository.getFavoriteGames();
    } catch (e) {
      debugPrint('Erro ao carregar favoritos: $e');
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      await _loadGames(page: _currentPage + 1);
    } catch (e) {
      _errorMsg = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    _isLoading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      await _loadGames(page: 1, reset: true);
    } catch (e) {
      _errorMsg = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleGenreFilter(String genreSlug) {
    if (_selectedGenres.contains(genreSlug)) {
      _selectedGenres.remove(genreSlug);
    } else {
      _selectedGenres.add(genreSlug);
    }
    _applyFilters();
  }

  void togglePlatformFilter(String platformSlug) {
    if (_selectedPlatforms.contains(platformSlug)) {
      _selectedPlatforms.remove(platformSlug);
    } else {
      _selectedPlatforms.add(platformSlug);
    }
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    _isLoading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      await _loadGames(page: 1, reset: true);
    } catch (e) {
      _errorMsg = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFilters() {
    _selectedGenres.clear();
    _selectedPlatforms.clear();
    _searchQuery = '';
    _applyFilters();
  }

  Future<void> toggleFavorite(Game game) async {
    try {
      final isFav = await repository.isFavorite(game.id);
      
      if (isFav) {
        await repository.removeFromFavorites(game.id);
        _favoriteGames.removeWhere((g) => g.id == game.id);
      } else {
        await repository.addToFavorites(game);
        _favoriteGames.add(game);
      }
      
      notifyListeners();
    } catch (e) {
      _errorMsg = 'Erro ao atualizar favoritos: $e';
      notifyListeners();
    }
  }

  Future<bool> isFavorite(int gameId) async {
    return repository.isFavorite(gameId);
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    await init();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
