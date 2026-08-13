import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
class FakeSecureStorage {
  static const MethodChannel _channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  static final Map<String, String> _store = {};

  static void install() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _store.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _channel,
      (MethodCall call) async {
        final args = call.arguments is Map ? Map<String, dynamic>.from(call.arguments as Map) : <String, dynamic>{};
        switch (call.method) {
          case 'write':
            _store[args['key'] as String] = args['value'] as String;
            return null;
          case 'read':
            return _store[args['key'] as String];
          case 'delete':
            _store.remove(args['key'] as String);
            return null;
          case 'readAll':
            return _store;
          case 'deleteAll':
            _store.clear();
            return null;
          case 'containsKey':
            return _store.containsKey(args['key'] as String);
          default:
            return null;
        }
      },
    );
  }

  static void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, null);
    _store.clear();
  }
}
