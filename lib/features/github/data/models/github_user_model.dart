import '../../domain/entities/github_user_entity.dart';

class GitHubUserModel extends GitHubUserEntity {
  const GitHubUserModel({
    required super.id,
    required super.login,
    required super.avatarUrl,
    required super.htmlUrl,
    super.name,
    super.bio,
    super.company,
    super.location,
    super.publicRepos,
    super.followers,
    super.following,
  });

  factory GitHubUserModel.fromJson(Map<String, dynamic> json) {
    return GitHubUserModel(
      id: json['id'] as int,
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
      htmlUrl: json['html_url'] as String,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      company: json['company'] as String?,
      location: json['location'] as String?,
      publicRepos: json['public_repos'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
      'name': name,
      'bio': bio,
      'company': company,
      'location': location,
      'public_repos': publicRepos,
      'followers': followers,
      'following': following,
    };
  }
}
