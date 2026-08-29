
import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../models/pin.dart';

class LikedPinsScreen extends StatelessWidget {
  const LikedPinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liked Pins',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: StreamBuilder<List<Pin>>(
        stream: firestore.watchLikes(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load liked pins.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final pins = snapshot.data ?? [];

          // Empty
          if (pins.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 72,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Your liked pins',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Like images you love and they will appear here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Pins
          return GridView.builder(
            padding: const EdgeInsets.all(16),
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

              return _LikedPinCard(
                pin: pin,
                onRemove: () async {
                  try {
                    await firestore.unlikePin(pin.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Removed from liked pins',
                          ),
                          behavior:
                              SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Could not remove like: $e',
                          ),
                          behavior:
                              SnackBarBehavior.floating,
                        ),
                      );
                    }
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

class _LikedPinCard extends StatelessWidget {
  final Pin pin;
  final VoidCallback onRemove;

  const _LikedPinCard({
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
          // Image
          Image.network(
            pin.imageUrl,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) {
              return Container(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 45,
                ),
              );
            },
            loadingBuilder:
                (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return Container(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),

          // Bottom gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(.75),
                  ],
                ),
              ),
            ),
          ),

          // Photographer
          Positioned(
            left: 12,
            right: 45,
            bottom: 12,
            child: Text(
              pin.photographer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Remove like
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.white.withOpacity(.92),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: Colors.red,
                    size: 21,
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