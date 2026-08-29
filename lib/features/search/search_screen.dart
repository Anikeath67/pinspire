
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../models/pin.dart';
import '../../services/pexels_service.dart';
import '../detail/pin_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {
  final TextEditingController _controller =
      TextEditingController();

  final PexelsService _api =
      PexelsService();

  List<Pin> _pins = [];

  bool _loading = false;
  String? _error;

  Future<void> _search() async {
    final query =
        _controller.text.trim();

    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result =
          await _api.search(query);

      if (!mounted) return;

      setState(() {
        _pins = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _pins = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              12,
            ),
            child: TextField(
              controller: _controller,
              textInputAction:
                  TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration:
                  InputDecoration(
                hintText:
                    'Search inspiration...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                ),
                suffixIcon: IconButton(
                  onPressed: _search,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                  ),
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : _error != null
                    ? _ErrorView(
                        error: _error!,
                        onRetry: _search,
                      )
                    : _pins.isEmpty
                        ? const _SearchEmpty()
                        : MasonryGridView.count(
                            padding:
                                const EdgeInsets
                                    .all(12),
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            itemCount:
                                _pins.length,
                            itemBuilder:
                                (_, index) {
                              final pin =
                                  _pins[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PinDetailScreen(
                                        pin: pin,
                                      ),
                                    ),
                                  );
                                },
                                child:
                                    ClipRRect(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    18,
                                  ),
                                  child:
                                      CachedNetworkImage(
                                    imageUrl:
                                        pin.imageUrl,
                                    fit:
                                        BoxFit.cover,
                                    placeholder:
                                        (_, __) =>
                                            const AspectRatio(
                                      aspectRatio:
                                          .75,
                                      child: Center(
                                        child:
                                            CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget:
                                        (_, __,
                                                ___) =>
                                            const AspectRatio(
                                      aspectRatio:
                                          .75,
                                      child: Center(
                                        child: Icon(
                                          Icons
                                              .broken_image_outlined,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 60,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
          const SizedBox(height: 15),
          const Text(
            'Search for inspiration',
            style: TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try anime, cars, bikes, nature or anything else.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 55,
            ),
            const SizedBox(height: 15),
            const Text(
              'Search failed',
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onRetry,
              child:
                  const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}