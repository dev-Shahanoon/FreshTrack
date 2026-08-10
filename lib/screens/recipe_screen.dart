import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/recipe_service.dart';

class RecipeScreen extends StatelessWidget {
  RecipeScreen({super.key});

  final FirestoreService firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Suggestions"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.getFoods(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          List<String> inventory = docs
              .map((doc) => doc["name"].toString().toLowerCase())
              .toList();

          final matches = RecipeService.findRecipes(inventory);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ingredients from Inventory",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                inventory.isEmpty
                    ? const Text(
                        "No food items found.",
                        style: TextStyle(color: Colors.grey),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: inventory.map((item) {
                          return Chip(
                            backgroundColor: Colors.green.shade100,
                            label: Text(
                              item.toUpperCase(),
                            ),
                          );
                        }).toList(),
                      ),

                const SizedBox(height: 25),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Suggested Recipes (${matches.length})",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Expanded(
                  child: matches.isEmpty
                      ? const Center(
                          child: Text(
                            "No matching recipes found.",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: matches.length,
                          itemBuilder: (context, index) {
                            final match = matches[index];

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(
                                    Icons.restaurant_menu,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  match.recipe.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "${match.recipe.category} • ${match.recipe.time} mins\n"
                                  "Match: ${match.percentage.toStringAsFixed(0)}%",
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                ),
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) {
                                      return Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                match.recipe.name,
                                                style: const TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              Text(
                                                  "Category: ${match.recipe.category}"),
                                              Text(
                                                  "Time: ${match.recipe.time} mins"),
                                              Text(
                                                  "Difficulty: ${match.recipe.difficulty}"),

                                              const SizedBox(height: 25),

                                              const Text(
                                                "Ingredients",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(height: 10),

                                              ...match.recipe.ingredients.map(
                                                (ingredient) => ListTile(
                                                  leading: const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                  ),
                                                  title: Text(ingredient),
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              const Text(
                                                "Steps",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(height: 10),

                                              ...match.recipe.steps
                                                  .asMap()
                                                  .entries
                                                  .map(
                                                    (step) => ListTile(
                                                      leading: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.green,
                                                        child: Text(
                                                          "${step.key + 1}",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      title:
                                                          Text(step.value),
                                                    ),
                                                  ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}