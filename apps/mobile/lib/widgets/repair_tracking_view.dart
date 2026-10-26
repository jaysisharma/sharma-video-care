import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../config/business_contact.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../services/guest_repair_tickets.dart';
import '../utils/format.dart';
import 'svc_snackbar.dart';

class RepairTrackingView extends StatefulWidget {
  final AppState appState;
  final VoidCallback onBookNow;

  const RepairTrackingView({
    super.key,
    required this.appState,
    required this.onBookNow,
  });

  @override
  State<RepairTrackingView> createState() => _RepairTrackingViewState();
}

bool _isCancelled(String status) {
  final s = status.toUpperCase();
  return s.contains('CANCEL') || s.contains('REJECT');
}

class _RepairTrackingViewState extends State<RepairTrackingView> {
  final _searchController = TextEditingController();
  ServiceRequestModel? _searchedTicket;
  bool _searching = false;
  String? _searchError;

  // Created once per signed-in user so rebuilds don't resubscribe
  String? _streamsUserId;
  Stream<List<ServiceRequestModel>>? _requestsStream;
  Stream<List<ServiceQuoteModel>>? _quotesStream;

  // Repairs booked on this phone without an account
  late Future<List<ServiceRequestModel>> _guestTickets;

  @override
  void initState() {
    super.initState();
    _guestTickets = _loadGuestTickets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _ensureStreams(String userId) {
    if (_streamsUserId == userId) return;
    _streamsUserId = userId;
    _requestsStream = FirestoreService().streamCustomerRequests(userId);
    _quotesStream = FirestoreService().streamCustomerQuotes(userId);
  }

  Future<List<ServiceRequestModel>> _loadGuestTickets() async {
    final ids = await GuestRepairTickets.load();
    final tickets = await Future.wait(ids.map((id) async {
      try {
        return await FirestoreService().getServiceRequest(id);
      } catch (_) {
        return null;
      }
    }));
    return tickets.whereType<ServiceRequestModel>().toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _lookupTicket() async {
    final query = _searchController.text.trim().replaceFirst(RegExp(r'^#'), '');
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _searching = true;
      _searchError = null;
      _searchedTicket = null;
    });

    String? error;
    ServiceRequestModel? found;
    try {
      found = await FirestoreService().getServiceRequest(query);
      if (found == null) error = 'No repair found with ticket number "$query". Please check the number and try again.';
    } on FirebaseException catch (e) {
      error = e.code == 'permission-denied'
          ? 'No repair found with ticket number "$query". Please check the number and try again.'
          : 'Couldn\'t look up your ticket. Check your internet connection and try again.';
    } catch (_) {
      // e.g. characters that can't be part of a ticket number
      error = 'No repair found with ticket number "$query". Please check the number and try again.';
    }
    if (!mounted) return;
    setState(() {
      _searchedTicket = found;
      _searchError = error;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.currentUser;
    if (user != null) _ensureStreams(user.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Lookup Bar
          _buildLookupBar(),
          const SizedBox(height: 18),

          // Searched ticket if found
          if (_searchedTicket != null) ...[
            const Text(
              'Search Result:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: SvcColors.muted),
            ),
            const SizedBox(height: 8),
            _buildTicketCard(_searchedTicket!, quote: null, canRespondToQuote: false),
            const SizedBox(height: 24),
          ],

          // Customer Live Tickets
          if (user != null) ...[
            _sectionHeader('Your Repairs'),
            const SizedBox(height: 12),
            StreamBuilder<List<ServiceRequestModel>>(
              stream: _requestsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) return _buildLoadError();
                if (!snapshot.hasData) return _buildLoading();

                final requests = snapshot.data!;
                if (requests.isEmpty) return _buildEmptyState();

                return StreamBuilder<List<ServiceQuoteModel>>(
                  stream: _quotesStream,
                  builder: (context, quoteSnapshot) {
                    final quotes = quoteSnapshot.data ?? const <ServiceQuoteModel>[];
                    return Column(
                      children: [
                        for (final req in requests)
                          _buildTicketCard(
                            req,
                            quote: _quoteFor(req, quotes),
                            canRespondToQuote: true,
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ] else ...[
            FutureBuilder<List<ServiceRequestModel>>(
              future: _guestTickets,
              builder: (context, snapshot) {
                final tickets = snapshot.data ?? const <ServiceRequestModel>[];
                if (tickets.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Booked on This Phone'),
                    const SizedBox(height: 12),
                    for (final t in tickets) _buildTicketCard(t, quote: null, canRespondToQuote: false),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
            // Guest Prompt
            _buildGuestPrompt(),
          ],
        ],
      ),
    );
  }

  ServiceQuoteModel? _quoteFor(ServiceRequestModel req, List<ServiceQuoteModel> quotes) {
    for (final q in quotes) {
      if (q.serviceRequestId == req.id || q.id == req.quoteId) return q;
    }
    return null;
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        const Icon(Icons.history_rounded, size: 18, color: SvcColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: SvcColors.ink),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(strokeWidth: 2, color: SvcColors.primary),
      ),
    );
  }

  Widget _buildLoadError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SvcColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SvcColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 32, color: SvcColors.muted),
          SizedBox(height: 10),
          Text(
            'Couldn\'t load your repairs',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: SvcColors.ink),
          ),
          SizedBox(height: 6),
          Text(
            'Check your internet connection. Your repairs will appear here once you\'re back online.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: SvcColors.muted, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildLookupBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SvcColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SvcColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Ticket Lookup',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                color: SvcColors.ink),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter the ticket number from your booking confirmation or walk-in receipt:',
            style: TextStyle(fontSize: 11.5, color: SvcColors.muted),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _lookupTicket(),
                  decoration: const InputDecoration(
                    hintText: 'Ticket number',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _searching ? null : _lookupTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SvcColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _searching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Track',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          if (_searchError != null) ...[
            const SizedBox(height: 8),
            Text(_searchError!,
                style: const TextStyle(fontSize: 11.5, color: SvcColors.danger)),
          ],
        ],
      ),
    );
  }

