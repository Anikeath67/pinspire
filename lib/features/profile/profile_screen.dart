import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../boards/boards_screen.dart';
import '../favorites/favorites_screen.dart';
import '../likes/liked_pins_screen.dart';
import '../downloads/downloads_screen.dart';
import '../recent/recently_viewed_screen.dart';
import 'package:pinspire/screens/settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text(
              'Please sign in to view your profile.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    final uid = user.uid;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ============================================================
            // TOP BAR
            // ============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  0,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    _CircleButton(
                      icon: Icons.settings_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ============================================================
            // PROFILE HEADER
            // ============================================================

            SliverToBoxAdapter(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data();

                  final name = (data?['displayName'] ??
                          user.displayName ??
                          'Pinspire User')
                      .toString();

                  final email = (data?['email'] ?? user.email ?? '').toString();

                  final photoUrl =
                      (data?['photoUrl'] ?? user.photoURL ?? '').toString();

                  final bio = (data?['bio'] ??
                          'Exploring beautiful things and saving what inspires me.')
                      .toString();

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      25,
                      20,
                      20,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // PROFILE IMAGE
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 105,
                              height: 105,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: photoUrl.isNotEmpty
                                    ? Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return _defaultAvatar(
                                            context,
                                          );
                                        },
                                      )
                                    : _defaultAvatar(
                                        context,
                                      ),
                              ),
                            ),

                            // EDIT BUTTON
                            Positioned(
                              right: -1,
                              bottom: 1,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  size: 15,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 18),

                        // USER INFORMATION
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (email.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(.6),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Text(
                                bio,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  height: 1.35,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ============================================================
            // LIVE STATISTICS
            // ============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    // PINS
                    Expanded(
                      child: _LiveStatCard(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .collection('favorites')
                            .snapshots()
                            .map(
                              (snapshot) => snapshot.size,
                            ),
                        label: 'Pins',
                        icon: Icons.push_pin_outlined,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // BOARDS
                    Expanded(
                      child: _LiveStatCard(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .collection('boards')
                            .snapshots()
                            .map(
                              (snapshot) => snapshot.size,
                            ),
                        label: 'Boards',
                        icon: Icons.folder_outlined,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // LIKES
                    Expanded(
                      child: _LiveStatCard(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .collection('likes')
                            .snapshots()
                            .map(
                              (snapshot) => snapshot.size,
                            ),
                        label: 'Likes',
                        icon: Icons.favorite_border_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ============================================================
            // PREMIUM
            // ============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  22,
                  20,
                  10,
                ),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(.18),
                        theme.colorScheme.primary.withOpacity(.07),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: theme.colorScheme.primary,
                          size: 29,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pinspire Premium',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Unlock more features',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Premium coming soon',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Upgrade'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ============================================================
            // YOUR PINSPIRE
            // ============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  8,
                ),
                child: Text(
                  'Your Pinspire',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
              ),
            ),

            // ============================================================
            // MENU
            // ============================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(.12),
                    ),
                  ),
                  child: Column(
                    children: [
                      // --------------------------------------------------
                      // LIKED PINS
                      // --------------------------------------------------

                      _ProfileMenuItem(
                        icon: Icons.favorite_rounded,
                        title: 'Liked Pins',
                        subtitle: 'Pins you liked',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LikedPinsScreen(),
                            ),
                          );
                        },
                      ),

                      _divider(context),

                      // --------------------------------------------------
                      // SAVED PINS
                      // --------------------------------------------------

                      _ProfileMenuItem(
                        icon: Icons.bookmark_rounded,
                        title: 'Saved Pins',
                        subtitle: 'Your saved collection',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FavoritesScreen(),
                            ),
                          );
                        },
                      ),

                      _divider(context),

                      // --------------------------------------------------
                      // MY BOARDS
                      // --------------------------------------------------

                      _ProfileMenuItem(
                        icon: Icons.folder_rounded,
                        title: 'My Boards',
                        subtitle: 'Organize your inspiration',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BoardsScreen(),
                            ),
                          );
                        },
                      ),

                      _divider(context),

                      // --------------------------------------------------
                      // DOWNLOADS
                      // --------------------------------------------------

                      _ProfileMenuItem(
                        icon: Icons.download_rounded,
                        title: 'Downloads',
                        subtitle: 'Images downloaded from Pinspire',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DownloadsScreen(),
                            ),
                          );
                        },
                      ),

                      _divider(context),

                      // --------------------------------------------------
                      // RECENTLY VIEWED
                      // --------------------------------------------------

                      _ProfileMenuItem(
                        icon: Icons.history_rounded,
                        title: 'Recently Viewed',
                        subtitle: 'Your recent inspiration',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RecentlyViewedScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ============================================================
            // BOTTOM SPACE
            // ============================================================

            const SliverToBoxAdapter(
              child: SizedBox(height: 30),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _defaultAvatar(
    BuildContext context,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person_rounded,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  static Widget _divider(
    BuildContext context,
  ) {
    return Divider(
      height: 1,
      indent: 82,
      endIndent: 18,
      color: Theme.of(context).dividerColor.withOpacity(.1),
    );
  }
}

// ============================================================================
// LIVE STAT CARD
// ============================================================================

class _LiveStatCard extends StatelessWidget {
  final Stream<int> stream;
  final String label;
  final IconData icon;

  const _LiveStatCard({
    required this.stream,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(.7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: StreamBuilder<int>(
        stream: stream,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 21,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 5),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(.65),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// SETTINGS BUTTON
// ============================================================================

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            Icons.settings_outlined,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PROFILE MENU ITEM
// ============================================================================

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(.10),
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.iconTheme.color?.withOpacity(.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
