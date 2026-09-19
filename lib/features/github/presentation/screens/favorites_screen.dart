import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorites_state.dart';
import '../providers/github_dependencies.dart';
import 'github_user_profile_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(favoritesNotifierProvider.notifier).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Users')),
      body: _buildContent(state),
    );
  }

  Widget _buildContent(FavoritesState state) {
    if (state.users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No favorites yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Save GitHub users from their profile to find them here.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (state.errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.redAccent.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
                title: Text(user.login),
                subtitle: Text(user.name ?? 'GitHub user'),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.redAccent),
                  onPressed: () {
                    ref
                        .read(favoritesNotifierProvider.notifier)
                        .toggleFavorite(user);
                  },
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          GitHubUserProfileScreen(username: user.login),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
