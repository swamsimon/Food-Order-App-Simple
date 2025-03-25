import 'package:flutter/material.dart';
import 'package:foodorderapplication/cart.dart';
import 'package:foodorderapplication/models/foodcardmodel.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = "Ice-cream";
  var storage = GetStorage();
  var cartItems = <FoodCard>[];

  Future<List<FoodCard>> fetchFoodItems() async {
    try {
      final response = await Supabase.instance.client.from('foods').select();
      return response.map<FoodCard>((item) => FoodCard.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  void saveCartToStorage() {
    List<Map<String, dynamic>> cartData =
        cartItems
            .map(
              (item) => item.toMap(),
            ) // Assuming you have a toJson method in CartItem
            .toList();
    storage.write('cart', cartData); // Save the cart to storage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Colors.white,
        shadowColor: Colors.grey,
        title: const Text(
          'Hello, User!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return FoodCardPage(
                      onCartCleared: () {
                        setState(() {
                          cartItems.clear();
                        });
                      },
                    );
                  },
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delicious Food",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Discover and enjoy great food",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Category Selection Row
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    ["Ice-cream", "Burger", "Salad", "Pizza"]
                        .map(
                          (category) => GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                            child: categoryCard(
                              category,
                              selectedCategory == category,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),

            Expanded(
              child: FutureBuilder<List<FoodCard>>(
                future: fetchFoodItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.data!.isEmpty) {
                    return const Center(child: Text('No food items found.'));
                  }

                  final foodItems = snapshot.data!;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Popular Foods",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Horizontal List
                        SizedBox(
                          height: 350, // Adjust based on your card height
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: foodItems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: SizedBox(
                                  width: 220, // Adjust width for better spacing
                                  child: _buildFoodCard(foodItems[index]),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          "New Arrived Foods",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Vertical List
                        SizedBox(
                          height: 350, // Adjust based on your card height
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: foodItems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: SizedBox(
                                  width: 220, // Adjust width for better spacing
                                  child: _buildFoodCard(foodItems[index]),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryCard(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepOrange : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFoodCard(FoodCard food) {
    return GestureDetector(
      onTap: () {
        setState(() {
          cartItems.add(food);
        });

        saveCartToStorage();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Food added to cart successfully!")),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(food.imageUrl, height: 200, fit: BoxFit.fill),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(Icons.favorite, color: Colors.red, size: 28),
                      onPressed: () {},
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${food.rating}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                food.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                food.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '\$${food.price}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      food.flavor,
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.deepOrange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
