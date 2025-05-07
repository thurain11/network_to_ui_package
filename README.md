# network_to_ui

A Flutter package that simplifies network requests and UI integration using Dio and BLoC. It provides reusable widgets and services to handle HTTP requests, manage authentication, and render responses directly in the UI.

## Features
- **Network Handling**: Perform GET, POST, PUT, and DELETE requests using Dio with built-in error handling.
- **BLoC Integration**: Use `NetworkToUiBloc` and `DataRequestBloc` for seamless state management.
- **UI Widgets**: `NetWorkToUiBuilder` and `DataRequestWidget` to render network responses with loading, error, and data states.
- **Storage Management**: Persistent storage using `SharedPreferences` for tokens and other data.
- **Dependency Injection**: Configurable dependency injection with `GetIt`.
- **Customizable Headers**: Support for dynamic headers, including authentication tokens and platform-specific versioning.
- **Object Parsing**: Parse JSON responses into Dart objects using `ObjectFactory`.

## Author

Created by [Thurain Hein](https://github.com/thurain11/).

## Installation
Add `network_to_ui` to your `pubspec.yaml`:

```yaml
dependencies:
  network_to_ui: ^0.1.0
```

Run the following command to install the package:

```bash
flutter pub get
```

## Setup
Before using the `network_to_ui` package, you need to initialize its core components in your app's `main.dart`. This ensures that dependency injection, storage, object parsing, and network configurations are properly set up.

### Why Setup is Required
- **Dependency Injection**: The package uses `GetIt` to manage dependencies like `StorageInterface` and `DioBaseNetworkConfig`. Initializing `GetIt` ensures these services are available throughout the app.
- **Object Parsing**: Factories for parsing JSON responses into Dart objects must be registered to handle API responses correctly.
- **Network Configuration**: Custom headers, app versions, and authentication tokens need to be configured for network requests to work as expected.

### Setup Code
Add the following code to your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:network_to_ui/network_to_ui.dart';

// Example models (replace withconstexpr
// with your actual models)
class CountryListOb {
  final String name;
  CountryListOb({required this.name});
  factory CountryListOb.fromJson(Map<String, dynamic> json) {
    return CountryListOb(name: json['name']);
  }
}

class UserOb {
  final String username;
  UserOb({required this.username});
  factory UserOb.fromJson(Map<String, dynamic> json) {
    return UserOb(username: json['username']);
  }
}

class FactoryManager {
  static void setupFactories() {
    ObjectFactory.registerFactory<CountryListOb>((json) => CountryListOb.fromJson(json));
    ObjectFactory.registerFactory<UserOb>((json) => UserOb.fromJson(json));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage and network
  final StorageInterface storage = await initializeNetwork();
  
  // Setup factories for object parsing
  FactoryManager.setupFactories();

  // Configure network settings
  DioBaseNetworkConfig().updateConfig(
    nowVersionIos: "1.0.0",
    nowVersionAndroid: "1.0.0",
    additionalHeaders: {
      "Content-Type": "application/json",
    },
    authorizationToken: await storage.getString("token"),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Hello, network_to_ui!')),
      ),
    );
  }
}
```

**Note**: The `CountryListOb` and `UserOb` classes are examples. Replace them with your actual model classes and ensure their `fromJson` methods match your API response structure. The `initializeNetwork` function is provided by the `network_to_ui` package and sets up `GetIt` and storage.

## Usage
Below are examples of how to use the main components of the `network_to_ui` package.

### 1. Using `NetWorkToUiBuilder`
Fetch and display data from an API using `NetWorkToUiBuilder`:

```dart
import 'package:flutter/material.dart';
import 'package:network_to_ui/network_to_ui.dart';

class CountryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NetWorkToUiBuilder<CountryListOb>(
      url: 'https://api.example.com/countries',
      widget: (data, reload) {
        if (data == null) return const Text('No data');
        return Column(
          children: [
            Text('Country: ${data.name}'),
            ElevatedButton(
              onPressed: () => reload(),
              child: const Text('Reload'),
            ),
          ],
        );
      },
      errorWidget: const Text('Failed to load data'),
      customLoadingWidget: const CircularProgressIndicator(),
    );
  }
}
```

### 2. Using `DataRequestWidget`
Perform a POST request (e.g., login) and handle responses:

```dart
import 'package:flutter/material.dart';
import 'package:network_to_ui/network_to_ui.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DataRequestWidget(
      url: 'https://api.example.com/login',
      text: 'Login',
      isShowDialog: true,
      onAsyncPress: () async {
        return {
          'email': 'user@example.com',
          'password': 'password123',
        };
      },
      successFunc: (ResponseOb resp) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful')),
        );
      },
      validFunc: (ResponseOb resp) {
        Map<String, dynamic> errors = resp.data['errors'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errors.toString())),
        );
      },
      errorFunc: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed')),
        );
      },
    );
  }
}
```

### 3. Authentication with `AuthService`
Manage user tokens using `AuthService`:

```dart
final authService = getIt<AuthService>();

// Save token
await authService.saveUserToken('your-jwt-token');

// Retrieve token
String? token = await authService.getUserToken();

// Logout
await authService.logout();
```

## Configuration
- **Storage**: Uses `SharedPreferences` by default. You can extend `StorageInterface` for other storage solutions (e.g., Hive).
- **Object Parsing**: Register factories for your models using `ObjectFactory` to parse JSON responses into Dart objects.
- **Error Handling**: Customize error messages and UI using `errorWidget`, `customErrorCallback`, or `AppUtils`.

## Contributing
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m 'Add your feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

Please ensure your code follows the Flutter style guide and includes tests.

## License
This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support
For issues or questions, please open an issue on the [GitHub repository](https://github.com/thurain11/) or contact the maintainer at [thurainhein097@gmail.com].