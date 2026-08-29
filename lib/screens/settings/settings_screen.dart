import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(
    BuildContext context,
  ) async {
    final result =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text('Logout'),
          content: const Text(
            'Do you want to logout from Pinspire?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child:
                  const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child:
                  const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    await FirebaseAuth.instance
        .signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const Text(
            'Preferences',
            style: TextStyle(
              fontWeight:
                  FontWeight.w900,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.dark_mode_outlined,
                  ),
                  title:
                      const Text('Theme'),
                  subtitle:
                      const Text(
                    'Follows system theme',
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.notifications_outlined,
                  ),
                  title: const Text(
                    'Notifications',
                  ),
                  trailing:
                      Switch(
                    value: true,
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Account',
            style: TextStyle(
              fontWeight:
                  FontWeight.w900,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                  ),
                  title:
                      const Text('Account'),
                  subtitle: Text(
                    FirebaseAuth
                            .instance
                            .currentUser
                            ?.email ??
                        '',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                  ),
                  title: const Text(
                    'About Pinspire',
                  ),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName:
                          'Pinspire',
                      applicationVersion:
                          '1.0.0',
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                  ),
                  title:
                      const Text('Logout'),
                  onTap: () =>
                      _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}