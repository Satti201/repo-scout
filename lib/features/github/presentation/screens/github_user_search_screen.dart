import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/github_dependencies.dart';
import '../providers/search_users_state.dart';
import 'github_user_profile_screen.dart';

class GitHubUserSearchScreen extends ConsumerStatefulWidget {
  const GitHubUserSearchScreen({super.key});

  @override
  ConsumerState<GitHubUserSearchScreen> createState() =>
      _GitHubUserSearchScreenState();
}

class _GitHubUserSearchScreenState
    extends ConsumerState<GitHubUserSearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchUsersNotifierProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchUsersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RepoScout'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search GitHub users',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: (value) {
          ref
              .read(searchUsersNotifierProvider.notifier)
              .search(value);
        },
      ),
    );
  }

  Widget _buildContent(SearchUsersState state) {
    if (state.isLoading && state.users.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null && state.users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.query.isEmpty) {
      return const Center(
        child: Text(
          'Search for a GitHub user',
        ),
      );
    }

    if (state.users.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
        ),
      );
    }

    return _buildUserList(state);
  }

  Widget _buildUserList(SearchUsersState state) {
    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(searchUsersNotifierProvider.notifier)
            .refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.users.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.users.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final user = state.users[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                user.avatarUrl,
              ),
            ),
            title: Text(user.login),
            subtitle: Text(
              user.name ?? 'GitHub user',
            ),
            trailing: const Icon(
              Icons.chevron_right,
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
      ),
    );
  }
}
