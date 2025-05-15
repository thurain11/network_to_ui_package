# Changelog

## [0.1.5] - 2025-05-15
- Updated `README.md` with `LoadMoreUiBuilder` documentation, including expected JSON format for pagination.

## [0.1.4] 
- Removed unnecessary packages and variables.
- Fixed minor bugs.

## [0.1.2]
- Updated `README.md` minor formatting improvements.

## [0.1.1]
- Fixed immutable class issue in `DataRequestWidget` by making all fields `final`.
- Added `mounted` checks in `DataRequestWidget` to prevent unsafe `BuildContext` usage across async gaps.
- Updated `NetWorkToUiBuilder` to use `super.key` for constructor parameters.
- Improved documentation for public APIs.

## [0.1.0]
- Initial release of `network_to_ui`.
- Added `NetWorkToUiBuilder` for seamless network-to-UI integration with BLoC.
- Added `DataRequestWidget` for handling HTTP requests with customizable UI and error handling.
- Implemented `AuthService` for token management using `SharedPreferences`.
- Added support for Dio-based HTTP requests with `FormData` for file uploads.
- Integrated `GetIt` for dependency injection and `fluttertoast` for user notifications.