import 'package:expand/features/auth/viewmodels/aut_viewmodel.dart';
import 'package:expand/lean_riverpod/post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In')),
      body: Center(
        child: authState.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
          data: (user) {
            if (user == null) {
              return ElevatedButton(
                onPressed:
                    () =>
                        ref
                            .read(authViewModelProvider.notifier)
                            .signInWithGoogle(),
                child: const Text('Sign in with Google'),
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Logged in as: ${user.email}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        () =>
                            ref.read(authViewModelProvider.notifier).signOut(),
                    child: const Text('Sign out'),
                  ),
                  // moving to the product screen
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PostScreen()),
                      );
                    },
                    child: Text("view product"),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
