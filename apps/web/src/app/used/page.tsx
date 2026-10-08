"use client";

import React, { useEffect, useState, useMemo } from "react";
import Link from "next/link";
import Image from "next/image";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../../lib/firebase";
import { useCart } from "../../context/CartContext";
import {
  CERTIFIED_USED_PRODUCTS,
  USED_CATEGORIES,
  USED_CONDITION_GRADES,
  CertifiedUsedItem,
} from "@/data/usedProducts";
import {
  ShieldCheck,
  CheckCircle2,
  Search,
  X,
  ArrowRight,
  ShoppingCart,
  Check,
  RotateCcw,
  Camera,
  Compass,
  ClipboardCheck,
  PhoneCall,
} from "lucide-react";

export default function UsedProductsPage() {
  const [listings, setListings] = useState<CertifiedUsedItem[]>(CERTIFIED_USED_PRODUCTS);
  const [loading, setLoading] = useState(false);
  const [search, setSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<string>("All");
  const [selectedGrade, setSelectedGrade] = useState<string>("All Grades");
  const [sortBy, setSortBy] = useState<"FEATURED" | "PRICE_ASC" | "PRICE_DESC">("FEATURED");
  const [addedId, setAddedId] = useState<string | null>(null);

  const { addToCart } = useCart();

  useEffect(() => {
    async function loadUsedProducts() {
      try {
        const snap = await getDocs(collection(db, "usedProducts"));
        if (!snap.empty) {
          const liveList: CertifiedUsedItem[] = [];
          snap.forEach((d) => {
            const data = d.data();
            liveList.push({
              id: d.id,
              ...data,
              usageMetric: data.usageMetric || "Tested & Certified",
              metricType: data.metricType || "SHUTTER",
            } as CertifiedUsedItem);
          });
          const liveIds = new Set(liveList.map((i) => i.id));
          const combined = [
            ...liveList,
            ...CERTIFIED_USED_PRODUCTS.filter((i) => !liveIds.has(i.id)),
          ];
          setListings(combined);
        } else {
          setListings(CERTIFIED_USED_PRODUCTS);
        }
      } catch (err) {
        console.warn("Using offline certified inventory fallback:", err);
        setListings(CERTIFIED_USED_PRODUCTS);
      } finally {
        setLoading(false);
      }
    }
    loadUsedProducts();
  }, []);

  // Filter & Search Logic
  const filtered = useMemo(() => {
    const q = search.toLowerCase().trim();
    return listings.filter((item) => {
      const matchesSearch =
        !q ||
        item.name.toLowerCase().includes(q) ||
        item.brand.toLowerCase().includes(q) ||
        item.model.toLowerCase().includes(q) ||
        item.usageMetric.toLowerCase().includes(q) ||
        item.conditionDescription.toLowerCase().includes(q);

      const matchesCategory =
        selectedCategory === "All" ||
        item.categoryName.toLowerCase() === selectedCategory.toLowerCase();

      const matchesGrade =
        selectedGrade === "All Grades" || item.conditionGrade === selectedGrade;

      return matchesSearch && matchesCategory && matchesGrade;
    });
  }, [listings, search, selectedCategory, selectedGrade]);

  // Sort
  const sorted = useMemo(() => {
    return [...filtered].sort((a, b) => {
      if (sortBy === "PRICE_ASC") return a.price - b.price;
      if (sortBy === "PRICE_DESC") return b.price - a.price;
      return 0; // FEATURED
    });
  }, [filtered, sortBy]);

  const handleAddToCart = (item: CertifiedUsedItem, e?: React.MouseEvent) => {
    if (e) {
      e.preventDefault();
      e.stopPropagation();
    }
    addToCart({
      productId: item.id,
      productType: "USED",
      name: item.name,
      image: item.images?.[0] || "/images/products/canon_eos.jpg",
      unitPrice: item.price,
      quantity: 1,
      totalPrice: item.price,
      warrantySummary: item.warrantyDetails,
    });
    setAddedId(item.id);
    setTimeout(() => setAddedId(null), 1800);
  };

  const getGradeBadge = (grade: string) => {
    switch (grade) {
      case "LIKE_NEW":
        return { label: "Grade A+ (Like New)", bg: "#ECFDF5", text: "#065F46", border: "#A7F3D0" };
      case "EXCELLENT":
        return { label: "Grade A (Excellent)", bg: "#EFF6FF", text: "#1E40AF", border: "#BFDBFE" };
      case "GOOD":
        return { label: "Grade B (Good)", bg: "#FFFBEB", text: "#92400E", border: "#FDE68A" };
      default:
        return { label: `Grade ${grade}`, bg: "#F1F5F9", text: "#334155", border: "#CBD5E1" };
    }
  };

  return (
    <div style={{ background: "#F8FAFC", minHeight: "100vh" }}>
      {/* Clean Compact Header */}
      <section
        style={{
          background: "#FFFFFF",
          borderBottom: "1px solid #E2E8F0",
          padding: "1.5rem 1.25rem",
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
                marginBottom: "2px",
              }}
            >
              <Link href="/" style={{ color: "#64748B", textDecoration: "none" }}>
                Home
              </Link>{" "}
              / <span style={{ color: "#0F172A", fontWeight: 600 }}>Certified Pre-Owned</span>
            </div>
            <h1
              style={{
                fontSize: "1.65rem",
                fontWeight: 800,
                color: "#0F172A",
                margin: 0,
                letterSpacing: "-0.02em",
              }}
            >
              Certified Pre-Owned Equipment
            </h1>
            <p style={{ fontSize: "13px", color: "#64748B", margin: "2px 0 0 0" }}>
              100% in-house owned, bench-tested, and warranted by Sharma Video Care technicians.
            </p>
          </div>

          <div style={{ display: "flex", gap: "8px" }}>
            <Link
              href="/trade-in"
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
                background: "#0F172A",
                color: "#FFFFFF",
                padding: "8px 14px",
                borderRadius: "6px",
                fontSize: "12.5px",
                fontWeight: 600,
                textDecoration: "none",
              }}
            >
              <span>Instant Trade-In Valuation</span>
              <ArrowRight size={13} />
            </Link>
          </div>
        </div>
      </section>

      {/* Main Content Area */}
      <div style={{ maxWidth: "1280px", margin: "0 auto", padding: "1.5rem 1.25rem 4rem 1.25rem" }}>
        {/* Trade-In Upgrade Callout Banner */}
        <div
          style={{
            background: "linear-gradient(135deg, #0F172A 0%, #1E293B 100%)",
            borderRadius: "12px",
            padding: "16px 20px",
            marginBottom: "1.25rem",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            flexWrap: "wrap",
            gap: "14px",
            border: "1px solid #334155",
            color: "#FFFFFF",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "14px" }}>
            <div
              style={{
                width: "40px",
                height: "40px",
                borderRadius: "10px",
                background: "rgba(232, 111, 28, 0.15)",
                border: "1px solid rgba(232, 111, 28, 0.3)",
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
              <div style={{ display: "flex", alignItems: "center", gap: "8px", flexWrap: "wrap" }}>
                <span style={{ fontWeight: 700, fontSize: "0.95rem", color: "#FFFFFF" }}>
                  Selling or Upgrading your Camera Gear?
                </span>
                <span
                  style={{
                    background: "#059669",
                    color: "#FFFFFF",
                    fontSize: "10.5px",
                    fontWeight: 750,
                    padding: "2px 8px",
                    borderRadius: "999px",
                  }}
                >
                  +10% Extra Store Credit
                </span>
              </div>
              <p style={{ margin: "3px 0 0 0", fontSize: "0.82rem", color: "#94A3B8" }}>
                Calculate instant buyout values for cameras, lenses, laptops &amp; drones. Janakpur counter drop-off or insured courier pickup across Nepal.
              </p>
            </div>
          </div>

          <Link
            href="/trade-in"
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "8px",
              background: "#E86F1C",
              color: "#FFFFFF",
              padding: "9px 18px",
              borderRadius: "8px",
              fontSize: "0.85rem",
              fontWeight: 700,
              textDecoration: "none",
              whiteSpace: "nowrap",
            }}
          >
            <span>Trade-In Calculator</span>
            <ArrowRight size={14} />
          </Link>
        </div>
        {/* Compact Filters Toolbar */}
        <div
          style={{
            background: "#FFFFFF",
            border: "1px solid #E2E8F0",
            borderRadius: "8px",
            padding: "10px 14px",
            marginBottom: "1.5rem",
            display: "flex",
            alignItems: "center",
            gap: "10px",
            flexWrap: "wrap",
          }}
        >
          {/* Search Box */}
          <div
            style={{
              position: "relative",
              flex: "1 1 220px",
              display: "flex",
              alignItems: "center",
            }}
          >
            <Search
              size={15}
              style={{
                position: "absolute",
                left: "10px",
                color: "#94A3B8",
                pointerEvents: "none",
              }}
            />
            <input
              type="text"
              placeholder="Search model, brand, shutter count..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              style={{
                width: "100%",
                height: "34px",
                padding: "0 30px 0 32px",
                borderRadius: "5px",
                border: "1px solid #CBD5E1",
                fontSize: "12.5px",
                color: "#0F172A",
                outline: "none",
                background: "#FFFFFF",
              }}
            />
            {search && (
              <button
                type="button"
                onClick={() => setSearch("")}
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
                <X size={13} />
              </button>
            )}
          </div>

          {/* Category Filter */}
          <div style={{ flex: "0 1 150px" }}>
            <select
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
              style={{
                width: "100%",
                height: "34px",
                padding: "0 8px",
                borderRadius: "5px",
                border: "1px solid #CBD5E1",
                fontSize: "12.5px",
                color: "#0F172A",
                background: "#FFFFFF",
                fontWeight: 550,
                cursor: "pointer",
                outline: "none",
              }}
            >
              {USED_CATEGORIES.map((cat) => (
                <option key={cat} value={cat}>
                  {cat === "All" ? "All Categories" : cat}
                </option>
              ))}
            </select>
          </div>

          {/* Condition Grade Filter */}
          <div style={{ flex: "0 1 160px" }}>
            <select
              value={selectedGrade}
              onChange={(e) => setSelectedGrade(e.target.value)}
              style={{
                width: "100%",
                height: "34px",
                padding: "0 8px",
                borderRadius: "5px",
                border: "1px solid #CBD5E1",
                fontSize: "12.5px",
                color: "#0F172A",
                background: "#FFFFFF",
                fontWeight: 550,
                cursor: "pointer",
                outline: "none",
              }}
            >
              <option value="All Grades">All Grades</option>
              <option value="LIKE_NEW">Grade A+ (Like New)</option>
              <option value="EXCELLENT">Grade A (Excellent)</option>
              <option value="GOOD">Grade B (Good)</option>
            </select>
          </div>

          {/* Sort Dropdown */}
          <div style={{ flex: "0 1 150px" }}>
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value as any)}
              style={{
                width: "100%",
                height: "34px",
                padding: "0 8px",
                borderRadius: "5px",
                border: "1px solid #CBD5E1",
                fontSize: "12.5px",
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
            </select>
          </div>

          {/* Clear Filters (if active) */}
          <div style={{ display: "flex", alignItems: "center", gap: "8px", marginLeft: "auto" }}>
            {(search || selectedCategory !== "All" || selectedGrade !== "All Grades") && (
              <button
                type="button"
                onClick={() => {
                  setSearch("");
                  setSelectedCategory("All");
                  setSelectedGrade("All Grades");
                }}
                style={{
                  background: "none",
                  border: "none",
                  color: "#E86F1C",
                  fontSize: "12px",
                  fontWeight: 650,
                  cursor: "pointer",
                  padding: "2px 6px",
                }}
              >
                Clear
              </button>
            )}
          </div>
        </div>

        {/* Clean, Visual-First Grid (No Text Walls!) */}
        {loading ? (
          <div
            style={{
              textAlign: "center",
              padding: "4rem 0",
              background: "#FFFFFF",
              borderRadius: "8px",
              border: "1px solid #E2E8F0",
              color: "#64748B",
              fontSize: "13px",
            }}
          >
            Loading certified inventory...
          </div>
        ) : sorted.length === 0 ? (
          <div
            style={{
              textAlign: "center",
              padding: "3.5rem 2rem",
              background: "#FFFFFF",
              borderRadius: "8px",
              border: "1px solid #E2E8F0",
            }}
          >
            <h3 style={{ fontSize: "1.15rem", fontWeight: 700, color: "#0F172A", margin: "0 0 0.5rem 0" }}>
              No matching certified equipment
            </h3>
            <p style={{ color: "#64748B", fontSize: "13px", margin: "0 0 1.25rem 0" }}>
              Try resetting your filters to explore available units.
            </p>
            <button
              type="button"
              onClick={() => {
                setSearch("");
                setSelectedCategory("All");
                setSelectedGrade("All Grades");
              }}
              style={{
                background: "#E86F1C",
                color: "#FFFFFF",
                border: "none",
                padding: "8px 16px",
                borderRadius: "5px",
                fontSize: "12.5px",
                fontWeight: 650,
                cursor: "pointer",
              }}
            >
              Reset Filters
            </button>
          </div>
        ) : (
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
              gap: "18px",
            }}
          >
            {sorted.map((item) => {
              const gradeInfo = getGradeBadge(item.conditionGrade);
              const isAdded = addedId === item.id;
              const imageSrc = item.images?.[0] || "/images/products/canon_eos.jpg";
              const savings =
                item.originalNewPrice && item.originalNewPrice > item.price
                  ? item.originalNewPrice - item.price
                  : 0;

              return (
                <div
                  key={item.id}
                  style={{
                    background: "#FFFFFF",
                    borderRadius: "10px",
                    border: "1px solid #E2E8F0",
                    overflow: "hidden",
                    display: "flex",
                    flexDirection: "column",
                    justifyContent: "space-between",
                    boxShadow: "0 1px 2px rgba(0, 0, 0, 0.02)",
                    transition: "border-color 0.15s ease",
                  }}
                >
                  <div>
                    {/* Image Canvas with Grade Tag & Bench Tested Badge */}
                    <Link
                      href={`/used/${item.id}`}
                      style={{
                        display: "block",
                        position: "relative",
                        height: "190px",
                        background: "#F8F6F0",
                        padding: "16px",
                        borderBottom: "1px solid #F1F5F9",
                        textDecoration: "none",
                      }}
                    >
                      {/* Condition Grade Badge */}
                      <span
                        style={{
                          position: "absolute",
                          top: "10px",
                          left: "10px",
                          zIndex: 2,
                          background: gradeInfo.bg,
                          color: gradeInfo.text,
                          border: `1px solid ${gradeInfo.border}`,
                          padding: "2px 7px",
                          borderRadius: "4px",
                          fontSize: "10.5px",
                          fontWeight: 750,
                        }}
                      >
                        {gradeInfo.label}
                      </span>

                      {/* Bench Tested Badge */}
                      <span
                        style={{
                          position: "absolute",
                          top: "10px",
                          right: "10px",
                          zIndex: 2,
                          background: "#0F172A",
                          color: "#FFFFFF",
                          padding: "2px 7px",
                          borderRadius: "4px",
                          fontSize: "10px",
                          fontWeight: 650,
                          display: "inline-flex",
                          alignItems: "center",
                          gap: "3px",
                        }}
                      >
                        <CheckCircle2 size={11} color="#10B981" />
                        <span>Tested</span>
                      </span>

                      {/* Image */}
                      <div style={{ position: "relative", width: "100%", height: "100%" }}>
                        {imageSrc.startsWith("http") ? (
                          <img
                            src={imageSrc}
                            alt={item.name}
                            style={{ width: "100%", height: "100%", objectFit: "contain", objectPosition: "center" }}
                            loading="lazy"
                          />
                        ) : (
                          <Image
                            src={imageSrc}
                            alt={item.name}
                            fill
                            sizes="(max-width: 768px) 100vw, 320px"
                            style={{ objectFit: "contain", objectPosition: "center" }}
                          />
                        )}
                      </div>
                    </Link>

                    {/* Clean Card Body (Minimal Text!) */}
                    <div style={{ padding: "14px 14px 10px 14px" }}>
                      {/* Metric Tag (Shutter or Optical) */}
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "4px" }}>
                        <span style={{ fontSize: "11px", fontWeight: 700, color: "#E86F1C", textTransform: "uppercase" }}>
                          {item.brand}
                        </span>

                        <span
                          style={{
                            display: "inline-flex",
                            alignItems: "center",
                            gap: "3px",
                            background: "#F1F5F9",
                            color: "#334155",
                            padding: "2px 6px",
                            borderRadius: "4px",
                            fontSize: "10.5px",
                            fontWeight: 650,
                          }}
                        >
                          {item.metricType === "SHUTTER" ? (
                            <Camera size={11} color="#64748B" />
                          ) : (
                            <Compass size={11} color="#64748B" />
                          )}
                          <span>{item.usageMetric}</span>
                        </span>
                      </div>

                      {/* Product Title (2-line clamp) */}
                      <h3
                        style={{
                          margin: 0,
                          fontSize: "14px",
                          fontWeight: 700,
                          lineHeight: "19px",
                          height: "38px",
                          overflow: "hidden",
                          display: "-webkit-box",
                          WebkitLineClamp: 2,
                          WebkitBoxOrient: "vertical",
                        }}
                      >
                        <Link
                          href={`/used/${item.id}`}
                          style={{ color: "#0F172A", textDecoration: "none" }}
                        >
                          {item.name}
                        </Link>
                      </h3>
                    </div>
                  </div>

                  {/* Clean Footer: Price, Savings & Direct Actions */}
                  <div
                    style={{
                      padding: "10px 14px",
                      background: "#FFFFFF",
                      borderTop: "1px solid #F1F5F9",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "space-between",
                      gap: "8px",
                    }}
                  >
                    <div>
                      <div
                        style={{
                          fontSize: "15.5px",
                          fontWeight: 800,
                          color: "#0F172A",
                          lineHeight: 1.1,
                        }}
                      >
                        Rs. {item.price.toLocaleString("en-IN")}
                      </div>

                      {savings > 0 && (
                        <div
                          style={{
                            fontSize: "10px",
                            fontWeight: 700,
                            color: "#15803D",
                            marginTop: "2px",
                          }}
                        >
                          Save Rs. {savings.toLocaleString("en-IN")}
                        </div>
                      )}
                    </div>

                    <div style={{ display: "flex", gap: "6px" }}>
                      <Link
                        href={`/used/${item.id}`}
                        style={{
                          padding: "6px 10px",
                          borderRadius: "5px",
                          border: "1px solid #CBD5E1",
                          color: "#334155",
                          fontSize: "11.5px",
                          fontWeight: 650,
                          textDecoration: "none",
                          display: "inline-flex",
                          alignItems: "center",
                        }}
                      >
                        Inspect
                      </Link>

                      <button
                        type="button"
                        onClick={(e) => handleAddToCart(item, e)}
                        style={{
                          padding: "6px 11px",
                          borderRadius: "5px",
                          background: isAdded ? "#16A34A" : "#E86F1C",
                          color: "#FFFFFF",
                          border: "none",
                          fontSize: "11.5px",
                          fontWeight: 700,
                          cursor: "pointer",
                          display: "inline-flex",
                          alignItems: "center",
                          gap: "4px",
                          transition: "background 0.15s ease",
                        }}
                      >
                        {isAdded ? (
                          <>
                            <Check size={13} /> Added
                          </>
                        ) : (
                          <>
                            <ShoppingCart size={13} /> Buy
                          </>
                        )}
                      </button>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}

        {/* Clean, Minimalist Trust Strip */}
        <div
          style={{
            marginTop: "3rem",
            background: "#FFFFFF",
            border: "1px solid #E2E8F0",
            borderRadius: "8px",
            padding: "1rem 1.25rem",
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
            gap: "14px",
          }}
        >
          <div style={{ display: "flex", gap: "8px", alignItems: "center" }}>
            <ClipboardCheck size={18} color="#E86F1C" style={{ flexShrink: 0 }} />
            <div style={{ fontSize: "12px", color: "#334155", fontWeight: 600 }}>
              45-Point Bench Test
            </div>
          </div>

          <div style={{ display: "flex", gap: "8px", alignItems: "center" }}>
            <ShieldCheck size={18} color="#E86F1C" style={{ flexShrink: 0 }} />
            <div style={{ fontSize: "12px", color: "#334155", fontWeight: 600 }}>
              90–180 Days Lab Warranty
            </div>
          </div>

          <div style={{ display: "flex", gap: "8px", alignItems: "center" }}>
            <RotateCcw size={18} color="#E86F1C" style={{ flexShrink: 0 }} />
            <div style={{ fontSize: "12px", color: "#334155", fontWeight: 600 }}>
              7-Day Inspection Return
            </div>
          </div>

          <div style={{ display: "flex", gap: "8px", alignItems: "center" }}>
            <PhoneCall size={18} color="#E86F1C" style={{ flexShrink: 0 }} />
            <div style={{ fontSize: "12px", color: "#334155", fontWeight: 600 }}>
              Janakpur Workshop Support
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
