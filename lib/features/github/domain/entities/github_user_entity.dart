class GitHubUserEntity {
  final int id;
  final String login;
  final String avatarUrl;
  final String htmlUrl;
  final String? name;
  final String? bio;
  final String? company;
  final String? location;
  final int publicRepos;
  final int followers;
  final int following;

  const GitHubUserEntity({
    required this.id,
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
    this.name,
    this.bio,
    this.company,
    this.location,
    this.publicRepos = 0,
    this.followers = 0,
    this.following = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitHubUserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          login == other.login;

  @override
  int get hashCode => id.hashCode ^ login.hashCode;
}
