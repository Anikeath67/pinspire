
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../models/pin.dart';
import '../../services/pexels_service.dart';
// import '../detail/pin_detail_screen.dart';
import '../../features/detail/pin_detail_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PexelsService _api = PexelsService();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _categories = [
    'Anime',
    'Cars',
    'Bikes',
    'Sports',
    'Nature',
    'Travel',
    'Gaming',
    'Technology',
    'Space',
    'Fashion',
    'Food',
  ];

  static const Map<String, List<String>> _searchTerms = {
    'Anime': [
      'anime',
      'anime art',
      'anime wallpaper',
      'anime character',
      'japanese anime',
      'one Piece',
      'naruto',
      'manga',
      'anime aesthetic',
      'anime goku',
      'Death Note',
      'jujutusu kaisen',
      'demon slayer',
      'attack on titan',
      'my hero academia',
      'dragon ball z',
      'bleach',
      'fullmental alchemist',
      'tokyo revengers',
      'doremon',
    ],
    'Cars': [
      'sports car',
      'supercar',
      'luxury car',
      'jdm car',
      'car photography',
      'modified car',
    ],
    'Bikes': [
      'motorcycle',
      'sports bike',
      'superbike',
      'motorbike',
      'bike photography',
    ],
    'Sports': [
      'football',
      'basketball',
      'cricket',
      'tennis',
      'sports photography',
    ],
    'Nature': [
      'nature',
      'mountains',
      'forest',
      'waterfall',
      'sunset nature',
      'landscape',
    ],
    'Travel': [
      'travel',
      'travel photography',
      'beautiful places',
      'beach travel',
      'city travel',
    ],
    'Gaming': [
      'gaming',
      'gaming setup',
      'gamer',
      'pc gaming',
      'video game',
    ],
    'Technology': [
      'technology',
      'computer',
      'smartphone',
      'coding',
      'technology setup',
    ],
    'Space': [
      'space',
      'galaxy',
      'universe',
      'astronaut',
      'nebula',
      'planet',
    ],
    'Fashion': [
      'fashion',
      'street fashion',
      'fashion photography',
      'clothing',
      'style',
    ],
    'Food': [
      'food',
      'food photography',
      'pizza',
      'burger',
      'dessert',
      'healthy food',
    ],
  };

  final Random _random = Random();

  String _category = 'Anime';

  List<Pin> _pins = [];

  int _page = 1;

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  String? _error;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _onScroll,
    );

    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position =
        _scrollController.position;

    if (position.pixels >=
            position.maxScrollExtent - 1000 &&
        !_loadingMore &&
        !_loading &&
        _hasMore) {
      _loadMore();
    }
  }

  String _randomSearchTerm(
    String category,
  ) {
    final terms =
        _searchTerms[category];

    if (terms == null || terms.isEmpty) {
      return category;
    }

    return terms[
        _random.nextInt(terms.length)];
  }

  Future<void> _loadInitial() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _loadingMore = false;
      _error = null;
      _page = 1;
      _hasMore = true;
      _pins = [];
    });

    try {
      final query =
          _randomSearchTerm(_category);

      final results =
          await _api.search(
        query,
        page: 1,
        perPage: 30,
      );

      if (!mounted) return;

      setState(() {
        _pins = results;
        _loading = false;
        _hasMore =
            results.length >= 30;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore ||
        !_hasMore ||
        _loading) {
      return;
    }

    setState(() {
      _loadingMore = true;
    });

    try {
      final nextPage = _page + 1;

      final query =
          _randomSearchTerm(_category);

      final results =
          await _api.search(
        query,
        page: nextPage,
        perPage: 30,
      );

      if (!mounted) return;

      setState(() {
        _page = nextPage;
        _pins.addAll(results);

        _loadingMore = false;

        if (results.length < 30) {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingMore = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: const Text(
            'Could not load more images.',
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadMore,
          ),
        ),
      );
    }
  }

  Future<void> _refresh() async {
    await _loadInitial();
  }

  void _selectCategory(
    String category,
  ) {
    if (_category == category) {
      return;
    }

    setState(() {
      _category = category;
    });

    _loadInitial();
  }

  void _openPin(Pin pin) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PinDetailScreen(
          pin: pin,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller:
                _scrollController,
            physics:
                const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  category: _category,
                ),
              ),

              SliverToBoxAdapter(
                child: _CategoryBar(
                  categories:
                      _categories,
                  selected:
                      _category,
                  onSelected:
                      _selectCategory,
                ),
              ),

              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorState(
                    message: _error!,
                    onRetry:
                        _loadInitial,
                  ),
                )
              else if (_pins.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons
                              .image_not_supported_outlined,
                          size: 55,
                          color: theme
                              .colorScheme
                              .primary,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text(
                          'No images found',
                          style:
                              TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        FilledButton(
                          onPressed:
                              _loadInitial,
                          child:
                              const Text(
                            'Try again',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    12,
                    14,
                    12,
                    20,
                  ),
                  sliver:
                      SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childCount:
                        _pins.length,
                    itemBuilder:
                        (context, index) {
                      final pin =
                          _pins[index];

                      return _PinCard(
                        key: ValueKey(
                          pin.id,
                        ),
                        pin: pin,
                        onTap: () =>
                            _openPin(pin),
                      );
                    },
                  ),
                ),

                if (_loadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.only(
                        bottom: 30,
                      ),
                      child: Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    ),
                  ),

                if (!_hasMore &&
                    _pins.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.only(
                        bottom: 30,
                      ),
                      child: Center(
                        child: Text(
                          'You reached the end.',
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String category;

  const _Header({
    required this.category,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        20,
        18,
        10,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color: theme
                      .colorScheme
                      .primary,
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: const Icon(
                  Icons
                      .push_pin_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              const Text(
                'Pinspire',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          // Text(
            
          //   style: theme
          //       .textTheme
          //       .headlineSmall
          //       ?.copyWith(
          //     fontWeight:
          //         FontWeight.w900,
          //   ),
          // ),

          const SizedBox(
            height: 6,
          ),

          Text(
            'Discover beautiful $category images and ideas.',
            style: theme
                .textTheme
                .bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _CategoryBar
    extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String>
      onSelected;

  const _CategoryBar({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      height: 55,
      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        scrollDirection:
            Axis.horizontal,
        itemCount:
            categories.length,
        separatorBuilder:
            (_, __) =>
                const SizedBox(
          width: 8,
        ),
        itemBuilder:
            (context, index) {
          final category =
              categories[index];

          return ChoiceChip(
            label:
                Text(category),
            selected:
                selected == category,
            onSelected: (_) =>
                onSelected(
              category,
            ),
          );
        },
      ),
    );
  }
}

class _PinCard
    extends StatelessWidget {
  final Pin pin;
  final VoidCallback onTap;

  const _PinCard({
    super.key,
    required this.pin,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return TweenAnimationBuilder<
        double>(
      tween: Tween(
        begin: 0.94,
        end: 1,
      ),
      duration:
          const Duration(
        milliseconds: 350,
      ),
      curve:
          Curves.easeOutCubic,
      builder:
          (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          child: Hero(
            tag:
                'pin-${pin.id}',
            child:
                CachedNetworkImage(
              imageUrl:
                  pin.imageUrl,
              fit:
                  BoxFit.cover,

              placeholder:
                  (context, url) {
                return AspectRatio(
                  aspectRatio:
                      0.78,
                  child:
                      Container(
                    color: Theme.of(
                            context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child:
                        const Center(
                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            2,
                      ),
                    ),
                  ),
                );
              },

              errorWidget:
                  (context, url,
                      error) {
                return AspectRatio(
                  aspectRatio:
                      0.78,
                  child:
                      Container(
                    color: Theme.of(
                            context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child:
                        Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        const Icon(
                          Icons
                              .broken_image_outlined,
                          size: 35,
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          'Image unavailable',
                          style:
                              Theme.of(
                            context,
                          )
                                  .textTheme
                                  .bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons
                  .cloud_off_outlined,
              size: 55,
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Unable to load images',
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              message,
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(
              height: 18,
            ),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label:
                  const Text(
                'Try again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}