import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/models/user_model.dart';

void main() {
  test('AuthState.isAuthenticated requires token and user after init', () {
    final state = AuthState(isInitializing: false, token: 'abc', user: null);
    expect(state.isAuthenticated, isFalse);

    final withUser = state.copyWith(
      user: UserModel(
        id: '1',
        name: 'Test',
        email: 't@example.com',
        phone: '9999999999',
      ),
    );
    expect(withUser.isAuthenticated, isTrue);
  });
}
