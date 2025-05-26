import 'package:coffee_app/order.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:coffee_app/models/coffee_model.dart';

const Color kCoffee = Color(0xFFC67C4E);
const double kRadius = 20;              

class CoffeeDetailPage extends StatefulWidget {
  final CoffeeModel coffee;

  const CoffeeDetailPage({super.key, required this.coffee});

  @override
  State<CoffeeDetailPage> createState() => _CoffeeDetailPageState();
}

class _CoffeeDetailPageState extends State<CoffeeDetailPage> {
  String selectedSize = 'M';
  bool _showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    final coffee = widget.coffee;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ---------- HEADER -------------------------------------------
              SliverAppBar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Detail',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  )
                ],
              ),

              // ---------- CONTENT -----------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- Coffee IMAGE ----------------------------
                      ClipRRect(
                        borderRadius: BorderRadius.circular(kRadius),
                        child: AspectRatio(
                          aspectRatio: 1.22,
                          child: Image.asset(coffee.img, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ---------- TITLE + ACTION ICONS --------------------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(coffee.name,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text('Ice/Hot',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _roundedIcon(Icons.local_fire_department_rounded),
                              const SizedBox(width: 10),
                              _roundedIcon(Icons.coffee_rounded),
                              const SizedBox(width: 10),
                              _roundedIcon(Icons.local_bar_rounded),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ---------- RATING ----------------------------------
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 20, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${coffee.rating}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text('  (${(coffee.rating * 50).toInt()})',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade300, height: 1),
                      const SizedBox(height: 20),

                      // ---------- DESCRIPTION -----------------------------
                      const Text('Description',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final textSpan = TextSpan(
                            text: coffee.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          );
                          
                          final textPainter = TextPainter(
                            text: textSpan,
                            maxLines: 3,
                            textDirection: TextDirection.ltr,
                          );
                          textPainter.layout(maxWidth: constraints.maxWidth);
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: _showFullDescription
                                          ? coffee.description
                                          : '${coffee.description.substring(0, coffee.description.length > 100 ? 100 : coffee.description.length)}... ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (!_showFullDescription && coffee.description.length > 100)
                                      TextSpan(
                                        text: 'Read More',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: kCoffee,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => setState(() => _showFullDescription = true),
                                      ),
                                    if (_showFullDescription && coffee.description.length > 100)
                                      TextSpan(
                                        text: ' Read Less',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: kCoffee,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => setState(() => _showFullDescription = false),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // ---------- SIZE ------------------------------------
                      const Text('Size',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ['S', 'M', 'L']
                            .map((s) => _sizeChip(s, selected: selectedSize == s))
                            .toList(),
                      ),
                      // Extra space for the fixed bottom button
                      SizedBox(height: screenHeight * 0.15),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ---------- FIXED BOTTOM PRICE & BUY BUTTON ---------------------
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      // Price Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade500)),
                          const SizedBox(height: 4),
                          Text(
                            '\$ ${_getPriceBySize().toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Buy Button
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 65,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderPage(coffee: coffee, size: selectedSize),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kCoffee,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Buy Now',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getPriceBySize() {
    double basePrice = widget.coffee.price;
    if (selectedSize == 'S') {
      return basePrice - 1;
    } else if (selectedSize == 'L') {
      return basePrice + 1;
    }
    return basePrice; // default is M
  }

  // =================== helpers ===========================================
  Widget _roundedIcon(IconData icon) => Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: Colors.grey.shade700),
      );

  Widget _sizeChip(String s, {required bool selected}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () => setState(() => selectedSize = s),
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selected ? kCoffee : Colors.grey.shade300, width: 1.4),
              color: selected ? kCoffee.withOpacity(.08) : Colors.transparent,
            ),
            child: Text(
              s,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? kCoffee : Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}