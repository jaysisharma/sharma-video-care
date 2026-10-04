import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'service_request_screen.dart';
import 'source_screen.dart';
import 'chat_screen.dart';

class AccountScreen extends StatefulWidget {
  final AppState appState;
  final void Function(int index)? onNavigateTab;

  const AccountScreen({
    super.key,
    required this.appState,
    this.onNavigateTab,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Push notification preferences state
  bool _orderNotifications = true;
  bool _repairNotifications = true;
  bool _promoNotifications = false;

  String _formatCurrency(int amount) {
    return 'Rs. ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        final user = widget.appState.currentUser;
        final isAuthenticated = widget.appState.isAuthenticated && user != null;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top App Bar: Profile title & action icons
                  _buildHeader(context),

                  const SizedBox(height: 16),

                  // Profile Card (Warm cream/peach background with avatar & verified badge)
                  _buildProfileCard(context, user, isAuthenticated),

                  const SizedBox(height: 20),

                  // Section 1: My Activity
                  _buildSectionHeader(
                    title: 'My Activity',
                    actionLabel: 'View All',
                    onAction: () => _openActivityModal(context, user, initialTab: 0),
                  ),
                  const SizedBox(height: 8),
                  _buildCardGroup([
                    _buildMenuItem(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Orders',
                      subtitle: 'Track your product orders',
                      onTap: () => _openOrdersModal(context, user),
                    ),
                    _buildMenuItem(
                      icon: Icons.build_outlined,
                      title: 'Service Requests',
                      subtitle: 'Check service status and history',
                      onTap: () => _openServiceRequestsModal(context, user),
                    ),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Quotations',
                      subtitle: 'View and manage your quotations',
                      onTap: () => _openQuotationsModal(context, user),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Section 2: Saved Information
                  _buildSectionHeader(title: 'Saved Information'),
                  const SizedBox(height: 8),
                  _buildCardGroup([
                    _buildMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Addresses',
                      subtitle: 'Manage your saved addresses',
                      onTap: () => _openAddressesModal(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.favorite_border,
                      title: 'Wishlist',
                      subtitle: 'Your favourite products',
                      onTap: () => _openWishlistModal(context),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Section 3: Support
                  _buildSectionHeader(title: 'Support'),
                  const SizedBox(height: 8),
                  _buildCardGroup([
                    _buildMenuItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Chat with Support',
                      subtitle: 'Get help from our team',
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(3); // Navigate to Chat tab
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(appState: widget.appState),
                            ),
                          );
                        }
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center',
                      subtitle: 'FAQs, guides and support',
                      onTap: () => _openHelpCenterModal(context),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Section 4: Account Settings
                  _buildSectionHeader(title: 'Account Settings'),
                  const SizedBox(height: 8),
                  _buildCardGroup([
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      subtitle: 'Name, phone, email and profile photo',
                      onTap: () => _openPersonalInfoModal(context, user),
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_none_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage your notification preferences',
                      onTap: () => _openNotificationsModal(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.shield_outlined,
                      title: 'Privacy & Security',
                      subtitle: 'Account security and data settings',
                      onTap: () => _openPrivacyModal(context),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // Logout Card (Soft Red background)
                  _buildLogoutCard(context, isAuthenticated),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.6,
          ),
        ),
        const Spacer(),
        // Notification bell with unread dot
        Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: () => _openNotificationsCenter(context),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.notifications_none_outlined,
                  size: 24,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        // Settings gear icon
        InkWell(
          onTap: () => _openSettingsModal(context),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.settings_outlined,
              size: 24,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PROFILE HERO CARD
  // ---------------------------------------------------------------------------
  Widget _buildProfileCard(BuildContext context, UserModel? user, bool isAuthenticated) {
    final displayName = isAuthenticated ? (user?.name ?? 'Customer') : 'Jaysi Sharma';
    final displayPhone = isAuthenticated
        ? (user?.phone.isNotEmpty == true ? user!.phone : '+977 98XXXXXXXX')
        : '+977 98XXXXXXXX';
    final displayEmail = isAuthenticated
        ? (user?.email ?? 'jaysi@example.com')
        : 'jaysi@example.com';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8F5), // Warm peach/cream card
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF4ECE4), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with Orange edit badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFFFEEAD9),
                  backgroundImage: AssetImage('assets/images/user_avatar.jpg'),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _openPersonalInfoModal(context, user),
                  child: Container(
                    padding: const EdgeInsets.all(4.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // User details & Verified pill
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  displayPhone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  displayEmail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 7),
                // Verified Account Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 13,
                        color: Color(0xFF16A34A),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verified Account',
                        style: TextStyle(
                          color: Color(0xFF15803D),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chevron Right
          IconButton(
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 24,
            ),
            onPressed: () => _openPersonalInfoModal(context, user),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION HEADERS & CARD GROUPS
  // ---------------------------------------------------------------------------
  Widget _buildSectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCardGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              const Divider(
                height: 1,
                thickness: 0.8,
                color: Color(0xFFF1F5F9),
                indent: 52,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Orange outline icon
            Icon(
              icon,
              size: 22,
              color: const Color(0xFFF97316),
            ),
            const SizedBox(width: 14),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            // Trailing Chevron
            const Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOGOUT ACTION CARD
  // ---------------------------------------------------------------------------
  Widget _buildLogoutCard(BuildContext context, bool isAuthenticated) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Soft light red
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEE2E2), width: 1.2),
      ),
      child: InkWell(
        onTap: () => _handleLogoutTap(context, isAuthenticated),
        borderRadius: BorderRadius.circular(16),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 22,
                color: Color(0xFFEF4444),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sign out from your account',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFF87171),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: Color(0xFFEF4444),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogoutTap(BuildContext context, bool isAuthenticated) {
    if (!isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(appState: widget.appState, redirectIndex: 4),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFEF4444),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Sign Out of Video Care?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You will need to sign in again to view your live repair quotes and nationwide order shipments.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          await widget.appState.signOut();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Signed out successfully'),
                                backgroundColor: Color(0xFF0F172A),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(fontWeight: FontWeight.w700),
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

  // ---------------------------------------------------------------------------
  // INTERACTIVE DETAIL MODALS & SHEETS
  // ---------------------------------------------------------------------------

  // 1. ORDERS MODAL
  void _openOrdersModal(BuildContext context, UserModel? user) {
    if (user == null) {
      _showAuthRequiredPrompt(context, 'view your active equipment orders');
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
                _buildSheetHandle(),
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
                Expanded(child: _buildOrdersList(user, scrollController)),
              ],
            );
          },
        );
      },
    );
  }

  // 2. SERVICE REQUESTS MODAL
  void _openServiceRequestsModal(BuildContext context, UserModel? user) {
    if (user == null) {
      _showAuthRequiredPrompt(context, 'check hardware repair status and diagnostic quotes');
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
                _buildSheetHandle(),
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
                Expanded(child: _buildRepairsList(user, scrollController)),
              ],
            );
          },
        );
      },
    );
  }

  // 3. QUOTATIONS MODAL
  void _openQuotationsModal(BuildContext context, UserModel? user) {
    if (user == null) {
      _showAuthRequiredPrompt(context, 'review quotations and procurement items');
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
                _buildSheetHandle(),
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
                Expanded(child: _buildSourcingList(user, scrollController)),
              ],
            );
          },
        );
      },
    );
  }

  // 4. "VIEW ALL" ALL-ACTIVITY TABBED MODAL
  void _openActivityModal(BuildContext context, UserModel? user, {int initialTab = 0}) {
    if (user == null) {
      _showAuthRequiredPrompt(context, 'view all your activity');
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
                  _buildSheetHandle(),
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
                        _buildOrdersList(user, scrollController),
                        _buildRepairsList(user, scrollController),
                        _buildSourcingList(user, scrollController),
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

  // 5. SAVED ADDRESSES MODAL
  void _openAddressesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSheetHandle(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Color(0xFFF97316)),
                    const SizedBox(width: 8),
                    const Text(
                      'Saved Delivery Addresses',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAddressCard(
                  title: 'Home / Studio (Default)',
                  address: 'Station Road, Janakpurdham, Madhesh Province, Nepal',
                  phone: '+977 9800000000',
                  isDefault: true,
                ),
                const SizedBox(height: 10),
                _buildAddressCard(
                  title: 'Kathmandu Transit Hub',
                  address: 'New Baneshwor, Kathmandu, Bagmati Province, Nepal',
                  phone: '+977 9851000000',
                  isDefault: false,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address management is configured with live orders.')),
                      );
                    },
                    icon: const Icon(Icons.add, color: Color(0xFFF97316)),
                    label: const Text(
                      'Add New Delivery Address',
                      style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: Color(0xFFF97316)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressCard({
    required String title,
    required String address,
    required String phone,
    required bool isDefault,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault ? const Color(0xFFF97316).withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDefault ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDefault ? const Color(0xFFF97316) : const Color(0xFF94A3B8),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEEAD9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(color: Color(0xFFC2570D), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(address, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(phone, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. WISHLIST MODAL
  void _openWishlistModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSheetHandle(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Color(0xFFF97316)),
                    const SizedBox(width: 8),
                    const Text(
                      'Saved Wishlist',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF7ED),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          size: 36,
                          color: Color(0xFFF97316),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Your Wishlist is Empty',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Save cinema cameras, precision lenses, and studio accessories to purchase whenever you are ready.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(2); // Navigate to Shop tab
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Browse Equipment Catalog', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // 7. HELP CENTER MODAL
  void _openHelpCenterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSheetHandle(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.help_outline_rounded, color: Color(0xFFF97316)),
                      const SizedBox(width: 8),
                      const Text(
                        'Help Center & Support FAQs',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFaqItem(
                    'How does the free physical inspection work in Janakpur?',
                    'Bring your cinema camera, DSLR, drone or lens to our workshop at Station Road, Janakpurdham. Our certified engineers perform a complete diagnostic free of charge (Rs. 0 inspection fee) and provide an itemized repair quotation.',
                  ),
                  _buildFaqItem(
                    'What is the Zero-Deposit policy for gear sourcing?',
                    'For rare lenses, cine primes, and custom broadcast rigs, Sharma Video Care sources equipment with Rs. 0 advance deposit. You only inspect and pay upon confirmed delivery.',
                  ),
                  _buildFaqItem(
                    'What repair warranty is provided on replaced optics?',
                    'All optical realignment and electronic component replacements carry up to 90 days of certified service warranty.',
                  ),
                  _buildFaqItem(
                    'Do you provide nationwide courier delivery across Nepal?',
                    'Yes, we ship new cameras, certified pre-owned units, and spare parts across all 7 provinces in Nepal with tracked courier logistics.',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
        ],
      ),
    );
  }

  // 8. PERSONAL INFORMATION MODAL
  void _openPersonalInfoModal(BuildContext context, UserModel? user) {
    final nameController = TextEditingController(text: user?.name ?? 'Jaysi Sharma');
    final phoneController = TextEditingController(
      text: user?.phone.isNotEmpty == true ? user!.phone : '+977 98XXXXXXXX',
    );
    final emailController = TextEditingController(text: user?.email ?? 'jaysi@example.com');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSheetHandle(),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, color: Color(0xFFF97316)),
                  const SizedBox(width: 8),
                  const Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                  helperText: 'Email is linked to authentication credentials',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile information updated successfully.'),
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // 9. NOTIFICATIONS PREFERENCES MODAL
  void _openNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSheetHandle(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.notifications_none_outlined, color: Color(0xFFF97316)),
                        const SizedBox(width: 8),
                        const Text(
                          'Notification Preferences',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      activeThumbColor: const Color(0xFFF97316),
                      title: const Text('Order Status Updates', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Courier tracking and dispatch notifications', style: TextStyle(fontSize: 12)),
                      value: _orderNotifications,
                      onChanged: (val) {
                        setSheetState(() => _orderNotifications = val);
                        setState(() => _orderNotifications = val);
                      },
                    ),
                    SwitchListTile(
                      activeThumbColor: const Color(0xFFF97316),
                      title: const Text('Service & Repair Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Diagnostic quotes and technician updates', style: TextStyle(fontSize: 12)),
                      value: _repairNotifications,
                      onChanged: (val) {
                        setSheetState(() => _repairNotifications = val);
                        setState(() => _repairNotifications = val);
                      },
                    ),
                    SwitchListTile(
                      activeThumbColor: const Color(0xFFF97316),
                      title: const Text('Gear Drops & Promotions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Pre-owned inventory and cinema discounts', style: TextStyle(fontSize: 12)),
                      value: _promoNotifications,
                      onChanged: (val) {
                        setSheetState(() => _promoNotifications = val);
                        setState(() => _promoNotifications = val);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 10. PRIVACY & SECURITY MODAL
  void _openPrivacyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSheetHandle(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Color(0xFFF97316)),
                    const SizedBox(width: 8),
                    const Text(
                      'Privacy & Security',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
                  title: const Text('Change Account Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset link sent to your registered email.')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.fingerprint, color: Color(0xFF64748B)),
                  title: const Text('Biometric Authentication', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Biometric authentication is active on this device.')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: Color(0xFF64748B)),
                  title: const Text('Data Privacy & Terms of Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () {
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 11. NOTIFICATIONS CENTER (BELL ICON)
  void _openNotificationsCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSheetHandle(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined, color: Color(0xFFF97316)),
                    const SizedBox(width: 8),
                    const Text(
                      'Notifications Center',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildNotificationAlert(
                  title: 'Free Diagnostic Inspection Active',
                  message: 'Visit our Janakpur workshop for zero-cost physical assessment of your camera equipment.',
                  time: '1h ago',
                ),
                _buildNotificationAlert(
                  title: 'Nationwide Delivery Ready',
                  message: 'Express courier delivery is running across all major cities in Nepal.',
                  time: 'Yesterday',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationAlert({
    required String title,
    required String message,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
              ),
              Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  // 12. APP SETTINGS (GEAR ICON)
  void _openSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSheetHandle(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.settings_outlined, color: Color(0xFFF97316)),
                    const SizedBox(width: 8),
                    const Text(
                      'App Settings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const ListTile(
                  leading: Icon(Icons.language_outlined, color: Color(0xFF64748B)),
                  title: Text('Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('English (Nepal)'),
                  trailing: Icon(Icons.chevron_right, size: 18),
                ),
                const ListTile(
                  leading: Icon(Icons.palette_outlined, color: Color(0xFF64748B)),
                  title: Text('Appearance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('Light Clean Optics Mode'),
                  trailing: Icon(Icons.chevron_right, size: 18),
                ),
                const ListTile(
                  leading: Icon(Icons.info_outline, color: Color(0xFF64748B)),
                  title: Text('App Version', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('Sharma Video Care v1.0.0 (Build 100)'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // LIVE FIRESTORE LIST BUILDERS FOR MY ACTIVITY
  // ---------------------------------------------------------------------------

  Widget _buildOrdersList(UserModel user, ScrollController scrollController) {
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
                      'Total: ${_formatCurrency(order.total)} (${order.paymentMethod})',
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
                        '🚚 Destination: ${order.streetAddress.isNotEmpty ? order.streetAddress : order.city}\nPayment: ${order.paymentMethod} • Status: ${order.paymentStatus}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRepairsList(UserModel user, ScrollController scrollController) {
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
                        MaterialPageRoute(builder: (_) => ServiceRequestScreen(appState: widget.appState)),
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

                        // Diagnostic Quote Box
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
                                      _formatCurrency(quote.total),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Labour: ${_formatCurrency(quote.labourTotal)} | Parts: ${_formatCurrency(quote.partsTotal)}',
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
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Quote Approved! Technician will proceed.')),
                                              );
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
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Quote Declined.')),
                                              );
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

  Widget _buildSourcingList(UserModel user, ScrollController scrollController) {
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
                    child: const Icon(Icons.search_outlined, size: 26, color: Color(0xFFF97316)),
                  ),
                  const SizedBox(height: 14),
                  const Text('No Sourcing Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text(
                    'Need specific cinema gear, rare lenses, or enterprise CCTV kits? Request procurement with Rs. 0 advance deposit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SourceRequestScreen(appState: widget.appState)),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Submit Sourcing Request'),
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

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final src = requests[index];

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
                          'Ref #${src.id.length > 8 ? src.id.substring(0, 8).toUpperCase() : src.id.toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            src.status.replaceAll('_', ' '),
                            style: const TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(src.itemDescription, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    Text(
                      'Budget: Rs. ${src.budget} • City: ${src.city}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    if (src.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Notes: ${src.notes}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '✓ ${_formatCurrency(src.advanceDeposit)} advance deposit collected (Zero-Deposit Policy).',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  void _showAuthRequiredPrompt(BuildContext context, String reason) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSheetHandle(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: Color(0xFFF97316), size: 30),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Sign In Required',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please sign in to your Sharma Video Care account to $reason.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(appState: widget.appState, redirectIndex: 4),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Sign In to Account', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegisterScreen(appState: widget.appState, redirectIndex: 4),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Create New Account', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
