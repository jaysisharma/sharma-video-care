"use client";

import React, { createContext, useContext, useState, useEffect } from "react";

export type Language = "en" | "ne";

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  toggleLanguage: () => void;
  t: (key: string, vars?: Record<string, string>) => string;
}

const DICTIONARY: Record<string, { en: string; ne: string }> = {
  // Navigation
  "nav.home": { en: "Home", ne: "गृहपृष्ठ" },
  "nav.repair": { en: "Repair", ne: "मर्मत सेवा" },
  "nav.estimator": { en: "Cost Estimator", ne: "खर्च अनुमान" },
  "nav.tradeIn": { en: "Sell / Trade-In", ne: "सामान बेच्नुहोस्" },
  "nav.shop": { en: "Shop", ne: "पसल" },
  "nav.preowned": { en: "Pre-owned", ne: "प्रमाणित सेकेन्ड-ह्यान्ड" },
  "nav.searchPlaceholder": { en: "Search cameras, lenses, drones, repairs...", ne: "क्यामेरा, लेन्स, ड्रोन, मर्मत खोज्नुहोस्..." },
  "nav.login": { en: "Login", ne: "लगइन" },
  "nav.account": { en: "Account", ne: "खाता" },
  "nav.myOrders": { en: "My Account & Orders", ne: "मेरो खाता र अर्डरहरू" },
  "nav.adminConsole": { en: "Admin Console", ne: "प्रशासक कन्सोल" },
  "nav.techPortal": { en: "Technician Portal", ne: "प्राविधिक पोर्टल" },
  "nav.signOut": { en: "Sign Out", ne: "बाहिरिनुहोस्" },
  "nav.janakpurCenter": { en: "Janakpur Center", ne: "जनकपुरधाम केन्द्र" },
  "nav.freeInspection": { en: "Free Physical Inspection", ne: "निःशुल्क भौतिक परीक्षण" },
  "nav.suggestions": { en: "Product Suggestions", ne: "उत्पादन सुझावहरू" },
  "nav.viewAllResults": { en: "View all results for", ne: "सबै नतिजाहरू हेर्नुहोस्" },

  // Hero Section
  "hero.badge": { en: "JANAKPUR'S NO. 1 TECH SERVICE & STORE", ne: "जनकपुरधामको नं. १ प्रविधि सेवा र स्टोर" },
  "hero.title": { en: "Reliable Electronics Repair & Genuine Tech Equipment", ne: "भरपर्दो इलेक्ट्रोनिक्स मर्मत र प्रामाणिक प्रविधि उपकरण" },
  "hero.sub": {
    en: "Expert camera, lens, TV & drone diagnosis in Janakpur with official manufacturer warranty and nationwide insured delivery across Nepal.",
    ne: "जनकपुरधाममा दक्ष क्यामेरा, लेन्स, टिभी र ड्रोन परीक्षण, आधिकारिक वारेन्टी र नेपालभर सुरक्षित कुरियर डेलिभरी।",
  },
  "hero.bookRepair": { en: "Book Repair Inspection", ne: "निःशुल्क परीक्षण बुक गर्नुहोस्" },
  "hero.exploreStore": { en: "Explore Store", ne: "स्टोर हेर्नुहोस्" },

  // Category Cards
  "cat.repairTitle": { en: "Electronics Repair", ne: "इलेक्ट्रोनिक्स मर्मत" },
  "cat.repairDesc": { en: "Cameras, Lenses, TVs, Drones", ne: "क्यामेरा, लेन्स, टिभी, ड्रोन" },
  "cat.storeTitle": { en: "Official Tech Store", ne: "आधिकारिक स्टोर" },
  "cat.storeDesc": { en: "Brand-new with Nepal Warranty", ne: "नयाँ सामान • नेपाल वारेन्टी" },
  "cat.certifiedTitle": { en: "Certified Pre-Owned", ne: "प्रमाणित सेकेन्ड-ह्यान्ड" },
  "cat.certifiedDesc": { en: "45-Point Bench Inspected", ne: "४५-बुँदे ल्याब परीक्षण पास" },
  "cat.janakpurTitle": { en: "Janakpur Workshop", ne: "जनकपुरधाम वर्कशप" },
  "cat.janakpurDesc": { en: "Station Road, Walk-in Center", ne: "स्टेसन रोड • प्रत्यक्ष सेवा" },

  // Popular Services
  "services.popularTitle": { en: "Popular Services", ne: "लोकप्रिय सेवाहरू" },
  "services.viewAll": { en: "View All Services", ne: "सबै सेवाहरू हेर्नुहोस्" },
  "services.ac": { en: "AC Repair", ne: "एसी मर्मत" },
  "services.washingMachine": { en: "Washing Machine", ne: "वाशिङ मेसिन" },
  "services.tv": { en: "TV Repair", ne: "टिभी मर्मत" },
  "services.camera": { en: "Camera Repair", ne: "क्यामेरा मर्मत" },
  "services.laptop": { en: "Laptop Repair", ne: "ल्यापटप मर्मत" },
  "services.plumber": { en: "Plumber", ne: "प्लम्बर (धारा/पाइप)" },
  "services.furniture": { en: "Furniture", ne: "फर्निचर (काठ काम)" },
  "services.cctv": { en: "CCTV Setup", ne: "सीसीटिभी जडान" },
  "services.mobile": { en: "Mobile Repair", ne: "मोबाइल मर्मत" },
  "services.appliance": { en: "Home Appliance", ne: "घरेलु उपकरण" },
  "services.wallMount": { en: "TV Wall Mounting", ne: "टिभी वाल माउन्ट" },
  "services.other": { en: "Other Services", ne: "अन्य विशेष सेवा" },
  "services.soon": { en: "SOON", ne: "चाँडै" },

  // Shop & Store
  "shop.title": { en: "Official Electronics Store", ne: "आधिकारिक इलेक्ट्रोनिक्स स्टोर" },
  "shop.subtitle": { en: "100% genuine products with official Nepal warranty and insured courier delivery.", ne: "१००% सक्कली उत्पादनहरू, आधिकारिक नेपाल वारेन्टी र सुरक्षित डेलिभरी।" },
  "shop.genuineBadge": { en: "100% Genuine • Official Warranty", ne: "१००% सक्कली • आधिकारिक वारेन्टी" },
  "shop.filters": { en: "Filters", ne: "फिल्टरहरू" },
  "shop.resetAll": { en: "Reset All", ne: "सबै रिसेट" },
  "shop.category": { en: "Category", ne: "वर्ग" },
  "shop.all": { en: "All", ne: "सबै" },
  "shop.maxPrice": { en: "Max Price", ne: "अधिकतम मूल्य" },
  "shop.priceRange": { en: "Price Range", ne: "मूल्य दायरा" },
  "shop.inStockOnly": { en: "In Stock Only", ne: "स्टकमा भएका मात्र" },
  "shop.sortBy": { en: "Sort by", ne: "क्रमबद्ध गर्नुहोस्" },
  "shop.featured": { en: "Featured", ne: "विशेष" },
  "shop.priceLowHigh": { en: "Price: Low to High", ne: "मूल्य: कम देखि बढी" },
  "shop.priceHighLow": { en: "Price: High to Low", ne: "मूल्य: बढी देखि कम" },
  "shop.topRated": { en: "Top Rated", ne: "उत्कृष्ट मूल्याङ्कन" },
  "shop.addToCart": { en: "Add to Cart", ne: "कार्टमा थप्नुहोस्" },
  "shop.added": { en: "Added", ne: "थपियो" },
  "shop.searchResultsFor": { en: "Search results for", ne: "को लागि खोज नतिजाहरू" },
  "shop.productsFound": { en: "products found", ne: "उत्पादनहरू भेटिए" },
  "shop.clearSearch": { en: "Clear Search", ne: "खोज हटाउनुहोस्" },
  "shop.noProducts": { en: "No matching products found", ne: "कुनै उत्पादन फेला परेन" },

  // Cart & Checkout
  "cart.title": { en: "Shopping Cart", ne: "सपिङ कार्ट" },
  "cart.empty": { en: "Your shopping cart is empty", ne: "तपाईंको कार्ट खाली छ" },
  "cart.checkout": { en: "Proceed to Checkout", ne: "चेकआउट गर्नुहोस्" },
  "cart.viewCart": { en: "View Cart", ne: "कार्ट हेर्नुहोस्" },
  "checkout.title": { en: "Secure Checkout", ne: "सुरक्षित चेकआउट" },
  "checkout.shippingAddress": { en: "Shipping Address (Nationwide Nepal)", ne: "डेलिभरी ठेगाना (नेपालभर)" },
  "checkout.paymentMethod": { en: "Select Payment Method", ne: "भुक्तानी माध्यम छान्नुहोस्" },
  "checkout.cod": { en: "Cash on Delivery (COD)", ne: "सामान पाएपछि नगद (COD)" },
  "checkout.bankTransfer": { en: "Bank Transfer", ne: "बैंक ट्रान्सफर / मोबाइल बैंकिङ" },
  "checkout.placeOrder": { en: "Confirm & Place Order", ne: "अर्डर निश्चित गर्नुहोस्" },

  // Footer & Policies
  "footer.about": {
    en: "Nepal's trusted destination for professional electronics repair, genuine tech equipment, and certified pre-owned devices in Janakpur and nationwide.",
    ne: "जनकपुरधाम र नेपालभर इलेक्ट्रोनिक्स मर्मत, सक्कली क्यामेरा/प्रविधि र प्रमाणित सेकेन्ड-ह्यान्डका लागि भरपर्दो गन्तव्य।",
  },
  "footer.support": { en: "Janakpur Center & Support", ne: "जनकपुरधाम केन्द्र र सहयोग" },
  "footer.workingHours": { en: "Sun – Fri: 9:00 AM – 7:30 PM", ne: "आइत – शुक्र: बिहान ९:०० – साँझ ७:३०" },
  "footer.whatsapp": { en: "WhatsApp Live Support", ne: "ह्वाट्सएप प्रत्यक्ष सहयोग" },
  "footer.copyright": { en: "QuickySewa. All rights reserved.", ne: "क्विकीसेवा। सर्वाधिकार सुरक्षित।" },

  // Authentication (login / register / forgot password)
  "auth.brandTagline": { en: "Janakpur's repair & electronics hub", ne: "जनकपुरधामको मर्मत र इलेक्ट्रोनिक्स केन्द्र" },
  "auth.brandPoint1": { en: "Track your repairs live, from inspection to pickup", ne: "परीक्षणदेखि डेलिभरीसम्म मर्मतको स्थिति हेर्नुहोस्" },
  "auth.brandPoint2": { en: "Approve repair quotes before any work starts", ne: "काम सुरु हुनुअघि मर्मत खर्च स्वीकृत गर्नुहोस्" },
  "auth.brandPoint3": { en: "Genuine products with official Nepal warranty", ne: "आधिकारिक नेपाल वारेन्टीसहित सक्कली सामान" },
  "auth.signedOut": { en: "You have been signed out.", ne: "तपाईं लगआउट हुनुभयो।" },
  "auth.back": { en: "Back to store", ne: "स्टोरमा फर्कनुहोस्" },
  "auth.guestNote": { en: "No account needed to shop or book a repair.", ne: "किनमेल वा मर्मत बुक गर्न खाता आवश्यक छैन।" },
  "auth.continueGuest": { en: "Continue as guest", ne: "अतिथिको रूपमा जारी राख्नुहोस्" },
  "auth.email": { en: "Email address", ne: "इमेल ठेगाना" },
  "auth.password": { en: "Password", ne: "पासवर्ड" },
  "auth.showPassword": { en: "Show password", ne: "पासवर्ड देखाउनुहोस्" },
  "auth.hidePassword": { en: "Hide password", ne: "पासवर्ड लुकाउनुहोस्" },
  "auth.capsLock": { en: "Caps Lock is on", ne: "क्याप्स लक अन छ" },

  "auth.login.title": { en: "Welcome back", ne: "फेरि स्वागत छ" },
  "auth.login.subtitle": { en: "Sign in to track your repairs and orders.", ne: "आफ्नो मर्मत र अर्डर हेर्न लगइन गर्नुहोस्।" },
  "auth.login.forgot": { en: "Forgot password?", ne: "पासवर्ड बिर्सनुभयो?" },
  "auth.login.remember": { en: "Keep me signed in on this device", ne: "यो उपकरणमा लगइन राख्नुहोस्" },
  "auth.login.submit": { en: "Sign in", ne: "लगइन गर्नुहोस्" },
  "auth.login.submitting": { en: "Signing in...", ne: "लगइन हुँदैछ..." },
  "auth.login.noAccount": { en: "New to QuickySewa?", ne: "क्विकीसेवामा नयाँ हुनुहुन्छ?" },
  "auth.login.createAccount": { en: "Create an account", ne: "खाता बनाउनुहोस्" },
  "auth.login.success": { en: "Welcome back, {name}!", ne: "फेरि स्वागत छ, {name}!" },

  "auth.register.title": { en: "Create your account", ne: "आफ्नो खाता बनाउनुहोस्" },
  "auth.register.subtitle": { en: "Track repairs, approve quotes and shop genuine electronics.", ne: "मर्मत ट्र्याक गर्नुहोस्, खर्च स्वीकृत गर्नुहोस् र सक्कली सामान किन्नुहोस्।" },
  "auth.register.name": { en: "Full name", ne: "पूरा नाम" },
  "auth.register.namePlaceholder": { en: "e.g. Ramesh Sah", ne: "जस्तै: रमेश साह" },
  "auth.register.phone": { en: "Mobile number", ne: "मोबाइल नम्बर" },
  "auth.register.phoneHint": { en: "We'll call or message you about repair pickup and delivery.", ne: "मर्मत र डेलिभरीबारे हामी तपाईंलाई सम्पर्क गर्नेछौं।" },
  "auth.register.passwordPlaceholder": { en: "At least 8 characters, letters & numbers", ne: "कम्तीमा ८ अक्षर, अक्षर र अंक दुवै" },
  "auth.register.confirm": { en: "Confirm password", ne: "पासवर्ड पुष्टि गर्नुहोस्" },
  "auth.register.confirmPlaceholder": { en: "Repeat your password", ne: "पासवर्ड फेरि लेख्नुहोस्" },
  "auth.register.agreePrefix": { en: "I agree to the", ne: "म" },
  "auth.register.terms": { en: "Terms of Service", ne: "सेवा सर्तहरू" },
  "auth.register.and": { en: "and", ne: "र" },
  "auth.register.privacy": { en: "Privacy Policy", ne: "गोपनीयता नीति" },
  "auth.register.agreeSuffix": { en: ".", ne: "मा सहमत छु।" },
  "auth.register.submit": { en: "Create account", ne: "खाता बनाउनुहोस्" },
  "auth.register.submitting": { en: "Creating account...", ne: "खाता बन्दैछ..." },
  "auth.register.haveAccount": { en: "Already have an account?", ne: "पहिले नै खाता छ?" },
  "auth.register.signIn": { en: "Sign in", ne: "लगइन गर्नुहोस्" },
  "auth.register.success": { en: "Account created! We sent a verification link to {email}.", ne: "खाता बन्यो! {email} मा प्रमाणीकरण लिङ्क पठाइएको छ।" },

  "auth.forgot.title": { en: "Reset your password", ne: "पासवर्ड रिसेट गर्नुहोस्" },
  "auth.forgot.subtitle": { en: "Enter your account email and we'll send you a reset link.", ne: "आफ्नो खाताको इमेल लेख्नुहोस्, हामी रिसेट लिङ्क पठाउनेछौं।" },
  "auth.forgot.submit": { en: "Send reset link", ne: "रिसेट लिङ्क पठाउनुहोस्" },
  "auth.forgot.submitting": { en: "Sending...", ne: "पठाउँदै..." },
  "auth.forgot.remember": { en: "Remembered your password?", ne: "पासवर्ड सम्झनुभयो?" },
  "auth.forgot.sentTitle": { en: "Check your inbox", ne: "आफ्नो इमेल हेर्नुहोस्" },
  "auth.forgot.sentBody": { en: "If an account exists for {email}, a password reset link is on its way.", ne: "{email} को खाता भएमा पासवर्ड रिसेट लिङ्क पठाइएको छ।" },
  "auth.forgot.sentToast": { en: "Reset link sent. Check your email.", ne: "रिसेट लिङ्क पठाइयो। इमेल हेर्नुहोस्।" },
  "auth.forgot.backToLogin": { en: "Back to sign in", ne: "लगइनमा फर्कनुहोस्" },

  "auth.err.required": { en: "Please enter your email and password.", ne: "कृपया इमेल र पासवर्ड लेख्नुहोस्।" },
  "auth.err.invalidCredentials": { en: "Email or password is incorrect.", ne: "इमेल वा पासवर्ड मिलेन।" },
  "auth.err.invalidEmail": { en: "Please enter a valid email address.", ne: "कृपया सही इमेल ठेगाना लेख्नुहोस्।" },
  "auth.err.disabled": { en: "This account has been deactivated. Please contact support.", ne: "यो खाता निष्क्रिय गरिएको छ। कृपया सम्पर्क गर्नुहोस्।" },
  "auth.err.tooMany": { en: "Too many attempts. Please wait a few minutes or reset your password.", ne: "धेरै प्रयास भयो। केही मिनेट पर्खनुहोस् वा पासवर्ड रिसेट गर्नुहोस्।" },
  "auth.err.network": { en: "No internet connection. Please check and try again.", ne: "इन्टरनेट जडान छैन। जाँच गरी फेरि प्रयास गर्नुहोस्।" },
  "auth.err.generic": { en: "Something went wrong. Please try again.", ne: "केही गडबड भयो। फेरि प्रयास गर्नुहोस्।" },
  "auth.err.name": { en: "Please enter your full name.", ne: "कृपया पूरा नाम लेख्नुहोस्।" },
  "auth.err.phone": { en: "Please enter a valid Nepal mobile number (e.g. 98XXXXXXXX).", ne: "कृपया सही मोबाइल नम्बर लेख्नुहोस् (जस्तै: ९८XXXXXXXX)।" },
  "auth.err.weakPassword": { en: "Password must be at least 8 characters with letters and numbers.", ne: "पासवर्ड कम्तीमा ८ अक्षरको, अक्षर र अंक सहित हुनुपर्छ।" },
  "auth.err.mismatch": { en: "Passwords do not match.", ne: "पासवर्ड मिलेन।" },
  "auth.err.terms": { en: "Please accept the Terms of Service to continue.", ne: "जारी राख्न सेवा सर्तहरूमा सहमति जनाउनुहोस्।" },
  "auth.err.emailInUse": { en: "An account with this email already exists. Please sign in.", ne: "यो इमेलको खाता पहिले नै छ। कृपया लगइन गर्नुहोस्।" },
};

const LanguageContext = createContext<LanguageContextType>({
  language: "en",
  setLanguage: () => {},
  toggleLanguage: () => {},
  t: (key: string) => key,
});

export const LanguageProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [language, setLanguageState] = useState<Language>("en");

  useEffect(() => {
    try {
      const saved = localStorage.getItem("svc_language") as Language | null;
      if (saved === "en" || saved === "ne") {
        setLanguageState(saved);
      }
    } catch (e) {
      // Ignore localStorage read errors in SSR/sandboxed mode
    }
  }, []);

  const setLanguage = (lang: Language) => {
    setLanguageState(lang);
    try {
      localStorage.setItem("svc_language", lang);
    } catch (e) {}
  };

  const toggleLanguage = () => {
    const next: Language = language === "en" ? "ne" : "en";
    setLanguage(next);
  };

  const t = (key: string, vars?: Record<string, string>): string => {
    const entry = DICTIONARY[key];
    if (!entry) return key;
    const text = entry[language] || entry.en || key;
    return vars ? text.replace(/\{(\w+)\}/g, (match, name) => vars[name] ?? match) : text;
  };

  return (
    <LanguageContext.Provider value={{ language, setLanguage, toggleLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  );
};

export const useLanguage = () => useContext(LanguageContext);
