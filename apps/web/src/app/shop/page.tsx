"use client";

import React, { useEffect, useState, useMemo, Suspense } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../../lib/firebase";
import { useCart } from "../../context/CartContext";
import { ProductCard } from "@/components/ProductCard";
import {
  SHOP_PRODUCTS,
  SHOP_CATEGORIES,
  SHOP_BRANDS,
  SHOP_PRICE_BRACKETS,
  ShopProduct,
} from "@/data/shopProducts";
import {
  Search,
  SlidersHorizontal,
  X,
  ShieldCheck,
  Truck,
  RotateCcw,
  Headphones,
  ArrowRight,
  Check,
  ChevronDown,
  RotateCcw as ResetIcon,
  Sparkles,
} from "lucide-react";

function ShopContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const urlQuery = searchParams.get("q") || "";
  const urlCat = searchParams.get("category") || "";

  const [products, setProducts] = useState<ShopProduct[]>(SHOP_PRODUCTS);
  const [search, setSearch] = useState(urlQuery);
  const [selectedCat, setSelectedCat] = useState<string>(urlCat || "All");
  const [selectedBrand, setSelectedBrand] = useState<string>("All Brands");
  const [selectedPriceBracket, setSelectedPriceBracket] = useState<string>("all");
  const [sortBy, setSortBy] = useState<"FEATURED" | "PRICE_ASC" | "PRICE_DESC" | "RATING">("FEATURED");
  const [onlyInStock, setOnlyInStock] = useState(false);
  const [loading, setLoading] = useState(false);
  const [addedId, setAddedId] = useState<string | null>(null);
  const [wishlist, setWishlist] = useState<string[]>([]);
  const [mobileDrawerOpen, setMobileDrawerOpen] = useState(false);

  // Sync state if URL query changes
  useEffect(() => {
    if (urlQuery !== undefined) {
      setSearch(urlQuery);
    }
  }, [urlQuery]);

  useEffect(() => {
    if (urlCat) {
      setSelectedCat(urlCat);
    }
  }, [urlCat]);

  // Cart toast
  const [cartToast, setCartToast] = useState<{ name: string; visible: boolean }>({
    name: "",
    visible: false,
  });

  const { addToCart } = useCart();

  useEffect(() => {
    async function loadProducts() {
      try {
        const snap = await getDocs(collection(db, "products"));
        if (!snap.empty) {
          const liveList: ShopProduct[] = [];
          snap.forEach((d) => {
            const data = d.data();
            liveList.push({
              id: d.id,
              title: data.name || data.title || "Product",
              subtitle: data.subtitle || data.description || "",
              trustNote: data.trustNote || "Official Nepal Warranty • Insured Delivery",
              tag: data.tag || (data.brand ? `Official ${data.brand}` : "Verified Genuine"),
              category: data.categoryName || data.category || "Cameras",
              brand: data.brand || "Brand",
              model: data.model || "",
              sku: data.sku || d.id,
              price: data.price || 0,
              originalPrice: data.originalPrice,
              rating: data.rating || 4.8,
              reviewsCount: data.reviewsCount || 15,
              image: data.image || (data.images && data.images[0]) || "/images/products/canon_eos.jpg",
              images: data.images || (data.image ? [data.image] : ["/images/products/canon_eos.jpg"]),
              availabilityType: data.availabilityType || "IN_STOCK",
              stockQuantity: data.stockQuantity || 5,
              warrantyInfo: data.warrantyInfo || "Official Manufacturer Warranty",
              returnPolicyInfo: data.returnPolicyInfo || "7-day replacement guarantee",
              description: data.description || "",
              specifications: data.specifications || {},
            });
          });

          const liveIds = new Set(liveList.map((p) => p.id));
          const combined = [...liveList, ...SHOP_PRODUCTS.filter((p) => !liveIds.has(p.id))];
          setProducts(combined);
        } else {
          setProducts(SHOP_PRODUCTS);
        }
      } catch (err) {
        console.warn("Using offline catalog fallback:", err);
        setProducts(SHOP_PRODUCTS);
      } finally {
        setLoading(false);
      }
    }
    loadProducts();
  }, []);

  // Counts
  const categoryCounts = useMemo(() => {
    const counts: Record<string, number> = { All: products.length };
    products.forEach((p) => {
      const cat = p.category || "Other";
      counts[cat] = (counts[cat] || 0) + 1;
    });
    return counts;
  }, [products]);

  const brandCounts = useMemo(() => {
    const counts: Record<string, number> = { "All Brands": products.length };
    products.forEach((p) => {
      const b = p.brand || "Other";
      counts[b] = (counts[b] || 0) + 1;
    });
    return counts;
  }, [products]);

  // Filtering
  const filtered = useMemo(() => {
    const q = search.toLowerCase().trim();
    const bracket = SHOP_PRICE_BRACKETS.find((b) => b.id === selectedPriceBracket);

    return products.filter((p) => {
      const matchesSearch =
        !q ||
        p.title.toLowerCase().includes(q) ||
        (p.brand && p.brand.toLowerCase().includes(q)) ||
        (p.subtitle && p.subtitle.toLowerCase().includes(q)) ||
        (p.category && p.category.toLowerCase().includes(q)) ||
        (p.description && p.description.toLowerCase().includes(q));

      const matchesCat =
        selectedCat === "All" ||
        (p.category && p.category.toLowerCase() === selectedCat.toLowerCase());

      const matchesBrand =
        selectedBrand === "All Brands" ||
        (p.brand && p.brand.toLowerCase() === selectedBrand.toLowerCase());

      const matchesStock = !onlyInStock || p.availabilityType === "IN_STOCK";

      let matchesPrice = true;
      if (bracket && bracket.id !== "all") {
        matchesPrice = p.price >= bracket.min && p.price < bracket.max;
      }

      return matchesSearch && matchesCat && matchesBrand && matchesStock && matchesPrice;
    });
  }, [products, search, selectedCat, selectedBrand, onlyInStock, selectedPriceBracket]);

  // Sorting
  const sorted = useMemo(() => {
    return [...filtered].sort((a, b) => {
      if (sortBy === "PRICE_ASC") return a.price - b.price;
      if (sortBy === "PRICE_DESC") return b.price - a.price;
      if (sortBy === "RATING") return (b.rating || 0) - (a.rating || 0);
      return 0; // FEATURED
    });
  }, [filtered, sortBy]);

  const handleAddToCart = (p: ShopProduct, e?: React.MouseEvent) => {
    if (e) {
      e.preventDefault();
      e.stopPropagation();
    }
    addToCart({
      productId: p.id,
      productType: "NEW",
      name: p.title,
      image: p.image || (p.images && p.images[0]),
      unitPrice: p.price,
      quantity: 1,
      totalPrice: p.price,
      warrantySummary: p.warrantyInfo || p.trustNote,
    });
    setAddedId(p.id);
    setCartToast({ name: p.title, visible: true });
    setTimeout(() => setAddedId(null), 1800);
    setTimeout(() => setCartToast((prev) => ({ ...prev, visible: false })), 4000);
  };

  const handleToggleWishlist = (id: string, e?: React.MouseEvent) => {
    if (e) {
      e.preventDefault();
      e.stopPropagation();
    }
    setWishlist((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const clearAllFilters = () => {
    setSearch("");
    setSelectedCat("All");
    setSelectedBrand("All Brands");
    setSelectedPriceBracket("all");
    setSortBy("FEATURED");
    setOnlyInStock(false);
    if (urlQuery || urlCat) {
      router.push("/shop");
    }
  };

  const activeFiltersCount =
    (search.trim() ? 1 : 0) +
    (selectedCat !== "All" ? 1 : 0) +
    (selectedBrand !== "All Brands" ? 1 : 0) +
    (selectedPriceBracket !== "all" ? 1 : 0) +
    (onlyInStock ? 1 : 0) +
    (sortBy !== "FEATURED" ? 1 : 0);

  // Common Filter Sidebar Component
  const FilterSidebar = () => (
    <div style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
      {/* Active Filter Header Indicator */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <span style={{ fontSize: "14px", fontWeight: 750, color: "#0F172A", textTransform: "uppercase", letterSpacing: "0.05em" }}>
          Filters
        </span>
        {activeFiltersCount > 0 && (
          <button
            type="button"
            onClick={clearAllFilters}
            style={{
              background: "none",
              border: "none",
              color: "#E86F1C",
              fontSize: "12px",
              fontWeight: 650,
              cursor: "pointer",
              padding: 0,
            }}
          >
            Reset All
          </button>
        )}
      </div>

      {/* Category Section */}
      <div>
        <div style={{ fontSize: "12px", fontWeight: 700, color: "#64748B", textTransform: "uppercase", letterSpacing: "0.06em", marginBottom: "10px" }}>
          Category
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
          {SHOP_CATEGORIES.map((cat) => {
            const isSelected = selectedCat === cat;
            return (
              <button
                key={cat}
                type="button"
                onClick={() => setSelectedCat(cat)}
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  padding: "7px 10px",
                  borderRadius: "6px",
                  border: "none",
                  background: isSelected ? "#0F172A" : "transparent",
                  color: isSelected ? "#FFFFFF" : "#334155",
                  fontSize: "13px",
                  fontWeight: isSelected ? 700 : 500,
                  cursor: "pointer",
                  textAlign: "left",
                  transition: "background 0.12s ease",
                }}
              >
                <span>{cat}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Brand Section */}
      <div>
        <div style={{ fontSize: "12px", fontWeight: 700, color: "#64748B", textTransform: "uppercase", letterSpacing: "0.06em", marginBottom: "10px" }}>
          Brand
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
          {SHOP_BRANDS.map((brand) => {
            const isSelected = selectedBrand === brand;
            return (
              <button
                key={brand}
                type="button"
                onClick={() => setSelectedBrand(brand)}
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  padding: "7px 10px",
                  borderRadius: "6px",
                  border: "none",
                  background: isSelected ? "#F1F5F9" : "transparent",
                  color: isSelected ? "#E86F1C" : "#475569",
                  fontSize: "13px",
                  fontWeight: isSelected ? 700 : 500,
                  cursor: "pointer",
                  textAlign: "left",
                }}
              >
                <span>{brand}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Price Budget Section */}
      <div>
        <div style={{ fontSize: "12px", fontWeight: 700, color: "#64748B", textTransform: "uppercase", letterSpacing: "0.06em", marginBottom: "10px" }}>
          Price Range
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
          {SHOP_PRICE_BRACKETS.map((b) => {
            const isSelected = selectedPriceBracket === b.id;
            return (
              <label
                key={b.id}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                  fontSize: "13px",
                  color: isSelected ? "#0F172A" : "#475569",
                  fontWeight: isSelected ? 650 : 500,
                  cursor: "pointer",
                }}
              >
                <input
                  type="radio"
                  name="priceBracket"
                  checked={isSelected}
                  onChange={() => setSelectedPriceBracket(b.id)}
                  style={{ accentColor: "#E86F1C", cursor: "pointer" }}
                />
                <span>{b.label}</span>
              </label>
            );
          })}
        </div>
      </div>

      {/* Availability Toggle */}
      <div style={{ paddingTop: "8px", borderTop: "1px solid #F1F5F9" }}>
        <label
          style={{
            display: "flex",
            alignItems: "center",
            gap: "8px",
            fontSize: "13px",
            color: "#0F172A",
            fontWeight: 600,
            cursor: "pointer",
          }}
        >
          <input
            type="checkbox"
            checked={onlyInStock}
            onChange={(e) => setOnlyInStock(e.target.checked)}
            style={{ accentColor: "#E86F1C", width: "16px", height: "16px", cursor: "pointer" }}
          />
          <span>In-Stock Only</span>
        </label>
      </div>
    </div>
  );

  return (
    <div style={{ background: "#F8FAFC", minHeight: "100vh" }}>
      {/* Clean, Streamlined Header */}
      <header
        style={{
          background: "#FFFFFF",
          borderBottom: "1px solid #E2E8F0",
          padding: "1.75rem 1.25rem",
        }}
      >
        <div
          style={{
            maxWidth: "1280px",
            margin: "0 auto",
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            flexWrap: "wrap",
            gap: "1rem",
          }}
        >
          <div>
            <div
              style={{
                fontSize: "12px",
                color: "#64748B",
                marginBottom: "4px",
              }}
            >
              <Link href="/" style={{ color: "#64748B", textDecoration: "none" }}>
                Home
              </Link>{" "}
              / <span style={{ color: "#0F172A", fontWeight: 600 }}>Store</span>
            </div>
            <h1
              style={{
                fontSize: "1.75rem",
                fontWeight: 800,
                color: "#0F172A",
                margin: 0,
                letterSpacing: "-0.02em",
              }}
            >
              Official Electronics Store
            </h1>
            <p style={{ fontSize: "13.5px", color: "#64748B", margin: "2px 0 0 0" }}>
              100% genuine products with official Nepal warranty and insured courier delivery.
            </p>
          </div>

          <div
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "8px",
              background: "#F8FAFC",
              border: "1px solid #E2E8F0",
              color: "#0F172A",
              padding: "8px 14px",
              borderRadius: "8px",
              fontSize: "12.5px",
              fontWeight: 650,
            }}
          >
            <ShieldCheck size={16} color="#16A34A" />
            <span>100% Genuine • Official Warranty</span>
          </div>
        </div>
      </header>

      {/* Main 2-Column Store Layout */}
      <div style={{ maxWidth: "1280px", margin: "0 auto", padding: "1.5rem 1.25rem 4rem 1.25rem" }}>
        <div style={{ display: "grid", gridTemplateColumns: "240px 1fr", gap: "28px", alignItems: "start" }}>
          {/* Desktop Left Sidebar */}
          <aside
            style={{
              background: "#FFFFFF",
              borderRadius: "12px",
              border: "1px solid #E2E8F0",
              padding: "20px",
              position: "sticky",
              top: "20px",
              maxHeight: "calc(100vh - 40px)",
              overflowY: "auto",
              overflowX: "hidden",
              scrollbarWidth: "thin",
              scrollbarColor: "#CBD5E1 transparent",
              display: "block",
            }}
            className="shop-desktop-sidebar"
          >
            <FilterSidebar />
          </aside>

          {/* Right Main Content Area */}
          <main>
            {/* Top Toolbar: Search + Mobile Filter Trigger + Sort Dropdown */}
            <div
              style={{
                background: "#FFFFFF",
                borderRadius: "10px",
                border: "1px solid #E2E8F0",
                padding: "10px 14px",
                marginBottom: "16px",
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                gap: "12px",
                flexWrap: "wrap",
              }}
            >
              {/* Search Bar */}
              <div
                style={{
                  position: "relative",
                  flex: "1 1 240px",
                  display: "flex",
                  alignItems: "center",
                }}
              >
                <Search
                  size={16}
                  style={{
                    position: "absolute",
                    left: "10px",
                    color: "#94A3B8",
                    pointerEvents: "none",
                  }}
                />
                <input
                  type="text"
                  placeholder="Search cameras, lenses, drones, models..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  style={{
                    width: "100%",
                    height: "36px",
                    padding: "0 32px 0 34px",
                    borderRadius: "6px",
                    border: "1px solid #CBD5E1",
                    fontSize: "13px",
                    color: "#0F172A",
                    outline: "none",
                    background: "#FFFFFF",
                  }}
                />
                {search && (
                  <button
                    type="button"
                    onClick={() => setSearch("")}
                    aria-label="Clear search"
                    style={{
                      position: "absolute",
                      right: "8px",
                      background: "none",
                      border: "none",
                      cursor: "pointer",
                      padding: "2px",
                      color: "#94A3B8",
                      display: "flex",
                    }}
                  >
                    <X size={14} />
                  </button>
                )}
              </div>

              {/* Right Controls: Sort + Mobile Button */}
              <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                {/* Sort Dropdown */}
                <select
                  value={sortBy}
                  onChange={(e) => setSortBy(e.target.value as any)}
                  style={{
                    height: "36px",
                    padding: "0 10px",
                    borderRadius: "6px",
                    border: "1px solid #CBD5E1",
                    fontSize: "13px",
                    color: "#0F172A",
                    background: "#FFFFFF",
                    fontWeight: 550,
                    cursor: "pointer",
                    outline: "none",
                  }}
                >
                  <option value="FEATURED">Featured</option>
                  <option value="PRICE_ASC">Price: Low to High</option>
                  <option value="PRICE_DESC">Price: High to Low</option>
                  <option value="RATING">Top Rated</option>
                </select>

                {/* Mobile Filter Button (Visible on small screens) */}
                <button
                  type="button"
                  onClick={() => setMobileDrawerOpen(true)}
                  style={{
                    display: "none",
                    alignItems: "center",
                    gap: "6px",
                    height: "36px",
                    padding: "0 12px",
                    borderRadius: "6px",
                    border: "1px solid #0F172A",
                    background: "#0F172A",
                    color: "#FFFFFF",
                    fontSize: "12.5px",
                    fontWeight: 650,
                    cursor: "pointer",
                  }}
                  className="shop-mobile-filter-btn"
                >
                  <SlidersHorizontal size={14} />
                  <span>Filters</span>
                  {activeFiltersCount > 0 && <span>({activeFiltersCount})</span>}
                </button>
              </div>
            </div>

            {/* Active Search Results Banner if query is active */}
            {search.trim() && (
              <div
                style={{
                  background: "#F8FAFC",
                  border: "1px solid #E2E8F0",
                  borderRadius: "8px",
                  padding: "12px 16px",
                  marginBottom: "16px",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  gap: "12px",
                  flexWrap: "wrap",
                }}
              >
                <div>
                  <span style={{ fontSize: "14px", fontWeight: 700, color: "#0F172A" }}>
                    Search results for &ldquo;{search.trim()}&rdquo;
                  </span>
                  <span style={{ fontSize: "13px", color: "#64748B", marginLeft: "8px" }}>
                    ({sorted.length} {sorted.length === 1 ? "product found" : "products found"})
                  </span>
                </div>
                <button
                  type="button"
                  onClick={() => {
                    setSearch("");
                    if (urlQuery) {
                      router.push("/shop");
                    }
                  }}
                  style={{
                    background: "#FFFFFF",
                    border: "1px solid #CBD5E1",
                    padding: "4px 10px",
                    borderRadius: "6px",
                    fontSize: "12px",
                    fontWeight: 600,
                    color: "#0F172A",
                    cursor: "pointer",
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "5px",
                  }}
                >
                  <X size={13} />
                  <span>Clear Search</span>
                </button>
              </div>
            )}

            {/* Active Filter Tags (Clean single row) */}
            {activeFiltersCount > 0 && (
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "6px",
                  flexWrap: "wrap",
                  marginBottom: "16px",
                  fontSize: "12px",
                }}
              >
                <span style={{ color: "#64748B", fontWeight: 600 }}>Active:</span>

                {search.trim() && (
                  <span
                    style={{
                      background: "#EEF2FF",
                      border: "1px solid #C7D2FE",
                      padding: "2px 8px",
                      borderRadius: "4px",
                      color: "#3730A3",
                      fontWeight: 600,
                      display: "inline-flex",
                      alignItems: "center",
                      gap: "4px",
                    }}
                  >
                    Query: &ldquo;{search.trim()}&rdquo;
                    <button
                      onClick={() => {
                        setSearch("");
                        if (urlQuery) router.push("/shop");
                      }}
                      style={{ background: "none", border: "none", cursor: "pointer", padding: 0, display: "flex", color: "#3730A3" }}
                    >
                      <X size={12} />
                    </button>
                  </span>
                )}

                {selectedCat !== "All" && (
                  <span
                    style={{
                      background: "#FFFFFF",
                      border: "1px solid #CBD5E1",
                      padding: "2px 8px",
                      borderRadius: "4px",
                      color: "#0F172A",
                      fontWeight: 600,
                      display: "inline-flex",
                      alignItems: "center",
                      gap: "4px",
                    }}
                  >
                    {selectedCat}
                    <button
                      onClick={() => setSelectedCat("All")}
                      style={{ background: "none", border: "none", cursor: "pointer", padding: 0, display: "flex", color: "#64748B" }}
                    >
                      <X size={12} />
                    </button>
                  </span>
                )}

                {selectedBrand !== "All Brands" && (
                  <span
                    style={{
                      background: "#FFFFFF",
                      border: "1px solid #CBD5E1",
                      padding: "2px 8px",
                      borderRadius: "4px",
                      color: "#0F172A",
                      fontWeight: 600,
                      display: "inline-flex",
                      alignItems: "center",
                      gap: "4px",
                    }}
                  >
                    {selectedBrand}
                    <button
                      onClick={() => setSelectedBrand("All Brands")}
                      style={{ background: "none", border: "none", cursor: "pointer", padding: 0, display: "flex", color: "#64748B" }}
                    >
                      <X size={12} />
                    </button>
                  </span>
                )}

                {selectedPriceBracket !== "all" && (
                  <span
                    style={{
                      background: "#FFF7ED",
                      border: "1px solid #FFEDD5",
                      padding: "2px 8px",
                      borderRadius: "4px",
                      color: "#C2410C",
                      fontWeight: 600,
                      display: "inline-flex",
                      alignItems: "center",
                      gap: "4px",
                    }}
                  >
                    {SHOP_PRICE_BRACKETS.find((b) => b.id === selectedPriceBracket)?.label}
                    <button
                      onClick={() => setSelectedPriceBracket("all")}
                      style={{ background: "none", border: "none", cursor: "pointer", padding: 0, display: "flex", color: "#C2410C" }}
                    >
                      <X size={12} />
                    </button>
                  </span>
                )}

                {onlyInStock && (
                  <span
                    style={{
                      background: "#ECFDF5",
                      border: "1px solid #D1FAE5",
                      padding: "2px 8px",
                      borderRadius: "4px",
                      color: "#059669",
                      fontWeight: 600,
                      display: "inline-flex",
                      alignItems: "center",
                      gap: "4px",
                    }}
                  >
                    In Stock Only
                    <button
                      onClick={() => setOnlyInStock(false)}
                      style={{ background: "none", border: "none", cursor: "pointer", padding: 0, display: "flex", color: "#059669" }}
                    >
                      <X size={12} />
                    </button>
                  </span>
                )}

                <button
                  type="button"
                  onClick={clearAllFilters}
                  style={{
                    background: "none",
                    border: "none",
                    color: "#E86F1C",
                    fontSize: "12px",
                    fontWeight: 700,
                    cursor: "pointer",
                    padding: "2px 6px",
                  }}
                >
                  Clear all
                </button>
              </div>
            )}

            {/* Product Grid */}
            {loading ? (
              <div
                style={{
                  textAlign: "center",
                  padding: "4rem 0",
                  background: "#FFFFFF",
                  borderRadius: "10px",
                  border: "1px solid #E2E8F0",
                  color: "#64748B",
                  fontSize: "14px",
                }}
              >
                Loading catalogue products...
              </div>
            ) : sorted.length === 0 ? (
              <div
                style={{
                  textAlign: "center",
                  padding: "4rem 2rem",
                  background: "#FFFFFF",
                  borderRadius: "12px",
                  border: "1px solid #E2E8F0",
                }}
              >
                <div
                  style={{
                    width: "48px",
                    height: "48px",
                    borderRadius: "50%",
                    background: "#F1F5F9",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    margin: "0 auto 1rem auto",
                    color: "#64748B",
                  }}
                >
                  <Search size={22} />
                </div>
                <h3 style={{ fontSize: "1.15rem", fontWeight: 700, color: "#0F172A", margin: "0 0 0.5rem 0" }}>
                  {search.trim() ? `No products found for "${search.trim()}"` : "No matching products"}
                </h3>
                <p style={{ color: "#64748B", fontSize: "13.5px", margin: "0 auto 1.25rem auto", maxWidth: "420px" }}>
                  {search.trim()
                    ? "Check your spelling or try searching with more general terms like camera, lens, tripod, or audio."
                    : "We couldn't find any items matching your selected criteria. Try resetting your filters."}
                </p>
                <button
                  type="button"
                  onClick={clearAllFilters}
                  style={{
                    background: "#E86F1C",
                    color: "#FFFFFF",
                    border: "none",
                    padding: "8px 18px",
                    borderRadius: "6px",
                    fontSize: "13px",
                    fontWeight: 650,
                    cursor: "pointer",
                  }}
                >
                  Reset All Filters
                </button>
              </div>
            ) : (
              <div
                style={{
                  display: "grid",
                  gridTemplateColumns: "repeat(auto-fill, minmax(250px, 1fr))",
                  gap: "18px",
                }}
              >
                {sorted.map((prod) => (
                  <ProductCard
                    key={prod.id}
                    product={{
                      id: prod.id,
                      title: prod.title,
                      brand: prod.brand,
                      category: prod.category,
                      price: prod.price,
                      originalPrice: prod.originalPrice,
                      subtitle: prod.subtitle,
                      trustNote: prod.trustNote,
                      tag: prod.tag,
                      image: prod.image,
                      images: prod.images,
                      availabilityType: prod.availabilityType,
                      warrantyInfo: prod.warrantyInfo,
                      rating: prod.rating,
                      reviewsCount: prod.reviewsCount,
                    }}
                    isWishlisted={wishlist.includes(prod.id)}
                    onToggleWishlist={handleToggleWishlist}
                    onAddToCart={(p, e) => handleAddToCart(prod, e)}
                    isAdded={addedId === prod.id}
                  />
                ))}
              </div>
            )}
          </main>
        </div>

        {/* Clean Reassurance Strip at Bottom (Not crowding the top) */}
        <div
          style={{
            marginTop: "3.5rem",
            background: "#FFFFFF",
            border: "1px solid #E2E8F0",
            borderRadius: "12px",
            padding: "1.5rem",
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
            gap: "16px",
          }}
        >
          <div style={{ display: "flex", gap: "10px", alignItems: "center" }}>
            <ShieldCheck size={22} color="#E86F1C" style={{ flexShrink: 0 }} />
            <div>
              <div style={{ fontSize: "13px", fontWeight: 700, color: "#0F172A" }}>
                100% Genuine Guarantee
              </div>
              <div style={{ fontSize: "11.5px", color: "#64748B" }}>
                Official brand warranty with VAT bill
              </div>
            </div>
          </div>

          <div style={{ display: "flex", gap: "10px", alignItems: "center" }}>
            <Truck size={22} color="#E86F1C" style={{ flexShrink: 0 }} />
            <div>
              <div style={{ fontSize: "13px", fontWeight: 700, color: "#0F172A" }}>
                Insured Nepal Courier
              </div>
              <div style={{ fontSize: "11.5px", color: "#64748B" }}>
                Tracked shipping to all 77 districts
              </div>
            </div>
          </div>

          <div style={{ display: "flex", gap: "10px", alignItems: "center" }}>
            <RotateCcw size={22} color="#E86F1C" style={{ flexShrink: 0 }} />
            <div>
              <div style={{ fontSize: "13px", fontWeight: 700, color: "#0F172A" }}>
                7-Day Replacement
              </div>
              <div style={{ fontSize: "11.5px", color: "#64748B" }}>
                Immediate replacement for defects
              </div>
            </div>
          </div>

          <div style={{ display: "flex", gap: "10px", alignItems: "center" }}>
            <Headphones size={22} color="#E86F1C" style={{ flexShrink: 0 }} />
            <div>
              <div style={{ fontSize: "13px", fontWeight: 700, color: "#0F172A" }}>
                Janakpur Workshop Lab
              </div>
              <div style={{ fontSize: "11.5px", color: "#64748B" }}>
                Pre-tested before final dispatch
              </div>
            </div>
          </div>
        </div>

        {/* Custom Sourcing Card */}
        <div
          style={{
            marginTop: "1.5rem",
            background: "#0F172A",
            borderRadius: "12px",
            padding: "2rem",
            color: "#FFFFFF",
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            flexWrap: "wrap",
            gap: "1.5rem",
          }}
        >
          <div>
            <h3 style={{ fontSize: "1.25rem", fontWeight: 800, color: "#FFFFFF", margin: "0 0 0.35rem 0" }}>
              Looking for specialized cinema, drone, or studio equipment?
            </h3>
            <p style={{ fontSize: "13.5px", color: "#94A3B8", margin: 0, maxWidth: "620px" }}>
              If a specific camera body, lens, or broadcast device is not listed, our procurement desk
              sources it directly through official channels.
            </p>
          </div>

          <div style={{ display: "flex", gap: "10px" }}>
            <Link
              href="/source-request"
              style={{
                background: "#E86F1C",
                color: "#FFFFFF",
                textDecoration: "none",
                padding: "10px 18px",
                borderRadius: "6px",
                fontSize: "13px",
                fontWeight: 700,
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
              }}
            >
              <span>Submit Request</span>
              <ArrowRight size={14} />
            </Link>
            <a
              href="tel:+9779854025000"
              style={{
                background: "#1E293B",
                color: "#FFFFFF",
                textDecoration: "none",
                padding: "10px 16px",
                borderRadius: "6px",
                fontSize: "13px",
                fontWeight: 600,
                border: "1px solid #334155",
              }}
            >
              +977-9854025000
            </a>
          </div>
        </div>
      </div>

      {/* Mobile Drawer (Visible on small screens when triggered) */}
      {mobileDrawerOpen && (
        <div
          style={{
            position: "fixed",
            inset: 0,
            background: "rgba(15, 23, 42, 0.6)",
            zIndex: 99999,
            display: "flex",
            justifyContent: "flex-end",
          }}
          onClick={() => setMobileDrawerOpen(false)}
        >
          <div
            style={{
              width: "85%",
              maxWidth: "320px",
              height: "100%",
              background: "#FFFFFF",
              padding: "20px",
              overflowY: "auto",
              boxShadow: "-10px 0 25px rgba(0, 0, 0, 0.2)",
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "20px" }}>
              <span style={{ fontSize: "16px", fontWeight: 800, color: "#0F172A" }}>
                Filter Products
              </span>
              <button
                type="button"
                onClick={() => setMobileDrawerOpen(false)}
                style={{
                  background: "#F1F5F9",
                  border: "none",
                  borderRadius: "50%",
                  width: "32px",
                  height: "32px",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  cursor: "pointer",
                }}
              >
                <X size={16} />
              </button>
            </div>

            <FilterSidebar />

            <button
              type="button"
              onClick={() => setMobileDrawerOpen(false)}
              style={{
                width: "100%",
                marginTop: "24px",
                background: "#E86F1C",
                color: "#FFFFFF",
                border: "none",
                borderRadius: "6px",
                padding: "11px",
                fontSize: "13.5px",
                fontWeight: 700,
                cursor: "pointer",
              }}
            >
              Apply Filters
            </button>
          </div>
        </div>
      )}

      {/* Responsive Styles Injection */}
      <style jsx global>{`
        .shop-desktop-sidebar::-webkit-scrollbar {
          width: 5px;
        }
        .shop-desktop-sidebar::-webkit-scrollbar-track {
          background: transparent;
        }
        .shop-desktop-sidebar::-webkit-scrollbar-thumb {
          background: #CBD5E1;
          border-radius: 4px;
        }
        .shop-desktop-sidebar::-webkit-scrollbar-thumb:hover {
          background: #94A3B8;
        }
        @media (max-width: 860px) {
          .shop-desktop-sidebar {
            display: none !important;
          }
          .shop-mobile-filter-btn {
            display: inline-flex !important;
          }
          div[style*="gridTemplateColumns: 240px 1fr"] {
            grid-template-columns: 1fr !important;
          }
        }
      `}</style>

      {/* Cart Toast Notification */}
      {cartToast.visible && (
        <div
          style={{
            position: "fixed",
            bottom: "24px",
            right: "24px",
            zIndex: 99999,
            background: "#0F172A",
            color: "#FFFFFF",
            padding: "12px 16px",
            borderRadius: "8px",
            boxShadow: "0 10px 25px -5px rgba(0, 0, 0, 0.3)",
            display: "flex",
            alignItems: "center",
            gap: "12px",
            border: "1px solid #334155",
            maxWidth: "380px",
          }}
        >
          <div
            style={{
              width: "24px",
              height: "24px",
              borderRadius: "50%",
              background: "#16A34A",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              flexShrink: 0,
            }}
          >
            <Check size={14} strokeWidth={3} />
          </div>

          <div style={{ flex: 1, overflow: "hidden" }}>
            <div style={{ fontSize: "11px", color: "#94A3B8", textTransform: "uppercase", fontWeight: 700 }}>
              Added to Cart
            </div>
            <div
              style={{
                fontSize: "12.5px",
                fontWeight: 650,
                color: "#FFFFFF",
                whiteSpace: "nowrap",
                overflow: "hidden",
                textOverflow: "ellipsis",
              }}
            >
              {cartToast.name}
            </div>
          </div>

          <Link
            href="/cart"
            style={{
              background: "#E86F1C",
              color: "#FFFFFF",
              textDecoration: "none",
              padding: "5px 10px",
              borderRadius: "5px",
              fontSize: "12px",
              fontWeight: 700,
              flexShrink: 0,
            }}
          >
            View Cart
          </Link>
        </div>
      )}
    </div>
  );
}

export default function ShopPage() {
  return (
    <Suspense
      fallback={
        <div style={{ minHeight: "60vh", padding: "60px", textAlign: "center", color: "#64748B" }}>
          Loading store...
        </div>
      }
    >
      <ShopContent />
    </Suspense>
  );
}
