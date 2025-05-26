import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_app/delivery.dart';
import 'package:coffee_app/models/coffee_model.dart';
import 'package:flutter/material.dart';

const Color kCoffee = Color(0xFFC67C4E); // brand colour
const double kRadius = 14;

class OrderPage extends StatefulWidget {
  final CoffeeModel coffee;
  final String size;
  
  const OrderPage({super.key, required this.coffee, required this.size});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool deliver = true;
  int qty = 1;
  bool hasDiscount = false;
  double originalDeliveryFee = 2.0;
  double discountedDeliveryFee = 1.0;
  
  // Calculate size-adjusted base price
  double get basePrice {
    switch (widget.size.toLowerCase()) {
      case 's':
        return widget.coffee.price - 1.0;
      case 'l':
        return widget.coffee.price + 1.0;
      case 'm':
      default:
        return widget.coffee.price;
    }
  }
  
  double get totalPrice => basePrice * qty;
  double get deliveryFee => deliver 
      ? (hasDiscount ? discountedDeliveryFee : originalDeliveryFee)
      : 0.0;
  double get grandTotal => totalPrice + deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: const Text('Order',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery toggle
              _buildDeliveryToggle(),
              const SizedBox(height: 24),

              // Delivery address
              _sectionHeader('Delivery Address'),
              const SizedBox(height: 12),
              _buildAddressCard(),
              const SizedBox(height: 24),

              // Coffee item
              _buildCoffeeItem(),
              const SizedBox(height: 24),

              // Discount banner
              _buildDiscountTile(),
              const SizedBox(height: 24),

              // Payment summary
              _sectionHeader('Payment Summary'),
              const SizedBox(height: 16),
              _paymentRow('Base Price', '\$${widget.coffee.price.toStringAsFixed(2)}'),
              _paymentRow('Size Adjustment', 
                widget.size == 'M' 
                  ? 'Standard (M)'
                  : widget.size == 'S'
                    ? '-\$1.00 (S)'
                    : '+\$1.00 (L)'
              ),
              _paymentRow('Item Total', '\$${basePrice.toStringAsFixed(2)}'),
              _paymentRow('Quantity', '$qty'),
              _paymentRow('Subtotal', '\$${totalPrice.toStringAsFixed(2)}'),
              _paymentRow(
                'Delivery Fee', 
                '\$${originalDeliveryFee.toStringAsFixed(2)}', 
                discount: hasDiscount ? '\$${discountedDeliveryFee.toStringAsFixed(2)}' : null,
              ),
              Divider(color: Colors.grey.shade300, height: 32),
              _paymentRow('Total', '\$${grandTotal.toStringAsFixed(2)}', isTotal: true),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPaymentMethod(),            // wallet row (no border)
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _placeOrder(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kCoffee,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kRadius),
                      ),
                    ),
                    child: const Text('Order', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showDiscountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Set background to white
        title: const Text('Available Discounts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.local_offer, color: Colors.green),
              title: const Text('Delivery Discount'),
              subtitle: const Text('\$1 off delivery fee'),
              onTap: () {
                setState(() {
                  hasDiscount = true;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.red),
              title: const Text('Remove Discount'),
              subtitle: const Text('Pay full delivery fee'),
              onTap: () {
                setState(() {
                  hasDiscount = false;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: kCoffee, // Use kCoffee color for the text
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  //  Widget helpers (keep all your existing helper methods)
  // ========================================================================
  
  Widget _buildDeliveryToggle() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Row(
        children: [
          _toggleChip(title: 'Deliver', active: deliver, onTap: () {
            setState(() => deliver = true);
          }),
          _toggleChip(title: 'Pick Up', active: !deliver, onTap: () {
            setState(() => deliver = false);
          }),
        ],
      ),
    );
  }

  Expanded _toggleChip(
      {required String title, required bool active, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: active ? kCoffee : Colors.transparent,
            borderRadius: BorderRadius.circular(kRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('3, Jalan PJS 11/15',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Bandar Sunway, 47500 Petaling Jaya, Selangor',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          Row(
            children: [
              _smallOutlineButton('Edit Address', onTap: () {}),
              const SizedBox(width: 12),
              _smallOutlineButton('Add Note', onTap: () {}),
            ],
          )
        ],
      ),
    );
  }

  Widget _smallOutlineButton(String text, {required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius)),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(text),
    );
  }

  Widget _buildCoffeeItem() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              widget.coffee.img,
              height: 48,
              width: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.coffee.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600, 
                      fontSize: 15
                    )),
                const SizedBox(height: 2),
                Text('${widget.coffee.sub} (${widget.size.toUpperCase()})',
                    style: TextStyle(
                      fontSize: 12, 
                      color: Colors.grey
                    )),
              ],
            ),
          ),
          _qtyButton(Icons.remove, onTap: () {
            if (qty > 1) setState(() => qty--);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('$qty',
                style: const TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 15
                )),
          ),
          _qtyButton(Icons.add, onTap: () {
            setState(() => qty++);
          }),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildDiscountTile() {
    return GestureDetector(
      onTap: () => _showDiscountDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(kRadius),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: kCoffee.withOpacity(.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_offer_rounded,
                size: 16, 
                color: kCoffee,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasDiscount ? '1 Discount Applied' : 'Select Discount',
                style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _paymentRow(String label, String value,
      {String? discount, bool isTotal = false}) {
    final baseStyle = TextStyle(
        fontSize: 14, 
        fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: baseStyle),
          discount == null
              ? Text(value, style: baseStyle)
              : Row(
                  children: [
                    Text(value,
                        style: baseStyle.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        )),
                    const SizedBox(width: 6),
                    Text(discount, style: baseStyle),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Row(
      children: [
        const Icon(Icons.account_balance_wallet_outlined, size: 20),
        const SizedBox(width: 12),
        const Expanded(
          child: Text('Cash/Wallet',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        Text('\$${grandTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
      ],
    );
  }

  Widget _sectionHeader(String text) => Text(text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));

  Future<void> _placeOrder() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFC67C4E),
          ),
        ),
      );

      // Get current user ID (you'll need to implement your auth system)
      final userId = 'current_user_id';

      // Create order data
      final orderData = {
        'userId': userId,
        'coffeeId': widget.coffee.id,
        'coffeeName': widget.coffee.name,
        'size': widget.size,
        'quantity': qty,
        'basePrice': widget.coffee.price,
        'sizeAdjustment': widget.size == 's' ? -1.0 : widget.size == 'l' ? 1.0 : 0.0,
        'itemTotal': basePrice,
        'subtotal': totalPrice,
        'deliveryFee': deliveryFee,
        'discountApplied': hasDiscount,
        'originalDeliveryFee': originalDeliveryFee,
        'discountedDeliveryFee': hasDiscount ? discountedDeliveryFee : null,
        'grandTotal': grandTotal,
        'deliveryMethod': deliver ? 'delivery' : 'pickup',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('coffee_orders').add(orderData);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order placed successfully!'),
          backgroundColor: const Color(0xFF4CAF50), // Success green
          behavior: SnackBarBehavior.floating,      // Make it float
          margin: const EdgeInsets.all(16),         // Optional: adds spacing around it
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),     // Optional: display time
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const DeliveryTrackingPage(),
        ),
      );
    } catch (e) {
      // Close loading indicator if still open
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: ${e.toString()}')),
      );
    }
  }
}