import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_food_screen.dart';
import 'inventory_screen.dart';
import 'analytics_screen.dart';
import 'scan_screen.dart';
import 'profile_screen.dart';
import 'alerts_screen.dart';
import 'recipe_screen.dart';
import 'food_status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? get user => FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFoodStream() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('foods')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots();
  }

  int calculateDays(Timestamp expiry) {
    final expiryDate = expiry.toDate();
    final now = DateTime.now();

    final expiryDay = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    );

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    return expiryDay.difference(today).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = user;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        title: Text(
          'FreshTrack',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: getFoodStream(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Something went wrong:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final foods = snapshot.data?.docs ?? [];

          int total = foods.length;
          int fresh = 0;
          int expiring = 0;
          int expired = 0;

          for (final food in foods) {
            final data = food.data();

            final expiry = data['expiryDate'];

            if (expiry is! Timestamp) {
              continue;
            }

            final days = calculateDays(expiry);

            if (days < 0) {
              expired++;
            } else if (days <= 3) {
              expiring++;
            } else {
              fresh++;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // --------------------------------------------------
                // WELCOME CARD
                // --------------------------------------------------

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),

                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff1B5E20),
                        Color(0xff4CAF50),
                      ],
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        '👋 Welcome Back',

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        stream: getUserStream(),

                        builder: (context, snapshot) {
                          String name = 'User';

                          if (snapshot.hasData &&
                              snapshot.data!.exists) {
                            final data = snapshot.data!.data();

                            if (data != null) {
                              final savedName = data['name'];

                              if (savedName != null &&
                                  savedName.toString().trim().isNotEmpty) {
                                name = savedName.toString().trim();
                              }
                            }
                          }

                          // Fallback to Firebase Auth display name.
                          if (name == 'User') {
                            final displayName =
                                FirebaseAuth.instance.currentUser
                                    ?.displayName;

                            if (displayName != null &&
                                displayName.trim().isNotEmpty) {
                              name = displayName.trim();
                            }
                          }

                          return Text(
                            name,

                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Manage your food smarter.\n'
                        'Reduce waste effortlessly.',

                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --------------------------------------------------
                // DASHBOARD
                // --------------------------------------------------

                const Text(
                  'Dashboard',

                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Total',
                        value: '$total',
                        icon: Icons.inventory_2,
                        color: Colors.blue,
                        status: 'Total',
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: StatCard(
                        title: 'Fresh',
                        value: '$fresh',
                        icon: Icons.check_circle,
                        color: Colors.green,
                        status: 'Fresh',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Expiring',
                        value: '$expiring',
                        icon: Icons.warning_amber,
                        color: Colors.orange,
                        status: 'Expiring',
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: StatCard(
                        title: 'Expired',
                        value: '$expired',
                        icon: Icons.cancel,
                        color: Colors.red,
                        status: 'Expired',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // --------------------------------------------------
                // QUICK ACTIONS
                // --------------------------------------------------

                const Text(
                  'Quick Actions',

                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                GridView.count(
                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  crossAxisCount: 2,

                  crossAxisSpacing: 15,

                  mainAxisSpacing: 15,

                  children: [
                    ActionCard(
                      icon: Icons.qr_code_scanner,
                      title: 'Scan Food',
                      page: const ScanScreen(),
                    ),

                    ActionCard(
                      icon: Icons.inventory_2,
                      title: 'Inventory',
                      page: const InventoryScreen(),
                    ),

                    ActionCard(
                      icon: Icons.restaurant_menu,
                      title: 'Recipes',
                      page: RecipeScreen(),
                    ),

                    ActionCard(
                      icon: Icons.bar_chart,
                      title: 'Analytics',
                      page: const AnalyticsScreen(),
                    ),

                    ActionCard(
                      icon: Icons.notifications_active,
                      title: 'Alerts',
                      page: const AlertsScreen(),
                    ),

                    ActionCard(
                      icon: Icons.person,
                      title: 'Profile',
                      page: const ProfileScreen(),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // --------------------------------------------------
                // EXPIRING SOON
                // --------------------------------------------------

                const Text(
                  'Expiring Soon',

                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                _buildExpiringSoon(context),
              ],
            ),
          );
        },
      ),

      // --------------------------------------------------
      // ADD FOOD
      // --------------------------------------------------

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,

        foregroundColor: Colors.white,

        icon: const Icon(Icons.add),

        label: const Text('Add Food'),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddFoodScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpiringSoon(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: getFoodStream(),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox();
        }

        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final foods = snapshot.data!.docs.where((food) {
          final data = food.data();

          final expiry = data['expiryDate'];

          if (expiry is! Timestamp) {
            return false;
          }

          final days = calculateDays(expiry);

          return days >= 0 && days <= 3;
        }).toList();

        // --------------------------------------------------
        // NOTHING EXPIRING
        // --------------------------------------------------

        if (foods.isEmpty) {
          return Container(
            width: double.infinity,

            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,

              borderRadius: BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,

                  backgroundColor:
                      Colors.green.withValues(alpha: 0.15),

                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 15),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        'All Good! 🎉',

                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'No food is expiring soon.',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // --------------------------------------------------
        // SHOW EXPIRING FOOD
        // --------------------------------------------------

        return Column(
          children: foods.take(3).map((food) {
            final data = food.data();

            final expiry = data['expiryDate'] as Timestamp;

            final days = calculateDays(expiry);

            final name =
                data['name']?.toString() ?? 'Food';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),

              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,

                borderRadius: BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.orange.withValues(alpha: 0.15),

                    blurRadius: 8,

                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Colors.orange.withValues(alpha: 0.15),

                    child: const Icon(
                      Icons.warning,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          name,

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          days == 0
                              ? 'Expires today'
                              : 'Expires in $days days',

                          style: const TextStyle(
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ==========================================================
// STAT CARD
// ==========================================================

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String status;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodStatusScreen(
              status: status,
            ),
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,

          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),

              blurRadius: 12,

              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Column(
          children: [
            CircleAvatar(
              radius: 28,

              backgroundColor:
                  color.withValues(alpha: 0.15),

              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              value,

              style: TextStyle(
                fontSize: 26,

                fontWeight: FontWeight.bold,

                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color,
              ),
            ),

            Text(title),

            const SizedBox(height: 5),

            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// ACTION CARD
// ==========================================================

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget page;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,

          borderRadius: BorderRadius.circular(25),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),

              blurRadius: 10,

              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            CircleAvatar(
              radius: 30,

              backgroundColor:
                  Colors.green.withValues(alpha: 0.15),

              child: Icon(
                icon,
                color: Colors.green,
                size: 32,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              title,

              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}