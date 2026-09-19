# RepoScout

![Flutter CI](https://github.com/Satti201/repo-scout/actions/workflows/flutter_ci.yml/badge.svg)

A production-style Flutter GitHub explorer built to demonstrate clean architecture, resilient API integration, offline-first UX, local persistence, pagination, favorites, automated testing, and CI.

RepoScout lets users search GitHub profiles, inspect public repositories, save favorite users, and continue viewing previously cached data when connectivity is unavailable.

## Why This Project Exists

RepoScout is not intended to be a feature-heavy GitHub clone.

It was built as an engineering portfolio project focused on:

- maintainable Flutter architecture
- strict separation between domain, data, and presentation layers
- remote and local data source coordination
- graceful offline fallback
- predictable state management
- testable business logic
- CI-backed code quality

## Engineering Highlights

- Clean Architecture with domain, data, and presentation separation
- Repository Pattern with remote + local data source coordination
- GitHub REST API integration using Dio
- Riverpod dependency injection and reactive presentation state
- Remote-first caching with Hive offline fallback
- Paginated user search and repository loading
- Persistent favorites/bookmarks
- Explicit exception mapping and user-friendly errors
- Cached-data indicators for offline UX
- Unit and widget test coverage across repository and state layers
- GitHub Actions CI for analyze + test on every push and pull request

## Tech Stack

| Area | Technology |
|---|---|
| UI | Flutter |
| Language | Dart |
| State Management | Riverpod |
| Networking | Dio |
| API | GitHub REST API |
| Local Persistence | Hive |
| Architecture | Clean Architecture |
| Patterns | Repository Pattern, Dependency Injection |
| Testing | Flutter Test |
| CI | GitHub Actions |

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

## Key User Flows

### Search
Search GitHub users with paginated REST API results.

### Profile
Open a user profile to view:
- avatar
- bio
- company
- location
- followers/following
- public repository count

### Repositories
Browse paginated public repositories with:
- description
- stars
- forks
- language

### Favorites
Bookmark GitHub users locally and access them after restarting the app.

### Offline Usage
Previously viewed profiles and repository pages are cached with Hive and can be displayed when remote requests fail because of connectivity, server, or rate-limit issues.

## Screenshots

Screenshots and demo media will be added in the next portfolio polish phase.

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

## What This Project Demonstrates

RepoScout demonstrates how I structure a Flutter application beyond UI implementation:

- converting requirements into architecture boundaries
- designing repository contracts
- separating API models from domain entities
- coordinating remote and local data sources
- implementing pagination and offline fallback
- isolating framework dependencies
- testing business and state logic
- maintaining code quality through CI

The same architecture can support Firebase, REST APIs, Supabase, or another backend without coupling the presentation layer to infrastructure details.

## Project Status

Core engineering implementation is complete.

Current focus:
- portfolio presentation
- screenshots/demo media
- documentation polish

The project intentionally avoids unnecessary feature expansion so the repository stays focused on architecture, reliability, and code quality.
