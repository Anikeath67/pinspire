
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/pin.dart';
import '../../services/firestore_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          'Saved',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),

      body: StreamBuilder<List<Pin>>(
        stream: firestore.watch(),
        builder: (context, snapshot) {
          // ----------------------------------------------------
          // LOADING
          // ----------------------------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ----------------------------------------------------
          // ERROR
          // ----------------------------------------------------

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 55,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Could not load saved pins',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 18),

                    FilledButton(
                      onPressed: () {
                        // StreamBuilder automatically retries
                        // when Firestore data changes.
                      },
                      child: const Text(
                        'Saved pins',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ----------------------------------------------------
          // DATA
          // ----------------------------------------------------

          final pins = snapshot.data ?? [];

          // ----------------------------------------------------
          // EMPTY
          // ----------------------------------------------------

          if (pins.isEmpty) {
            return const _EmptySaved();
          }

          // ----------------------------------------------------
          // SAVED PINS
          // ----------------------------------------------------

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              14,
              8,
              14,
              24,
            ),

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),

            itemCount: pins.length,

            itemBuilder: (context, index) {
              final pin = pins[index];

              return _SavedPinCard(
                pin: pin,
                onRemove: () async {
                  try {
                    await firestore.remove(
                      pin.id,
                    );

                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Removed from saved pins',
                          ),
                          behavior:
                              SnackBarBehavior.floating,
                        ),
                      );
                  } catch (e) {
                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            'Could not remove pin: $e',
                          ),
                          behavior:
                              SnackBarBehavior.floating,
                        ),
                      );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ================================================================
// EMPTY SAVED SCREEN
// ================================================================

class _EmptySaved extends StatelessWidget {
  const _EmptySaved();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 72,
              color: theme.colorScheme.primary,
            ),

            const SizedBox(height: 18),

            const Text(
              'Your saved pins',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Save images you love and they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// SAVED PIN CARD
// ================================================================

class _SavedPinCard extends StatelessWidget {
  final Pin pin;
  final VoidCallback onRemove;

  const _SavedPinCard({
    required this.pin,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),

      child: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------------------------
          // IMAGE
          // ------------------------------------------------------

          CachedNetworkImage(
            imageUrl: pin.imageUrl,
            fit: BoxFit.cover,

            placeholder: (
              context,
              url,
            ) {
              return Container(
                color: Colors.grey.shade100,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },

            errorWidget: (
              context,
              url,
              error,
            ) {
              return Container(
                color: Colors.grey.shade100,
                child: const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 45,
                  ),
                ),
              );
            },
          ),

          // ------------------------------------------------------
          // DARK GRADIENT
          // ------------------------------------------------------

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 100,

            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,

                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.78),
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------------
          // CATEGORY
          // ------------------------------------------------------

          if (pin.category.isNotEmpty)
            Positioned(
              left: 10,
              top: 10,

              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Text(
                  pin.category,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

          // ------------------------------------------------------
          // PHOTOGRAPHER
          // ------------------------------------------------------

          Positioned(
            left: 12,
            right: 52,
            bottom: 12,

            child: Text(
              'Photo by ${pin.photographer}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),

          // ------------------------------------------------------
          // REMOVE SAVED
          // ------------------------------------------------------

          Positioned(
            right: 8,
            top: 8,

            child: Material(
              color: Colors.white.withOpacity(0.94),
              shape: const CircleBorder(),

              child: InkWell(
                customBorder:
                    const CircleBorder(),

                onTap: onRemove,

                child: const Padding(
                  padding: EdgeInsets.all(9),

                  child: Icon(
                    Icons.bookmark_rounded,
                    size: 21,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}