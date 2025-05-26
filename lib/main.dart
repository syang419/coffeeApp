import 'package:coffee_app/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //await addCoffeesToFirestore();
  runApp(const CoffeeBlissApp());
}


// final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Future<void> addCoffeesToFirestore() async {
//   try {
//     // Create a "coffees" collection
//     CollectionReference coffees = _firestore.collection('coffees');
    
//     // Add your coffee items
//     await coffees.add({
//       'name': 'Americano',
//       'sub': 'Americano',
//       'price': 5.53,
//       'rating': 4.8,
//       'img': 'assets/mock/mocha.jpg',
//       'category': 'Americano',
//       'createdAt': FieldValue.serverTimestamp(),
//     });
    
//     print('Coffees added successfully');
//   } catch (e) {
//     print('Error adding coffees: $e');
//   }
// }

class CoffeeBlissApp extends StatelessWidget {
  const CoffeeBlissApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Bliss',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const CoffeeBlissWelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CoffeeBlissWelcomeScreen extends StatelessWidget {
  const CoffeeBlissWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4), 
                BlendMode.darken,
              ),
              child: Image.asset(
                'assets/coffee_background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Centered bottom content
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Fall in Love with\nCoffee in Blissful\nDelight!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome to our cozy coffee corner, where\n'
                        'every cup is a delightful for you.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BottomNavigationScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC67C4E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
