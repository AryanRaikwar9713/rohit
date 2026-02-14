// User-side / production smoke tests.
// Full MyApp widget test requires main() and locale setup.
import 'package:flutter_test/flutter_test.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/screens/auth/model/error_model.dart';

void main() {
  test('App entry point and MyApp widget exist', () {
    expect(const MyApp(), isNotNull);
  });

  test('ErrorModel default values', () {
    final model = ErrorModel();
    expect(model.error, isEmpty);
    expect(model.otherDevice, isEmpty);
  });
}

