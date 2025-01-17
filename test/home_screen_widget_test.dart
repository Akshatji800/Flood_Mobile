import 'dart:io';
import 'package:flood_mobile/Constants/theme_provider.dart';
import 'package:flood_mobile/Model/notification_model.dart';
import 'package:flood_mobile/Model/torrent_model.dart';
import 'package:flood_mobile/Pages/home_screen.dart';
import 'package:flood_mobile/Provider/api_provider.dart';
import 'package:flood_mobile/Provider/client_provider.dart';
import 'package:flood_mobile/Provider/filter_provider.dart';
import 'package:flood_mobile/Provider/home_provider.dart';
import 'package:flood_mobile/Provider/sse_provider.dart';
import 'package:flood_mobile/Provider/user_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockHomeProvider extends Mock implements HomeProvider {}

class MockClientSettingsProvider extends Mock
    implements ClientSettingsProvider {}

void main() {
  setUp(() {});
  MockHomeProvider mockHomeProvider = MockHomeProvider();
  MockClientSettingsProvider mockClientSettingsProvider =
      MockClientSettingsProvider();
  setUpAll(() => HttpOverrides.global = null);
  when(() => mockHomeProvider.unreadNotifications).thenReturn(0);
  when(() => mockHomeProvider.notificationModel).thenReturn(NotificationModel(
      read: 0,
      notifications: [
        NotificationContentModel(
            identification: 'test identification',
            id: 'test id',
            name: 'test name',
            read: false,
            ts: 0,
            status: 'test status')
      ],
      total: 1,
      unread: 1));
  when(() => mockHomeProvider.torrentList).thenReturn([
    TorrentModel(
        bytesDone: 0.0,
        dateAdded: 0.0,
        dateCreated: 0.0,
        directory: "test1 directory",
        downRate: 0.0,
        downTotal: 0.0,
        eta: -1,
        hash: 'test1 hash',
        isInitialSeeding: false,
        isPrivate: false,
        isSequential: false,
        message: 'test1 message',
        name: 'test1 name',
        peersConnected: 0.0,
        peersTotal: 0.0,
        percentComplete: 1.1,
        priority: 0.0,
        ratio: 0.0,
        seedsConnected: 0.0,
        seedsTotal: 0.0,
        sizeBytes: 100.0,
        status: ['downloading'],
        tags: ['test1 tags'],
        trackerURIs: ['test1 trackerURIs'],
        upRate: 0.0,
        upTotal: 0.0),
  ]);
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserDetailProvider>(
          create: (context) => UserDetailProvider(),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (context) => mockHomeProvider,
        ),
        ChangeNotifierProvider<SSEProvider>(
          create: (context) => SSEProvider(),
        ),
        ChangeNotifierProvider<ApiProvider>(
          create: (context) => ApiProvider(),
        ),
        ChangeNotifierProvider<ClientSettingsProvider>(
          create: (context) => mockClientSettingsProvider,
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<FilterProvider>(
          create: (context) => FilterProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          print(ThemeProvider.themeMode);
          return MaterialApp(
              home: Material(
            child: HomeScreen(),
          ));
        },
      ),
    );
  }

  group("Check different widgets in home-screen", () {
    testWidgets("Check top bar widgets", (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byKey(Key('Flood Icon')), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.wb_sunny_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.mode_night_rounded), findsOneWidget);
      expect(find.byKey(Key('Badge Widget')), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('Notification Alert Dialog')), findsOneWidget);
      expect(find.text('test status'), findsOneWidget);
      expect(
          find.text(DateTime.fromMillisecondsSinceEpoch(
                  mockHomeProvider.notificationModel.notifications[0].ts)
              .toString()),
          findsOneWidget);
      expect(find.text('test name'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets("Check menu button working", (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.ensureVisible(find.byIcon(Icons.menu));
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('Flood Icon menu')), findsOneWidget);
      expect(find.byKey(Key('Release Shield')), findsOneWidget);
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.text('Torrents'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.byIcon(FontAwesomeIcons.github), findsOneWidget);
      expect(find.text('GitHub'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.exit_to_app));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('Alert Dialog')), findsOneWidget);
      expect(find.text('Are you sure you want to\n Log out ?'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'No'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Yes'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });
}
