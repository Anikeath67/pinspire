import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/pin.dart';
import '../../services/firestore_service.dart';
import '../detail/pin_detail_screen.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({
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
          'Downloads',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),

        actions: [
          StreamBuilder<List<Pin>>(
            stream: service.watchDownloads(),
            builder: (context, snapshot) {
              final hasDownloads =
                  snapshot.data?.isNotEmpty ??
                      false;

              if (!hasDownloads) {
                return const SizedBox();
              }

              return IconButton(
                tooltip: 'Clear downloads',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                ),
                onPressed: () async {
                  await service.clearDownloads();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Downloads cleared',
                      ),
                      behavior:
                          SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<List<Pin>>(
        stream: service.watchDownloads(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Text(
                  'Unable to load downloads.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final pins =
              snapshot.data ?? [];

          if (pins.isEmpty) {
            return const _EmptyDownloads();
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
              return _DownloadCard(
                pin: pins[index],
                onDelete: () async {
                  await service.removeDownload(
                    pins[index].id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyDownloads
    extends StatelessWidget {
  const _EmptyDownloads();

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
              Icons.download_outlined,
              size: 70,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(height: 18),

            const Text(
              'No downloads yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Images you download will '
              'appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadCard
    extends StatelessWidget {
  final Pin pin;
  final VoidCallback onDelete;

  const _DownloadCard({
    required this.pin,
    required this.onDelete,
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

            // Bottom gradient
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

            // Category
            Positioned(
              top: 10,
              left: 10,
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

            // Delete
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.white
                    .withOpacity(.92),
                shape:
                    const CircleBorder(),
                child: InkWell(
                  onTap: onDelete,
                  customBorder:
                      const CircleBorder(),
                  child:
                      const Padding(
                    padding:
                        EdgeInsets.all(9),
                    child: Icon(
                      Icons
                          .delete_outline_rounded,
                      size: 21,
                    ),
                  ),
                ),
              ),
            ),

            // Photographer
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
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