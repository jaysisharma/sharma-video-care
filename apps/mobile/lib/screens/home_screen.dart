import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../services/localization_service.dart';
import 'service_request_screen.dart';
import 'used_screen.dart';
import 'estimator_screen.dart';
import 'trade_in_screen.dart';
import 'cart_screen.dart';
import 'notifications_screen.dart';
import 'search_screen.dart';
import 'shop_screen.dart';
import '../data/used_products_data.dart';
import '../utils/format.dart';
import '../widgets/delivery_hub_sheet.dart';
import '../widgets/product_cart_stepper_button.dart';
import '../widgets/product_image.dart';
import '../widgets/svc_snackbar.dart';
import '../widgets/used_inspection_sheets.dart';

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
  // Navigation / Filter State
  String _selectedCategory = 'All';

  // Scroll Controller
  final ScrollController _scrollController = ScrollController();

  // One Firestore subscription feeds both Flash Deals and the product feed
  StreamSubscription<List<ProductModel>>? _productsSub;
  final ValueNotifier<List<ProductModel>> _liveProducts = ValueNotifier(const []);
  late final Stream<List<UsedProductModel>> _usedProductsStream;

  // Hero Banner Carousel State
  late final PageController _heroController;
  int _currentHeroIndex = 0;
  Timer? _heroAutoTimer;

  // Flash Deals Countdown State
  // Ticks every second so the flash-deal countdown (and expiry) stays live
  final ValueNotifier<DateTime> _clock = ValueNotifier(DateTime.now());
  Timer? _countdownTimer;

  // Infinite Scrolling Products State
  // Product feed paging
  static const int _initialProductCount = 12;
  static const int _pageSize = 8;
  int _visibleProductCount = _initialProductCount;

  final List<String> _categories = [
    'All',
    'Cameras',
    'Lenses',
    'Drones',
    'Laptops',
    'Audio',
    'Accessories',
  ];

  // Carousel Hero Banners
  final List<Map<String, dynamic>> _heroSlides = [
    {
      'tag': 'CAMERA & OPTICS FEST • UP TO 35% OFF',
      'tagNe': 'क्यामेरा तथा अप्टिक्स महोत्सव • ३५% सम्म छुट',
      'title': 'Certified Cameras & Lens Marketplace',
      'titleNe': 'प्रमाणित क्यामेरा तथा लेन्स बजार',
      'subtitle': '45-point lab inspected Sony, Canon & Nikon bodies with 6-month warranty.',
      'subtitleNe': '४५-बुँदे ल्याब परीक्षण पास सोनी, क्यानन र निकोन क्यामेरा ६ महिना वारेन्टीसहित।',
      'imageAsset': 'assets/images/hero_tech_gear.jpg',
      'imageUrl': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80',
      'actionType': 'used',
      'btnText': 'Explore Gear',
      'btnTextNe': 'गियर हेर्नुहोस्',
    },
    {
      'tag': 'INSTANT VALUATION • JANAKPUR LAB',
      'tagNe': 'तत्काल मूल्याङ्कन • जनकपुर ल्याब',
      'title': 'Sell / Trade-In Your Old Gear in 15 Mins',
      'titleNe': 'पुरानो क्यामेरा १५ मिनेटमै साट्नुहोस् वा बेच्नुहोस्',
      'subtitle': 'Get immediate benchmark cash buyout or +10% bonus store credit upgrade.',
      'subtitleNe': 'तत्काल नगद भुक्तानी पाउनुहोस् वा नयाँ क्यामेरामा +१०% थप स्टोर क्रेडिट पाउनुहोस्।',
      'imageAsset': 'assets/images/preowned_gear.jpg',
      'imageUrl': 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?auto=format&fit=crop&w=800&q=80',
      'actionType': 'trade_in',
      'btnText': 'Value Your Gear',
      'btnTextNe': 'मूल्याङ्कन निकाल्नुहोस्',
    },
    {
      'tag': 'CLEANROOM LAB • CHIP-LEVEL SERVICE',
      'tagNe': 'जनकपुर प्राविधिक ल्याब • चिप-लेभल मर्मत',
      'title': 'Precision Optical & Board Repair',
      'titleNe': 'सटिक क्यामेरा, लेन्स र बोर्ड मर्मत',
      'subtitle': 'Expert sensor cleaning, optical collimation, and drone gimbal calibration.',
      'subtitleNe': 'विशेषज्ञ सेन्सर सफाइ, अप्टिकल क्यालिब्रेसन र ड्रोन गिम्बल मर्मत।',
      'imageAsset': 'assets/images/repair_banner.jpg',
      'imageUrl': 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=800&q=80',
      'actionType': 'estimator',
      'btnText': 'Cost Estimator',
      'btnTextNe': 'खर्च क्याल्कुलेटर',
    },
    {
      'tag': 'DOORSTEP SERVICE • MADHESH EXPRESS',
      'tagNe': 'घरदैलो सेवा • मधेश एक्सप्रेस',
      'title': 'Certified AC & Home Appliance Care',
      'titleNe': 'प्रमाणित एसी तथा घरेलु उपकरण मर्मत',
      'subtitle': 'Inverter AC chemical wash, gas refilling, and quick home visits within 2 hrs.',
      'subtitleNe': 'इन्भर्टर एसी सफाइ, ग्यास रिफिल र २ घण्टाभित्र भरपर्दो घरदैलो सेवा।',
      'imageAsset': 'assets/images/promo_ac.jpg',
      'imageUrl': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=800&q=80',
      'actionType': 'ac_service',
      'btnText': 'Book AC Service',
      'btnTextNe': 'एसी मर्मत बुक गर्नुहोस्',
    },
  ];

  // 8 Marketplace Department Bubbles
  final List<Map<String, dynamic>> _departments = [
    {
      'name': 'Cameras',
      'nameNe': 'क्यामेरा',
      'icon': Icons.camera_alt_rounded,
      'color': const Color(0xFFEA580C),
      'asset': 'assets/images/products/canon_eos.jpg',
      'action': 'shop_camera',
    },
    {
      'name': 'Pre-Owned',
      'nameNe': 'सेकेन्ड-ह्यान्ड',
      'icon': Icons.verified_rounded,
      'color': const Color(0xFF16A34A),
      'asset': 'assets/images/preowned_gear.jpg',
      'action': 'used',
    },
    {
      'name': 'Lenses',
      'nameNe': 'लेन्सहरू',
      'icon': Icons.filter_center_focus_rounded,
      'color': const Color(0xFF2563EB),
      'asset': 'assets/images/products/sony_lens.jpg',
      'action': 'shop_lens',
    },
    {
      'name': 'Drones',
      'nameNe': 'ड्रोन',
      'icon': Icons.flight_rounded,
      'color': const Color(0xFF0D9488),
      'asset': 'assets/images/products/dji_drone.jpg',
      'action': 'shop_drone',
    },
    {
      'name': 'Laptops',
      'nameNe': 'ल्यापटप',
      'icon': Icons.laptop_mac_rounded,
      'color': const Color(0xFF7C3AED),
      'asset': 'assets/images/products/macbook_pro.jpg',
      'action': 'shop_laptop',
    },
    {
      'name': 'AC Care',
      'nameNe': 'एसी सेवा',
      'icon': Icons.ac_unit_rounded,
      'color': const Color(0xFF0284C7),
      'asset': 'assets/images/products/ac_unit.jpg',
      'action': 'repair_ac',
    },
    {
      'name': 'Smart TV',
      'nameNe': 'स्मार्ट टिभी',
      'icon': Icons.tv_rounded,
      'color': const Color(0xFFDC2626),
      'asset': 'assets/images/services/tv_repair.jpg',
      'action': 'repair_tv',
    },
    {
      'name': 'CCTV',
      'nameNe': 'सीसीटिभी',
      'icon': Icons.videocam_rounded,
      'color': const Color(0xFF059669),
      'asset': 'assets/images/products/hikvision_cctv.jpg',
      'action': 'repair_cctv',
    },
    {
      'name': 'All Repairs',
      'nameNe': 'सबै मर्मत',
      'icon': Icons.handyman_rounded,
      'color': const Color(0xFFD97706),
      'asset': 'assets/images/card_repair.jpg',
      'action': 'repair_all',
    },
  ];

  // Popular Services Grid
  final List<Map<String, dynamic>> _popularServices = [
    {
      'title': 'Camera\nRepair',
      'titleNe': 'क्यामेरा\nमर्मत',
      'category': 'Camera',
      'imageUrl': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=300&q=80',
      'isSoon': false,
    },
    {
      'title': 'AC\nRepair',
      'titleNe': 'एसी\nमर्मत',
      'category': 'AC',
      'imageUrl': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=300&q=80',
      'isSoon': false,
    },
    {
      'title': 'Laptop\nRepair',
      'titleNe': 'ल्यापटप\nमर्मत',
      'category': 'Laptop',
      'imageUrl': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=300&q=80',
      'isSoon': false,
    },
    {
      'title': 'TV\nRepair',
      'titleNe': 'टिभी\nमर्मत',
      'category': 'TV & Display',
      'imageUrl': 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=300&q=80',
      'isSoon': false,
    },
    {
      'title': 'Washing\nMachine',
      'titleNe': 'वाशिङ\nमेसिन',
      'category': 'Washing Machine',
      'imageUrl': 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=300&q=80',
      'isSoon': false,
    },
    {
      'title': 'CCTV\nSetup',
      'titleNe': 'सीसीटिभी\nजडान',
      'category': 'CCTV',
      'imageUrl': 'https://images.unsplash.com/photo-1557597774-9d273605dfa9?auto=format&fit=crop&w=300&q=80',
      'isSoon': false,
    },
    {
      'title': 'Plumber\n(Pipe/Tap)',
      'titleNe': 'प्लम्बर\n(धारा/पाइप)',
      'category': 'Plumber (Coming Soon)',
      'imageUrl': 'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?auto=format&fit=crop&w=300&q=80',
      'isSoon': true,
    },
    {
      'title': 'Furniture\n(Carpentry)',
      'titleNe': 'फर्निचर\n(काठ काम)',
      'category': 'Furniture (Coming Soon)',
      'imageUrl': 'https://images.unsplash.com/photo-1538688525198-9b88f6f53126?auto=format&fit=crop&w=300&q=80',
      'isSoon': true,
    },
  ];

  // Master Gear Catalog for Infinite Scrolling Marketplace Feed
  final List<Map<String, dynamic>> _masterGearCatalog = [
    {
      'id': 'gear-1',
      'name': 'Canon EOS R5 Mirrorless 8K Body',
      'brand': 'CANON',
      'category': 'Cameras',
      'price': 485000,
      'originalPrice': 540000,
      'discount': '-10%',
      'rating': 4.9,
      'reviewsCount': 46,
      'isHot': true,
      'isNew': false,
      'specs': '45MP Full-Frame • 8K RAW • In-Body IS • Dual CFexpress/SD Slots',
      'warranty': '1-Year Official Canon Nepal Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-2',
      'name': 'Sony Alpha A7 IV Full-Frame Body',
      'brand': 'SONY',
      'category': 'Cameras',
      'price': 320000,
      'originalPrice': 385000,
      'discount': '-17%',
      'rating': 4.8,
      'reviewsCount': 89,
      'isHot': true,
      'isNew': false,
      'specs': '33MP Exmor R CMOS • 4K 60p 10-Bit • S-Cinetone • Real-Time AF',
      'warranty': '1-Year Official Sony Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-3',
      'name': 'DJI Mini 4 Pro Drone with RC 2 Screen',
      'brand': 'DJI',
      'category': 'Drones',
      'price': 165000,
      'originalPrice': 195000,
      'discount': '-15%',
      'rating': 4.9,
      'reviewsCount': 52,
      'isHot': true,
      'isNew': true,
      'specs': '< 249g • Omnidirectional Sensing • 4K/60fps HDR • 20km O4 Range',
      'warranty': 'Official DJI Nepal Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1527977966376-1c8408f9f108?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-4',
      'name': 'Sony FE 50mm f/1.8 Compact Prime Lens',
      'brand': 'SONY',
      'category': 'Lenses',
      'price': 42000,
      'originalPrice': 52000,
      'discount': '-19%',
      'rating': 4.7,
      'reviewsCount': 114,
      'isHot': false,
      'isNew': false,
      'specs': 'E-Mount Full-Frame • Fast f/1.8 Aperture • 7-Blade Circular Aperture',
      'warranty': '1-Year Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1617005082133-548c4dd27f35?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-5',
      'name': 'Apple MacBook Pro M3 Pro 14" (18GB/512GB)',
      'brand': 'APPLE',
      'category': 'Laptops',
      'price': 295000,
      'originalPrice': 335000,
      'discount': '-12%',
      'rating': 4.9,
      'reviewsCount': 34,
      'isHot': true,
      'isNew': true,
      'specs': 'Apple M3 Pro 11-Core CPU • 14-Core GPU • Liquid Retina XDR • Space Black',
      'warranty': '1-Year Apple Care Official',
      'imageUrl': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-6',
      'name': 'Canon RF 70-200mm f/2.8L IS USM',
      'brand': 'CANON',
      'category': 'Lenses',
      'price': 360000,
      'originalPrice': 399000,
      'discount': '-10%',
      'rating': 5.0,
      'reviewsCount': 28,
      'isHot': false,
      'isNew': false,
      'specs': 'L-Series Telephoto Zoom • Optical Stabilizer 5 Stops • Dual Nano USM',
      'warranty': 'Official Canon Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1606999122070-2629b4e54446?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-7',
      'name': 'Nikon Z8 Flagship Full-Frame Mirrorless',
      'brand': 'NIKON',
      'category': 'Cameras',
      'price': 540000,
      'originalPrice': 585000,
      'discount': '-8%',
      'rating': 4.9,
      'reviewsCount': 21,
      'isHot': false,
      'isNew': true,
      'specs': '45.7MP Stacked Sensor • 8.3K 60p RAW • Subject Detection • Internal 12-Bit',
      'warranty': '1-Year Nikon Nepal Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1512790182412-b19e6d62bc39?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-8',
      'name': 'Fujifilm X-T5 Mirrorless Body (Black)',
      'brand': 'FUJIFILM',
      'category': 'Cameras',
      'price': 235000,
      'originalPrice': 260000,
      'discount': '-10%',
      'rating': 4.8,
      'reviewsCount': 63,
      'isHot': true,
      'isNew': false,
      'specs': '40.2MP X-Trans CMOS 5 HR • 7-Stop In-Body IS • 6.2K 30p Video',
      'warranty': '1-Year Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1510127034890-ba27508e9f1c?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-9',
      'name': 'Sigma 24-70mm f/2.8 DG DN Art Sony E',
      'brand': 'SIGMA',
      'category': 'Lenses',
      'price': 148000,
      'originalPrice': 165000,
      'discount': '-10%',
      'rating': 4.8,
      'reviewsCount': 72,
      'isHot': false,
      'isNew': false,
      'specs': 'Constant f/2.8 Max Aperture • 11-Blade Rounded Diaphragm • Dust-Proof',
      'warranty': '1-Year Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1617005082133-548c4dd27f35?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-10',
      'name': 'DJI Air 3 Fly More Combo with RC 2',
      'brand': 'DJI',
      'category': 'Drones',
      'price': 215000,
      'originalPrice': 240000,
      'discount': '-10%',
      'rating': 4.9,
      'reviewsCount': 41,
      'isHot': false,
      'isNew': true,
      'specs': 'Dual Primary Cameras 1/1.3" CMOS • 46-Min Max Flight • 4K/60fps HDR',
      'warranty': 'Official DJI Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1508614589041-895b88991e3e?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-11',
      'name': 'Apple MacBook Air M2 13" (8GB/256GB)',
      'brand': 'APPLE',
      'category': 'Laptops',
      'price': 185000,
      'originalPrice': 205000,
      'discount': '-10%',
      'rating': 4.9,
      'reviewsCount': 105,
      'isHot': false,
      'isNew': false,
      'specs': 'Apple M2 Chip • 13.6" Liquid Retina • MagSafe 3 • 18 hrs Battery',
      'warranty': '1-Year Official Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-12',
      'name': 'Rode Wireless PRO Dual-Channel Mic System',
      'brand': 'RODE',
      'category': 'Audio',
      'price': 58000,
      'originalPrice': 68000,
      'discount': '-15%',
      'rating': 4.9,
      'reviewsCount': 37,
      'isHot': true,
      'isNew': true,
      'specs': '32-Bit Float Recording • Timecode Sync • 260m Transmission Range',
      'warranty': 'Official Rode Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-13',
      'name': 'Godox AD200 Pro TTL Pocket Outdoor Flash',
      'brand': 'GODOX',
      'category': 'Accessories',
      'price': 44000,
      'originalPrice': 52000,
      'discount': '-15%',
      'rating': 4.8,
      'reviewsCount': 59,
      'isHot': false,
      'isNew': false,
      'specs': '200Ws Output • Bare Bulb & Speedlite Heads • 2.4G Wireless TTL',
      'warranty': '1-Year Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-14',
      'name': 'Sony WH-1000XM5 Wireless ANC Headphones',
      'brand': 'SONY',
      'category': 'Audio',
      'price': 48000,
      'originalPrice': 56000,
      'discount': '-14%',
      'rating': 4.8,
      'reviewsCount': 81,
      'isHot': false,
      'isNew': false,
      'specs': 'Noise Cancellation • Auto NC Optimizer • 30hr Battery • LDAC Hi-Res',
      'warranty': '1-Year Official Sony Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-15',
      'name': 'SanDisk Extreme Pro 128GB SDXC UHS-II',
      'brand': 'SANDISK',
      'category': 'Accessories',
      'price': 14500,
      'originalPrice': 18000,
      'discount': '-19%',
      'rating': 4.8,
      'reviewsCount': 140,
      'isHot': false,
      'isNew': false,
      'specs': 'Up to 300MB/s Read • V90 8K Video Speed Class • Shock & X-Ray Proof',
      'warranty': 'Lifetime Limited Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1590212151175-e58edd96185b?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 'gear-16',
      'name': 'Zhiyun Crane 4 Handheld 3-Axis Gimbal',
      'brand': 'ZHIYUN',
      'category': 'Accessories',
      'price': 85000,
      'originalPrice': 98000,
      'discount': '-13%',
      'rating': 4.7,
      'reviewsCount': 22,
      'isHot': false,
      'isNew': true,
      'specs': 'Cinema & DSLR Payload • Built-in 10W Fill Light • Balance Indicators',
      'warranty': '1-Year Warranty',
      'imageUrl': 'https://images.unsplash.com/photo-1546776310-eef45dd6d63c?auto=format&fit=crop&w=600&q=80',
    },
  ];

  /// Products shown in the feed: live Firestore products, or the built-in
  /// catalogue while the store has none. Filtered by the selected category.
  List<Map<String, dynamic>> _feedItems(List<ProductModel> liveProducts) {
    final List<Map<String, dynamic>> source = liveProducts.isNotEmpty
        ? liveProducts.map((p) => {
              'id': p.id,
              'name': p.name,
              'brand': p.brand.toUpperCase(),
              'category': p.categoryName,
              'price': p.price,
              'originalPrice': p.originalPrice ?? (p.price * 1.15).toInt(),
              'discount': p.hasDiscount ? '-${p.discountPercent}%' : '-12%',
              'rating': 4.9,
              'reviewsCount': 42,
              'isHot': true,
              'isNew': true,
              'specs': p.description,
              'warranty': p.warrantyInfo,
              'imageUrl': p.imageUrl ?? 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?auto=format&fit=crop&w=600&q=80',
            }).toList()
        : _masterGearCatalog;
    if (_selectedCategory == 'All') return source;
    final selected = _selectedCategory.toLowerCase();
    return source.where((i) => (i['category'] ?? '').toString().toLowerCase().contains(selected)).toList();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 600) {
      _showMoreProducts();
    }
  }

  void _showMoreProducts() {
    if (_visibleProductCount >= _feedItems(_liveProducts.value).length) return;
    setState(() => _visibleProductCount += _pageSize);
  }

  @override
  void initState() {
    super.initState();
    _heroController = PageController();
    try {
      _productsSub = FirestoreService().streamProducts().listen(
        (products) {
          if (mounted) _liveProducts.value = products;
        },
        onError: (Object e) => debugPrint('Home products stream error: $e'),
      );
    } catch (e) {
      debugPrint('HomeScreen products listen error: $e');
    }
    try {
      _usedProductsStream = FirestoreService().streamUsedProducts();
    } catch (e) {
      debugPrint('HomeScreen used products stream error: $e');
      _usedProductsStream = Stream.value(const <UsedProductModel>[]);
    }
    _scrollController.addListener(_onScroll);

    // Auto-advance hero carousel every 4.5 seconds
    _heroAutoTimer = Timer.periodic(const Duration(milliseconds: 4500), (timer) {
      if (_isVisibleTab && _heroController.hasClients) {
        final nextIndex = (_currentHeroIndex + 1) % _heroSlides.length;
        _heroController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    // Flash deals 1-second countdown ticker
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isVisibleTab) _clock.value = DateTime.now();
    });
  }

  /// False while another bottom tab is showing (MainNavigationScreen turns
  /// TickerMode off for hidden tabs), so the timers above skip their work.
  bool get _isVisibleTab => mounted && TickerMode.valuesOf(context).enabled;

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _heroAutoTimer?.cancel();
    _countdownTimer?.cancel();
    _clock.dispose();
    _productsSub?.cancel();
    _liveProducts.dispose();
    _heroController.dispose();
    super.dispose();
  }

  void _handleSlideAction(String actionType) {
    switch (actionType) {
      case 'used':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UsedProductsScreen(appState: widget.appState)),
        );
        break;
      case 'trade_in':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TradeInScreen(appState: widget.appState)),
        );
        break;
      case 'estimator':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EstimatorScreen(appState: widget.appState)),
        );
        break;
      case 'ac_service':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceRequestScreen(
              appState: widget.appState,
              initialCategory: 'AC',
            ),
          ),
        );
        break;
      default:
        widget.onNavigateTab(2); // Shop
    }
  }

  // Department bubble action -> Shop category chip it opens on
  static const Map<String, String> _shopDepartmentCategories = {
    'shop_camera': 'Cameras',
    'shop_lens': 'Lenses',
    'shop_drone': 'Drones',
    'shop_laptop': 'Laptops',
  };

  void _handleDepartmentAction(String action) {
    if (action == 'used') {
      widget.onNavigateTab(3); // Pre-Owned Tab in Bottom Nav
    } else if (_shopDepartmentCategories.containsKey(action)) {
      final category = _shopDepartmentCategories[action]!;
      final dept = _departments.firstWhere((d) => d['action'] == action);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShopScreen(
            appState: widget.appState,
            initialCategory: category,
            pageTitle: SvcLocalization.isNepali ? dept['nameNe'] : dept['name'],
          ),
        ),
      );
    } else if (action == 'repair_ac') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceRequestScreen(appState: widget.appState, initialCategory: 'AC'),
        ),
      );
    } else if (action == 'repair_tv') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceRequestScreen(appState: widget.appState, initialCategory: 'TV & Display'),
        ),
      );
    } else if (action == 'repair_cctv') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceRequestScreen(appState: widget.appState, initialCategory: 'CCTV'),
        ),
      );
    } else {
      widget.onNavigateTab(1); // Repairs Tab
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (d.isNegative) d = Duration.zero;
    final days = d.inDays;
    final hours = twoDigits(d.inHours.remainder(24));
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    final clock = '$hours:$minutes:$seconds';
    return days > 0 ? '${days}d $clock' : clock;
  }

  @override
  Widget build(BuildContext context) {
    final isNe = SvcLocalization.isNepali;

    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: SvcColors.canvas,
          // ==========================================
          // 1. PROPER MARKETPLACE APPBAR (2 Tiers)
          // ==========================================
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(116),
            child: Container(
              decoration: BoxDecoration(
                color: SvcColors.surface,
                border: Border(bottom: BorderSide(color: SvcColors.border.withValues(alpha: 0.8))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tier 1: Delivery Location & Utility Badges (Clean Modern Header)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Location Icon + Delivering to + City / Hub (Tappable to change hub)
                          Expanded(
                            child: InkWell(
                              onTap: () => showDeliveryHubSheet(context, widget.appState),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      color: SvcColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            isNe ? 'डेलिभरी ठेगाना' : 'Delivering to',
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: SvcColors.muted,
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  widget.appState.selectedDeliveryHub,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: -0.2,
                                                    color: SvcColors.ink,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              const Icon(
                                                Icons.keyboard_arrow_down_rounded,
                                                color: SvcColors.ink,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Notification Bell with Unread Badge
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NotificationsScreen(appState: widget.appState),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: SvcColors.canvas,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: SvcColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    size: 20,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                if (widget.appState.unreadNotificationCount > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: SvcColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                      child: Text(
                                        widget.appState.unreadNotificationCount > 9 ? '9+' : '${widget.appState.unreadNotificationCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Cart Button with Live Badge
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => CartScreen(appState: widget.appState)),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: SvcColors.canvas,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: SvcColors.border),
                                  ),
                                  child: const Icon(Icons.shopping_cart_outlined, size: 20, color: Color(0xFF1E293B)),
                                ),
                                if (widget.appState.cartCount > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: SvcColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                      child: Text(
                                        widget.appState.cartCount > 9 ? '9+' : '${widget.appState.cartCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),

                      // Tier 2: Marketplace Search Bar Header
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SearchScreen(appState: widget.appState)),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: SvcColors.canvas,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: SvcColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: SvcColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isNe
                                      ? 'क्यामेरा, लेन्स, ड्रोन, एसी वा मर्मत खोज्नुहोस्...'
                                      : 'Search cameras, lenses, drones, AC or repairs...',
                                  style: const TextStyle(
                                    color: SvcColors.muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.tune_rounded, color: SvcColors.primaryDark, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // 2. MAIN SCROLLABLE MARKETPLACE FEED
          // ==========================================
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Section 1: Auto-Scrolling Hero Promotional Banner Carousel
                    _buildHeroCarousel(isNe),

                    const SizedBox(height: 16),

                    // Section 2: Marketplace Department Bubbles (8 Visual Categories)
                    _buildDepartmentBubbles(isNe),

                    const SizedBox(height: 18),

                    // Section 3: Flash Deals / Steals Carousel (With Live Countdown)
                    _buildFlashDealsSection(isNe),

                    // Section 4: 4 Core Marketplace Pillars (Matching Web CategoryCards.tsx)
                    _buildFourPillarsSection(isNe),

                    const SizedBox(height: 20),

                    // Section 5: Certified Pre-Owned & Second-Hand Gear Marketplace Spotlight
                    _buildCertifiedUsedSpotlight(isNe),

                    const SizedBox(height: 20),

                    // Section 6: Interactive Repair Cost Estimator Spotlight Banner
                    _buildEstimatorSpotlightBanner(isNe),

                    const SizedBox(height: 20),

                    // Section 7: Popular On-Demand Services Grid (With Plumber & Carpentry SOON)
                    _buildPopularServicesSection(isNe),

                    const SizedBox(height: 20),

                    // Section 8: Infinite Scrolling 2-Column Marketplace Product Feed
                    _buildStoreCatalogueHeader(isNe),
                  ],
                ),
              ),
              _buildStoreCatalogueGrid(isNe),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 40),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStoreCatalogueFooter(isNe),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // SECTION BUILDERS
  // =========================================================================

  /// Section 1: Auto-Scrolling Hero Promotional Banner Carousel
  Widget _buildHeroCarousel(bool isNe) {
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _heroController,
            onPageChanged: (idx) {
              setState(() => _currentHeroIndex = idx);
            },
            itemCount: _heroSlides.length,
            itemBuilder: (context, index) {
              final slide = _heroSlides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: InkWell(
                  onTap: () => _handleSlideAction(slide['actionType']),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Image with Fallback
                          Image.asset(
                            slide['imageAsset'],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => CachedNetworkImage(
                              imageUrl: slide['imageUrl'],
                              fit: BoxFit.cover,
                            ),
                          ),

                          // Deep Luxury Dark Gradient Scrim
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF0F0B08).withValues(alpha: 0.94),
                                  const Color(0xFF19120D).withValues(alpha: 0.85),
                                  Colors.transparent,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: const [0.0, 0.65, 1.0],
                              ),
                            ),
                          ),

                          // Banner Content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Kicker Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: SvcColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isNe ? slide['tagNe'] : slide['tag'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Title
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 240),
                                  child: Text(
                                    isNe ? slide['titleNe'] : slide['title'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w900,
                                      height: 1.15,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Subtitle
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 220),
                                  child: Text(
                                    isNe ? slide['subtitleNe'] : slide['subtitle'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 10.5,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Action Button
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isNe ? slide['btnTextNe'] : slide['btnText'],
                                        style: const TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_rounded, size: 12, color: SvcColors.primary),
                                    ],
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
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Carousel Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_heroSlides.length, (i) {
            final isActive = i == _currentHeroIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? SvcColors.primary : SvcColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Section 2: Marketplace Department Bubbles (8 Visual Categories)
  Widget _buildDepartmentBubbles(bool isNe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  isNe ? 'प्रमुख विभागहरू' : 'Shop by Department',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: SvcColors.ink,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              InkWell(
                onTap: () => widget.onNavigateTab(2), // Shop
                child: Text(
                  isNe ? 'सबै हेर्नुहोस् →' : 'View All →',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: SvcColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _departments.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final dept = _departments[index];
              return InkWell(
                onTap: () => _handleDepartmentAction(dept['action']),
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 66,
                  child: Column(
                    children: [
                      // Circular Bubble Container with Badge
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: (dept['color'] as Color).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (dept['color'] as Color).withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                dept['asset'],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  dept['icon'],
                                  color: dept['color'],
                                  size: 26,
                                ),
                              ),
                              // Tint overlay for icons
                              Container(
                                color: Colors.black.withValues(alpha: 0.08),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isNe ? dept['nameNe'] : dept['name'],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Section 3: Flash Deals / Steals Carousel (With Live Countdown).
  /// Products flagged `isFlashDeal` in Firestore; hidden when none are live.
  Widget _buildFlashDealsSection(bool isNe) {
    return ValueListenableBuilder<List<ProductModel>>(
      valueListenable: _liveProducts,
      builder: (context, products, _) => ValueListenableBuilder<DateTime>(
        valueListenable: _clock,
        builder: (context, now, _) {
          final deals = products.where((p) => p.isLiveFlashDeal(now)).toList()
            ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
          if (deals.isEmpty) return const SizedBox.shrink();
          final endsAt = deals
              .map((d) => d.flashDealEndsAt!)
              .reduce((a, b) => a.isBefore(b) ? a : b);
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildFlashDealsContent(deals, endsAt.difference(now), isNe),
          );
        },
      ),
    );
  }

  Widget _buildFlashDealsContent(List<ProductModel> deals, Duration remaining, bool isNe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Live Timer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 4),
                  Text(
                    isNe ? 'फ्ल्यास अफरहरू' : 'Flash Deals',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: SvcColors.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // Countdown Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.white, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(remaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              InkWell(
                onTap: () => widget.onNavigateTab(2), // Shop
                child: Text(
                  isNe ? 'सबै अफरहरू →' : 'See All →',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: SvcColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Horizontal Deal Cards
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: deals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final deal = deals[index];
              return Container(
                width: 148,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SvcColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SvcColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Container with Discount Tag
                    Stack(
                      children: [
                        Container(
                          height: 94,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SvcProductImage(source: deal.imageUrl, placeholderIconSize: 28),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          left: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${deal.discountPercent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Text(
                      deal.brand.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: SvcColors.muted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      deal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: SvcColors.ink,
                      ),
                    ),
                    const Spacer(),

                    // Price Row with Circular Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rs. ${(deal.price / 1000).toStringAsFixed(0)}k',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              '${(deal.originalPrice! / 1000).toStringAsFixed(0)}k',
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFF94A3B8),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        ProductCartStepperButton(
                          appState: widget.appState,
                          productId: deal.id,
                          productType: 'NEW',
                          name: deal.name,
                          unitPrice: deal.price,
                          imageUrl: deal.imageUrl,
                          height: 28,
                          compact: true,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Section 4: 4 Core Marketplace Pillars (Matching Web CategoryCards.tsx)
  Widget _buildFourPillarsSection(bool isNe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNe ? 'हाम्रा मुख्य सेवा तथा स्टोर' : 'Core Services & Marketplace',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: SvcColors.ink,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPillarCard(
                  title: isNe ? 'इलेक्ट्रोनिक्स मर्मत' : 'Electronics Repair',
                  desc: isNe ? 'क्यामेरा, लेन्स, टिभी, ड्रोन' : 'Cameras, Lenses, TVs, Drones',
                  tag: isNe ? 'ल्याब ग्यारेन्टी' : '45-Pt Lab Check',
                  gradientColors: [const Color(0xFFFFF7F2), const Color(0xFFFEEFE6)],
                  borderColor: const Color(0xFFFED7AA),
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
                child: _buildPillarCard(
                  title: isNe ? 'आधिकारिक टेक स्टोर' : 'Official Tech Store',
                  desc: isNe ? 'नयाँ सामान • नेपाल वारेन्टी' : 'Brand-New Gear with Warranty',
                  tag: isNe ? '१००% सक्कली' : '100% Genuine',
                  gradientColors: [const Color(0xFFF0F7FF), const Color(0xFFE2EEFD)],
                  borderColor: const Color(0xFFBFDBFE),
                  iconColor: const Color(0xFF2563EB),
                  icon: Icons.shopping_bag_rounded,
                  onTap: () => widget.onNavigateTab(2), // Shop
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPillarCard(
                  title: isNe ? 'प्रमाणित सेकेन्ड-ह्यान्ड' : 'Certified Pre-Owned',
                  desc: isNe ? 'ल्याब परीक्षण पास • ६ महिना वारेन्टी' : 'Inspected, Tested & Warranted',
                  tag: isNe ? 'साटासाट उपलब्ध' : 'Trade-In Ready',
                  gradientColors: [const Color(0xFFF0FDF4), const Color(0xFFDDFCE8)],
                  borderColor: const Color(0xFFBBF7D0),
                  iconColor: const Color(0xFF16A34A),
                  icon: Icons.verified_rounded,
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
                child: _buildPillarCard(
                  title: isNe ? 'सामान साट्नुहोस् / बेच्नुहोस्' : 'Sell & Trade-In Gear',
                  desc: isNe ? '१५ मिनेटमै तत्काल नगद भुक्तानी' : 'Instant Benchmark Buyout & Credit',
                  tag: isNe ? '+१०% स्टोर क्रेडिट' : '+10% Bonus',
                  gradientColors: [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF)],
                  borderColor: const Color(0xFFE9D5FF),
                  iconColor: const Color(0xFF9333EA),
                  icon: Icons.currency_exchange_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TradeInScreen(appState: widget.appState)),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section 5: Interactive Estimator Spotlight Banner
  Widget _buildEstimatorSpotlightBanner(bool isNe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SvcColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SvcColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isNe ? 'अनलाइन क्याल्कुलेटर' : 'ESTIMATOR',
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isNe ? 'पारदर्शी लागत' : 'Instant Pricing',
                        style: const TextStyle(fontSize: 10.5, color: SvcColors.muted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isNe ? 'मर्मत खर्च अनुमान क्याल्कुलेटर' : 'Live Repair Cost Estimator',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: SvcColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isNe
                        ? 'क्यामेरा, लेन्स वा टिभीको लक्षण छानेर पार्ट्स र श्रम शुल्कको तत्काल अनुमान निकाल्नुहोस्।'
                        : 'Select your gear & issue to get an instant transparent parts + labor quote.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: SvcColors.muted,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EstimatorScreen(appState: widget.appState)),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                      decoration: BoxDecoration(
                        color: SvcColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isNe ? 'खर्च अनुमान निकाल्नुहोस् →' : 'Calculate Estimate →',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: SvcColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calculate_outlined, color: SvcColors.primary, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  /// Section 6: Popular On-Demand Services Grid (With Plumber & Carpentry SOON)
  Widget _buildPopularServicesSection(bool isNe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isNe ? 'लोकप्रिय ल्याब तथा अन-डिमान्ड सेवाहरू' : 'Popular Lab & On-Demand Services',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: SvcColors.ink,
                  letterSpacing: -0.2,
                ),
              ),
              InkWell(
                onTap: () => widget.onNavigateTab(1), // Repairs Tab
                child: Text(
                  isNe ? 'सबै सेवाहरू →' : 'View All →',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: SvcColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 114,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _popularServices.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = _popularServices[index];
              final isSoon = item['isSoon'] == true;

              return InkWell(
                onTap: () {
                  if (isSoon) {
                    SvcSnackbar.show(
                      context,
                      isNe ? 'यो सेवा चाँडै सुरु हुँदैछ।' : 'This service is coming soon.',
                      type: SnackType.info,
                    );
                    return;
                  }
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
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 86,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: SvcColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: SvcColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(item['imageUrl']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (isSoon)
                            Positioned(
                              top: -4,
                              right: -6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF97316),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isNe ? 'चाँडै' : 'SOON',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isNe ? item['titleNe']! : item['title']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10.5,
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
        ),
      ],
    );
  }

  /// Section 5: Certified Pre-Owned Marketplace — live listings from the
  /// `usedProducts` collection (same as the Pre-Owned tab) plus trade-in.
  Widget _buildCertifiedUsedSpotlight(bool isNe) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFECFDF5), Color(0xFFF8FAFC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, color: Colors.white, size: 17),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    isNe ? 'प्रमाणित सेकेन्ड-ह्यान्ड बजार' : 'Certified Pre-Owned',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: SvcColors.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => widget.onNavigateTab(3), // Pre-Owned Tab in Bottom Nav
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Text(
                      isNe ? 'सबै हेर्नुहोस् →' : 'See All →',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Listings rail (hidden when nothing is listed)
          StreamBuilder<List<UsedProductModel>>(
            stream: _usedProductsStream,
            builder: (context, snapshot) {
              final items = (snapshot.data ?? const <UsedProductModel>[]).take(8).toList();
              if (items.isEmpty) return const SizedBox(height: 4);
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: 214,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) => _buildPreOwnedCard(items[index]),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Sell / Trade-In row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TradeInScreen(appState: widget.appState)),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SvcColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.currency_exchange_rounded, color: Color(0xFFEA580C), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isNe ? 'पुरानो क्यामेरा बेच्नुहोस् वा साट्नुहोस्' : 'Sell or Trade-In Your Gear',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: SvcColors.ink,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            isNe ? 'तत्काल क्यास वा +१०% स्टोर क्रेडिट' : 'Instant cash or +10% store credit',
                            style: const TextStyle(fontSize: 10.5, color: SvcColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: SvcColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isNe ? 'मूल्याङ्कन' : 'Value Gear',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreOwnedCard(UsedProductModel item) {
    final badge = getGradeBadge(item.conditionGrade);
    return InkWell(
      onTap: () => showUsedProductDetailModal(context, item, widget.appState),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 152,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF064E3B).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo with condition grade
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: SizedBox(
                    width: 152,
                    height: 112,
                    child: SvcProductImage(source: item.imageUrl),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: badge['bg'] as Color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badge['border'] as Color),
                    ),
                    child: Text(
                      badge['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: badge['text'] as Color,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.brand.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: SvcColors.muted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: SvcColors.ink,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatRs(item.price),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: SvcColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section 9: Infinite Scrolling 2-Column Marketplace Product Feed (header & category pills)
  Widget _buildStoreCatalogueHeader(bool isNe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Item Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isNe ? 'सबै टेक गियर' : 'Explore All Tech Gear',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: SvcColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Horizontal Category Filter Pills
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = cat == _selectedCategory;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = cat;
                    _visibleProductCount = _initialProductCount;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? SvcColors.primary : SvcColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? SvcColors.primary : SvcColors.border,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  /// Product grid as a sliver, so only the cards on screen are built.
  Widget _buildStoreCatalogueGrid(bool isNe) {
    return ValueListenableBuilder<List<ProductModel>>(
      valueListenable: _liveProducts,
      builder: (context, liveProducts, _) {
        final allItems = _feedItems(liveProducts).take(_visibleProductCount).toList();

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 0.67,
            ),
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              final prod = allItems[index];
              final originalPrice = prod['originalPrice'] ?? (prod['price'] * 1.15).toInt();
              final discount = prod['discount'] ?? '-10%';

              return InkWell(
                onTap: () => _showProductDetailModal(context, prod, isNe),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: SvcColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image with Single Elegant Discount Pill
                      Stack(
                        children: [
                          Container(
                            height: 130,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                              child: CachedNetworkImage(
                                imageUrl: prod['imageUrl'],
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => const Center(
                                  child: Icon(Icons.camera_alt_outlined, size: 36, color: SvcColors.muted),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 7,
                            left: 7,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                discount,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (prod['brand'] ?? 'GENUINE').toString().toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: SvcColors.muted,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 11, color: Color(0xFFF59E0B)),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${prod['rating'] ?? 4.9}',
                                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              prod['name'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: SvcColors.ink,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rs. ${(prod['price'] / 1000).toStringAsFixed(0)}k',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    if (originalPrice > prod['price'])
                                      Text(
                                        '${(originalPrice / 1000).toStringAsFixed(0)}k',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF94A3B8),
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                  ],
                                ),
                                ProductCartStepperButton(
                                  appState: widget.appState,
                                  productId: prod['id'] ?? 'item-$index',
                                  productType: 'NEW',
                                  name: prod['name'],
                                  unitPrice: prod['price'],
                                  imageUrl: prod['imageUrl'],
                                  height: 30,
                                  compact: false,
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
            },
          ),
        );
      },
    );
  }

  /// "Load More" only while more products remain; nothing otherwise.
  Widget _buildStoreCatalogueFooter(bool isNe) {
    return ValueListenableBuilder<List<ProductModel>>(
      valueListenable: _liveProducts,
      builder: (context, liveProducts, _) {
        if (_feedItems(liveProducts).length <= _visibleProductCount) {
          return const SizedBox(height: 24);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Center(
            child: OutlinedButton.icon(
              onPressed: _showMoreProducts,
              icon: const Icon(Icons.arrow_downward_rounded, size: 15, color: SvcColors.primary),
              label: Text(
                isNe ? 'थप उत्पादनहरू देखाउनुहोस्' : 'Load More Products',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SvcColors.ink),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                side: const BorderSide(color: SvcColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: SvcColors.canvas,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProductDetailModal(BuildContext context, Map<String, dynamic> prod, bool isNe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final originalPrice = prod['originalPrice'] ?? (prod['price'] * 1.15).toInt();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: SvcColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: prod['imageUrl'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox(
                      height: 120,
                      child: Center(child: Icon(Icons.camera_alt, size: 40, color: SvcColors.muted)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (prod['brand'] ?? 'GENUINE').toString().toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: SvcColors.primary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'IN STOCK • JANAKPUR HUB',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF15803D)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  prod['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Rs. ${prod['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: SvcColors.primaryDark),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rs. ${originalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), decoration: TextDecoration.lineThrough),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        prod['discount'] ?? '-10%',
                        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (prod['specs'] != null) ...[
                  Text(
                    prod['specs'],
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.35),
                  ),
                  const SizedBox(height: 10),
                ],
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SvcColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: SvcColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          prod['warranty'] ?? '1-Year Official Distributor Warranty across Nepal',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          widget.appState.addToCart(CartItemModel(
                            productId: prod['id'] ?? 'item-modal',
                            productType: 'NEW',
                            name: prod['name'],
                            unitPrice: prod['price'],
                            imageUrl: prod['imageUrl'],
                          ));
                          Navigator.pop(ctx);
                          SvcSnackbar.show(context, 'Added "${prod['name']}" to cart!', type: SnackType.success);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: SvcColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          isNe ? 'झोलामा थप्नुहोस्' : 'Add to Cart',
                          style: const TextStyle(color: SvcColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.appState.addToCart(CartItemModel(
                            productId: prod['id'] ?? 'item-modal',
                            productType: 'NEW',
                            name: prod['name'],
                            unitPrice: prod['price'],
                            imageUrl: prod['imageUrl'],
                          ));
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CartScreen(appState: widget.appState)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SvcColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          isNe ? 'अहिले किन्नुहोस्' : 'Buy Now',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildPillarCard({
    required String title,
    required String desc,
    required String tag,
    required List<Color> gradientColors,
    required Color borderColor,
    required Color iconColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SvcColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SvcColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, color: SvcColors.ink),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
