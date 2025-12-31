import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/main.dart';

import 'package:tickdose/core/services/deep_link_service.dart';

class FakeDeepLinkService extends DeepLinkService {
  FakeDeepLinkService() : super.test();

  @override
  Future<void> initialize({
    Function(String token)? onInvitationToken,
    Function(String email, String link)? onEmailAuthLink,
  }) async {
    // No-op for testing
  }
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ProviderScope(
      child: TickdoseApp(deepLinkService: FakeDeepLinkService()),
    ));

    // Verify that our app initializes and shows Splash Screen.
    expect(find.text('TICKDOSE'), findsOneWidget);
    
    // Allow the splash screen timer to complete
    await tester.pump(const Duration(seconds: 3));
  });
}