  Widget _buildTicketCard(
    ServiceRequestModel ticket, {
    required ServiceQuoteModel? quote,
    required bool canRespondToQuote,
  }) {
    final statusColor = _getStatusColor(ticket.status);
    final statusLabel = _formatStatus(ticket.status);
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(ticket.createdAt);
    final cancelled = _isCancelled(ticket.status);
    final awaitingQuote = ticket.status.toUpperCase().contains('QUOTE');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SvcColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SvcColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: full ticket number (tap to copy) and status
          Row(
            children: [
              Flexible(
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: ticket.id));
                    if (mounted) SvcSnackbar.show(context, 'Ticket number copied', type: SnackType.success);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            '#${ticket.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: SvcColors.inkSecondary),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.copy_rounded, size: 11, color: SvcColors.muted),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title & Issue
          Text(
            ticket.title,
            style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: SvcColors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            ticket.description,
            style: const TextStyle(
                fontSize: 12, color: SvcColors.inkSecondary, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // 5-Stage Stepper, or a cancelled note
          if (cancelled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SvcColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cancel_outlined, size: 16, color: SvcColors.danger),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This repair was cancelled. No work was carried out.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SvcColors.danger),
                    ),
                  ),
                ],
              ),
            )
          else
            _buildStatusStepper(ticket.status),

          // Quote: approve/decline here, or contact us when it can't be shown
          if (!cancelled && quote != null) ...[
            const SizedBox(height: 12),
            _QuoteBox(quote: quote, canRespond: canRespondToQuote),
          ] else if (!cancelled && awaitingQuote) ...[
            const SizedBox(height: 12),
            _buildQuoteContactNote(ticket.id),
          ],
          const SizedBox(height: 14),

          const Divider(color: SvcColors.border, height: 1),
          const SizedBox(height: 10),

          // Meta info footer
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 12, color: SvcColors.muted),
              const SizedBox(width: 4),
              Text(dateStr,
                  style:
                      const TextStyle(fontSize: 10.5, color: SvcColors.muted)),
              const Spacer(),
              if (ticket.assignedTechnicianName != null) ...[
                const Icon(Icons.person_pin_rounded,
                    size: 13, color: SvcColors.primary),
                const SizedBox(width: 4),
                Text(
                  ticket.assignedTechnicianName!,
                  style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: SvcColors.ink),
                ),
              ] else if (!cancelled) ...[
                const Text('Triage Queue',
                    style: TextStyle(
                        fontSize: 10.5,
                        color: SvcColors.muted,
                        fontStyle: FontStyle.italic)),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Action button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showContactSupportDialog(context, ticket.id),
              icon: const Icon(Icons.headset_mic_rounded,
                  size: 15, color: SvcColors.primary),
              label: const Text('Inquire About This Ticket',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: SvcColors.primary)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFED7AA)),
                backgroundColor: SvcColors.primarySoft,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shown when a quote is ready but can't be approved in the app (guests,
  /// or the quote hasn't synced yet).
  Widget _buildQuoteContactNote(String ticketId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your quote is ready',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFC2570D)),
          ),
          const SizedBox(height: 4),
          Text(
            widget.appState.currentUser == null
                ? 'Call or WhatsApp us to hear the quote and approve it. Log in to approve quotes right here next time.'
                : 'Call or WhatsApp us to hear the quote and approve it.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.35),
          ),
          const SizedBox(height: 10),
          _contactButtons(ticketId),
        ],
      ),
    );
  }

  Widget _contactButtons(String ticketId) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => callWorkshop(context),
            icon: const Icon(Icons.call_rounded, size: 15),
            label: const Text('Call', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: SvcColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => whatsappWorkshop(
              context,
              message: 'Hello ${BusinessContact.name}, I have a question about my repair ticket $ticketId.',
            ),
            icon: const Icon(Icons.chat_rounded, size: 15, color: Color(0xFF16A34A)),
            label: const Text('WhatsApp',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFBBF7D0)),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusStepper(String status) {
    int activeStep = 1;
    final s = status.toUpperCase();
    if (s.contains('REQUEST') || s.contains('PENDING')) {
      activeStep = 1;
    } else if (s.contains('ASSIGN') ||
        s.contains('INSPECT') ||
        s.contains('DIAGNOS')) {
      activeStep = 2;
    } else if (s.contains('QUOTE')) {
      activeStep = 3;
    } else if (s.contains('REPAIR') || s.contains('PROGRESS')) {
      activeStep = 4;
    } else if (s.contains('COMPLETE') || s.contains('READY')) {
      activeStep = 5;
    }

    final steps = ['Received', 'Diagnosis', 'Quoted', 'In Repair', 'Ready'];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final lineStep = (index ~/ 2) + 1;
          final isPassed = lineStep < activeStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isPassed ? SvcColors.primary : SvcColors.border,
            ),
          );
        }

        final stepIndex = (index ~/ 2) + 1;
        final isDone = stepIndex <= activeStep;
        final isCurrent = stepIndex == activeStep;

        return Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? SvcColors.primary : const Color(0xFFF1F5F9),
                border: Border.all(
                  color: isCurrent
                      ? SvcColors.primaryDark
                      : (isDone ? SvcColors.primary : SvcColors.border),
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : Text(
                        '$stepIndex',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: SvcColors.muted),
                      ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              steps[stepIndex - 1],
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? SvcColors.primaryDark : SvcColors.muted,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: SvcColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SvcColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: SvcColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.handyman_outlined,
                size: 36, color: SvcColors.primary),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Repairs Yet',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: SvcColors.ink),
          ),
          const SizedBox(height: 6),
          const Text(
            'Repairs you book will show up here with live status updates.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: SvcColors.muted, height: 1.3),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onBookNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: SvcColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Book a Free Inspection Now',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestPrompt() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SvcColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: SvcColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Tracking as Guest',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: SvcColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Repairs you book on this phone appear above. Booked somewhere else? Enter its ticket number in the search bar. Log in to see all your repairs and approve quotes in the app.',
            style: TextStyle(
                fontSize: 12, color: SvcColors.inkSecondary, height: 1.35),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onBookNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: SvcColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Book New Repair Request',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context, String ticketId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.support_agent_rounded, color: SvcColors.primary),
            SizedBox(width: 8),
            Text('Ticket Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ticket: #$ticketId',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            const Text(
              'For status updates, urgent requests or questions about your quote, contact our Janakpur workshop:',
              style: TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone & WhatsApp: ${BusinessContact.phoneDisplay}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(height: 4),
                  Text('${BusinessContact.street}, ${BusinessContact.city}',
                      style: TextStyle(fontSize: 11.5, color: SvcColors.muted)),
                  SizedBox(height: 2),
                  Text(BusinessContact.hours,
                      style: TextStyle(fontSize: 11.5, color: SvcColors.muted)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _contactButtons(ticketId),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toUpperCase();
    if (s.contains('COMPLETE') || s.contains('READY')) {
      return const Color(0xFF059669);
    }
    if (s.contains('PROGRESS') || s.contains('REPAIR')) {
      return const Color(0xFF2563EB);
    }
    if (s.contains('QUOTE')) return const Color(0xFFE86F1C);
    if (s.contains('CANCEL') || s.contains('REJECT')) return SvcColors.danger;
    return const Color(0xFF475569);
  }

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'REQUESTED':
        return 'Request Received';
      case 'TECHNICIAN_ASSIGNED':
        return 'Tech Assigned';
      case 'INSPECTION_SCHEDULED':
        return 'Inspection Set';
      case 'INSPECTION_COMPLETED':
        return 'Diagnosis Ready';
      case 'QUOTE_SENT':
        return 'Quote Sent';
      case 'IN_PROGRESS':
        return 'In Repair';
      case 'COMPLETED':
        return 'Ready / Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status.replaceAll('_', ' ');
    }
  }
}

