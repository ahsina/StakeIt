import 'package:flutter/material.dart';

/// Optimized list view with automatic pagination
class OptimizedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final double loadMoreThreshold;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
    this.loadingWidget,
    this.emptyWidget,
    this.controller,
    this.padding,
    this.loadMoreThreshold = 0.8,
  });

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !widget.hasMore || widget.onLoadMore == null) {
      return;
    }

    final position = _scrollController.position;
    final threshold = position.maxScrollExtent * widget.loadMoreThreshold;

    if (position.pixels >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      await widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          // Loading indicator at the bottom
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget.loadingWidget ??
                const Center(
                  child: CircularProgressIndicator(),
                ),
          );
        }

        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}

/// Optimized grid view with automatic pagination
class OptimizedGridView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final double loadMoreThreshold;

  const OptimizedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.loadingWidget,
    this.emptyWidget,
    this.controller,
    this.padding,
    this.loadMoreThreshold = 0.8,
  });

  @override
  State<OptimizedGridView<T>> createState() => _OptimizedGridViewState<T>();
}

class _OptimizedGridViewState<T> extends State<OptimizedGridView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !widget.hasMore || widget.onLoadMore == null) {
      return;
    }

    final position = _scrollController.position;
    final threshold = position.maxScrollExtent * widget.loadMoreThreshold;

    if (position.pixels >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      await widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    return GridView.builder(
      controller: _scrollController,
      padding: widget.padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: widget.childAspectRatio,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
      ),
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          // Loading indicator at the bottom
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget.loadingWidget ??
                const Center(
                  child: CircularProgressIndicator(),
                ),
          );
        }

        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}
