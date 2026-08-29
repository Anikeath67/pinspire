
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/pin.dart';
import '../../services/download_service.dart';
import '../../services/firestore_service.dart';

class PinDetailScreen extends StatefulWidget {
  final Pin pin;

  const PinDetailScreen({
    super.key,
    required this.pin,
  });

  @override
  State<PinDetailScreen> createState() =>
      _PinDetailScreenState();
}

class _PinDetailScreenState
    extends State<PinDetailScreen> {
  final FirestoreService _firestore =
      FirestoreService();

  final DownloadService _downloadService =
      DownloadService();

  bool _isLiked = false;
  bool _isSaved = false;

  bool _loadingLike = true;
  bool _loadingSave = true;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    // ------------------------------------------------------------
    // Record this pin as recently viewed
    // ------------------------------------------------------------
    try {
      await _firestore.recordRecentlyViewed(
        widget.pin,
      );
    } catch (e) {
      debugPrint(
        'Recently viewed error: $e',
      );
    }

    // ------------------------------------------------------------
    // Check current like/save status
    // ------------------------------------------------------------
    try {
      final results = await Future.wait([
        _firestore.isLiked(widget.pin.id),
        _firestore.isSaved(widget.pin.id),
      ]);

      if (!mounted) return;

      setState(() {
        _isLiked = results[0];
        _isSaved = results[1];

        _loadingLike = false;
        _loadingSave = false;
      });
    } catch (e) {
      debugPrint(
        'Pin status error: $e',
      );

      if (!mounted) return;

      setState(() {
        _loadingLike = false;
        _loadingSave = false;
      });
    }
  }

  // ============================================================
  // LIKE
  // ============================================================

  Future<void> _toggleLike() async {
    if (_loadingLike) return;

    setState(() {
      _loadingLike = true;
    });

    try {
      final liked =
          await _firestore.toggleLike(
        widget.pin,
      );

      if (!mounted) return;

      setState(() {
        _isLiked = liked;
        _loadingLike = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingLike = false;
      });

      _showMessage(
        'Could not update like.',
      );
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _toggleSave() async {
    if (_loadingSave) return;

    setState(() {
      _loadingSave = true;
    });

    try {
      final saved =
          await _firestore.toggleSave(
        widget.pin,
      );

      if (!mounted) return;

      setState(() {
        _isSaved = saved;
        _loadingSave = false;
      });

      _showMessage(
        saved
            ? 'Pin saved'
            : 'Pin removed from saved pins',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingSave = false;
      });

      _showMessage(
        'Could not update saved pin.',
      );
    }
  }

  // ============================================================
  // DOWNLOAD
  // ============================================================

  Future<void> _download() async {
    if (_downloading) return;

    setState(() {
      _downloading = true;
    });

    try {
      await _downloadService.downloadPin(
        widget.pin,
      );

      if (!mounted) return;

      _showMessage(
        'Image saved to your gallery',
      );
    } catch (e) {
      debugPrint(
        'Download error: $e',
      );

      if (!mounted) return;

      _showMessage(
        'Unable to save image.\n$e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _downloading = false;
        });
      }
    }
  }

  // ============================================================
  // SHARE
  // ============================================================

  Future<void> _share() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text:
              'Check out this inspiration on Pinspire!\n\n'
              '${widget.pin.imageUrl}',
          subject: 'Pinspire',
        ),
      );
    } catch (e) {
      debugPrint(
        'Share error: $e',
      );
    }
  }

  // ============================================================
  // BOARD
  // ============================================================

  Future<void> _showBoardDialog() async {
    try {
      final snapshot =
          await _firestore.getBoards();

      if (!mounted) return;

      final boards = snapshot.docs;

      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        showDragHandle: true,
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                5,
                20,
                20,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Save to a board',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Choose where you want to '
                    'save this pin.',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // CREATE BOARD
                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFEDE7F6,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                      ),
                    ),
                    title: const Text(
                      'Create new board',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(
                        context,
                      );

                      await _createBoard();
                    },
                  ),

                  const Divider(),

                  if (boards.isEmpty)
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      child: Center(
                        child: Text(
                          'No boards yet.\n'
                          'Create your first board.',
                          textAlign:
                              TextAlign.center,
                        ),
                      ),
                    ),

                  if (boards.isNotEmpty)
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            boards.length,
                        itemBuilder:
                            (context, index) {
                          final board =
                              boards[index];

                          final name =
                              board.data()[
                                      'name']
                                  ?.toString() ??
                              'Board';

                          return ListTile(
                            contentPadding:
                                EdgeInsets.zero,
                            leading:
                                Container(
                              width: 48,
                              height: 48,
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFEDE7F6,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .folder_rounded,
                              ),
                            ),
                            title: Text(
                              name,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            onTap: () async {
                              Navigator.pop(
                                context,
                              );

                              try {
                                await _firestore
                                    .addToBoard(
                                  board.id,
                                  widget.pin,
                                );

                                if (!mounted) {
                                  return;
                                }

                                _showMessage(
                                  'Added to $name',
                                );
                              } catch (e) {
                                if (!mounted) {
                                  return;
                                }

                                _showMessage(
                                  'Could not add to board.',
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Could not load boards.',
      );
    }
  }

  Future<void> _createBoard() async {
    final controller =
        TextEditingController();

    final name =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Create board',
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization:
                TextCapitalization.words,
            decoration:
                const InputDecoration(
              hintText:
                  'Board name',
              border:
                  OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value =
                    controller.text.trim();

                if (value.isEmpty) {
                  return;
                }

                Navigator.pop(
                  context,
                  value,
                );
              },
              child:
                  const Text('Create'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (name == null ||
        name.trim().isEmpty) {
      return;
    }

    try {
      final boardId =
          await _firestore.createBoard(
        name,
      );

      await _firestore.addToBoard(
        boardId,
        widget.pin,
      );

      if (!mounted) return;

      _showMessage(
        'Board created and pin added',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Could not create board.',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final pin = widget.pin;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF9F5FC),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // TOP BAR
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                8,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon:
                        Icons.arrow_back_rounded,
                    onTap: () {
                      Navigator.pop(
                        context,
                      );
                    },
                  ),

                  _CircleButton(
                    icon:
                        Icons.share_rounded,
                    onTap: _share,
                  ),
                ],
              ),
            ),

            // ==================================================
            // CONTENT
            // ==================================================

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // IMAGE
                    // ==========================================

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        24,
                      ),
                      child:
                          CachedNetworkImage(
                        imageUrl:
                            pin.imageUrl,
                        width:
                            double.infinity,
                        fit: BoxFit.fitWidth,

                        placeholder:
                            (context, url) {
                          return AspectRatio(
                            aspectRatio:
                                0.75,
                            child:
                                Container(
                              color:
                                  Colors.black12,
                              child:
                                  const Center(
                                child:
                                    CircularProgressIndicator(),
                              ),
                            ),
                          );
                        },

                        errorWidget:
                            (context,
                                url,
                                error) {
                          return Container(
                            height: 400,
                            color:
                                Colors.black12,
                            child:
                                const Center(
                              child: Icon(
                                Icons
                                    .broken_image_outlined,
                                size: 55,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ==========================================
                    // ACTION BUTTONS
                    // ==========================================

                    Row(
                      children: [
                        // SAVE
                        Expanded(
                          child:
                              _ActionButton(
                            icon: _isSaved
                                ? Icons
                                    .bookmark_rounded
                                : Icons
                                    .bookmark_border_rounded,
                            label:
                                _isSaved
                                    ? 'Saved'
                                    : 'Save',
                            onTap:
                                _toggleSave,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        // BOARD
                        Expanded(
                          child:
                              _ActionButton(
                            icon: Icons
                                .folder_outlined,
                            label: 'Board',
                            onTap:
                                _showBoardDialog,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        // LIKE
                        _RoundActionButton(
                          icon: _isLiked
                              ? Icons
                                  .favorite_rounded
                              : Icons
                                  .favorite_border_rounded,
                          active:
                              _isLiked,
                          loading:
                              _loadingLike,
                          onTap:
                              _toggleLike,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        // DOWNLOAD
                        _RoundActionButton(
                          icon: Icons
                              .download_rounded,
                          loading:
                              _downloading,
                          onTap:
                              _download,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==========================================
                    // CATEGORY
                    // ==========================================

                    if (pin.category
                        .trim()
                        .isNotEmpty)
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFE9DDF5,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                        child: Text(
                          pin.category,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF69459A,
                            ),
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ==========================================
                    // PHOTOGRAPHER
                    // ==========================================

                    Text(
                      'Photo by '
                      '${pin.photographer}',
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'Discover more inspiration '
                      'like this on Pinspire.',
                      style: TextStyle(
                        color:
                            Colors.black54,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==========================================
                    // SOURCE
                    // ==========================================

                    if (pin.originalUrl
                        .trim()
                        .isNotEmpty)
                      Text(
                        'Source image available '
                        'from the original provider.',
                        style:
                            const TextStyle(
                          color:
                              Colors.black45,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CIRCLE BUTTON
// ============================================================

class _CircleButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEDE7F3),
      shape: const CircleBorder(),

      child: InkWell(
        onTap: onTap,
        customBorder:
            const CircleBorder(),

        child: const SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            Icons.arrow_back_rounded,
            size: 25,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ACTION BUTTON
// ============================================================

class _ActionButton
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8E1EB),
      borderRadius:
          BorderRadius.circular(22),

      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(22),

        child: SizedBox(
          height: 58,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
              ),

              const SizedBox(
                width: 9,
              ),

              Text(
                label,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ROUND ACTION BUTTON
// ============================================================

class _RoundActionButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool loading;

  const _RoundActionButton({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? const Color(0xFFE7D5FA)
          : const Color(0xFFE8E1EB),
      shape: const CircleBorder(),

      child: InkWell(
        onTap: loading ? null : onTap,
        customBorder:
            const CircleBorder(),

        child: SizedBox(
          width: 58,
          height: 58,

          child: loading
              ? const Padding(
                  padding:
                      EdgeInsets.all(18),
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2.5,
                  ),
                )
              : Icon(
                  icon,
                  size: 27,
                  color: active
                      ? const Color(
                          0xFF6E4B9B,
                        )
                      : Colors.black87,
                ),
        ),
      ),
    );
  }
}