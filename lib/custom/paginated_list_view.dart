import 'package:gamehub/utils/logging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef FetchPage<T> =
    Future<List<T>> Function(int page, int currentItemsCount);

class PaginatedListController<T> extends ChangeNotifier {
  final FetchPage<T> _fetchPage;
  final int _itemsPerPage;

  PaginatedListController({
    required FetchPage<T> fetchPage,
    int itemsPerPage = 20,
  }) : _fetchPage = fetchPage,
       _itemsPerPage = itemsPerPage {
    _fetchInitialItems();
  }

  // --- Internal State ---
  List<T> _items = [];
  int _currentPage = 1;
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMorePages = true;
  bool _hasError = false;
  String? _errorMessage;

  List<T> get items => _items;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get hasMorePages => _hasMorePages;

  Future<void> _fetchInitialItems() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    _currentPage = 1;
    _items = [];
    _hasMorePages = true;
    notifyListeners();

    try {
      final newItems = await _fetchPage(_currentPage, _items.length);
      _items = newItems;
      _isLoading = false;
      // If the API returns less items than expected, consider it's the last page.
      if (newItems.length < _itemsPerPage) {
        _hasMorePages = false;
      }
    } catch (e, s) {
      logger.e("Error loading initial data", error: e, stackTrace: s);
      _isLoading = false;
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMoreItems() async {
    if (_isFetchingMore || !_hasMorePages || _isLoading || _hasError) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final newItems = await _fetchPage(nextPage, _items.length);

      if (newItems.isEmpty) {
        _hasMorePages = false;
      } else {
        _items.addAll(newItems);
        _currentPage = nextPage;
        // If the API returns less items than expected, consider it's the last page.
        if (newItems.length < _itemsPerPage) {
          _hasMorePages = false;
        }
      }
    } catch (e, s) {
      logger.e("Error fetching more items", error: e, stackTrace: s);
      _hasMorePages = false;
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    if (!_isLoading) {
      await _fetchInitialItems();
    }
  }
}

typedef ItemWidgetBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

class PaginatedListView<T> extends StatefulWidget {
  final FetchPage<T> fetchPage;
  final ItemWidgetBuilder<T> itemBuilder;
  final Widget? itemLoadingIndicator;
  final Widget Function(String? error, VoidCallback retryCallback)?
  errorIndicatorBuilder;
  final Widget? emptyListIndicator;
  final Widget? loadingIndicator;
  final Axis scrollDirection;
  final int itemsPerPage;
  final bool shrinkWrap;

  const PaginatedListView({
    super.key,
    required this.fetchPage,
    required this.itemBuilder,
    this.itemLoadingIndicator,
    this.errorIndicatorBuilder,
    this.emptyListIndicator,
    this.loadingIndicator,
    this.scrollDirection = Axis.vertical,
    this.itemsPerPage = 20,
    this.shrinkWrap = false,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  late final PaginatedListController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaginatedListController<T>(
      fetchPage: widget.fetchPage,
      itemsPerPage: widget.itemsPerPage,
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _controller.fetchMoreItems();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<PaginatedListController<T>>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return widget.itemLoadingIndicator ??
                const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError) {
            return widget.errorIndicatorBuilder != null
                ? widget.errorIndicatorBuilder!(
                  controller.errorMessage,
                  controller.retry,
                )
                : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'An error happend when trying to load the data: ${controller.errorMessage ?? 'Unknow error'}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.retry,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
          }

          if (controller.items.isEmpty) {
            return widget.emptyListIndicator ??
                const Center(child: Text('No item found.'));
          }

          return ListView.builder(
            shrinkWrap: widget.shrinkWrap,
            scrollDirection: widget.scrollDirection,
            controller: _scrollController,
            itemCount:
                controller.items.length + (controller.isFetchingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.items.length) {
                return controller.hasMorePages
                    ? widget.loadingIndicator ??
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                    : const SizedBox.shrink();
              }

              final item = controller.items[index];
              return widget.itemBuilder(context, item, index);
            },
          );
        },
      ),
    );
  }
}
