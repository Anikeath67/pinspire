import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/pin.dart';
import '../../services/firestore_service.dart';
import '../detail/pin_detail_screen.dart';

class RecentlyViewedScreen
    extends StatelessWidget {
  const RecentlyViewedScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Recently Viewed',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),

        actions: [
          StreamBuilder<List<Pin>>(
            stream:
                service.watchRecentlyViewed(),

            builder:
                (context, snapshot) {
              final hasPins =
                  snapshot.data?.isNotEmpty ??
                      false;

              if (!hasPins) {
                return const SizedBox();
              }

              return IconButton(
                tooltip: 'Clear history',

                icon: const Icon(
                  Icons.delete_outline_rounded,
                ),

                onPressed: () async {
                  await service
                      .clearRecentlyViewed();

                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Recently viewed cleared',
                      ),
                      behavior:
                          SnackBarBehavior
                              .floating,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<List<Pin>>(
        stream:
            service.watchRecentlyViewed(),

        builder:
            (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Text(
                  'Unable to load recently viewed.\n\n'
                  '${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          final pins =
              snapshot.data ?? [];

          if (pins.isEmpty) {
            return const _EmptyRecent();
          }

          return GridView.builder(
            padding:
                const EdgeInsets.all(16),

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),

            itemCount: pins.length,

            itemBuilder:
                (context, index) {
              return _RecentCard(
                pin: pins[index],
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyRecent
    extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.history_rounded,
              size: 70,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(height: 18),

            const Text(
              'Nothing viewed yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Pins you open will appear here.',
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentCard
    extends StatelessWidget {
  final Pin pin;

  const _RecentCard({
    required this.pin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PinDetailScreen(pin: pin),
          ),
        );
      },

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(18),

        child: Stack(
          fit: StackFit.expand,

          children: [
            CachedNetworkImage(
              imageUrl: pin.imageUrl,
              fit: BoxFit.cover,

              placeholder:
                  (context, url) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              },

              errorWidget:
                  (context, url, error) {
                return const Center(
                  child: Icon(
                    Icons
                        .broken_image_outlined,
                    size: 45,
                  ),
                );
              },
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 90,

              child: DecoratedBox(
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black
                          .withOpacity(.8),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 10,
              top: 10,

              child: Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.black54,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child: Text(
                  pin.category,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 10,
              right: 10,
              bottom: 10,

              child: Text(
                'Photo by '
                '${pin.photographer}',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}