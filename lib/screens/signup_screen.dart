import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      final username = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;

      // --------------------------------------------------
      // CREATE FIREBASE AUTH ACCOUNT
      // --------------------------------------------------

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception(
          'Account could not be created.',
        );
      }

      // --------------------------------------------------
      // SAVE USER INFORMATION IN FIRESTORE
      // --------------------------------------------------

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // --------------------------------------------------
      // SAVE NAME TO FIREBASE AUTH
      // --------------------------------------------------

      await user.updateDisplayName(username);

      // Refresh user information.
      await user.reload();

      // --------------------------------------------------
      // MAKE SURE SCREEN STILL EXISTS
      // --------------------------------------------------

      if (!mounted) {
        return;
      }

      // --------------------------------------------------
      // GO DIRECTLY TO HOME
      // --------------------------------------------------

      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),

        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message =
              'An account already exists with this email.';
          break;

        case 'invalid-email':
          message =
              'Please enter a valid email address.';
          break;

        case 'weak-password':
          message =
              'Password is too weak. Use at least 6 characters.';
          break;

        case 'operation-not-allowed':
          message =
              'Email/password sign-up is not enabled in Firebase.';
          break;

        case 'network-request-failed':
          message =
              'Network error. Please check your internet connection.';
          break;

        default:
          message =
              e.message ?? 'Could not create account.';
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ??
                'Could not save your account information.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,

        backgroundColor: Colors.transparent,

        foregroundColor:
            theme.colorScheme.primary,

        title: const Text(
          'Create Account',

          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 20),

                Text(
                  'Create your account',

                  style: TextStyle(
                    fontSize: 30,

                    fontWeight: FontWeight.bold,

                    color: theme.textTheme
                        .headlineMedium
                        ?.color,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Enter your details to start using FreshTrack.',

                  style: TextStyle(
                    fontSize: 15,

                    color: theme.textTheme
                        .bodyMedium
                        ?.color,
                  ),
                ),

                const SizedBox(height: 35),

                // --------------------------------------------------
                // USERNAME
                // --------------------------------------------------

                TextFormField(
                  controller: nameController,

                  textInputAction:
                      TextInputAction.next,

                  keyboardType:
                      TextInputType.name,

                  decoration: InputDecoration(
                    labelText: 'Username',

                    hintText:
                        'Enter your username',

                    prefixIcon: const Icon(
                      Icons.person_outline,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),

                  validator: (value) {
                    final name =
                        value?.trim() ?? '';

                    if (name.isEmpty) {
                      return 'Please enter a username';
                    }

                    if (name.length < 2) {
                      return 'Username must be at least 2 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // --------------------------------------------------
                // EMAIL
                // --------------------------------------------------

                TextFormField(
                  controller: emailController,

                  textInputAction:
                      TextInputAction.next,

                  keyboardType:
                      TextInputType.emailAddress,

                  autocorrect: false,

                  decoration: InputDecoration(
                    labelText: 'Email',

                    hintText:
                        'Enter your email',

                    prefixIcon: const Icon(
                      Icons.email_outlined,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),

                  validator: (value) {
                    final email =
                        value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Please enter your email';
                    }

                    if (!email.contains('@') ||
                        !email.contains('.')) {
                      return 'Please enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // --------------------------------------------------
                // PASSWORD
                // --------------------------------------------------

                TextFormField(
                  controller:
                      passwordController,

                  obscureText:
                      obscurePassword,

                  textInputAction:
                      TextInputAction.next,

                  decoration: InputDecoration(
                    labelText: 'Password',

                    hintText:
                        'Enter your password',

                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),

                      onPressed: () {
                        setState(() {
                          obscurePassword =
                              !obscurePassword;
                        });
                      },
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),

                  validator: (value) {
                    final password =
                        value ?? '';

                    if (password.isEmpty) {
                      return 'Please enter a password';
                    }

                    if (password.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // --------------------------------------------------
                // CONFIRM PASSWORD
                // --------------------------------------------------

                TextFormField(
                  controller:
                      confirmPasswordController,

                  obscureText:
                      obscureConfirmPassword,

                  textInputAction:
                      TextInputAction.done,

                  onFieldSubmitted: (_) {
                    if (!isLoading) {
                      createAccount();
                    }
                  },

                  decoration: InputDecoration(
                    labelText:
                        'Confirm Password',

                    hintText:
                        'Re-enter your password',

                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),

                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword =
                              !obscureConfirmPassword;
                        });
                      },
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),

                  validator: (value) {
                    final confirmPassword =
                        value ?? '';

                    if (confirmPassword.isEmpty) {
                      return 'Please confirm your password';
                    }

                    if (confirmPassword !=
                        passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // --------------------------------------------------
                // CREATE ACCOUNT BUTTON
                // --------------------------------------------------

                SizedBox(
                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : createAccount,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green,

                      foregroundColor:
                          Colors.white,

                      disabledBackgroundColor:
                          Colors.green.withValues(
                        alpha: 0.5,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),

                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Account',

                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'Your username will be shown on your FreshTrack dashboard.',

                    textAlign:
                        TextAlign.center,

                    style: TextStyle(
                      fontSize: 13,

                      color: theme.textTheme
                          .bodySmall
                          ?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}