# RepoScout

![Flutter CI](https://github.com/Satti201/repo-scout/actions/workflows/flutter_ci.yml/badge.svg)

RepoScout is a production-grade Flutter application for discovering and exploring GitHub users and repositories. Built with Clean Architecture, Riverpod state management, Dio networking, and Hive offline caching, it demonstrates enterprise-quality mobile development patterns.

## Features

- GitHub user search
- Paginated user results
- User profiles
- Paginated public repositories
- Pull-to-refresh
- Persistent favorites
- Hive local caching
- Offline profile/repository fallback
- Friendly error states
- Cached-data indicators
- Clean Architecture
- Riverpod dependency injection
- Automated unit and widget tests
- GitHub Actions CI

## Architecture

RepoScout follows Clean Architecture principles, ensuring strict separation of concerns, testability, and independence from external frameworks:

```text
Presentation
    ↓
Use Cases
    ↓
Repository Contract
    ↓
Repository Implementation
   ↙              ↘
Remote             Local
Datasource         Datasource
   ↓                  ↓
  Dio                Hive
   ↓
GitHub API
```

- **Domain Layer**: Contains pure Dart business entities, repository contracts, and use cases with zero external framework dependencies.
- **Data Layer**: Implements repository contracts, orchestrating remote data fetching (Dio) and local persistence (Hive) with dedicated data models and exception handling.
- **Presentation Layer**: Built with Flutter and Riverpod (`StateNotifier`), providing reactive UI, clean state models, pagination triggers, and user-friendly error banners.

### Offline Strategy

RepoScout uses a remote-first caching strategy:

1. Requests are attempted against the GitHub REST API.
2. Successful profile and repository responses are cached locally using Hive.
3. Network, server, and rate-limit failures fall back to cached data when available.
4. `NotFoundException` and parsing failures are not masked by stale cache.
5. Connectivity status is used only for UX hints and never to bypass remote requests.

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Dart SDK (>=3.0.0)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Satti201/repo-scout.git
   cd repo_scout
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Testing

The project contains tests covering:

- Local Hive caching
- Repository remote/local coordination
- Offline fallback
- Cache write behavior
- Exception propagation
- Favorite persistence
- Favorites state management
- Profile presentation state
- Pagination failure handling
- Basic widget rendering

Run:

```bash
flutter test
```

And:

```bash
flutter analyze
```
