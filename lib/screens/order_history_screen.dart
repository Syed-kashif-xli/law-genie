import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/order_model.dart';
import '../features/certified_copy/certified_copy_token_page.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _ordersFuture = _firestoreService.getUserOrders(user.uid);
    } else {
      _ordersFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order History',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading orders',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.receipt_item,
                      size: 64, color: Colors.white.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    // Determine order type and icon based on details or token format
    String title = 'Order #${order.token}';
    IconData icon = Iconsax.receipt;
    Color color = const Color(0xFF02F1C3);

    // Simple logic to guess type (can be improved if we store 'type' in OrderModel)
    if (order.token.startsWith('SUB')) {
      title = 'Subscription';
      icon = Iconsax.crown;
      color = const Color(0xFFFFD700);
    } else if (order.token.startsWith('MP') || order.token.startsWith('DL')) {
      title = 'Certified Copy Request';
      icon = Iconsax.document_copy;
      color = const Color(0xFF02F1C3);
    }

    final amount = order.details['amount'] ?? 0;
    final formattedDate =
        DateFormat('MMM d, yyyy • h:mm a').format(order.createdAt);

    return GestureDetector(
      onTap: () {
        // Navigate to tracking page for certified copies
        // For subscriptions, we might want a different page, but for now we'll use the token page
        // or restrict it. Assuming user wants to track copies.
        if (!order.token.startsWith('SUB')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CertifiedCopyTokenPage(
                token: order.token,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151038),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: _getStatusColor(order.status)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: _getStatusColor(order.status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (amount > 0)
                        Text(
                          '₹$amount',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return Colors.blue;
      case 'searching':
        return Colors.orange;
      case 'found':
        return Colors.green;
      case 'not_found':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
