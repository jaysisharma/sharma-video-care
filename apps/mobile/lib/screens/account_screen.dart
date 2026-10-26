import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/account/account_profile_card.dart';
import '../widgets/account/account_addresses_sheet.dart';
import '../widgets/account/account_gear_locker_sheet.dart';
import '../widgets/account/account_activity_sheets.dart';
import '../widgets/account/account_settings_sheets.dart';
import 'chat_screen.dart';
import 'notifications_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _orderNotifications = prefs.getBool('svc_notif_orders') ?? true;
          _repairNotifications = prefs.getBool('svc_notif_repairs') ?? true;
          _promoNotifications = prefs.getBool('svc_notif_promos') ?? false;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveNotificationPref(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {}
  }

  void _showAuthRequiredPrompt(BuildContext context, String reason) {
    AccountSettingsSheets.showAuthRequiredPrompt(context, widget.appState, reason);
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

                  // Profile Card
                  AccountProfileCard(
                    user: user,
                    isAuthenticated: isAuthenticated,
                    appState: widget.appState,
                    onEditProfile: () => AccountSettingsSheets.openPersonalInfoModal(
                      context: context,
                      user: user,
                      appState: widget.appState,
                      showAuthRequiredPrompt: _showAuthRequiredPrompt,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section 1: My Activity
                  _buildSectionHeader(
                    title: 'My Activity',
                    actionLabel: 'View All',
                    onAction: () => AccountActivitySheets.openActivityModal(
                      context: context,
                      user: user,
                      appState: widget.appState,
                      initialTab: 0,
                      showAuthRequiredPrompt: _showAuthRequiredPrompt,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCardGroup([
                    _buildMenuItem(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Orders',
                      onTap: () => AccountActivitySheets.openOrdersModal(
                        context: context,
                        user: user,
                        showAuthRequiredPrompt: _showAuthRequiredPrompt,
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.build_outlined,
                      title: 'Service Requests',
                      onTap: () => AccountActivitySheets.openServiceRequestsModal(
                        context: context,
                        user: user,
                        appState: widget.appState,
                        showAuthRequiredPrompt: _showAuthRequiredPrompt,
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Quotations',
                      onTap: () => AccountActivitySheets.openQuotationsModal(
                        context: context,
                        user: user,
                        showAuthRequiredPrompt: _showAuthRequiredPrompt,
                      ),
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
                      onTap: () => AccountAddressesSheet.openAddressesModal(
                        context: context,
                        user: user,
                        appState: widget.appState,
                        showAuthRequiredPrompt: _showAuthRequiredPrompt,
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.favorite_border,
                      title: 'Wishlist',
                      onTap: () => _openWishlistModal(context, user),
                    ),
                    _buildMenuItem(
                      icon: Icons.camera_alt_outlined,
                      title: 'My Gear Locker',
                      onTap: () => AccountGearLockerSheet.openGearLockerModal(
                        context: context,
                        user: user,
                        appState: widget.appState,
                        showAuthRequiredPrompt: _showAuthRequiredPrompt,
                      ),
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
                      onTap: () => AccountSettingsSheets.openPersonalInfoModal(
                        context: context,
                        user: user,
                        appState: widget.appState,
                        showAuthRequiredPrompt: _showAuthRequiredPrompt,
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_none_outlined,
                      title: 'Notifications',
                      onTap: () => AccountSettingsSheets.openNotificationsModal(
                        context: context,
                        orderNotifications: _orderNotifications,
                        repairNotifications: _repairNotifications,
                        promoNotifications: _promoNotifications,
                        onChanged: (orders, repairs, promos) {
                          setState(() {
                            _orderNotifications = orders;
                            _repairNotifications = repairs;
                            _promoNotifications = promos;
                          });
                          _saveNotificationPref('svc_notif_orders', orders);
                          _saveNotificationPref('svc_notif_repairs', repairs);
                          _saveNotificationPref('svc_notif_promos', promos);
                        },
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.shield_outlined,
                      title: 'Privacy & Security',
                      onTap: () => AccountSettingsSheets.openPrivacyModal(
                        context: context,
                        user: user,
                        appState: widget.appState,
                        showAuthRequiredPrompt: _showAuthRequiredPrompt,
                      ),
                    ),
                  ]),

                  if (isAuthenticated) ...[
                    const SizedBox(height: 16),
                    _buildLogoutCard(context),
                  ],

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
            if (widget.appState.unreadNotificationCount > 0)
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
          onTap: () => AccountSettingsSheets.openAppSettingsModal(context),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: const Color(0xFFF97316),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
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
  Widget _buildLogoutCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEE2E2), width: 1.2),
      ),
      child: InkWell(
        onTap: () => AccountSettingsSheets.showLogoutConfirmSheet(
          context: context,
          appState: widget.appState,
        ),
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

  // ---------------------------------------------------------------------------
  // WISHLIST & HELP MODALS
  // ---------------------------------------------------------------------------
  void _openWishlistModal(BuildContext context, UserModel? user) {
    if (user == null) {
      _showAuthRequiredPrompt(context, 'access your saved wishlist');
      return;
    }

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
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
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
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
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
                    'For rare lenses, cine primes, and custom broadcast rigs, QuickySewa sources equipment with Rs. 0 advance deposit. You only inspect and pay upon confirmed delivery.',
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

  void _openNotificationsCenter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(appState: widget.appState),
      ),
    );
  }
}