/// A repair quote with Approve / Decline for the signed-in customer.
class _QuoteBox extends StatefulWidget {
  final ServiceQuoteModel quote;
  final bool canRespond;

  const _QuoteBox({required this.quote, required this.canRespond});

  @override
  State<_QuoteBox> createState() => _QuoteBoxState();
}

class _QuoteBoxState extends State<_QuoteBox> {
  bool _busy = false;

  Future<void> _respond(bool approve) async {
    final quote = widget.quote;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(approve ? 'Approve this quote?' : 'Decline this quote?'),
        content: Text(
          approve
              ? 'The technician will start the repair for ${formatRs(quote.total)}.'
              : 'No repair will be done. We will call you to arrange returning your device.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? SvcColors.primary : SvcColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(approve ? 'Approve' : 'Decline'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await FirestoreService().updateQuoteStatus(quote.id, approve ? 'ACCEPTED' : 'REJECTED');
      if (mounted) {
        SvcSnackbar.show(
          context,
          approve ? 'Quote approved. The technician will start your repair.' : 'Quote declined. No repair will be done.',
          type: approve ? SnackType.success : SnackType.info,
        );
      }
    } catch (_) {
      if (mounted) {
        SvcSnackbar.show(context, 'Couldn\'t send your answer. Please try again.', type: SnackType.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
    final status = quote.status.toUpperCase();
    return Container(
      width: double.infinity,
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
                'Repair Quote',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFC2570D)),
              ),
              Text(
                formatRs(quote.total),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Labour ${formatRs(quote.labourTotal)} · Parts ${formatRs(quote.partsTotal)}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
          ),
          if (quote.warrantyTerms.isNotEmpty)
            Text(
              quote.warrantyTerms,
              style: const TextStyle(fontSize: 12, color: Color(0xFF15803D), fontWeight: FontWeight.w600),
            ),
          if (quote.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(quote.notes, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
          ],
          const SizedBox(height: 10),
          if (status == 'SENT' && widget.canRespond)
            _busy
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: SvcColors.primary),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _respond(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SvcColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Approve Quote', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _respond(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: SvcColors.danger,
                            side: const BorderSide(color: SvcColors.danger),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Decline', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  )
          else if (status == 'ACCEPTED')
            const Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Color(0xFF16A34A)),
                SizedBox(width: 6),
                Text('Approved. Repair underway.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
              ],
            )
          else if (status == 'REJECTED')
            const Text('Declined. No repair carried out.', style: TextStyle(fontSize: 12, color: SvcColors.danger)),
        ],
      ),
    );
  }
}
