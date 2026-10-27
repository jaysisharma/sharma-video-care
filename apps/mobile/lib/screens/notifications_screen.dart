import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'shop_screen.dart';
import 'service_request_screen.dart';
import 'trade_in_screen.dart';
import 'cart_screen.dart';
import '../theme_tokens.dart';
import '../widgets/svc_snackbar.dart';

class NotificationsScreen extends StatefulWidget {
  final AppState appState;

  const NotificationsScreen({super.key, required this.appState});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedCategory = 'all';
  String? _errorMessage;

  static const List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'label': 'All', 'icon': Icons.all_inbox_rounded},
    {'id': 'orders', 'label': 'Orders', 'icon': Icons.local_shipping_outlined},
    {'id': 'repairs', 'label': 'Repairs', 'icon': Icons.build_outlined},
    {'id': 'offers', 'label': 'Offers', 'icon': Icons.local_offer_outlined},
    {'id': 'system', 'label': 'System', 'icon': Icons.shield_outlined},
  ];

  // AppState keeps notifications live for the whole session (for the badges);
  // this screen only shows them.
  bool get _isLoading =>
      widget.appState.notificationsLoading && widget.appState.notifications.isEmpty;
  bool get _hasError =>
      widget.appState.notificationsError != null && widget.appState.notifications.isEmpty;

  Future<void> _loadNotifications() => widget.appState.refreshNotifications();

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'orders':
        return Icons.local_shipping_outlined;
      case 'repairs':
        return Icons.build_outlined;
      case 'offers':
        return Icons.local_offer_outlined;
      case 'system':
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'orders':
        return const Color(0xFFEA580C);
      case 'repairs':
        return const Color(0xFF2563EB);
      case 'offers':
        return const Color(0xFF16A34A);
      case 'system':
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getCategorySoftColor(String category) {
    switch (category.toLowerCase()) {
      case 'orders':
        return const Color(0xFFFFF7ED);
      case 'repairs':
        return const Color(0xFFEFF6FF);
      case 'offers':
        return const Color(0xFFF0FDF4);
      case 'system':
      default:
        return const Color(0xFFF8FAFC);
    }
  }

  Map<String, List<NotificationItemModel>> _groupNotifications(List<NotificationItemModel> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<NotificationItemModel>> groups = {
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };

    for (final item in items) {
      final itemDate = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
      if (itemDate.isAtSameMomentAs(today)) {
        groups['Today']!.add(item);
      } else if (itemDate.isAtSameMomentAs(yesterday)) {
        groups['Yesterday']!.add(item);
      } else {
        groups['Earlier']!.add(item);
      }
    }

    groups.removeWhere((key, value) => value.isEmpty);
    return groups;
  }

  void _handleNotificationTap(NotificationItemModel item) {
    widget.appState.markNotificationAsRead(item.id);

    if (item.actionRoute != null) {
      switch (item.actionRoute) {
        case 'shop':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ShopScreen(appState: widget.appState)),
          );
          break;
        case 'services':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ServiceRequestScreen(appState: widget.appState)),
          );
          break;
        case 'tradein':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TradeInScreen(appState: widget.appState)),
          );
          break;
        case 'cart':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CartScreen(appState: widget.appState)),
          );
          break;
        default:
          _showDetailSheet(item);
          break;
      }
    } else {
      _showDetailSheet(item);
    }
  }

  void _showDetailSheet(NotificationItemModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final color = _getCategoryColor(item.category);
        final softColor = _getCategorySoftColor(item.category);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: softColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_getCategoryIcon(item.category), color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: color,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTimestamp(item.timestamp),
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.message,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF475569),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton.outlined(
                      onPressed: () {
                        widget.appState.toggleNotificationRead(item.id);
                        Navigator.pop(ctx);
                      },
                      icon: Icon(
                        item.isRead ? Icons.mark_email_unread_outlined : Icons.mark_email_read_outlined,
                        size: 19,
                        color: const Color(0xFF475569),
                      ),
                      tooltip: item.isRead ? 'Mark unread' : 'Mark read',
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      onPressed: () {
                        widget.appState.removeNotification(item.id);
                        Navigator.pop(ctx);
                        SvcSnackbar.show(context, 'Notification removed', type: SnackType.success);
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 19, color: Color(0xFFEF4444)),
                      tooltip: 'Delete notification',
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (item.actionLabel != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _handleNotificationTap(item);
                          },
                          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                          label: Text(
                            item.actionLabel!,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Dismiss',
                            style: TextStyle(
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Clear All Notifications?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Are you sure you want to remove all notifications? This cannot be undone.',
            style: TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.appState.clearAllNotifications();
                Navigator.pop(ctx);
                SvcSnackbar.show(context, 'All notifications cleared', type: SnackType.success);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        final all = widget.appState.notifications;
        final filtered = _selectedCategory == 'all'
            ? all
            : all.where((n) => n.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

        final unreadCount = widget.appState.unreadNotificationCount;
        final grouped = _groupNotifications(filtered);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unreadCount new',
                      style: const TextStyle(
                        color: Color(0xFFEA580C),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (unreadCount > 0)
                IconButton(
                  icon: const Icon(Icons.done_all_rounded, size: 21, color: Color(0xFFEA580C)),
                  tooltip: 'Mark all as read',
                  onPressed: () {
                    widget.appState.markAllNotificationsAsRead();
                    SvcSnackbar.show(context, 'All marked as read', type: SnackType.success);
                  },
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20, color: Color(0xFF64748B)),
                tooltip: 'Options',
                onSelected: (val) {
                  if (val == 'mark_read') {
                    widget.appState.markAllNotificationsAsRead();
                  } else if (val == 'clear_read') {
                    widget.appState.clearReadNotifications();
                    SvcSnackbar.show(context, 'Read notifications cleared', type: SnackType.success);
                  } else if (val == 'clear_all') {
                    _confirmClearAll();
                  }
                },
                itemBuilder: (context) => [
                  if (unreadCount > 0)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.done_all_rounded, size: 18, color: SvcColors.primary),
                          SizedBox(width: 10),
                          Text('Mark all as read', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  if (all.any((n) => n.isRead))
                    const PopupMenuItem(
                      value: 'clear_read',
                      child: Row(
                        children: [
                          Icon(Icons.cleaning_services_outlined, size: 18, color: SvcColors.muted),
                          SizedBox(width: 10),
                          Text('Clear read notifications', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  if (all.isNotEmpty)
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep_outlined, size: 18, color: SvcColors.danger),
                          SizedBox(width: 10),
                          Text('Clear all notifications', style: TextStyle(fontSize: 13, color: SvcColors.danger)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadNotifications,
            color: SvcColors.primary,
            child: Column(
              children: [
                // Category Filter Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _categories.map((cat) {
                        final id = cat['id'] as String;
                        final label = cat['label'] as String;
                        final icon = cat['icon'] as IconData;
                        final isSelected = _selectedCategory == id;

                        int count;
                        if (id == 'all') {
                          count = all.length;
                        } else {
                          count = all.where((n) => n.category.toLowerCase() == id).length;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedCategory = id),
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    icon,
                                    size: 14,
                                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    id == 'all' ? '$label ($count)' : label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: isSelected ? Colors.white : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Dynamic Body States: Loading, Error, Empty, or Grouped List
                Expanded(
                  child: _buildBodyContent(all, filtered, grouped),
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBodyContent(
    List<NotificationItemModel> all,
    List<NotificationItemModel> filtered,
    Map<String, List<NotificationItemModel>> grouped,
  ) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (filtered.isEmpty) {
      return _buildEmptyState(allTotalCount: all.length);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      itemCount: grouped.keys.length,
      itemBuilder: (context, groupIndex) {
        final sectionTitle = grouped.keys.elementAt(groupIndex);
        final sectionItems = grouped[sectionTitle]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    sectionTitle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFE2E8F0),
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),

            // Notification items in section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: sectionItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildNotificationCard(item),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationItemModel item) {
    final color = _getCategoryColor(item.category);
    final softColor = _getCategorySoftColor(item.category);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        widget.appState.removeNotification(item.id);
        SvcSnackbar.show(context, 'Notification removed', type: SnackType.success, actionLabel: 'Undo', onAction: () => widget.appState.addNotification(item));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFFDBA74).withValues(alpha: 0.6),
            width: item.isRead ? 1.0 : 1.2,
          ),
        ),
        child: InkWell(
          onTap: () => _handleNotificationTap(item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: softColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(item.category),
                    color: color,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag + Time
                      Row(
                        children: [
                          Text(
                            item.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text('•', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                          const SizedBox(width: 5),
                          Text(
                            _formatTimestamp(item.timestamp),
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                          if (item.targetGroup == 'all' || item.targetGroup == 'guest') ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: item.targetGroup == 'guest' ? const Color(0xFFFAF5FF) : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: item.targetGroup == 'guest' ? const Color(0xFFE9D5FF) : const Color(0xFFA7F3D0),
                                ),
                              ),
                              child: Text(
                                item.targetGroup == 'guest' ? 'GUEST' : 'ALL',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: item.targetGroup == 'guest' ? const Color(0xFF7E22CE) : const Color(0xFF059669),
                                ),
                              ),
                            ),
                          ],
                          if (!item.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEA580C),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                      if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl!,
                              height: 110,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                height: 110,
                                color: const Color(0xFFF1F5F9),
                                child: const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      if (item.actionLabel != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.actionLabel!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEA580C),
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 11.5,
                              color: Color(0xFFEA580C),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing Action IconButtons
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        item.isRead ? Icons.mark_email_unread_outlined : Icons.mark_email_read_outlined,
                        size: 17,
                        color: const Color(0xFF94A3B8),
                      ),
                      tooltip: item.isRead ? 'Mark unread' : 'Mark read',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      onPressed: () => widget.appState.toggleNotificationRead(item.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                      tooltip: 'Dismiss',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      onPressed: () => widget.appState.removeNotification(item.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required int allTotalCount}) {
    final isCategoryFiltered = _selectedCategory != 'all';

    IconData emptyIcon = Icons.notifications_none_rounded;
    String emptyTitle = 'All Caught Up';
    String emptySubtitle =
        'You have no active notifications right now. Order status, service diagnostic reports, and exclusive offers will appear here.';

    if (isCategoryFiltered) {
      switch (_selectedCategory) {
        case 'orders':
          emptyIcon = Icons.local_shipping_outlined;
          emptyTitle = 'No Order Updates';
          emptySubtitle = 'You don\'t have any shipment, delivery, or pickup notifications at this time.';
          break;
        case 'repairs':
          emptyIcon = Icons.build_outlined;
          emptyTitle = 'No Repair Tickets';
          emptySubtitle = 'You don\'t have any active bench diagnosis or repair status logs in this category.';
          break;
        case 'offers':
          emptyIcon = Icons.local_offer_outlined;
          emptyTitle = 'No Promotional Offers';
          emptySubtitle = 'Check back soon for seasonal discounts on camera sensors and certified pre-owned optics.';
          break;
        case 'system':
          emptyIcon = Icons.shield_outlined;
          emptyTitle = 'No System Notices';
          emptySubtitle = 'Your account, security settings, and app configurations are operating normally.';
          break;
      }
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(emptyIcon, color: const Color(0xFF64748B), size: 28),
            ),
            const SizedBox(height: 18),
            Text(
              emptyTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              emptySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            if (isCategoryFiltered)
              OutlinedButton.icon(
                onPressed: () => setState(() => _selectedCategory = 'all'),
                icon: const Icon(Icons.all_inbox_rounded, size: 16),
                label: Text('Show All Notifications ($allTotalCount)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ShopScreen(appState: widget.appState)),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                label: const Text('Explore Equipment Store'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 180,
                        height: 11,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFDC2626),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to Load Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Network synchronization timed out. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SvcColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
