# network_to_ui

A Flutter package to simplify network requests and UI integration using Dio, BLoC, and reactive streams. It provides a clean way to fetch data, handle responses, and update UI reactively, with support for local storage using Hive or SharedPreferences.

## Features
- **Reactive UI Updates**: Uses `rxdart` streams to update UI based on network response states (loading, data, error, more).
- **Network Integration**: Built on `dio` for robust HTTP requests with configurable headers and error handling.
- **BLoC Pattern**: Implements `SingleUiBloc` for managing network requests and data streams.
- **UI Builder**: `SingleUiBuilder` widget for seamless integration of network data into Flutter UI.
- **Storage Support**: Interchangeable storage backends (`HiveStorage`, `SharedPrefsStorage`) for key-value persistence.
- **Dependency Injection**: Uses `get_it` for singleton management of configurations and storage.

## Installation

Add `network_to_ui` to your `pubspec.yaml`:

```yaml
dependencies:
  network_to_ui:
    path: ./path/to/network_to_ui # Replace with Git URL or pub.dev version if published
```

Run `flutter pub get` to install the package.

### Dependencies
Ensure the following dependencies are included in your `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.0
  rxdart: ^0.27.7
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  get_it: ^7.6.4
  path_provider: ^2.1.1
```

## Setup

1. **Initialize Hive** (if using `HiveStorage`):
   ```dart
   import 'package:hive_flutter/hive_flutter.dart';

   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Hive.initFlutter();
     await Hive.openBox('app_storage');
     runApp(MyApp());
   }
   ```

2. **Setup Dependency Injection**:
   Call `setupLocator` to register singletons:
   ```dart
   import 'package:network_to_ui/network_to_ui.dart';

   void main() async {
     // After Hive initialization
     setupLocator();
     runApp(MyApp());
   }
   ```

3. **Configure Network**:
   Update `DioBaseNetworkConfig` with your app's configuration:
   ```dart
   import 'package:network_to_ui/network_to_ui.dart';

   void main() async {
     // After setupLocator
     final storage = HiveStorage();
     DioBaseNetworkConfig().updateConfig(
       nowVersionIos: "1.0.0",
       nowVersionAndroid: "1.0.0",
       authorizationToken: await storage.getString("token"),
       language: "en",
       shopCity: "default_city",
     );
     runApp(MyApp());
   }
   ```

## Usage

### Fetching Data with `SingleUiBuilder`
Use `SingleUiBuilder` to fetch data and display it reactively:

```dart
import 'package:flutter/material.dart';
import 'package:network_to_ui/network_to_ui.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleUiBuilder<Map<String, dynamic>>(
      url: "https://api.example.com/data",
      widget: (data, reload) {
        return ListView.builder(
          itemCount: data?["items"]?.length ?? 0,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(data["items"][index]["name"] ?? "No Name"),
              onTap: () => reload(), // Refresh data
            );
          },
        );
      },
      customLoadingWidget: const Center(child: CircularProgressIndicator()),
      errorWidget: const Center(child: Text("Failed to load data")),
    );
  }
}
```

### Handling Responses
`SingleUiBuilder` automatically handles different response states:
- **Loading**: Shows `customLoadingWidget` or a default `CircularProgressIndicator`.
- **Data**: Renders the `widget` with parsed data.
- **Error**: Shows `errorWidget` or a default error message.
- **More**: Supports pagination or partial data with `moreWidget`.

### Custom Callbacks
Add callbacks for success, error, or more states:
```dart
SingleUiBuilder<Map<String, dynamic>>(
  url: "https://api.example.com/data",
  widget: (data, reload) => Text(data.toString()),
  successCallback: (resp) => print("Success: ${resp.data}"),
  customErrorCallback: (resp) => print("Error: ${resp.data}"),
  customMoreCallback: (resp) => print("More data: ${resp.data}"),
)
```

## Storage
Use `HiveStorage` or `SharedPrefsStorage` for local persistence:
```dart
final storage = getIt<HiveStorage>();
await storage.setString("token", "your_token");
String? token = await storage.getString("token");
await storage.remove("token");
```

## Contributing
Contributions are welcome! Please open an issue or submit a pull request on [GitHub](#) (replace with your repo URL).

## License
This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support
For issues or questions, please open an issue on [GitHub](#) or contact [your_email@example.com].