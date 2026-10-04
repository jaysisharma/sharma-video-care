"use client";

import React, { useEffect, useState, useMemo } from "react";
import Link from "next/link";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../../lib/firebase";
import { useCart } from "../../context/CartContext";
import { ProductCard } from "@/components/ProductCard";
import { SHOP_PRODUCTS, SHOP_CATEGORIES, SHOP_BRANDS, ShopProduct } from "@/data/shopProducts";
import {
  Search,
  SlidersHorizontal,
  X,
  ShieldCheck,
  Truck,
  RotateCcw,
  Headphones,
  ArrowRight,
  Sparkles,
} from "lucide-react";

export default function ShopPage() {
  const [products, setProducts] = useState<ShopProduct[]>(SHOP_PRODUCTS);
  const [search, setSearch] = useState("");
  const [selectedCat, setSelectedCat] = useState<string>("All");
  const [selectedBrand, setSelectedBrand] = useState<string>("All Brands");
  const [sortBy, setSortBy] = useState<"FEATURED" | "PRICE_ASC" | "PRICE_DESC" | "RATING">("FEATURED");
  const [onlyInStock, setOnlyInStock] = useState(false);
  const [loading, setLoading] = useState(false);
  const [addedId, setAddedId] = useState<string | null>(null);
  const [wishlist, setWishlist] = useState<string[]>([]);

  const { addToCart } = useCart();

  // Load Firestore products and merge with curated verified catalog
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

          // Merge without duplicate IDs
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

  // Category counts
  const categoryCounts = useMemo(() => {
    const counts: Record<string, number> = { All: products.length };
    products.forEach((p) => {
      const cat = p.category || "Other";
      counts[cat] = (counts[cat] || 0) + 1;
    });
    return counts;
  }, [products]);

  // Filtering
  const filtered = useMemo(() => {
    const q = search.toLowerCase().trim();
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

      return matchesSearch && matchesCat && matchesBrand && matchesStock;
    });
  }, [products, search, selectedCat, selectedBrand, onlyInStock]);

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
    setTimeout(() => setAddedId(null), 1800);
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
    setSortBy("FEATURED");
    setOnlyInStock(false);
  };

  const hasActiveFilters =
    search.trim() !== "" ||
    selectedCat !== "All" ||
    selectedBrand !== "All Brands" ||
    onlyInStock ||
    sortBy !== "FEATURED";

  return (
    <div style={{ background: "#F8FAFC", minHeight: "100vh" }}>
      {/* Top Banner / Store Header */}
      <section
        style={{
          background: "#FFFFFF",
          borderBottom: "1px solid #E2E8F0",
          padding: "2.5rem 1.25rem 2rem 1.25rem",
        }}
      >
        <div style={{ maxWidth: "1280px", margin: "0 auto" }}>
          {/* Breadcrumb */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "8px",
              fontSize: "13px",
              color: "#64748B",
              marginBottom: "12px",
            }}
          >
            <Link href="/" style={{ color: "#64748B", textDecoration: "none" }}>
              Home
            </Link>
            <span>/</span>
            <span style={{ color: "#0F172A", fontWeight: 600 }}>Store & Catalogue</span>
          </div>

          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "flex-end",
              flexWrap: "wrap",
              gap: "1.5rem",
            }}
          >
            <div>
              <div
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "6px",
                  background: "#FFF7ED",
                  color: "#E86F1C",
                  border: "1px solid #FFEDD5",
                  padding: "4px 10px",
                  borderRadius: "6px",
                  fontSize: "12px",
                  fontWeight: 700,
                  textTransform: "uppercase",
                  letterSpacing: "0.04em",
                  marginBottom: "0.75rem",
                }}
              >
                <Sparkles size={14} /> Official Nepal Store
              </div>

              <h1
                style={{
                  fontSize: "2.25rem",
                  fontWeight: 800,
                  color: "#0F172A",
                  letterSpacing: "-0.025em",
                  margin: "0 0 0.5rem 0",
                  lineHeight: 1.2,
                }}
              >
                Electronics & Equipment Store
              </h1>
              <p
                style={{
                  fontSize: "1rem",
                  color: "#475569",
                  margin: 0,
                  maxWidth: "760px",
                  lineHeight: 1.5,
                }}
              >
                Direct distributor & verified laboratory-certified electronics. Every camera, lens,
                drone, and surveillance system includes genuine manufacturer warranty and insured
                nationwide delivery.
              </p>
            </div>

            <Link
              href="/source-request"
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "8px",
                background: "#0F172A",
                color: "#FFFFFF",
                padding: "10px 18px",
                borderRadius: "8px",
                fontSize: "13px",
                fontWeight: 650,
                textDecoration: "none",
                border: "1px solid #0F172A",
                transition: "background 0.15s ease",
              }}
            >
              <span>Can't find a model? Request Sourcing</span>
              <ArrowRight size={15} />
            </Link>
          </div>

          {/* Trust Value Strip */}
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
              gap: "12px",
              marginTop: "2rem",
              paddingTop: "1.5rem",
              borderTop: "1px solid #F1F5F9",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
              <div
                style={{
                  width: "36px",
                  height: "36px",
                  borderRadius: "8px",
                  background: "#F8FAFC",
                  border: "1px solid #E2E8F0",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  color: "#E86F1C",
                  flexShrink: 0,
                }}
              >
                <ShieldCheck size={20} />
              </div>
              <div>
                <div style={{ fontSize: "13px", fontWeight: 700, color: "#0F172A" }}>
                  100% Genuine Products
                </div>
                <div style={{ fontSize: "11px", color: "#64748B" }}>
                  Official brand warranties with VAT bill
                </div>
              </div>
            </div>

            <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
              <div
                style={{
                  width: "36px",
                  height: "36px",
                  borderRadius: "8px",
                  background: "#F8FAFC",
                  border: "1px solid #E2E8F0",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  color: "#E86F1C",
                  flexShrink: 0,
                }}
              >
                <Truck size={20} />
              </div>
              <div>
                <div style={{ fontSize: "13px", fontWeight: 700, color: "#0F172A" }}>
                  Insured Nepal Courier
                </div>
                <div style={{ fontSize: "11px", color: "#64748B" }}>
                  Free Janakpur pickup & tracked transit
                </div>
              </div>
            </div>

            <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
              <div
                style={{
                  width: "36px",
                  height: "36px",
                  borderRadius: "8px",
                  background: "#F8FAFC",
                  border: "1px solid #E2E8F0",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  color: "#E86F1C",
                  flexShrink: 0,
                }}
              >
                <RotateCcw size={20} />
              </div>
              <div>
                <div style={{ fontSize: "13px", fontWeight: 700, color: "#0F172A" }}>
                  7-Day Replacement
                </div>
                <div style={{ fontSize: "11px", color: "#64748B" }}>
                  Guaranteed replacement for defects
                </div>
              </div>
            </div>

            <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
              <div
                style={{
                  width: "36px",
                  height: "36px",
                  borderRadius: "8px",
                  background: "#F8FAFC",
                  border: "1px solid #E2E8F0",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  color: "#E86F1C",
                  flexShrink: 0,
                }}
              >
                <Headphones size={20} />
              </div>
              <div>
                <div style={{ fontSize: "13px", fontWeight: 700, color: "#0F172A" }}>
                  Technician Lab Support
                </div>
                <div style={{ fontSize: "11px", color: "#64748B" }}>
                  Janakpur workshop service backup
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Main Content Area */}
      <div style={{ maxWidth: "1280px", margin: "0 auto", padding: "2rem 1.25rem 4rem 1.25rem" }}>
        {/* Horizontal Category Filter Pills */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: "8px",
            overflowX: "auto",
            paddingBottom: "8px",
            marginBottom: "1.5rem",
            scrollbarWidth: "none",
          }}
        >
          {SHOP_CATEGORIES.map((cat) => {
            const isSelected = selectedCat === cat;
            const count = categoryCounts[cat] || 0;
            return (
              <button
                key={cat}
                type="button"
                onClick={() => setSelectedCat(cat)}
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "6px",
                  padding: "8px 16px",
                  borderRadius: "8px",
                  fontSize: "13.5px",
                  fontWeight: isSelected ? 700 : 550,
                  color: isSelected ? "#FFFFFF" : "#334155",
                  background: isSelected ? "#E86F1C" : "#FFFFFF",
                  border: isSelected ? "1px solid #E86F1C" : "1px solid #E2E8F0",
                  cursor: "pointer",
                  whiteSpace: "nowrap",
                  transition: "all 0.15s ease",
                  boxShadow: isSelected
                    ? "0 2px 6px rgba(232, 111, 28, 0.25)"
                    : "0 1px 2px rgba(0, 0, 0, 0.03)",
                }}
              >
                <span>{cat}</span>
                {count > 0 && (
                  <span
                    style={{
                      fontSize: "11px",
                      padding: "1px 6px",
                      borderRadius: "10px",
                      background: isSelected ? "rgba(255, 255, 255, 0.25)" : "#F1F5F9",
                      color: isSelected ? "#FFFFFF" : "#64748B",
                      fontWeight: 650,
                    }}
                  >
                    {count}
                  </span>
                )}
              </button>
            );
          })}
        </div>

        {/* Search, Brand, Availability & Sort Toolbar */}
        <div
          style={{
            background: "#FFFFFF",
            border: "1px solid #E2E8F0",
            borderRadius: "12px",
            padding: "1rem 1.25rem",
            marginBottom: "1.75rem",
            display: "flex",
            flexDirection: "column",
            gap: "1rem",
            boxShadow: "0 1px 3px rgba(0, 0, 0, 0.02)",
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "12px",
              flexWrap: "wrap",
            }}
          >
            {/* Search Input with Clear Button */}
            <div
              style={{
                position: "relative",
                flex: "1 1 280px",
                display: "flex",
                alignItems: "center",
              }}
            >
              <Search
                size={18}
                style={{
                  position: "absolute",
                  left: "12px",
                  color: "#94A3B8",
                  pointerEvents: "none",
                }}
              />
              <input
                type="text"
                placeholder="Search cameras, lenses, drones, models, specifications..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                style={{
                  width: "100%",
                  height: "40px",
                  padding: "0 36px 0 38px",
                  borderRadius: "8px",
                  border: "1px solid #CBD5E1",
                  fontSize: "13.5px",
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
                    right: "10px",
                    background: "none",
                    border: "none",
                    cursor: "pointer",
                    padding: "4px",
                    color: "#94A3B8",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                  }}
                >
                  <X size={15} />
                </button>
              )}
            </div>

            {/* Brand Filter Dropdown */}
            <div style={{ flex: "0 1 180px", minWidth: "150px" }}>
              <select
                value={selectedBrand}
                onChange={(e) => setSelectedBrand(e.target.value)}
                style={{
                  width: "100%",
                  height: "40px",
                  padding: "0 12px",
                  borderRadius: "8px",
                  border: "1px solid #CBD5E1",
                  fontSize: "13px",
                  color: "#0F172A",
                  background: "#FFFFFF",
                  fontWeight: 550,
                  cursor: "pointer",
                  outline: "none",
                }}
              >
                {SHOP_BRANDS.map((brand) => (
                  <option key={brand} value={brand}>
                    {brand}
                  </option>
                ))}
              </select>
            </div>

            {/* Sort Dropdown */}
            <div style={{ flex: "0 1 190px", minWidth: "170px" }}>
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value as any)}
                style={{
                  width: "100%",
                  height: "40px",
                  padding: "0 12px",
                  borderRadius: "8px",
                  border: "1px solid #CBD5E1",
                  fontSize: "13px",
                  color: "#0F172A",
                  background: "#FFFFFF",
                  fontWeight: 550,
                  cursor: "pointer",
                  outline: "none",
                }}
              >
                <option value="FEATURED">Sort: Featured</option>
                <option value="PRICE_ASC">Price: Low to High</option>
                <option value="PRICE_DESC">Price: High to Low</option>
                <option value="RATING">Top Customer Rating</option>
              </select>
            </div>

            {/* In-Stock Toggle */}
            <label
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "8px",
                fontSize: "13px",
                color: "#334155",
                fontWeight: 600,
                cursor: "pointer",
                userSelect: "none",
                padding: "8px 12px",
                borderRadius: "8px",
                background: onlyInStock ? "#F1F5F9" : "transparent",
                border: "1px solid",
                borderColor: onlyInStock ? "#CBD5E1" : "transparent",
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

          {/* Active Filter Chips & Results Count Bar */}
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              flexWrap: "wrap",
              gap: "8px",
              paddingTop: "0.75rem",
              borderTop: "1px solid #F1F5F9",
              fontSize: "13px",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: "8px", flexWrap: "wrap" }}>
              <span style={{ color: "#64748B" }}>
                Showing <strong style={{ color: "#0F172A" }}>{sorted.length}</strong> of{" "}
                <strong style={{ color: "#0F172A" }}>{products.length}</strong> products
              </span>

              {selectedCat !== "All" && (
                <span
                  style={{
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "4px",
                    background: "#F1F5F9",
                    color: "#334155",
                    padding: "2px 8px",
                    borderRadius: "4px",
                    fontSize: "12px",
                    fontWeight: 600,
                  }}
                >
                  Category: {selectedCat}
                  <button
                    onClick={() => setSelectedCat("All")}
                    style={{
                      background: "none",
                      border: "none",
                      cursor: "pointer",
                      padding: 0,
                      color: "#64748B",
                      display: "flex",
                    }}
                  >
                    <X size={12} />
                  </button>
                </span>
              )}

              {selectedBrand !== "All Brands" && (
                <span
                  style={{
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "4px",
                    background: "#F1F5F9",
                    color: "#334155",
                    padding: "2px 8px",
                    borderRadius: "4px",
                    fontSize: "12px",
                    fontWeight: 600,
                  }}
                >
                  Brand: {selectedBrand}
                  <button
                    onClick={() => setSelectedBrand("All Brands")}
                    style={{
                      background: "none",
                      border: "none",
                      cursor: "pointer",
                      padding: 0,
                      color: "#64748B",
                      display: "flex",
                    }}
                  >
                    <X size={12} />
                  </button>
                </span>
              )}

              {onlyInStock && (
                <span
                  style={{
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "4px",
                    background: "#ECFDF5",
                    color: "#059669",
                    padding: "2px 8px",
                    borderRadius: "4px",
                    fontSize: "12px",
                    fontWeight: 600,
                  }}
                >
                  In-Stock Only
                  <button
                    onClick={() => setOnlyInStock(false)}
                    style={{
                      background: "none",
                      border: "none",
                      cursor: "pointer",
                      padding: 0,
                      color: "#059669",
                      display: "flex",
                    }}
                  >
                    <X size={12} />
                  </button>
                </span>
              )}
            </div>

            {hasActiveFilters && (
              <button
                type="button"
                onClick={clearAllFilters}
                style={{
                  background: "none",
                  border: "none",
                  color: "#E86F1C",
                  fontSize: "12.5px",
                  fontWeight: 650,
                  cursor: "pointer",
                  padding: "4px 8px",
                }}
              >
                Reset All Filters
              </button>
            )}
          </div>
        </div>

        {/* Product Grid */}
        {loading ? (
          <div
            style={{
              textAlign: "center",
              padding: "5rem 0",
              background: "#FFFFFF",
              borderRadius: "12px",
              border: "1px solid #E2E8F0",
              color: "#64748B",
              fontSize: "15px",
            }}
          >
            Loading catalogue products...
          </div>
        ) : sorted.length === 0 ? (
          <div
            style={{
              textAlign: "center",
              padding: "4.5rem 2rem",
              background: "#FFFFFF",
              borderRadius: "14px",
              border: "1px solid #E2E8F0",
              boxShadow: "0 1px 3px rgba(0, 0, 0, 0.02)",
            }}
          >
            <div
              style={{
                width: "56px",
                height: "56px",
                borderRadius: "50%",
                background: "#F1F5F9",
                color: "#64748B",
                display: "inline-flex",
                alignItems: "center",
                justifyContent: "center",
                marginBottom: "1rem",
              }}
            >
              <Search size={24} />
            </div>
            <h3
              style={{
                fontSize: "1.25rem",
                fontWeight: 700,
                color: "#0F172A",
                margin: "0 0 0.5rem 0",
              }}
            >
              No products found matching your criteria
            </h3>
            <p
              style={{
                color: "#64748B",
                fontSize: "14px",
                maxWidth: "480px",
                margin: "0 auto 1.5rem auto",
                lineHeight: 1.5,
              }}
            >
              We couldn't find any items matching &ldquo;{search || selectedCat}&rdquo;. Try
              adjusting your search keywords or clearing your active filters.
            </p>

            <div style={{ display: "flex", justifyContent: "center", gap: "12px", flexWrap: "wrap" }}>
              <button
                type="button"
                onClick={clearAllFilters}
                style={{
                  background: "#E86F1C",
                  color: "#FFFFFF",
                  border: "none",
                  padding: "10px 20px",
                  borderRadius: "8px",
                  fontSize: "13.5px",
                  fontWeight: 650,
                  cursor: "pointer",
                }}
              >
                Reset All Filters
              </button>
              <Link
                href="/source-request"
                style={{
                  background: "#0F172A",
                  color: "#FFFFFF",
                  textDecoration: "none",
                  padding: "10px 20px",
                  borderRadius: "8px",
                  fontSize: "13.5px",
                  fontWeight: 650,
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "6px",
                }}
              >
                <span>Request Custom Sourcing</span>
                <ArrowRight size={14} />
              </Link>
            </div>
          </div>
        ) : (
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
              gap: "24px",
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

        {/* Custom Sourcing Callout Card */}
        <div
          style={{
            marginTop: "4rem",
            background: "#0F172A",
            borderRadius: "14px",
            padding: "2.5rem 2rem",
            color: "#FFFFFF",
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            flexWrap: "wrap",
            gap: "2rem",
            border: "1px solid #1E293B",
          }}
        >
          <div style={{ maxWidth: "680px" }}>
            <span
              style={{
                fontSize: "12px",
                fontWeight: 750,
                color: "#E86F1C",
                textTransform: "uppercase",
                letterSpacing: "0.08em",
                display: "block",
                marginBottom: "6px",
              }}
            >
              Direct Procurement Desk
            </span>
            <h2
              style={{
                fontSize: "1.65rem",
                fontWeight: 800,
                color: "#FFFFFF",
                letterSpacing: "-0.015em",
                margin: "0 0 0.5rem 0",
              }}
            >
              Looking for specialized cinema, drone, or studio equipment?
            </h2>
            <p
              style={{
                fontSize: "14px",
                color: "#94A3B8",
                margin: 0,
                lineHeight: 1.6,
              }}
            >
              If a specific camera body, cinema lens, drone payload, or broadcast device is not in our
              immediate stock, our procurement team sources it directly via authorized manufacturer
              channels with guaranteed Nepal customs clearance and official warranty.
            </p>
          </div>

          <div style={{ display: "flex", gap: "12px", flexWrap: "wrap" }}>
            <Link
              href="/source-request"
              style={{
                background: "#E86F1C",
                color: "#FFFFFF",
                textDecoration: "none",
                padding: "12px 24px",
                borderRadius: "8px",
                fontSize: "14px",
                fontWeight: 700,
                display: "inline-flex",
                alignItems: "center",
                gap: "8px",
                boxShadow: "0 2px 6px rgba(232, 111, 28, 0.3)",
              }}
            >
              <span>Submit Sourcing Request</span>
              <ArrowRight size={16} />
            </Link>
            <a
              href="tel:+9779854025000"
              style={{
                background: "#1E293B",
                color: "#F8FAFC",
                textDecoration: "none",
                padding: "12px 20px",
                borderRadius: "8px",
                fontSize: "14px",
                fontWeight: 650,
                border: "1px solid #334155",
                display: "inline-flex",
                alignItems: "center",
                gap: "8px",
              }}
            >
              <Headphones size={16} color="#E86F1C" />
              <span>Call Janakpur Desk</span>
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
