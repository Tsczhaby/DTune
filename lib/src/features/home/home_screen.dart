import 'package:flutter/material.dart';

import '../../widgets/dtune_logo.dart';
import '../authentication/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  void _onLogout(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DTune'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _onLogout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const DTuneLogo(size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, Listener!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your Navidrome library will appear here once connected.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    return GridView.count(
                      crossAxisCount: isWide ? 3 : 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: const [
                        _HomePlaceholderCard(
                          icon: Icons.library_music_outlined,
                          title: 'Library',
                          description: 'Browse your albums, artists, and tracks.',
                        ),
                        _HomePlaceholderCard(
                          icon: Icons.queue_music_outlined,
                          title: 'Playlists',
                          description: 'Curate playlists synced from Navidrome.',
                        ),
                        _HomePlaceholderCard(
                          icon: Icons.podcasts_outlined,
                          title: 'Podcasts',
                          description: 'Access your favorite podcasts and shows.',
                        ),
                        _HomePlaceholderCard(
                          icon: Icons.download_outlined,
                          title: 'Downloads',
                          description: 'Manage offline content for on-the-go listening.',
                        ),
                        _HomePlaceholderCard(
                          icon: Icons.search,
                          title: 'Search',
                          description: 'Find artists, albums, playlists, or tracks.',
                        ),
                        _HomePlaceholderCard(
                          icon: Icons.equalizer,
                          title: 'Now Playing',
                          description: 'Control playback and view the queue.',
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.link,
                    color: colorScheme.primary,
                  ),
                  label: const Text('Connect to Navidrome'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _HomePlaceholderCard extends StatelessWidget {
  const _HomePlaceholderCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.arrow_forward,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
