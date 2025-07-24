// Temporary mock implementations for Flutter packages to enable static analysis

// Mock Flutter foundation
void debugPrint(String? message, {int? wrapWidth}) {
  print(message);
}

// Mock Flutter Material Design
class MaterialApp extends StatelessWidget {
  final String? title;
  final bool? debugShowCheckedModeBanner;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;
  final Widget Function(BuildContext, Widget?)? builder;
  final Widget? home;
  
  const MaterialApp({
    Key? key,
    this.title,
    this.debugShowCheckedModeBanner,
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.builder,
    this.home,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) => Container();
}

enum ThemeMode { system, light, dark }

class ThemeData {
  final bool? useMaterial3;
  final ColorScheme? colorScheme;
  
  const ThemeData({this.useMaterial3, this.colorScheme});
}

class ColorScheme {
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color background;
  final Color error;
  final Color onSurface;
  final Color surfaceVariant;
  
  const ColorScheme.dark({
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.background,
    required this.error,
    this.onSurface = const Color(0xFFFFFFFF),
    this.surfaceVariant = const Color(0xFF424242),
  });
  
  const ColorScheme.light({
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.background,
    required this.error,
    this.onSurface = const Color(0xFF000000),
    this.surfaceVariant = const Color(0xFFF5F5F5),
  });
}

class Color {
  final int value;
  const Color(this.value);
  
  Color withOpacity(double opacity) => this;
}

class Colors {
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFF44336);
  static const Color orange = Color(0xFFFF9800);
  static const Color blue = Color(0xFF2196F3);
  static const Color grey = Color(0xFF9E9E9E);
}

// Basic Widget classes
abstract class Widget {
  const Widget({Key? key});
}

abstract class StatelessWidget extends Widget {
  const StatelessWidget({super.key});
  Widget build(BuildContext context);
}

abstract class StatefulWidget extends Widget {
  const StatefulWidget({super.key});
  State createState();
}

abstract class State<T extends StatefulWidget> {
  T get widget;
  void setState(VoidCallback fn) {}
}

class BuildContext {}
class Key {}
typedef VoidCallback = void Function();

class Container extends StatelessWidget {
  final Widget? child;
  const Container({super.key, this.child});
  @override
  Widget build(BuildContext context) => this;
}

// Mock Bluetooth classes
class BluetoothDevice {
  final String address;
  final String name;
  
  BluetoothDevice({required this.address, required this.name});
  
  factory BluetoothDevice.fromMap(Map<String, dynamic> map) {
    return BluetoothDevice(
      address: map['address'] as String,
      name: map['name'] as String,
    );
  }
}

class BluetoothConnection {
  static Future<BluetoothConnection> toAddress(String address) async {
    return BluetoothConnection._();
  }
  
  BluetoothConnection._();
  
  Stream<List<int>>? get input => Stream.empty();
  late BluetoothConnectionOutput output = BluetoothConnectionOutput._();
  
  Future<void> close() async {}
}

class BluetoothConnectionOutput {
  BluetoothConnectionOutput._();
  
  void add(List<int> data) {}
  Future<void> get allSent async {}
}

class FlutterBluetoothSerial {
  static FlutterBluetoothSerial get instance => FlutterBluetoothSerial._();
  FlutterBluetoothSerial._();
  
  Future<List<BluetoothDevice>> getBondedDevices() async {
    return [];
  }
}

// Mock Secure Storage
class FlutterSecureStorage {
  const FlutterSecureStorage({
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
  });
  
  Future<String?> read({required String key}) async => null;
  Future<void> write({required String key, required String value}) async {}
  Future<void> delete({required String key}) async {}
  Future<void> deleteAll() async {}
}

class AndroidOptions {
  const AndroidOptions({bool? encryptedSharedPreferences});
}

class IOSOptions {
  const IOSOptions({KeychainAccessibility? accessibility});
}

enum KeychainAccessibility {
  first_unlock_this_device,
}

// Mock SharedPreferences
class SharedPreferences {
  static Future<SharedPreferences> getInstance() async {
    return SharedPreferences._();
  }
  
  SharedPreferences._();
  
  String? getString(String key) => null;
  int? getInt(String key) => null;
  List<String>? getStringList(String key) => null;
  
  Future<bool> setString(String key, String value) async => true;
  Future<bool> setInt(String key, int value) async => true;
  Future<bool> setStringList(String key, List<String> value) async => true;
  Future<bool> remove(String key) async => true;
}

// Mock Crypto
class Digest {
  final String value;
  Digest(this.value);
  
  @override
  String toString() => value;
}

final sha256 = _SHA256();

class _SHA256 {
  Digest convert(List<int> input) {
    return Digest('mock_hash_${input.length}');
  }
}