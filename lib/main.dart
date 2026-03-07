import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'components/bottom_navbar_page.dart';
import 'core/storage/auth_prefs.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/screen/forgetpass_screen.dart';
import 'features/auth/screen/login_screen.dart';
import 'features/auth/screen/register_screen.dart';
import 'features/auth/screen/resetpass_screen.dart';
import 'features/post/screen/post_detail_screen.dart';
import 'features/post/screen/edit_post_screen.dart';
import 'features/profile/screen/other_user_profile_screen.dart';
import 'models/post_model.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  redirect: (context, state) async {
    final location = state.matchedLocation;

    final hasToken = await TokenStorage.hasToken();
    final isLoggedIn = await AuthPrefs.isLoggedIn();
    final signedIn = hasToken && isLoggedIn;

    final isAuthLocation =
        location == '/' ||
        location == '/login' ||
        location == '/register' ||
        location == '/forgetpass' ||
        location == '/resetpass';

    if (signedIn && isAuthLocation) {
      return '/home';
    }

    final isProtectedLocation =
        location == '/home' ||
        location == '/post-detail' ||
        location.startsWith('/profile/');
    if (!signedIn && isProtectedLocation) {
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/home',
      builder: (context, state) => const BottomNavbarPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgetpass',
      builder: (context, state) => const ForgetpassScreen(),
    ),
    GoRoute(
      path: '/resetpass',
      builder: (context, state) => const ResetpassScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/post-detail',
      builder: (context, state) {
        final extra = state.extra;
        Post post;

        if (extra is Post) {
          post = extra;
        } else if (extra is Map<String, dynamic>) {
          post = Post.fromJson(extra);
        } else {
          throw Exception('Invalid post data passed to /post-detail');
        }

        return PostDetailScreen(post: post);
      },
    ),
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) {
        final userId = int.parse(state.pathParameters['userId']!);
        final extra = state.extra as Map<String, dynamic>?;
        final username = extra?['username'] as String? ?? 'User';
        final profileImage = extra?['profileImage'] as String?;
        return OtherUserProfileScreen(
          userId: userId,
          username: username,
          profileImage: profileImage,
        );
      },
    ),
    GoRoute(
      path: '/edit-post',
      builder: (context, state) {
        final post = state.extra as Post;
        return EditPostScreen(post: post);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LifeHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _router,
    );
  }
}
