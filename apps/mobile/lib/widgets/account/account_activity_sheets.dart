import 'package:flutter/material.dart';
import '../../theme_tokens.dart';
import '../payment_proof_sheet.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../services/firestore_service.dart';
import '../../screens/service_request_screen.dart';
import '../svc_snackbar.dart';

class AccountActivitySheets {
  static String formatCurrency(int amount) {
    return 'Rs. ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  static Widget buildSheetHandle() {
    return Container(
      width: 38,
      height: 4,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  static void openOrdersModal({
    required BuildContext context,
    required UserModel? user,
    required void Function(BuildContext, String) showAuthRequiredPrompt,
  }) {
    if (user == null) {
      showAuthRequiredPrompt(context, 'view your active equipment orders');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                buildSheetHandle(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: Color(0xFFF97316), size: 22),
                      const SizedBox(width: 10),
                      const Text(
                        'Orders & Shipments',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: buildOrdersList(user, scrollController)),
              ],
            );
          },
        );
      },
    );
  }

  static void openServiceRequestsModal({
    required BuildContext context,
    required UserModel? user,
    required AppState appState,
    required void Function(BuildContext, String) showAuthRequiredPrompt,
  }) {
    if (user == null) {
      showAuthRequiredPrompt(context, 'check hardware repair status and diagnostic quotes');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                buildSheetHandle(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.build_outlined, color: Color(0xFFF97316), size: 22),
                      const SizedBox(width: 10),
                      const Text(
                        'Service Requests & Repairs',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: buildRepairsList(context, user, scrollController, appState)),
              ],
            );
          },
        );
      },
    );
  }

  static void openQuotationsModal({
    required BuildContext context,
    required UserModel? user,
    required void Function(BuildContext, String) showAuthRequiredPrompt,
  }) {
    if (user == null) {
      showAuthRequiredPrompt(context, 'review quotations and procurement items');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                buildSheetHandle(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, color: Color(0xFFF97316), size: 22),
                      const SizedBox(width: 10),
                      const Text(
                        'Quotations & Sourcing',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: buildSourcingList(user, scrollController)),
              ],
            );
          },
        );
      },
    );
  }

  static void openActivityModal({
    required BuildContext context,
    required UserModel? user,
    required AppState appState,
    int initialTab = 0,
    required void Function(BuildContext, String) showAuthRequiredPrompt,
  }) {
    if (user == null) {
      showAuthRequiredPrompt(context, 'view all your activity');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DefaultTabController(
          length: 3,
          initialIndex: initialTab,
          child: DraggableScrollableSheet(
            initialChildSize: 0.88,
            minChildSize: 0.5,
            maxChildSize: 0.96,
            expand: false,
            builder: (_, scrollController) {
              return Column(
                children: [
                  buildSheetHandle(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      children: [
                        const Text(
                          'My Activity',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const TabBar(
                    labelColor: Color(0xFFF97316),
                    unselectedLabelColor: Color(0xFF64748B),
                    indicatorColor: Color(0xFFF97316),
                    indicatorWeight: 3,
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: [
                      Tab(text: 'Orders'),
                      Tab(text: 'Repairs'),
                      Tab(text: 'Sourcing'),
                    ],
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildOrdersList(user, scrollController),
                        buildRepairsList(context, user, scrollController, appState),
                        buildSourcingList(user, scrollController),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  static Widget buildOrdersList(UserModel user, ScrollController scrollController) {
    return StreamBuilder<List<OrderModel>>(
      stream: FirestoreService().streamOrders(customerId: user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, size: 26, color: Color(0xFFF97316)),
                  ),
                  const SizedBox(height: 14),
                  const Text('No Orders Placed Yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text(
                    'Order cameras, certified pre-owned units, and accessories with nationwide Nepal courier delivery.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final itemsText = order.itemsSummary.isNotEmpty ? order.itemsSummary : 'Equipment Order';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: order.orderStatus == 'DELIVERED'
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            order.orderStatus.replaceAll('_', ' '),
                            style: TextStyle(
                              color: order.orderStatus == 'DELIVERED'
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB45309),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(itemsText, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${formatCurrency(order.total)} (${order.paymentMethod})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFF97316)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Deliver to: ${order.streetAddress.isNotEmpty ? '${order.streetAddress}, ${order.city}' : order.city}\nPayment: ${order.paymentMethod == 'COD' ? 'Cash on delivery' : 'Bank transfer'} · ${order.paymentStatus.replaceAll('_', ' ').toLowerCase()}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                      ),
                    ),
                    if (order.paymentMethod == 'BANK_TRANSFER' && order.orderStatus == 'PENDING_PAYMENT') ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => showPaymentProofSheet(
                            context,
                            orderId: order.id,
                            customerId: order.customerId,
                            amount: order.total,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SvcColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Submit payment', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget buildRepairsList(
    BuildContext context,
    UserModel user,
    ScrollController scrollController,
    AppState appState,
  ) {
    return StreamBuilder<List<ServiceRequestModel>>(
      stream: FirestoreService().streamServiceRequests(customerId: user.id),
      builder: (context, reqSnapshot) {
        if (reqSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = reqSnapshot.data ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: const Icon(Icons.build_outlined, size: 26, color: Color(0xFFF97316)),
                  ),
                  const SizedBox(height: 14),
                  const Text('No Active Repairs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text(
                    'Book a camera, lens, drone or CCTV repair with free physical inspection in Janakpur.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ServiceRequestScreen(appState: appState)),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Book Free Inspection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return StreamBuilder<List<ServiceQuoteModel>>(
          stream: FirestoreService().streamQuotes(customerId: user.id),
          builder: (context, quoteSnapshot) {
            final quotes = quoteSnapshot.data ?? [];

            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                ServiceQuoteModel? quote;
                for (final q in quotes) {
                  if (q.serviceRequestId == req.id || q.id == req.quoteId) {
                    quote = q;
                    break;
                  }
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ref #${req.id.length > 8 ? req.id.substring(0, 8).toUpperCase() : req.id.toUpperCase()}',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: req.status == 'COMPLETED'
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                req.status.replaceAll('_', ' '),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: req.status == 'COMPLETED'
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(req.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          '${req.streetAddress}, ${req.city} • Slot: ${req.preferredTimeSlot}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        if (req.assignedTechnicianName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Assigned Tech: ${req.assignedTechnicianName} (Inspection Fee: Rs. 0)',
                            style: const TextStyle(fontSize: 12, color: Color(0xFFC2570D), fontWeight: FontWeight.w500),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          req.description,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),

                        if (quote != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFFEDD5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Diagnostic Quotation',
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFC2570D)),
                                    ),
                                    Text(
                                      formatCurrency(quote.total),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Labour: ${formatCurrency(quote.labourTotal)} | Parts: ${formatCurrency(quote.partsTotal)}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                                ),
                                Text(
                                  'Warranty: ${quote.warrantyTerms}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF15803D), fontWeight: FontWeight.w600),
                                ),
                                if (quote.notes.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Notes: ${quote.notes}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                                const SizedBox(height: 10),

                                if (quote.status == 'SENT')
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            await FirestoreService().updateQuoteStatus(quote!.id, 'ACCEPTED');
                                            if (context.mounted) {
                                              SvcSnackbar.show(context, 'Quote Approved! Technician will proceed.', type: SnackType.success);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFF97316),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                          child: const Text('Approve Quote', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            await FirestoreService().updateQuoteStatus(quote!.id, 'REJECTED');
                                            if (context.mounted) {
                                              SvcSnackbar.show(context, 'Quote Declined.', type: SnackType.info);
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFFDC2626),
                                            side: const BorderSide(color: Color(0xFFDC2626)),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                          child: const Text('Decline', style: TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                    ],
                                  )
                                else if (quote.status == 'ACCEPTED')
                                  const Row(
                                    children: [
                                      Icon(Icons.check_circle, size: 16, color: Color(0xFF16A34A)),
                                      SizedBox(width: 6),
                                      Text('Approved. Repair underway.', style: TextStyle(fontSize: 12, color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                else
                                  const Text('Declined. No repair carried out.', style: TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  static Widget buildSourcingList(UserModel user, ScrollController scrollController) {
    return StreamBuilder<List<SourceRequestModel>>(
      stream: FirestoreService().streamSourceRequests(customerId: user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: const Icon(Icons.description_outlined, size: 26, color: Color(0xFFF97316)),
                  ),
                  const SizedBox(height: 14),
                  const Text('No Sourcing Quotes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text(
                    'Request quotation for rare lenses, camera bodies or cinema gear not available in standard catalog.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sourcing #${req.id.length > 8 ? req.id.substring(0, 8).toUpperCase() : req.id.toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: req.status == 'COMPLETED'
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            req.status.replaceAll('_', ' '),
                            style: TextStyle(
                              color: req.status == 'COMPLETED'
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB45309),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(req.itemDescription, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    if (req.budget.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Target Budget: ${req.budget}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFFF97316), fontWeight: FontWeight.w600),
                      ),
                    ],
                    if (req.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(req.notes, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
