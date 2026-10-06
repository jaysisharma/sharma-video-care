"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { collection, getDocs } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { useCart } from "@/context/CartContext";
import { useLanguage } from "@/context/LanguageContext";
import { ProductCard, ProductCardData } from "@/components/ProductCard";

// Comprehensive catalog items for the storefront
const CATALOGUE_ITEMS: ProductCardData[] = [
  {
    id: "cat-1",
    title: "Canon EOS R5 Mirrorless Camera Body",
    subtitle: "45MP Full-Frame • 8K RAW • In-Body IS",
    category: "Cameras",
    brand: "Canon",
    price: 485000,
    originalPrice: 520000,
    rating: 4.9,
    reviewsCount: 34,
    image: "/images/products/canon_eos.jpg",
    availabilityType: "IN_STOCK",
  },
  {
    id: "cat-2",
    title: "Sony Alpha A7 IV Full-Frame Camera Body",
    subtitle: "33MP Exmor R • 4K 60p • 10-bit 4:2:2",
    category: "Cameras",
    brand: "Sony",
    price: 320000,
    originalPrice: 345000,
    rating: 4.9,
    reviewsCount: 48,
    image: "/images/products/canon_eos.jpg",
    availabilityType: "IN_STOCK",
  },
  {
    id: "cat-3",
    title: "Apple MacBook Pro 16\" Liquid Retina XDR",
    subtitle: "Apple M3 Pro Chip • 18GB RAM • 512GB SSD",
    category: "Laptops",
    brand: "Apple",
    price: 345000,
    originalPrice: 365000,
    rating: 5.0,
    reviewsCount: 42,
    image: "/images/products/macbook_pro.jpg",
    availabilityType: "IN_STOCK",
  },
  {
    id: "cat-4",
    title: "Apple iPhone 15 Pro Max 256GB Titanium",
    subtitle: "Grade 5 Titanium • A17 Pro Chip • 48MP Pro",
    category: "Mobile",
    brand: "Apple",
    price: 195000,
    originalPrice: 209000,
    rating: 4.9,
    reviewsCount: 68,
    image: "/images/products/iphone_15_pro.jpg",
    availabilityType: "IN_STOCK",
  },
  {
    id: "cat-5",
    title: "Sony WH-1000XM5 Wireless Noise-Cancelling Headphones",
    subtitle: "Industry-Leading ANC • Auto NC Optimizer",
    category: "Audio",
    brand: "Sony",
    price: 46500,
    originalPrice: 52000,
    rating: 4.8,
    reviewsCount: 51,
    image: "/images/products/sony_headphones.jpg",
    availabilityType: "IN_STOCK",
  },
  {
    id: "cat-6",
    title: "Hikvision 4K Ultra HD Outdoor Bullet CCTV",
    subtitle: "8MP Ultra HD • Smart IR 30m • IP67 Metal",
    category: "CCTV",
    brand: "Hikvision",
    price: 24500,
    originalPrice: 28000,
    rating: 4.9,
    reviewsCount: 29,
    image: "/images/products/hikvision_cctv.jpg",
    availabilityType: "IN_STOCK",
  },
  {
    id: "cat-7",
    title: "Nikon D850 DSLR Camera + 24-120mm Kit",
    subtitle: "45.7MP FX Sensor • 4K UHD • Certified Used",
    category: "Cameras",
    brand: "Nikon",
    price: 215000,
    originalPrice: 285000,
    rating: 4.8,
    reviewsCount: 19,
    image: "/images/products/nikon_d850.jpg",
    availabilityType: "IN_STOCK",
  },
  {
    id: "cat-8",
    title: "DJI Mini 4 Pro Drone with RC 2 Controller",
    subtitle: "Under 249g • 4K/60fps HDR • Omnidirectional Sensing",
    category: "Drones",
    brand: "DJI",
    price: 165000,
    originalPrice: 178000,
    rating: 4.9,
    reviewsCount: 31,
    image: "/images/products/dji_drone.jpg",
    availabilityType: "IN_STOCK",
  },
  {
    id: "cat-9",
    title: "Sony FE 24-70mm f/2.8 GM II Standard Zoom Lens",
    subtitle: "G Master Quality • Constant f/2.8 • Ultra Compact",
    category: "Lenses",
    brand: "Sony",
    price: 285000,
    originalPrice: 310000,
    rating: 5.0,
    reviewsCount: 15,
    image: "/images/products/sony_lens.jpg",
    availabilityType: "IN_STOCK",
  },
  {
    id: "cat-10",
    title: "Canon RF 50mm f/1.2 L USM Prime Lens",
    subtitle: "f/1.2 Maximum Aperture • Ring USM • Weather Sealed",
    category: "Lenses",
    brand: "Canon",
    price: 295000,
    rating: 4.9,
    reviewsCount: 22,
    image: "/images/products/sony_lens.jpg",
    availabilityType: "IN_STOCK",
  },
  {
    id: "cat-11",
    title: "Daikin 1.5 Ton 5-Star Inverter Split AC",
    subtitle: "Triple Display • PM 2.5 Filter • Copper Condenser",
    category: "Appliances",
    brand: "Daikin",
    price: 88500,
    originalPrice: 96000,
    rating: 4.9,
    reviewsCount: 37,
    image: "/images/products/ac_unit.jpg",
    availabilityType: "IN_STOCK",
  },
  {
    id: "cat-12",
    title: "LG 8kg AI DirectDrive Front-Load Smart Washer",
    subtitle: "AI DD™ • Steam™ Allergy Care • 1400 RPM",
    category: "Appliances",
    brand: "LG",
    price: 74000,
    originalPrice: 82500,
    rating: 4.8,
    reviewsCount: 26,
    image: "/images/products/washing_machine.jpg",
    availabilityType: "IN_STOCK",
  },
];

