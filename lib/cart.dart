import 'package:flutter/material.dart';
import 'package:foodorderapplication/models/foodcardmodel.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoodCardPage extends StatefulWidget {
  final VoidCallback onCartCleared;
  const FoodCardPage({super.key, required this.onCartCleared});

  @override
  State<FoodCardPage> createState() => _FoodCardPageState();
}

class _FoodCardPageState extends State<FoodCardPage> {
  var storage = GetStorage();
  var foodItems = <FoodCard>[];

  @override
  void initState() {
    
    super.initState();
    loadCartFromStorage();
  }

  void loadCartFromStorage() {
    List<dynamic>? cartData = storage.read('cart'); // Read the stored cart data

    if (cartData != null) {
      setState(() {
        foodItems = cartData.map((item) => FoodCard.fromMap(item)).toList();
      });
    }
  }

  Future<void> postCartItemsToSupabase() async {
    try {
      if (foodItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sorry, Cart is Empty. Please add items first"),
          ),
        );
        return;
      }

      // Convert cart items to a list of maps
      List<Map<String, dynamic>> cartData =
          foodItems.map((item) => item.toMap()).toList();

      // Insert cart items into the Supabase database
      await Supabase.instance.client.from('orders').insert({
        'items': cartData, // items field is JSONB in Supabase
      });

      // Clear local cart after successful post
      setState(() {
        foodItems.clear();
      });

      // Remove from local storage
      storage.remove('cart');

      // Show success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Congrats, Your Order has been uploaded successfully! Check your database now!",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to post cart items.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  foodItems.clear();
                });
                storage.remove('cart');
                widget.onCartCleared(); // Notify HomePage to clear cartItems
              },
              child: Row(
                children: [
                  Text("Clear Cart"),
                  SizedBox(width: 4),
                  Icon(Icons.delete, color: Colors.deepOrange),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          return _buildCartItem(foodItems[index], index);
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            postCartItemsToSupabase();
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: Text("Checkout"),
        ),
      ),
    );
  }

  Widget _buildCartItem(FoodCard food, int index) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                food.imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${food.price}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
