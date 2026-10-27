import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SvcLocalization {
  static const String _kLanguageKey = 'svc_language';
  static String currentLanguage = 'en'; // 'en' or 'ne'

  static final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');

  static const Map<String, Map<String, String>> _dictionary = {
    // Navigation & General
    "nav.home": {"en": "Home", "ne": "गृहपृष्ठ"},
    "nav.repair": {"en": "Repair", "ne": "मर्मत सेवा"},
    "nav.estimator": {"en": "Cost Estimator", "ne": "खर्च अनुमान"},
    "nav.tradeIn": {"en": "Sell / Trade-In", "ne": "सामान बेच्नुहोस्"},
    "nav.shop": {"en": "Shop", "ne": "पसल"},
    "nav.preowned": {"en": "Pre-owned", "ne": "प्रमाणित सेकेन्ड-ह्यान्ड"},
    "nav.searchPlaceholder": {
      "en": "Search cameras, lenses, drones, repairs...",
      "ne": "क्यामेरा, लेन्स, ड्रोन, मर्मत खोज्नुहोस्..."
    },
    "nav.login": {"en": "Login", "ne": "लगइन"},
    "nav.account": {"en": "Account", "ne": "खाता"},
    "nav.myOrders": {"en": "My Account & Orders", "ne": "मेरो खाता र अर्डरहरू"},
    "nav.adminConsole": {"en": "Admin Console", "ne": "प्रशासक कन्सोल"},
    "nav.techPortal": {"en": "Technician Portal", "ne": "प्राविधिक पोर्टल"},
    "nav.signOut": {"en": "Sign Out", "ne": "बाहिरिनुहोस्"},
    "nav.janakpurCenter": {"en": "Janakpur Center", "ne": "जनकपुरधाम केन्द्र"},
    "nav.freeInspection": {"en": "Free Physical Inspection", "ne": "निःशुल्क भौतिक परीक्षण"},
    "nav.suggestions": {"en": "Product Suggestions", "ne": "उत्पादन सुझावहरू"},
    "nav.viewAllResults": {"en": "View all results for", "ne": "सबै नतिजाहरू हेर्नुहोस्"},

    // Hero Section
    "hero.badge": {
      "en": "JANAKPUR'S NO. 1 TECH SERVICE & STORE",
      "ne": "जनकपुरधामको नं. १ प्रविधि सेवा र स्टोर"
    },
    "hero.kicker": {
      "en": "REPAIR • BUY • INSTALL • MAINTAIN",
      "ne": "मर्मत • खरिद • जडान • स्याहार"
    },
    "hero.title": {
      "en": "Reliable Electronics Repair & Genuine Tech Equipment",
      "ne": "भरपर्दो इलेक्ट्रोनिक्स मर्मत र प्रामाणिक प्रविधि उपकरण"
    },
    "hero.brandName": {
      "en": "QuickySewa",
      "ne": "क्विकीसेवा"
    },
    "hero.sub": {
      "en": "Expert camera, lens, TV & drone diagnosis in Janakpur with official manufacturer warranty and nationwide insured delivery across Nepal.",
      "ne": "जनकपुरधाममा दक्ष क्यामेरा, लेन्स, टिभी र ड्रोन परीक्षण, आधिकारिक वारेन्टी र नेपालभर सुरक्षित कुरियर डेलिभरी।"
    },
    "hero.bookRepair": {"en": "Book Repair", "ne": "निःशुल्क परीक्षण बुक गर्नुहोस्"},
    "hero.estimatorBtn": {"en": "Repair Cost Estimator", "ne": "मर्मत खर्च अनुमान"},
    "hero.tradeInBtn": {"en": "Sell Old Gear / Trade-In", "ne": "सामान बेच्नुहोस् / साट्नुहोस्"},
    "hero.exploreStore": {"en": "Explore Store", "ne": "स्टोर हेर्नुहोस्"},

    // Category Cards
    "cat.repairTitle": {"en": "Electronics Repair", "ne": "इलेक्ट्रोनिक्स मर्मत"},
    "cat.repairDesc": {"en": "Cameras, Lenses, TVs, Drones", "ne": "क्यामेरा, लेन्स, टिभी, ड्रोन"},
    "cat.storeTitle": {"en": "Official Tech Store", "ne": "आधिकारिक स्टोर"},
    "cat.storeDesc": {"en": "Brand-new with Nepal Warranty", "ne": "नयाँ सामान • नेपाल वारेन्टी"},
    "cat.certifiedTitle": {"en": "Certified Pre-Owned", "ne": "प्रमाणित सेकेन्ड-ह्यान्ड"},
    "cat.certifiedDesc": {"en": "45-Point Bench Inspected", "ne": "४५-बुँदे ल्याब परीक्षण पास"},
    "cat.cctvTitle": {"en": "CCTV & Security", "ne": "सीसीटिभी र सुरक्षा"},
    "cat.cctvDesc": {"en": "HD Camera Installation & Setup", "ne": "एचडी क्यामेरा जडान र मर्मत"},
    "cat.janakpurTitle": {"en": "Janakpur Workshop", "ne": "जनकपुरधाम वर्कशप"},
    "cat.janakpurDesc": {"en": "Station Road, Walk-in Center", "ne": "स्टेसन रोड • प्रत्यक्ष सेवा"},

    // Popular Services
    "services.popularTitle": {"en": "Popular Services", "ne": "लोकप्रिय सेवाहरू"},
    "services.viewAll": {"en": "View All Services", "ne": "सबै सेवाहरू हेर्नुहोस्"},
    "services.ac": {"en": "AC Repair", "ne": "एसी मर्मत"},
    "services.washingMachine": {"en": "Washing Machine", "ne": "वाशिङ मेसिन"},
    "services.tv": {"en": "TV Repair", "ne": "टिभी मर्मत"},
    "services.camera": {"en": "Camera Repair", "ne": "क्यामेरा मर्मत"},
    "services.laptop": {"en": "Laptop Repair", "ne": "ल्यापटप मर्मत"},
    "services.plumber": {"en": "Plumber", "ne": "प्लम्बर (धारा/पाइप)"},
    "services.furniture": {"en": "Furniture", "ne": "फर्निचर (काठ काम)"},
    "services.cctv": {"en": "CCTV Setup", "ne": "सीसीटिभी जडान"},
    "services.mobile": {"en": "Mobile Repair", "ne": "मोबाइल मर्मत"},
    "services.appliance": {"en": "Home Appliance", "ne": "घरेलु उपकरण"},
    "services.wallMount": {"en": "TV Wall Mounting", "ne": "टिभी वाल माउन्ट"},
    "services.other": {"en": "Other Services", "ne": "अन्य विशेष सेवा"},
    "services.soon": {"en": "SOON", "ne": "चाँडै"},

    // Estimator
    "estimator.title": {"en": "Interactive Repair Cost Estimator", "ne": "अन्तरक्रियात्मक मर्मत खर्च अनुमान"},
    "estimator.subtitle": {"en": "Select your device and symptoms to calculate estimated labor and parts costs.", "ne": "आफ्नो उपकरण र समस्या छनोट गरी अनुमानित मर्मत खर्च पत्ता लगाउनुहोस्।"},
    "estimator.selectDevice": {"en": "1. Select Device Type", "ne": "१. उपकरण छान्नुहोस्"},
    "estimator.selectBrand": {"en": "2. Select Brand", "ne": "२. ब्रान्ड छान्नुहोस्"},
    "estimator.selectIssue": {"en": "3. What is the issue?", "ne": "३. समस्या के हो?"},
    "estimator.summary": {"en": "Instant Repair Estimate", "ne": "अनुमानित मर्मत खर्च"},
    "estimator.turnaround": {"en": "Estimated Time", "ne": "लाग्ने समय"},
    "estimator.warranty": {"en": "Service Warranty", "ne": "सेवा वारेन्टी"},
    "estimator.bookNow": {"en": "Book Repair with this Estimate", "ne": "यो अनुमान सहित मर्मत बुक गर्नुहोस्"},

    // Trade In
    "tradein.title": {"en": "Sell Old Gear & Instant Valuation", "ne": "सामान बेच्नुहोस् र तत्काल मूल्याङ्कन"},
    "tradein.subtitle": {"en": "Calculate accurate market buyout value for your used cameras, lenses, laptops & drones.", "ne": "आफ्नो सेकेन्ड-ह्यान्ड क्यामेरा, लेन्स, ल्यापटप वा ड्रोनको बजार मूल्य तुरुन्तै जान्नुहोस्।"},
    "tradein.selectCat": {"en": "Select Category", "ne": "उपकरण वर्ग छान्नुहोस्"},
    "tradein.selectModel": {"en": "Select Equipment Model", "ne": "मोडेल छान्नुहोस्"},
    "tradein.conditionCheck": {"en": "Equipment Condition Assessment", "ne": "उपकरणको अवस्था मूल्याङ्कन"},
    "tradein.cosmetic": {"en": "Cosmetic Condition", "ne": "बाहिरी अवस्था (कस्मेटिक)"},
    "tradein.functional": {"en": "Operational & Functional Status", "ne": "सञ्चालन तथा प्राविधिक अवस्था"},
    "tradein.shutterCount": {"en": "Shutter Actuations (Clicks)", "ne": "सटर क्लिक गणना"},
    "tradein.accessories": {"en": "Included Original Accessories", "ne": "साथमा भएका सक्कली सामानहरू"},
    "tradein.estimatedCash": {"en": "Estimated Cash Payout", "ne": "नगद भुक्तानी अनुमान"},
    "tradein.estimatedCredit": {"en": "Store Credit Upgrade (+10% Bonus)", "ne": "स्टोर क्रेडिट साटासाट (+१०% बोनस)"},
    "tradein.submitQuote": {"en": "Request Instant Valuation Call / Inspection", "ne": "मूल्याङ्कन अनुरोध पठाउनुहोस्"},

    // Shop & Store
    "shop.title": {"en": "Official Electronics Store", "ne": "आधिकारिक इलेक्ट्रोनिक्स स्टोर"},
    "shop.subtitle": {
      "en": "100% genuine products with official Nepal warranty and insured courier delivery.",
      "ne": "१००% सक्कली उत्पादनहरू, आधिकारिक नेपाल वारेन्टी र सुरक्षित डेलिभरी।"
    },
    "shop.genuineBadge": {"en": "100% Genuine • Official Warranty", "ne": "१००% सक्कली • आधिकारिक वारेन्टी"},
    "shop.filters": {"en": "Filters", "ne": "फिल्टरहरू"},
    "shop.resetAll": {"en": "Reset All", "ne": "सबै रिसेट"},
    "shop.category": {"en": "Category", "ne": "वर्ग"},
    "shop.all": {"en": "All", "ne": "सबै"},
    "shop.maxPrice": {"en": "Max Price", "ne": "अधिकतम मूल्य"},
    "shop.priceRange": {"en": "Price Range", "ne": "मूल्य दायरा"},
    "shop.inStockOnly": {"en": "In Stock Only", "ne": "स्टकमा भएका मात्र"},
    "shop.sortBy": {"en": "Sort by", "ne": "क्रमबद्ध गर्नुहोस्"},
    "shop.featured": {"en": "Featured", "ne": "विशेष"},
    "shop.priceLowHigh": {"en": "Price: Low to High", "ne": "मूल्य: कम देखि बढी"},
    "shop.priceHighLow": {"en": "Price: High to Low", "ne": "मूल्य: बढी देखि कम"},
    "shop.topRated": {"en": "Top Rated", "ne": "उत्कृष्ट मूल्याङ्कन"},
    "shop.addToCart": {"en": "Add to Cart", "ne": "कार्टमा थप्नुहोस्"},
    "shop.added": {"en": "Added", "ne": "थपियो"},
    "shop.searchResultsFor": {"en": "Search results for", "ne": "को लागि खोज नतिजाहरू"},
    "shop.productsFound": {"en": "products found", "ne": "उत्पादनहरू भेटिए"},
    "shop.clearSearch": {"en": "Clear Search", "ne": "खोज हटाउनुहोस्"},
    "shop.noProducts": {"en": "No matching products found", "ne": "कुनै उत्पादन फेला परेन"},

    // Used / Pre-Owned
    "used.title": {"en": "Certified Pre-Owned Gear", "ne": "प्रमाणित सेकेन्ड-ह्यान्ड गियर"},
    "used.subtitle": {"en": "100% bench-tested and backed by QuickySewa warranty.", "ne": "१००% ल्याब परीक्षण गरिएको र क्विकीसेवाको वारेन्टी सहित।"},
    "used.sellBanner": {"en": "Have gear to sell? Get instant trade-in value", "ne": "पुरानो सामान बेच्ने हो? तुरुन्तै मूल्य जान्नुहोस्"},
    "used.instantValuation": {"en": "Instant Trade-In Valuation", "ne": "तत्काल मूल्याङ्कन क्याल्कुलेटर"},
    "used.gradeAplus": {"en": "Grade A+ (Like New)", "ne": "ग्रेड A+ (नयाँ जस्तै)"},
    "used.gradeA": {"en": "Grade A (Excellent)", "ne": "ग्रेड A (उत्कृष्ट)"},
    "used.gradeB": {"en": "Grade B (Good)", "ne": "ग्रेड B (राम्रो)"},

    // Cart & Checkout
    "cart.title": {"en": "Shopping Cart", "ne": "सपिङ कार्ट"},
    "cart.empty": {"en": "Your shopping cart is empty", "ne": "तपाईंको कार्ट खाली छ"},
    "cart.checkout": {"en": "Proceed to Checkout", "ne": "चेकआउट गर्नुहोस्"},
    "cart.viewCart": {"en": "View Cart", "ne": "कार्ट हेर्नुहोस्"},
    "checkout.title": {"en": "Secure Checkout", "ne": "सुरक्षित चेकआउट"},
    "checkout.shippingAddress": {"en": "Shipping Address (Nationwide Nepal)", "ne": "डेलिभरी ठेगाना (नेपालभर)"},
    "checkout.paymentMethod": {"en": "Select Payment Method", "ne": "भुक्तानी माध्यम छान्नुहोस्"},
    "checkout.cod": {"en": "Cash on Delivery (COD)", "ne": "सामान पाएपछि नगद (COD)"},
    "checkout.bankTransfer": {"en": "Bank Transfer", "ne": "बैंक ट्रान्सफर / मोबाइल बैंकिङ"},
    "checkout.placeOrder": {"en": "Confirm & Place Order", "ne": "अर्डर निश्चित गर्नुहोस्"},

    // Trust & Janakpur
    "trust.lab": {"en": "In-House Lab Tested", "ne": "स्वदेशी ल्याब परीक्षण"},
    "trust.warranty": {"en": "90-Day Warranty", "ne": "९० दिन सेवा वारेन्टी"},
    "trust.genuine": {"en": "100% Genuine Parts", "ne": "१००% सक्कली स्पेयर पार्ट्स"},
    "trust.delivery": {"en": "Insured Nepal Delivery", "ne": "नेपालभर सुरक्षित डेलिभरी"},

    // Authentication (login / register / forgot password)
    "auth.or": {"en": "or", "ne": "वा"},
    "auth.apple": {"en": "Continue with Apple", "ne": "Apple बाट जारी राख्नुहोस्"},
    "auth.google": {"en": "Continue with Google", "ne": "Google बाट जारी राख्नुहोस्"},
    "auth.googleUnavailable": {"en": "Google sign-in isn't available yet. Please use email for now.", "ne": "Google लगइन अहिले उपलब्ध छैन। कृपया इमेल प्रयोग गर्नुहोस्।"},
    "auth.err.accountExistsDifferentCredential": {"en": "This email is registered with a password. Sign in with email instead.", "ne": "यो इमेल पासवर्डसहित दर्ता छ। इमेलबाट लगइन गर्नुहोस्।"},
    "auth.guestButton": {"en": "Continue as guest", "ne": "अतिथिको रूपमा जारी राख्नुहोस्"},
    "auth.languageSwitch": {"en": "नेपाली", "ne": "English"},
    "auth.title.login": {"en": "Welcome back", "ne": "फेरि स्वागत छ"},
    "auth.subtitle.login": {"en": "Sign in to track your repairs and orders.", "ne": "आफ्नो मर्मत र अर्डर हेर्न लगइन गर्नुहोस्।"},
    "auth.email": {"en": "Email address", "ne": "इमेल ठेगाना"},
    "auth.password": {"en": "Password", "ne": "पासवर्ड"},
    "auth.showPassword": {"en": "Show password", "ne": "पासवर्ड देखाउनुहोस्"},
    "auth.hidePassword": {"en": "Hide password", "ne": "पासवर्ड लुकाउनुहोस्"},
    "auth.forgot": {"en": "Forgot password?", "ne": "पासवर्ड बिर्सनुभयो?"},
    "auth.signIn": {"en": "Sign in", "ne": "लगइन गर्नुहोस्"},
    "auth.noAccount": {"en": "New to QuickySewa?", "ne": "क्विकीसेवामा नयाँ हुनुहुन्छ?"},
    "auth.createAccount": {"en": "Create an account", "ne": "खाता बनाउनुहोस्"},
    "auth.guestNote": {"en": "No account needed to shop or book a repair.", "ne": "किनमेल वा मर्मत बुक गर्न खाता आवश्यक छैन।"},
    "auth.continueGuest": {"en": "Continue as guest", "ne": "अतिथिको रूपमा जारी राख्नुहोस्"},
    "auth.welcome": {"en": "Welcome back, {name}!", "ne": "फेरि स्वागत छ, {name}!"},
    "auth.title.register": {"en": "Create your account", "ne": "आफ्नो खाता बनाउनुहोस्"},
    "auth.subtitle.register": {"en": "Track repairs, approve quotes and shop genuine electronics.", "ne": "मर्मत ट्र्याक गर्नुहोस्, खर्च स्वीकृत गर्नुहोस् र सक्कली सामान किन्नुहोस्।"},
    "auth.name": {"en": "Full name", "ne": "पूरा नाम"},
    "auth.namePlaceholder": {"en": "e.g. Ramesh Sah", "ne": "जस्तै: रमेश साह"},
    "auth.phone": {"en": "Mobile number", "ne": "मोबाइल नम्बर"},
    "auth.phoneHint": {"en": "We'll call or message you about repair pickup and delivery.", "ne": "मर्मत र डेलिभरीबारे हामी तपाईंलाई सम्पर्क गर्नेछौं।"},
    "auth.passwordPlaceholder": {"en": "At least 8 characters, letters & numbers", "ne": "कम्तीमा ८ अक्षर, अक्षर र अंक दुवै"},
    "auth.confirmPassword": {"en": "Confirm password", "ne": "पासवर्ड पुष्टि गर्नुहोस्"},
    "auth.agreePrefix": {"en": "I agree to the ", "ne": "म "},
    "auth.terms": {"en": "Terms of Service & Privacy Policy", "ne": "सेवा सर्त र गोपनीयता नीति"},
    "auth.agreeSuffix": {"en": ", including the 30-day repair warranty terms.", "ne": "(३० दिने मर्मत वारेन्टी सहित) मा सहमत छु।"},
    "auth.haveAccount": {"en": "Already have an account?", "ne": "पहिले नै खाता छ?"},
    "auth.registerSuccess": {"en": "Account created! We sent a verification link to {email}.", "ne": "खाता बन्यो! {email} मा प्रमाणीकरण लिङ्क पठाइएको छ।"},
    "auth.title.forgot": {"en": "Reset your password", "ne": "पासवर्ड रिसेट गर्नुहोस्"},
    "auth.subtitle.forgot": {"en": "Enter your account email and we'll send you a reset link.", "ne": "आफ्नो खाताको इमेल लेख्नुहोस्, हामी रिसेट लिङ्क पठाउनेछौं।"},
    "auth.sendReset": {"en": "Send reset link", "ne": "रिसेट लिङ्क पठाउनुहोस्"},
    "auth.resetSentTitle": {"en": "Check your inbox", "ne": "आफ्नो इमेल हेर्नुहोस्"},
    "auth.resetSentBody": {"en": "If an account exists for {email}, a password reset link is on its way.", "ne": "{email} को खाता भएमा पासवर्ड रिसेट लिङ्क पठाइएको छ।"},
    "auth.resetSentToast": {"en": "Reset link sent. Check your email.", "ne": "रिसेट लिङ्क पठाइयो। इमेल हेर्नुहोस्।"},
    "auth.backToLogin": {"en": "Back to sign in", "ne": "लगइनमा फर्कनुहोस्"},
    "auth.rememberPassword": {"en": "Remembered your password?", "ne": "पासवर्ड सम्झनुभयो?"},
    "auth.err.emailRequired": {"en": "Please enter your email address.", "ne": "कृपया इमेल ठेगाना लेख्नुहोस्।"},
    "auth.err.passwordRequired": {"en": "Please enter your password.", "ne": "कृपया पासवर्ड लेख्नुहोस्।"},
    "auth.err.invalidCredentials": {"en": "Email or password is incorrect.", "ne": "इमेल वा पासवर्ड मिलेन।"},
    "auth.err.invalidEmail": {"en": "Please enter a valid email address.", "ne": "कृपया सही इमेल ठेगाना लेख्नुहोस्।"},
    "auth.err.disabled": {"en": "This account has been deactivated. Please contact support.", "ne": "यो खाता निष्क्रिय गरिएको छ। कृपया सम्पर्क गर्नुहोस्।"},
    "auth.err.tooMany": {"en": "Too many attempts. Please wait a few minutes or reset your password.", "ne": "धेरै प्रयास भयो। केही मिनेट पर्खनुहोस् वा पासवर्ड रिसेट गर्नुहोस्।"},
    "auth.err.network": {"en": "No internet connection. Please check and try again.", "ne": "इन्टरनेट जडान छैन। जाँच गरी फेरि प्रयास गर्नुहोस्।"},
    "auth.err.generic": {"en": "Something went wrong. Please try again.", "ne": "केही गडबड भयो। फेरि प्रयास गर्नुहोस्।"},
    "auth.err.name": {"en": "Please enter your full name.", "ne": "कृपया पूरा नाम लेख्नुहोस्।"},
    "auth.err.phone": {"en": "Enter a valid 10-digit mobile number (98XXXXXXXX).", "ne": "सही १० अंकको मोबाइल नम्बर लेख्नुहोस् (९८XXXXXXXX)।"},
    "auth.err.weakPassword": {"en": "Use at least 8 characters with letters and numbers.", "ne": "कम्तीमा ८ अक्षर, अक्षर र अंक सहित प्रयोग गर्नुहोस्।"},
    "auth.err.mismatch": {"en": "Passwords do not match.", "ne": "पासवर्ड मिलेन।"},
    "auth.err.terms": {"en": "Please accept the Terms of Service to continue.", "ne": "जारी राख्न सेवा सर्तहरूमा सहमति जनाउनुहोस्।"},
    "auth.err.emailInUse": {"en": "An account with this email already exists. Please sign in.", "ne": "यो इमेलको खाता पहिले नै छ। कृपया लगइन गर्नुहोस्।"},
    "auth.err.unavailable": {"en": "Sign-up is temporarily unavailable. Please contact support.", "ne": "खाता बनाउने सुविधा अस्थायी रूपमा बन्द छ। कृपया सम्पर्क गर्नुहोस्।"},
  };

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kLanguageKey);
      if (saved == 'en' || saved == 'ne') {
        currentLanguage = saved!;
      } else {
        // First launch: follow the phone's language until the user picks one.
        final device = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
        currentLanguage = device == 'ne' ? 'ne' : 'en';
      }
      languageNotifier.value = currentLanguage;
    } catch (e) {
      debugPrint('Error initializing language: $e');
    }
  }

  static Future<void> setLanguage(String lang) async {
    if (lang != 'en' && lang != 'ne') return;
    currentLanguage = lang;
    languageNotifier.value = lang;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLanguageKey, lang);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  static void toggleLanguage() {
    final next = currentLanguage == 'en' ? 'ne' : 'en';
    setLanguage(next);
  }

  /// Looks up [key]; `{name}` placeholders are filled from [vars].
  static String t(String key, [Map<String, String>? vars]) {
    final entry = _dictionary[key];
    if (entry == null) return key;
    final text = entry[currentLanguage] ?? entry['en'] ?? key;
    if (vars == null) return text;
    return text.replaceAllMapped(RegExp(r'\{(\w+)\}'), (m) => vars[m.group(1)] ?? m.group(0)!);
  }

  static bool get isNepali => currentLanguage == 'ne';
}
