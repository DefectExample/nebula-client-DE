import 'package:go_router/go_router.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/master_pass_screen.dart';
import '../features/explorer/explorer_screen.dart';
import '../features/transfers/transfers_screen.dart';
import '../features/vault_unlock/vault_unlock_screen.dart';

final router = GoRouter(
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/setup-password',
      builder: (context, state) => const MasterPassScreen(),
    ),
    GoRoute(
      path: '/vault-unlock',
      builder: (context, state) => const VaultUnlockScreen(),
    ),
    GoRoute(
      path: '/explorer',
      builder: (context, state) => const ExplorerScreen(),
    ),
    GoRoute(
      path: '/transfers',
      builder: (context, state) => const TransfersScreen(),
    ),
  ],
);