const CATEGORIES = [
  "All",
  "Cameras",
  "Lenses",
  "Drones",
  "CCTV",
  "Audio",
  "Laptops",
  "Mobile",
  "Appliances",
];

const CATEGORY_NAMES_NE: Record<string, string> = {
  All: "सबै",
  Cameras: "क्यामेरा",
  Lenses: "लेन्स",
  Drones: "ड्रोन",
  CCTV: "सीसीटिभी",
  Audio: "अडियो",
  Laptops: "ल्यापटप",
  Mobile: "मोबाइल",
  Appliances: "घरेलु उपकरण",
};

export const StoreCatalogue: React.FC = () => {
  const { addToCart } = useCart();
  const { language } = useLanguage();
  const [products, setProducts] = useState<ProductCardData[]>(CATALOGUE_ITEMS);
  const [search, setSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("All");
  const [sortBy, setSortBy] = useState<"FEATURED" | "PRICE_ASC" | "PRICE_DESC" | "RATING">("FEATURED");
  const [wishlist, setWishlist] = useState<string[]>([]);
  const [addedId, setAddedId] = useState<string | null>(null);

  // Fetch Firestore products and merge with catalog
  useEffect(() => {
    async function loadLiveProducts() {
      try {
        const snap = await getDocs(collection(db, "products"));
        if (!snap.empty) {
          const liveList: ProductCardData[] = [];
          snap.forEach((d) => {
            const data = d.data();
            liveList.push({
              id: d.id,
              title: data.name || data.title,
              brand: data.brand || "",
              price: data.price || 0,
              originalPrice: data.originalPrice,
              subtitle: data.description || data.subtitle,
              images: data.images,
              image: data.image || (data.images && data.images[0]),
              category: data.categoryName || data.category || "Cameras",
              rating: data.rating || 4.8,
              reviewsCount: data.reviewsCount || 12,
              availabilityType: data.availabilityType || "IN_STOCK",
              warrantyInfo: data.warrantyInfo,
            });
          });

          // Merge: ensure existing catalog items remain accessible
          const existingIds = new Set(liveList.map((p) => p.id));
          const combined = [...liveList, ...CATALOGUE_ITEMS.filter((p) => !existingIds.has(p.id))];
          setProducts(combined);
        }
      } catch (err) {
        console.error("Firestore catalogue load fallback:", err);
      }
    }
    loadLiveProducts();
  }, []);

  const handleAddToCart = (product: ProductCardData, e?: React.MouseEvent) => {
    if (e) {
      e.preventDefault();
      e.stopPropagation();
    }
    addToCart({
      productId: product.id,
      productType: "NEW",
      name: product.title,
      image: product.image || (product.images && product.images[0]),
      unitPrice: product.price,
      quantity: 1,
      totalPrice: product.price,
      warrantySummary: product.warrantyInfo || product.trustNote,
    });
    setAddedId(product.id);
    setTimeout(() => setAddedId(null), 1800);
  };

  const toggleWishlist = (id: string, e?: React.MouseEvent) => {
    if (e) {
      e.preventDefault();
      e.stopPropagation();
    }
    setWishlist((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  // Filter & Search Logic
  const filtered = products.filter((p) => {
    const query = search.toLowerCase().trim();
    const matchesSearch =
      !query ||
      p.title.toLowerCase().includes(query) ||
      (p.brand && p.brand.toLowerCase().includes(query)) ||
      (p.subtitle && p.subtitle.toLowerCase().includes(query)) ||
      (p.category && p.category.toLowerCase().includes(query));

    const matchesCategory =
      selectedCategory === "All" ||
      (p.category && p.category.toLowerCase() === selectedCategory.toLowerCase());

    return matchesSearch && matchesCategory;
  });

  // Sort Logic
  const sorted = [...filtered].sort((a, b) => {
    if (sortBy === "PRICE_ASC") return a.price - b.price;
    if (sortBy === "PRICE_DESC") return b.price - a.price;
    if (sortBy === "RATING") return (b.rating || 0) - (a.rating || 0);
    return 0; // Default FEATURED
  });

  const displayedProducts = sorted;

  return (
    <section
      id="store-catalogue"
      style={{
        width: "100%",
        padding: "20px 24px 70px 24px",
      }}
    >
      <div
        style={{
          maxWidth: "1280px",
          margin: "0 auto",
        }}
      >
        {/* Section Header */}
        <div style={{ marginBottom: "24px" }}>
          <div
            style={{
              fontSize: "12px",
              fontWeight: 750,
              color: "#E86F1C",
              textTransform: "uppercase",
              letterSpacing: "0.08em",
              marginBottom: "4px",
            }}
          >
            {language === "ne" ? "आधिकारिक स्टोर क्याटलग" : "Official Store Catalogue"}
          </div>
          <div
            style={{
              display: "flex",
              alignItems: "flex-end",
              justifyContent: "space-between",
              flexWrap: "wrap",
              gap: "12px",
            }}
          >
            <div>
              <h2
                style={{
                  fontSize: "24px",
                  fontWeight: 800,
                  color: "#181512",
                  letterSpacing: "-0.02em",
                  margin: 0,
                }}
              >
                {language === "ne"
                  ? "सम्पूर्ण उपकरण क्याटलग हेर्नुहोस्"
                  : "Explore Full Equipment Catalogue"}
              </h2>
              <p
                style={{
                  fontSize: "14px",
                  color: "#7E756C",
                  margin: "4px 0 0 0",
                  maxWidth: "680px",
                }}
              >
                {language === "ne"
                  ? "क्यामेरा, लेन्स, ड्रोन, सुरक्षा क्यामेरा र प्रविधि सामग्री खोज्नुहोस् — आधिकारिक वारेन्टी र नेपालभर सुरक्षित डेलिभरी।"
                  : "Search and explore cameras, lenses, drones, surveillance systems, and tech accessories with genuine warranty and Nepal-wide courier delivery."}
              </p>
            </div>

            <span
              style={{
                fontSize: "13px",
                fontWeight: 600,
                color: "#8C827A",
              }}
            >
              {language === "ne" ? (
                <>
                  जम्मा <strong style={{ color: "#181512" }}>{displayedProducts.length}</strong> /{" "}
                  <strong style={{ color: "#181512" }}>{filtered.length}</strong> सामान
                </>
              ) : (
                <>
                  Showing <strong style={{ color: "#181512" }}>{displayedProducts.length}</strong> of{" "}
                  <strong style={{ color: "#181512" }}>{filtered.length}</strong> items
                </>
              )}
            </span>
          </div>
        </div>

        {/* Catalogue Controls: Search & Category Chips & Filter Bar */}
        <div
          style={{
            background: "#FFFFFF",
            border: "1px solid #ECE7E0",
            borderRadius: "14px",
            padding: "16px 18px",
            marginBottom: "24px",
            display: "flex",
            flexDirection: "column",
            gap: "14px",
            boxShadow: "0 2px 6px rgba(0, 0, 0, 0.02)",
          }}
        >
          {/* Top Row: Search Input + Sort Dropdown */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "12px",
              flexWrap: "wrap",
            }}
          >
            {/* Search Input */}
            <div
              style={{
                position: "relative",
                flex: "1 1 280px",
                display: "flex",
                alignItems: "center",
              }}
            >
              <svg
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="#8C827A"
                strokeWidth="2.2"
                strokeLinecap="round"
                strokeLinejoin="round"
                style={{
                  position: "absolute",
                  left: "14px",
                  pointerEvents: "none",
                }}
              >
                <circle cx="11" cy="11" r="8" />
                <line x1="21" y1="21" x2="16.65" y2="16.65" />
              </svg>
              <input
                type="text"
                placeholder={
                  language === "ne"
                    ? "क्यामेरा, लेन्स, ड्रोन, मोडेल खोज्नुहोस् (उदा. Canon R5, Sony)..."
                    : "Search cameras, lenses, drones, models, e.g. Canon R5, Sony..."
                }
                value={search}
                onChange={(e) => {
                  setSearch(e.target.value);
                }}
                style={{
                  width: "100%",
                  padding: "9px 14px 9px 38px",
                  borderRadius: "8px",
                  border: "1px solid #E2DCD4",
                  fontSize: "13.5px",
                  color: "#181512",
                  background: "#FAF9F7",
                  outline: "none",
                  transition: "border-color 0.15s ease",
                }}
                onFocus={(e) => (e.currentTarget.style.borderColor = "#E86F1C")}
                onBlur={(e) => (e.currentTarget.style.borderColor = "#E2DCD4")}
              />
              {search && (
                <button
                  type="button"
                  onClick={() => setSearch("")}
                  style={{
                    position: "absolute",
                    right: "12px",
                    background: "none",
                    border: "none",
                    fontSize: "14px",
                    color: "#8C827A",
                    cursor: "pointer",
                    padding: 0,
                  }}
                >
                  ✕
                </button>
              )}
            </div>

            {/* Sort Dropdown */}
            <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
              <span style={{ fontSize: "12.5px", color: "#8C827A" }}>
                {language === "ne" ? "क्रमबद्ध:" : "Sort:"}
              </span>
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value as any)}
                style={{
                  padding: "7px 12px",
                  borderRadius: "8px",
                  border: "1px solid #E2DCD4",
                  background: "#FAF9F7",
                  fontSize: "12.5px",
                  fontWeight: 600,
                  color: "#181512",
                  cursor: "pointer",
                  outline: "none",
                }}
              >
                <option value="FEATURED">{language === "ne" ? "विशेष" : "Featured"}</option>
                <option value="PRICE_ASC">{language === "ne" ? "मूल्य: कम देखि बढी" : "Price: Low to High"}</option>
                <option value="PRICE_DESC">{language === "ne" ? "मूल्य: बढी देखि कम" : "Price: High to Low"}</option>
                <option value="RATING">{language === "ne" ? "उच्च मूल्याङ्कन" : "Highest Rated"}</option>
              </select>
            </div>
          </div>

          {/* Bottom Row: Category Pills */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              flexWrap: "wrap",
              gap: "6px",
              paddingTop: "6px",
              borderTop: "1px solid #F5F2EB",
            }}
          >
            {CATEGORIES.map((cat) => {
              const isActive = selectedCategory === cat;
              return (
                <button
                  key={cat}
                  type="button"
                  onClick={() => {
                    setSelectedCategory(cat);
                  }}
                  style={{
                    padding: "5px 13px",
                    borderRadius: "9999px",
                    fontSize: "12.5px",
                    fontWeight: isActive ? 700 : 500,
                    border: "none",
                    cursor: "pointer",
                    background: isActive ? "#E86F1C" : "#F4F0E8",
                    color: isActive ? "#FFFFFF" : "#544D44",
                    transition: "all 0.15s ease",
                  }}
                  onMouseEnter={(e) => {
                    if (!isActive) e.currentTarget.style.background = "#EBE5DB";
                  }}
                  onMouseLeave={(e) => {
                    if (!isActive) e.currentTarget.style.background = "#F4F0E8";
                  }}
                >
                  {language === "ne" ? (CATEGORY_NAMES_NE[cat] || cat) : cat}
                </button>
              );
            })}
          </div>
        </div>

        {/* Products Grid */}
        {displayedProducts.length === 0 ? (
          <div
            style={{
              background: "#FFFFFF",
              border: "1px dashed #D6CEC2",
              borderRadius: "14px",
              padding: "48px 24px",
              textAlign: "center",
              maxWidth: "600px",
              margin: "0 auto",
            }}
          >
            <div
              style={{
                width: "48px",
                height: "48px",
                borderRadius: "50%",
                background: "#FFF3EA",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                margin: "0 auto 14px auto",
                color: "#E86F1C",
              }}
            >
              🔍
            </div>
            <h3 style={{ fontSize: "17px", fontWeight: 750, color: "#181512", margin: "0 0 6px 0" }}>
              {language === "ne" ? "तपाईंको खोज अनुसार कुनै सामान भेटिएन" : "No items match your search & filter"}
            </h3>
            <p style={{ fontSize: "13.5px", color: "#7E756C", margin: "0 0 16px 0", lineHeight: 1.5 }}>
              {language === "ne"
                ? "कृपया फरक शब्द, ब्रान्ड वा वर्ग छानेर पुन: प्रयास गर्नुहोस्।"
                : "Try searching with different keywords, brand names, or reset your category filter to explore all available products."}
            </p>
            <div style={{ display: "flex", justifyContent: "center" }}>
              <button
                type="button"
                onClick={() => {
                  setSearch("");
                  setSelectedCategory("All");
                }}
                style={{
                  padding: "9px 20px",
                  borderRadius: "8px",
                  background: "#E86F1C",
                  color: "#FFFFFF",
                  border: "none",
                  fontSize: "13px",
                  fontWeight: 700,
                  cursor: "pointer",
                  boxShadow: "0 2px 6px rgba(232, 111, 28, 0.25)",
                }}
              >
                {language === "ne" ? "खोज र फिल्टर रिसेट गर्नुहोस्" : "Reset Search & Filters"}
              </button>
            </div>
          </div>
        ) : (
          <>
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))",
                gap: "20px",
              }}
            >
              {displayedProducts.map((product) => (
                <ProductCard
                  key={product.id}
                  product={product}
                  isWishlisted={wishlist.includes(product.id)}
                  onToggleWishlist={toggleWishlist}
                  onAddToCart={handleAddToCart}
                  isAdded={addedId === product.id}
                />
              ))}
            </div>
          </>
        )}
      </div>
    </section>
  );
};

export default StoreCatalogue;
