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
      appBar: AppBar(
        title: const Text('Favorite Users'),
      ),
      body: _buildContent(state),
    );
  }

  Widget _buildContent(FavoritesState state) {
    if (state.users.isEmpty) {
      return const Center(
        child: Text('No favorite users yet'),
      );
    }

    return ListView.builder(
      itemCount: state.users.length,
      itemBuilder: (context, index) {
        final user = state.users[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
          title: Text(user.login),
          subtitle: Text(
            user.name ?? 'GitHub user',
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.favorite,
              color: Colors.redAccent,
            ),
            onPressed: () {
              ref
                  .read(favoritesNotifierProvider.notifier)
                  .toggleFavorite(user);
            },
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GitHubUserProfileScreen(
                  username: user.login,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
