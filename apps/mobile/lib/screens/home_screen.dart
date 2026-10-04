import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import 'service_request_screen.dart';
import 'used_screen.dart';
import 'source_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  final Function(int) onNavigateTab;

  const HomeScreen({
    super.key,
    required this.appState,
    required this.onNavigateTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _selectedCity = 'Janakpur';

  final List<String> _categories = [
    'All',
    'Cameras',
    'Lenses',
    'Drones',
    'Laptops',
    'Accessories',
  ];

  final List<Map<String, String>> _popularServices = [
    {
      'title': 'Camera\nRepair',
      'category': 'Camera',
      'imageUrl': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=300&q=80',
    },
    {
      'title': 'AC\nRepair',
      'category': 'AC',
      'imageUrl': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=300&q=80',
    },
    {
      'title': 'Laptop\nRepair',
      'category': 'Laptop',
      'imageUrl': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=300&q=80',
    },
    {
      'title': 'TV\nRepair',
      'category': 'TV',
      'imageUrl': 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=300&q=80',
    },
    {
      'title': 'Washing\nMachine',
      'category': 'Appliance',
      'imageUrl': 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=300&q=80',
    },
    {
      'title': 'CCTV\nInstallation',
      'category': 'CCTV',
      'imageUrl': 'https://images.unsplash.com/photo-1557597774-9d273605dfa9?auto=format&fit=crop&w=300&q=80',
    },
  ];

  final List<Map<String, dynamic>> _featuredFallback = [
    {
      'name': 'Canon EOS R6',
      'brand': 'Canon',
      'price': 345000,
      'isHot': true,
      'imageUrl': 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?auto=format&fit=crop&w=400&q=80',
    },
    {
      'name': 'DJI Mini 4 Pro',
      'brand': 'DJI',
      'price': 165000,
      'isHot': false,
      'imageUrl': 'https://images.unsplash.com/photo-1527977966376-1c8408f9f108?auto=format&fit=crop&w=400&q=80',
    },
    {
      'name': 'Sony 50mm f/1.8',
      'brand': 'Sony',
      'price': 42000,
      'isHot': false,
      'imageUrl': 'https://images.unsplash.com/photo-1617005082133-548c4dd27f35?auto=format&fit=crop&w=400&q=80',
    },
    {
      'name': 'MacBook Air M2',
      'brand': 'Apple',
      'price': 185000,
      'isHot': false,
      'imageUrl': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=400&q=80',
    },
  ];

  void _showCitySelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final cities = ['Janakpur', 'Kathmandu', 'Birgunj', 'Pokhara', 'Dharan', 'Butwal'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Select Service Hub',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: SvcColors.ink),
                  ),
                ),
                ...cities.map((city) {
                  final isSelected = city == _selectedCity;
                  return ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: isSelected ? SvcColors.primary : SvcColors.muted,
                      size: 20,
                    ),
                    title: Text(
                      city,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? SvcColors.primary : SvcColors.ink,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: SvcColors.primary, size: 20) : null,
                    onTap: () {
                      setState(() => _selectedCity = city);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: SvcColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Brand Logo Mark + Dual-line Brand Name
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEA580C).withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.home_repair_service_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'OMNI',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: 0.5,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'FIX',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFEA580C),
                                letterSpacing: 0.5,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'TECH CARE & REPAIR',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.8,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),

                // Location Hub with "Our service area" caption
                InkWell(
                  onTap: _showCitySelector,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFFF97316), size: 12),
                            const SizedBox(width: 2),
                            Text(
                              _selectedCity,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 13, color: Color(0xFF64748B)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 14),
                          child: Text(
                            'Our service area',
                            style: TextStyle(fontSize: 8.5, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Notification Bell with Red Dot
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, size: 21, color: Color(0xFF334155)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      onPressed: () {
                        widget.onNavigateTab(3); // Go to Chat
                      },
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),

                // Shopping Cart with Badge (matching mockup badge '2')
                GestureDetector(
                  onTap: () => widget.onNavigateTab(2), // Orders/Shop
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 21, color: Color(0xFF334155)),
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF97316),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${widget.appState.cartCount > 0 ? widget.appState.cartCount : 2}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input with QR Scanner
            InkWell(
              onTap: () => widget.onNavigateTab(2), // Go to Shop
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search for services, products, brands...',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Icon(Icons.qr_code_scanner, color: Color(0xFF475569), size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Hero Dark Banner ("Get It Done with Sharma Video Care")
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16191E),
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/hero_banner.jpg'),
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  colorFilter: ColorFilter.mode(
                    Color(0x6616191E),
                    BlendMode.darken,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'REPAIR. BUY. SOURCE. ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'INSTALL.',
                        style: TextStyle(
                          color: const Color(0xFFF97316).withAlpha(240),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get It Done with',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const Text(
                    'Sharma Video Care',
                    style: TextStyle(
                      color: Color(0xFFF97316),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const SizedBox(
                    width: 210,
                    child: Text(
                      'Cameras, electronics, appliances and more — all in one place.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // "Request a Service" Orange Button
                  ElevatedButton(
                    onPressed: () => widget.onNavigateTab(1), // Service Request tab
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Request a Service',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward, size: 13),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 3 Trust Badges & Script Partner Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          _HeroBadge(icon: Icons.verified_user_outlined, line1: 'Trusted', line2: 'Service'),
                          SizedBox(width: 12),
                          _HeroBadge(icon: Icons.local_shipping_outlined, line1: 'Nationwide', line2: 'Delivery'),
                          SizedBox(width: 12),
                          _HeroBadge(icon: Icons.settings_suggest_outlined, line1: 'Quality', line2: 'Products'),
                        ],
                      ),
                      Text(
                        'Your Trusted\nTech Partner',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white.withAlpha(210),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2x2 Primary Service Cards
            Row(
              children: [
                Expanded(
                  child: _PrimaryServiceTile(
                    title: 'Repair Services',
                    subtitle: 'AC, TV, Camera, Laptop and more',
                    bgColor: const Color(0xFFFFF7ED),
                    borderColor: const Color(0xFFFFEDD5),
                    iconColor: const Color(0xFFEA580C),
                    icon: Icons.build_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ServiceRequestScreen(appState: widget.appState)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PrimaryServiceTile(
                    title: 'Shop Products',
                    subtitle: 'New electronics, accessories and more',
                    bgColor: const Color(0xFFEFF6FF),
                    borderColor: const Color(0xFFDBEAFE),
                    iconColor: const Color(0xFF2563EB),
                    icon: Icons.shopping_cart_rounded,
                    onTap: () => widget.onNavigateTab(2), // Shop
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PrimaryServiceTile(
                    title: 'Used Products',
                    subtitle: 'Quality second-hand items at great prices',
                    bgColor: const Color(0xFFF0FDF4),
                    borderColor: const Color(0xFFDCFCE7),
                    iconColor: const Color(0xFF16A34A),
                    icon: Icons.recycling_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => UsedProductsScreen(appState: widget.appState)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PrimaryServiceTile(
                    title: 'Custom Request',
                    subtitle: 'Need something specific? Tell us, we\'ll arrange it.',
                    bgColor: const Color(0xFFFAF5FF),
                    borderColor: const Color(0xFFF3E8FF),
                    iconColor: const Color(0xFF9333EA),
                    icon: Icons.description_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SourceRequestScreen(appState: widget.appState)),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Popular Services Row with Arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Services',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                InkWell(
                  onTap: () => widget.onNavigateTab(1), // Repairs
                  child: const Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF475569)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal Scroll of Popular Services
            SizedBox(
              height: 108,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _popularServices.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final item = _popularServices[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServiceRequestScreen(
                                appState: widget.appState,
                                initialCategory: item['category'],
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 82,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(item['imageUrl']!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['title']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                  height: 1.15,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Floating Circle Next Arrow Button
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // "Something not working?" Repair Promotion Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                children: [
                  // Left info & Request Button
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            children: [
                              TextSpan(text: 'Something '),
                              TextSpan(text: 'not working?', style: TextStyle(color: Color(0xFFF97316))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Free inspection & visit. Final quotation after diagnosis.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ServiceRequestScreen(appState: widget.appState)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Request a Repair',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 3),
                                Icon(Icons.arrow_forward, size: 12),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Image
                  Container(
                    width: 86,
                    height: 86,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/repair_banner.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Right 4 Checkmark bullets
                  const Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CheckBullet(text: 'Inspection Free'),
                        SizedBox(height: 5),
                        _CheckBullet(text: 'Visit Free'),
                        SizedBox(height: 5),
                        _CheckBullet(text: 'Expert Technicians'),
                        SizedBox(height: 5),
                        _CheckBullet(text: 'Quality Service'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Featured Products Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Featured Products',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                InkWell(
                  onTap: () => widget.onNavigateTab(2), // Shop
                  child: const Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF475569)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Horizontal Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedCategory = cat),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Horizontal Product Grid / Cards
            StreamBuilder<List<ProductModel>>(
              stream: FirestoreService().streamProducts(),
              builder: (context, snapshot) {
                final liveProducts = snapshot.data ?? [];
                final List<Map<String, dynamic>> displayItems = liveProducts.isNotEmpty
                    ? liveProducts.map((p) => {
                          'id': p.id,
                          'name': p.name,
                          'brand': p.brand,
                          'price': p.price,
                          'isHot': false,
                          'imageUrl': p.imageUrl ?? 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?auto=format&fit=crop&w=400&q=80',
                        }).toList()
                    : _featuredFallback;

                return SizedBox(
                  height: 185,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: displayItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = displayItems[index];
                      return Container(
                        width: 145,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image with Heart Favorite Button & Optional Hot Badge
                            Stack(
                              children: [
                                Container(
                                  height: 95,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                    image: DecorationImage(
                                      image: NetworkImage(item['imageUrl']!),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(220),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.favorite_border, size: 14, color: Color(0xFF94A3B8)),
                                  ),
                                ),
                                if (item['isHot'] == true)
                                  Positioned(
                                    left: 8,
                                    bottom: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'Hot',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            // Name & Price
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 11,
                                            color: Color(0xFF0F172A),
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: 'NPR ',
                                              style: TextStyle(
                                                color: Color(0xFF94A3B8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 9.5,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '${item['price']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 11.5,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${item['name']} added to cart'),
                                              backgroundColor: const Color(0xFFF97316),
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                          ),
                                          child: const Icon(Icons.shopping_cart_outlined, size: 13, color: Color(0xFF475569)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 1. Dual Promotional Cards (Pre-owned & Sourcing)
            Row(
              children: [
                // Left Card: Quality Pre-owned Gear
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => UsedProductsScreen(appState: widget.appState)),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 135,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/preowned_gear.jpg'),
                          fit: BoxFit.cover,
                          alignment: Alignment.centerRight,
                          colorFilter: ColorFilter.mode(
                            Color(0xBB0F172A),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quality\nPre-owned Gear',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  height: 1.15,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Cameras, lenses, drones and more.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Explore Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(Icons.arrow_forward, size: 11, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Right Card: Can't find what you need?
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SourceRequestScreen(appState: widget.appState)),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 135,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF8F3),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF3E8D8)),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/sourcing_boxes.jpg'),
                          fit: BoxFit.cover,
                          alignment: Alignment.centerRight,
                          colorFilter: ColorFilter.mode(
                            Color(0x33FFFFFF),
                            BlendMode.dstATop,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Can't find what you need?",
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  height: 1.15,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Request a product and we'll source it for you.",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 9,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Request Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(Icons.arrow_forward, size: 11, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 2. Why Choose Sharma Video Care? Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Why Choose Sharma Video Care?',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: const Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward, size: 13, color: Color(0xFF475569)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 4 Feature Pillars Row
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _FeatureBenefitTile(
                    icon: Icons.verified_user_outlined,
                    iconColor: Color(0xFFEA580C),
                    title: 'Experienced\nTechnicians',
                    subtitle: 'Skilled and trusted',
                  ),
                  SizedBox(width: 8),
                  _FeatureBenefitTile(
                    icon: Icons.local_shipping_outlined,
                    iconColor: Color(0xFFEA580C),
                    title: 'Nationwide\nDelivery',
                    subtitle: 'Safe and reliable',
                  ),
                  SizedBox(width: 8),
                  _FeatureBenefitTile(
                    icon: Icons.settings_suggest_outlined,
                    iconColor: Color(0xFFEA580C),
                    title: 'Quality\nProducts',
                    subtitle: 'New and pre-owned',
                  ),
                  SizedBox(width: 8),
                  _FeatureBenefitTile(
                    icon: Icons.headset_mic_outlined,
                    iconColor: Color(0xFFEA580C),
                    title: 'Customer\nSupport',
                    subtitle: "We're here to help",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 3. Popular Brands Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Brands',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                InkWell(
                  onTap: () => widget.onNavigateTab(2), // Shop
                  child: const Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward, size: 13, color: Color(0xFF475569)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _BrandCard(name: 'Canon', color: Color(0xFFCC0000)),
                  SizedBox(width: 8),
                  _BrandCard(name: 'SONY', isBoldSerif: true),
                  SizedBox(width: 8),
                  _BrandCard(name: 'Nikon', isNikon: true),
                  SizedBox(width: 8),
                  _BrandCard(name: 'DJI', isDji: true),
                  SizedBox(width: 8),
                  _BrandCard(name: 'GoPro', isGoPro: true),
                  SizedBox(width: 8),
                  _BrandCard(name: 'Apple', icon: Icons.apple),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 4. What Our Customers Say Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'What Our Customers Say',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: const Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward, size: 13, color: Color(0xFF475569)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _TestimonialCard(
                    name: 'Ramesh Yadav',
                    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80',
                    review: 'Camera lens repair was done perfectly. Professional and friendly service. Highly recommend!',
                  ),
                  SizedBox(width: 10),
                  _TestimonialCard(
                    name: 'Sita Sharma',
                    avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=120&q=80',
                    review: "Bought a used camera and it's in excellent condition. Great support from the team.",
                  ),
                  SizedBox(width: 10),
                  _TestimonialCard(
                    name: 'Aman Thapa',
                    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&q=80',
                    review: 'Fast service for my laptop repair. Transparent pricing and very helpful staff.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. Get Updates & Offers Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: const Icon(Icons.mail_outline_rounded, color: Color(0xFFF97316), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Get Updates & Offers',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Be the first to know about new products, services and special offers.',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF64748B),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(3),
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Thank you for subscribing to updates!'),
                                  backgroundColor: Color(0xFFF97316),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Text('Subscribe', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
      },
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String line1;
  final String line2;

  const _HeroBadge({
    required this.icon,
    required this.line1,
    required this.line2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFF97316), size: 16),
        const SizedBox(width: 5),
        Text(
          '$line1\n$line2',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class _PrimaryServiceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryServiceTile({
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 86,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon squircle
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF64748B),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Circular Right Arrow Icon
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(200),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward, size: 11, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckBullet extends StatelessWidget {
  final String text;

  const _CheckBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: const BoxDecoration(
            color: Color(0xFFF97316),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 10, color: Colors.white),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _FeatureBenefitTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _FeatureBenefitTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF64748B),
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final String name;
  final Color? color;
  final IconData? icon;
  final bool isBoldSerif;
  final bool isNikon;
  final bool isDji;
  final bool isGoPro;

  const _BrandCard({
    required this.name,
    this.color,
    this.icon,
    this.isBoldSerif = false,
    this.isNikon = false,
    this.isDji = false,
    this.isGoPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: 22, color: const Color(0xFF1E293B))
          : Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: color ?? const Color(0xFF0F172A),
                fontFamily: isBoldSerif ? 'Georgia' : (isNikon ? 'Courier' : null),
                fontStyle: isNikon ? FontStyle.italic : FontStyle.normal,
                letterSpacing: isDji ? 1.5 : (isGoPro ? 0.5 : 0.2),
              ),
            ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final String review;

  const _TestimonialCard({
    required this.name,
    required this.avatarUrl,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star, size: 10, color: Color(0xFFFBBF24)),
                        Icon(Icons.star, size: 10, color: Color(0xFFFBBF24)),
                        Icon(Icons.star, size: 10, color: Color(0xFFFBBF24)),
                        Icon(Icons.star, size: 10, color: Color(0xFFFBBF24)),
                        Icon(Icons.star, size: 10, color: Color(0xFFFBBF24)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF475569),
              height: 1.35,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
