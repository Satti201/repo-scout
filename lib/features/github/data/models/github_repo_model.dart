import '../../domain/entities/github_repo_entity.dart';

class GitHubRepoModel extends GitHubRepoEntity {
  const GitHubRepoModel({
    required super.id,
    required super.name,
    required super.fullName,
    super.description,
    required super.htmlUrl,
    super.stargazersCount,
    super.forksCount,
    super.openIssuesCount,
    super.language,
    super.updatedAt,
    super.isPrivate,
  });

  factory GitHubRepoModel.fromJson(Map<String, dynamic> json) {
    return GitHubRepoModel(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String?,
      htmlUrl: json['html_url'] as String,
      stargazersCount: json['stargazers_count'] as int? ?? 0,
      forksCount: json['forks_count'] as int? ?? 0,
      openIssuesCount: json['open_issues_count'] as int? ?? 0,
      language: json['language'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      isPrivate: json['private'] as bool? ?? false,
    );
  }
}
