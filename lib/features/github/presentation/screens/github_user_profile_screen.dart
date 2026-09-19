import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/github_repo_entity.dart';
import '../../domain/entities/github_user_entity.dart';
import '../providers/github_dependencies.dart';
import '../providers/user_profile_state.dart';

class GitHubUserProfileScreen extends ConsumerStatefulWidget {
  final String username;

  const GitHubUserProfileScreen({
    super.key,
    required this.username,
  });

  @override
  ConsumerState<GitHubUserProfileScreen> createState() =>
      _GitHubUserProfileScreenState();
}

class _GitHubUserProfileScreenState
    extends ConsumerState<GitHubUserProfileScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    Future.microtask(() {
      ref
          .read(userProfileNotifierProvider.notifier)
          .loadProfile(widget.username);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(userProfileNotifierProvider.notifier)
          .loadRepositories(widget.username);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(favoritesNotifierProvider);
    final state = ref.watch(userProfileNotifierProvider);
    final user = state.user;
    final isFavorite = user != null
        ? ref.read(favoritesNotifierProvider.notifier).isFavorite(user.login)
        : false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.redAccent : null,
              ),
              onPressed: () {
                ref
                    .read(favoritesNotifierProvider.notifier)
                    .toggleFavorite(user);
              },
            ),
        ],
      ),
      body: _buildContent(state),
    );
  }

  Widget _buildContent(UserProfileState state) {
    if (state.isLoadingProfile && state.user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null && state.user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(userProfileNotifierProvider.notifier)
                      .loadProfile(widget.username);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final user = state.user;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(userProfileNotifierProvider.notifier)
            .loadProfile(widget.username);
      },
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (state.isUsingCachedProfile || state.isUsingCachedRepositories)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: const Row(
                children: [
                  Icon(Icons.cloud_off),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing cached data. Some information may be outdated.',
                    ),
                  ),
                ],
              ),
            ),
          _buildProfileHeader(user),
          const SizedBox(height: 24),
          Text(
            'Repositories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (state.errorMessage != null && state.user != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(userProfileNotifierProvider.notifier)
                          .loadRepositories(
                            widget.username,
                            reset: state.repositories.isEmpty,
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          if (state.repositories.isEmpty && !state.isLoadingRepos && state.errorMessage == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No public repositories found'),
              ),
            )
          else
            ...state.repositories.map(
              (repo) => _buildRepoCard(repo),
            ),
          if (state.isLoadingRepos)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(GitHubUserEntity user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage(user.avatarUrl),
        ),
        const SizedBox(height: 12),
        Text(
          user.name ?? user.login,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          '@${user.login}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        if (user.bio != null) ...[
          const SizedBox(height: 12),
          Text(
            user.bio!,
            textAlign: TextAlign.center,
          ),
        ],
        if (user.company != null) ...[
          const SizedBox(height: 8),
          Text('Company: ${user.company}'),
        ],
        if (user.location != null)
          Text('Location: ${user.location}'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStat('Repos', user.publicRepos),
            _buildStat('Followers', user.followers),
            _buildStat('Following', user.following),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(label),
      ],
    );
  }

  Widget _buildRepoCard(GitHubRepoEntity repo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              repo.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (repo.description != null) ...[
              const SizedBox(height: 8),
              Text(repo.description!),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.star_border,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(repo.stargazersCount.toString()),
                const SizedBox(width: 16),
                const Icon(
                  Icons.call_split,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(repo.forksCount.toString()),
                if (repo.language != null) ...[
                  const SizedBox(width: 16),
                  Text(repo.language!),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
