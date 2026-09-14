import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lifeos_flutter/theme/app_theme.dart';
import 'package:lifeos_flutter/routes/app_router.dart';
import 'package:lifeos_flutter/providers/auth_provider.dart';
import 'package:lifeos_flutter/providers/task_provider.dart';
import 'package:lifeos_flutter/providers/calendar_provider.dart';
import 'package:lifeos_flutter/providers/expense_provider.dart';
import 'package:lifeos_flutter/providers/note_provider.dart';
import 'package:lifeos_flutter/providers/ai_chat_provider.dart';
import 'package:lifeos_flutter/providers/goal_provider.dart';
import 'package:lifeos_flutter/providers/study_provider.dart';
import 'package:lifeos_flutter/providers/theme_provider.dart';
import 'package:lifeos_flutter/providers/global_search_provider.dart';
import 'package:lifeos_flutter/services/hive_service.dart';
import 'package:lifeos_flutter/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await HiveService.init(); 
  await LocalNotificationService.init(); 

  runApp(const LifeOSApp()); 
}

class LifeOSApp extends StatefulWidget {
  const LifeOSApp({super.key});

  @override
  State<LifeOSApp> createState() => _LifeOSAppState();
}

class _LifeOSAppState extends State<LifeOSApp> {
  GoRouter? _router;
  final AuthProvider _authProvider = AuthProvider();

  // A key that changes every time the user logs in/out, forcing providers to rebuild.
  Key _providerKey = UniqueKey();
  String? _lastUid;

  @override
  void initState() {
    super.initState();
    _authProvider.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    final uid = _authProvider.currentUser?.uid;
    if (uid != _lastUid) {
      setState(() {
        _lastUid = uid;
        // Reset providerKey so all data providers are rebuilt fresh for the new user.
        _providerKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GlobalSearchProvider()),
        ChangeNotifierProvider(create: (_) => AIChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          _router ??= AppRoutes.createRouter(_authProvider);
          return MaterialApp.router(
            title: 'OSLife',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: _router!,
            builder: (context, child) {
              return Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final uid = authProvider.currentUser?.uid ?? 'guest';
                  // Rebuild all user-scoped providers whenever the uid changes.
                  return MultiProvider(
                    key: _providerKey,
                    providers: [
                      ChangeNotifierProvider(
                        create: (_) => TaskProvider(uid: uid),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => CalendarProvider(uid: uid),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => ExpenseProvider(uid: uid),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => NoteProvider(uid: uid),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => GoalProvider(uid: uid),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => StudyProvider(uid: uid),
                      ),
                    ],
                    child: child!,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
