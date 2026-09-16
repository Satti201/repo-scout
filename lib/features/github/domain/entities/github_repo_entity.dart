class GitHubRepoEntity {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final String htmlUrl;
  final int stargazersCount;
  final int forksCount;
  final int openIssuesCount;
  final String? language;
  final DateTime? updatedAt;
  final bool isPrivate;

  const GitHubRepoEntity({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.htmlUrl,
    this.stargazersCount = 0,
    this.forksCount = 0,
    this.openIssuesCount = 0,
    this.language,
    this.updatedAt,
    this.isPrivate = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitHubRepoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
