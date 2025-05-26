import 'package:coffee_app/coffee_detail.dart';
import 'package:coffee_app/order_history.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_app/models/coffee_model.dart';

class CoffeeShopApp extends StatelessWidget {
  const CoffeeShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Bliss',
      theme: ThemeData(
        primaryColor: const Color(0xFFC67C4E),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor(0xFFC67C4E, {
            50: Color(0xFFF8EDE8),
            100: Color(0xFFF1DAD1),
            200: Color(0xFFE3B5A3),
            300: Color(0xFFD49075),
            400: Color(0xFFC67C4E),
            500: Color(0xFFB86737),
            600: Color(0xFFA05220),
            700: Color(0xFF883D09),
            800: Color(0xFF702800),
            900: Color(0xFF581300),
          }),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFC67C4E)),
          ),
          focusColor: Color(0xFFC67C4E),
        ),
      ),
      home: const BottomNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const CoffeeShopHomePage(),
    const Scaffold(body: Center(child: Text('Menu Page'))), 
    const OrderHistoryPage(),
    const Scaffold(body: Center(child: Text('Profile Page'))), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -3), 
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent, 
          elevation: 0, 
          selectedItemColor: const Color(0xFFC67C4E),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

const Color kCoffee = Color(0xFFC67C4E);         
const double kRadius = 16;                     
const EdgeInsets kPagePadding = EdgeInsets.all(16);

class CoffeeShopHomePage extends StatefulWidget {
  const CoffeeShopHomePage({super.key});

  @override
  State<CoffeeShopHomePage> createState() => _CoffeeShopHomePageState();
}

class _CoffeeShopHomePageState extends State<CoffeeShopHomePage> {
  final List<String> categories = [
    'All Coffee',
    'Machiato',
    'Latte',
    'Americano',
    'Espresso',
  ];
  int selectedCategory = 0;
  List<CoffeeModel> coffees = [];
  bool isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchCoffees();
  }

  Future<void> _fetchCoffees() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('coffees')
          .get();

      List<CoffeeModel> loadedCoffees = querySnapshot.docs
          .map((doc) => CoffeeModel.fromFirestore(doc))
          .toList();

      setState(() {
        coffees = loadedCoffees;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching coffees: $e')),
      );
    }
  }

  List<CoffeeModel> get filteredCoffees {
    var filtered = coffees;
    
    if (selectedCategory != 0) {
      filtered = filtered.where((coffee) => 
        coffee.category == categories[selectedCategory]
      ).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((coffee) {
        final nameWords = coffee.name.toLowerCase().split(' ');
        final subWords = coffee.sub.toLowerCase().split(' ');
        final queryWords = _searchQuery.toLowerCase().split(' ');
        
        return queryWords.every((queryWord) =>
          nameWords.any((nameWord) => nameWord.contains(queryWord)) ||
          subWords.any((subWord) => subWord.contains(queryWord))
        );
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 240, 
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 36, 33, 32),
                ),
                child: Padding(
                  padding: kPagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationRow(),
                      const SizedBox(height: 20),
                      _buildSearchAndFilter(),
                    ],
                  ),
                ),
              ),
              
              Padding(
                padding: kPagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -80),
                      child: _buildPromoCard(),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: _buildCategoryRow(),
                    ),
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFC67C4E), 
                              strokeWidth: 2.0,
                            ),
                          )
                        : filteredCoffees.isEmpty
                            ? const Center(child: Text('No coffees found'))
                            : _buildCoffeeGrid(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------- S E C T I O N S ----------------------------------
  Widget _buildLocationRow() {
    return Row(
      children: [
        const Icon(Icons.location_on_rounded, color: kCoffee, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Location',
                style: TextStyle(fontSize: 11, color: Color.fromARGB(255, 216, 216, 216))),
            Row(
              children: [
                Text('Petaling Jaya, Selangor',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
              ],
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          color: Colors.white,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(kRadius),
            ),
            child: TextField(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 14),
                border: InputBorder.none,
                hintText: 'Search coffee',
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: kCoffee,
            borderRadius: BorderRadius.circular(kRadius),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
            onPressed: () {
              // todo
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        image: const DecorationImage(
          image: AssetImage('assets/mock/promo_banner.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // overlay gradient
          Positioned.fill(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kRadius),
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(.7), Colors.transparent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _PromoBadge(),
                SizedBox(height: 4),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Buy one get\none FREE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () => setState(() => selectedCategory = i),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: i == selectedCategory ? kCoffee : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              categories[i],
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    i == selectedCategory ? FontWeight.w600 : FontWeight.normal,
                color: i == selectedCategory ? Colors.white : Colors.grey[800],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoffeeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredCoffees.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (ctx, i) {
        final coffee = filteredCoffees[i];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CoffeeDetailPage(coffee: coffee),
              ),
            );
          },
          child: _CoffeeCard(coffee: coffee),
        );
      },
    );
  }
}

class _PromoBadge extends StatelessWidget {
  const _PromoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kCoffee,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('Promo',
          style: TextStyle(color: Colors.white, fontSize: 11)),
    );
  }
}

class _CoffeeCard extends StatelessWidget {
  const _CoffeeCard({required this.coffee});

  final CoffeeModel coffee;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(kRadius)),
                  child: Image.asset(coffee.img,
                      width: double.infinity, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coffee.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(coffee.sub,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$ ${coffee.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            color: kCoffee,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add,
                              size: 18, color: Colors.white),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // rating badge -----------------------------------------------------
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star,
                      size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(coffee.rating.toString(),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}