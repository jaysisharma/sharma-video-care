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
  AlertTriangle,
  RotateCcw,
  Camera,
  Compass,
  Sparkles,
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
        item.conditionDescription.toLowerCase().includes(q) ||
        (item.knownDefects && item.knownDefects.some((d) => d.toLowerCase().includes(q)));

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
      {/* Streamlined Header */}
      <section
        style={{
          background: "#FFFFFF",
          borderBottom: "1px solid #E2E8F0",
          padding: "2rem 1.25rem 1.75rem 1.25rem",
        }}
      >
        <div style={{ maxWidth: "1280px", margin: "0 auto" }}>
          {/* Breadcrumb */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "8px",
              fontSize: "12.5px",
              color: "#64748B",
              marginBottom: "8px",
            }}
          >
            <Link href="/" style={{ color: "#64748B", textDecoration: "none" }}>
              Home
            </Link>
            <span>/</span>
            <span style={{ color: "#0F172A", fontWeight: 600 }}>Certified Pre-Owned</span>
          </div>

          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "flex-end",
              flexWrap: "wrap",
              gap: "1.25rem",
            }}
          >
            <div>
              <div
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "6px",
                  background: "#ECFDF5",
                  color: "#059669",
                  border: "1px solid #D1FAE5",
                  padding: "3px 8px",
                  borderRadius: "6px",
                  fontSize: "11.5px",
                  fontWeight: 700,
                  textTransform: "uppercase",
                  letterSpacing: "0.04em",
                  marginBottom: "0.5rem",
                }}
              >
                <ShieldCheck size={14} /> 100% In-House Tested & Owned
              </div>

              <h1
                style={{
                  fontSize: "1.85rem",
                  fontWeight: 800,
                  color: "#0F172A",
                  letterSpacing: "-0.02em",
                  margin: "0 0 0.35rem 0",
                  lineHeight: 1.2,
                }}
              >
                Certified Pre-Owned Inventory
              </h1>
              <p
                style={{
                  fontSize: "14px",
                  color: "#475569",
                  margin: 0,
                  maxWidth: "760px",
                  lineHeight: 1.5,
                }}
              >
                Zero third-party sellers. Every camera, lens, and drone is owned, bench-tested, and
                warranted by Sharma Video Care technicians with disclosed shutter counts and defect records.
              </p>
            </div>

            <div style={{ display: "flex", gap: "10px", flexWrap: "wrap" }}>
              <Link
                href="/shop"
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "6px",
                  background: "#FFFFFF",
                  color: "#0F172A",
                  padding: "8px 14px",
                  borderRadius: "6px",
                  fontSize: "13px",
                  fontWeight: 650,
                  textDecoration: "none",
                  border: "1px solid #CBD5E1",
                }}
              >
                <span>New Products Store</span>
                <ArrowRight size={14} />
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Main Content */}
      <div style={{ maxWidth: "1280px", margin: "0 auto", padding: "1.75rem 1.25rem 4rem 1.25rem" }}>
        {/* Filter Controls Row */}
        <div
          style={{
            background: "#FFFFFF",
            border: "1px solid #E2E8F0",
            borderRadius: "10px",
            padding: "12px 16px",
            marginBottom: "1.75rem",
            display: "flex",
            alignItems: "center",
            gap: "12px",
            flexWrap: "wrap",
            boxShadow: "0 1px 3px rgba(0, 0, 0, 0.02)",
          }}
        >
          {/* Search Box */}
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
                left: "12px",
                color: "#94A3B8",
                pointerEvents: "none",
              }}
            />
            <input
              type="text"
              placeholder="Search cameras, lenses, drones, shutter counts..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              style={{
                width: "100%",
                height: "36px",
                padding: "0 34px 0 36px",
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
                style={{
                  position: "absolute",
                  right: "10px",
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

          {/* Category Filter */}
          <div style={{ flex: "0 1 160px", minWidth: "140px" }}>
            <select
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
              style={{
                width: "100%",
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
              {USED_CATEGORIES.map((cat) => (
                <option key={cat} value={cat}>
                  {cat === "All" ? "All Categories" : cat}
                </option>
              ))}
            </select>
          </div>

          {/* Condition Grade Filter */}
          <div style={{ flex: "0 1 180px", minWidth: "150px" }}>
            <select
              value={selectedGrade}
              onChange={(e) => setSelectedGrade(e.target.value)}
              style={{
                width: "100%",
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
              <option value="All Grades">All Condition Grades</option>
              <option value="LIKE_NEW">Grade A+ (Like New)</option>
              <option value="EXCELLENT">Grade A (Excellent)</option>
              <option value="GOOD">Grade B (Good)</option>
            </select>
          </div>

          {/* Sort Dropdown */}
          <div style={{ flex: "0 1 170px", minWidth: "140px" }}>
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value as any)}
              style={{
                width: "100%",
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
              <option value="FEATURED">Sort: Featured</option>
              <option value="PRICE_ASC">Price: Low to High</option>
              <option value="PRICE_DESC">Price: High to Low</option>
            </select>
          </div>

          {/* Results Count & Clear */}
          <div style={{ display: "flex", alignItems: "center", gap: "10px", marginLeft: "auto" }}>
            <span style={{ fontSize: "13px", color: "#64748B" }}>
              Showing <strong style={{ color: "#0F172A" }}>{sorted.length}</strong> verified units
            </span>

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
                  fontSize: "12.5px",
                  fontWeight: 650,
                  cursor: "pointer",
                  padding: "4px 8px",
                }}
              >
                Reset
              </button>
            )}
          </div>
        </div>

        {/* Listings Grid */}
        {loading ? (
          <div
            style={{
              textAlign: "center",
              padding: "5rem 0",
              background: "#FFFFFF",
              borderRadius: "12px",
              border: "1px solid #E2E8F0",
              color: "#64748B",
            }}
          >
            Loading certified pre-owned equipment...
          </div>
        ) : sorted.length === 0 ? (
          <div
            style={{
              textAlign: "center",
              padding: "4.5rem 2rem",
              background: "#FFFFFF",
              borderRadius: "12px",
              border: "1px solid #E2E8F0",
            }}
          >
            <h3 style={{ fontSize: "1.25rem", fontWeight: 700, color: "#0F172A", margin: "0 0 0.5rem 0" }}>
              No certified equipment matching your filters
            </h3>
            <p style={{ color: "#64748B", fontSize: "14px", margin: "0 0 1.5rem 0" }}>
              Try clearing your search query or grade filters to see all available units.
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
                padding: "10px 20px",
                borderRadius: "6px",
                fontSize: "13px",
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
              gridTemplateColumns: "repeat(auto-fill, minmax(350px, 1fr))",
              gap: "22px",
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
              const savingsPercent =
                item.originalNewPrice && savings > 0
                  ? Math.round((savings / item.originalNewPrice) * 100)
                  : 0;

              return (
                <div
                  key={item.id}
                  style={{
                    background: "#FFFFFF",
                    borderRadius: "12px",
                    border: "1px solid #E2E8F0",
                    overflow: "hidden",
                    display: "flex",
                    flexDirection: "column",
                    justifyContent: "space-between",
                    boxShadow: "0 1px 3px rgba(0, 0, 0, 0.02)",
                  }}
                >
                  <div>
                    {/* Image Canvas with Grade Tag & Bench Tested Badge */}
                    <Link
                      href={`/used/${item.id}`}
                      style={{
                        display: "block",
                        position: "relative",
                        height: "215px",
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
                          top: "12px",
                          left: "12px",
                          zIndex: 2,
                          background: gradeInfo.bg,
                          color: gradeInfo.text,
                          border: `1px solid ${gradeInfo.border}`,
                          padding: "3px 8px",
                          borderRadius: "4px",
                          fontSize: "11px",
                          fontWeight: 700,
                          letterSpacing: "0.02em",
                        }}
                      >
                        {gradeInfo.label}
                      </span>

                      {/* Bench Tested Badge */}
                      <span
                        style={{
                          position: "absolute",
                          top: "12px",
                          right: "12px",
                          zIndex: 2,
                          background: "#0F172A",
                          color: "#FFFFFF",
                          padding: "3px 8px",
                          borderRadius: "4px",
                          fontSize: "10.5px",
                          fontWeight: 650,
                          display: "inline-flex",
                          alignItems: "center",
                          gap: "4px",
                        }}
                      >
                        <CheckCircle2 size={12} color="#10B981" />
                        <span>Bench Tested</span>
                      </span>

                      {/* Image */}
                      <div style={{ position: "relative", width: "100%", height: "100%" }}>
                        <Image
                          src={imageSrc}
                          alt={item.name}
                          fill
                          sizes="(max-width: 768px) 100vw, 400px"
                          style={{ objectFit: "contain", objectPosition: "center" }}
                        />
                      </div>
                    </Link>

                    {/* Card Body */}
                    <div style={{ padding: "16px" }}>
                      <div
                        style={{
                          display: "flex",
                          justifyContent: "space-between",
                          alignItems: "center",
                          marginBottom: "6px",
                        }}
                      >
                        <span
                          style={{
                            fontSize: "11.5px",
                            fontWeight: 700,
                            color: "#E86F1C",
                            textTransform: "uppercase",
                            letterSpacing: "0.05em",
                          }}
                        >
                          {item.brand} • {item.categoryName}
                        </span>

                        {/* Dedicated Shutter Count / Flight Time / Optical Metric Badge */}
                        <span
                          style={{
                            display: "inline-flex",
                            alignItems: "center",
                            gap: "4px",
                            background: "#F1F5F9",
                            color: "#0F172A",
                            padding: "2px 8px",
                            borderRadius: "4px",
                            fontSize: "11px",
                            fontWeight: 700,
                          }}
                        >
                          {item.metricType === "SHUTTER" ? (
                            <Camera size={12} color="#0F172A" />
                          ) : (
                            <Compass size={12} color="#0F172A" />
                          )}
                          <span>{item.usageMetric}</span>
                        </span>
                      </div>

                      <h3 style={{ margin: "0 0 6px 0", fontSize: "15.5px", fontWeight: 750, lineHeight: 1.35 }}>
                        <Link
                          href={`/used/${item.id}`}
                          style={{ color: "#0F172A", textDecoration: "none" }}
                        >
                          {item.name}
                        </Link>
                      </h3>

                      <p
                        style={{
                          fontSize: "13px",
                          color: "#64748B",
                          lineHeight: 1.45,
                          margin: "0 0 10px 0",
                          display: "-webkit-box",
                          WebkitLineClamp: 2,
                          WebkitBoxOrient: "vertical",
                          overflow: "hidden",
                        }}
                      >
                        {item.conditionDescription}
                      </p>

                      {/* Disclosed Marks / Highlights */}
                      {item.knownDefects && item.knownDefects.length > 0 && (
                        <div
                          style={{
                            background: "#FFFBEB",
                            border: "1px solid #FEF3C7",
                            borderRadius: "6px",
                            padding: "6px 9px",
                            fontSize: "11.5px",
                            color: "#92400E",
                            display: "flex",
                            alignItems: "flex-start",
                            gap: "5px",
                            marginBottom: "10px",
                          }}
                        >
                          <AlertTriangle size={13} style={{ flexShrink: 0, marginTop: "2px" }} />
                          <div>
                            <strong>Disclosed:</strong> {item.knownDefects[0]}
                          </div>
                        </div>
                      )}

                      {/* Test Notes Snippet */}
                      <div
                        style={{
                          fontSize: "11.5px",
                          color: "#475569",
                          background: "#F8FAFC",
                          border: "1px solid #E2E8F0",
                          borderRadius: "6px",
                          padding: "6px 9px",
                        }}
                      >
                        <span style={{ fontWeight: 650, color: "#0F172A" }}>Lab Report:</span>{" "}
                        {item.testNotes}
                      </div>
                    </div>
                  </div>

                  {/* Card Footer: Price, Savings & Actions */}
                  <div
                    style={{
                      padding: "12px 16px",
                      background: "#FFFFFF",
                      borderTop: "1px solid #F1F5F9",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "space-between",
                      gap: "10px",
                    }}
                  >
                    <div>
                      {/* Price with Struck-Through Original New Price & Savings */}
                      <div style={{ display: "flex", alignItems: "baseline", gap: "6px" }}>
                        <span
                          style={{
                            fontSize: "18px",
                            fontWeight: 800,
                            color: "#0F172A",
                            letterSpacing: "-0.015em",
                          }}
                        >
                          Rs. {item.price.toLocaleString("en-IN")}
                        </span>

                        {item.originalNewPrice && (
                          <span
                            style={{
                              fontSize: "11.5px",
                              color: "#94A3B8",
                              textDecoration: "line-through",
                            }}
                          >
                            Rs. {item.originalNewPrice.toLocaleString("en-IN")}
                          </span>
                        )}
                      </div>

                      {savings > 0 && (
                        <div
                          style={{
                            fontSize: "10.5px",
                            fontWeight: 700,
                            color: "#15803D",
                            marginTop: "2px",
                          }}
                        >
                          Save Rs. {savings.toLocaleString("en-IN")} ({savingsPercent}% Off New)
                        </div>
                      )}
                    </div>

                    <div style={{ display: "flex", gap: "8px" }}>
                      <Link
                        href={`/used/${item.id}`}
                        style={{
                          padding: "8px 11px",
                          borderRadius: "6px",
                          border: "1px solid #CBD5E1",
                          color: "#334155",
                          fontSize: "12px",
                          fontWeight: 650,
                          textDecoration: "none",
                          display: "inline-flex",
                          alignItems: "center",
                          gap: "4px",
                        }}
                      >
                        <span>Inspection</span>
                        <ArrowRight size={13} />
                      </Link>

                      <button
                        type="button"
                        onClick={(e) => handleAddToCart(item, e)}
                        style={{
                          padding: "8px 13px",
                          borderRadius: "6px",
                          background: isAdded ? "#16A34A" : "#E86F1C",
                          color: "#FFFFFF",
                          border: "none",
                          fontSize: "12px",
                          fontWeight: 700,
                          cursor: "pointer",
                          display: "inline-flex",
                          alignItems: "center",
                          gap: "5px",
                          transition: "background 0.15s ease",
                        }}
                      >
                        {isAdded ? (
                          <>
                            <Check size={14} /> Added
                          </>
                        ) : (
                          <>
                            <ShoppingCart size={14} /> Buy Unit
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

        {/* 4-Pillar Certification Guarantee Strip */}
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
          <div style={{ display: "flex", gap: "10px", alignItems: "flex-start" }}>
            <ClipboardCheck size={22} color="#E86F1C" style={{ flexShrink: 0, marginTop: "2px" }} />
            <div>
              <div style={{ fontSize: "13.5px", fontWeight: 700, color: "#0F172A" }}>
                45-Point Bench Inspection
              </div>
              <div style={{ fontSize: "12px", color: "#64748B", marginTop: "2px" }}>
                Sensors, shutter curtains, AF accuracy, and optical elements tested under microscope.
              </div>
            </div>
          </div>

          <div style={{ display: "flex", gap: "10px", alignItems: "flex-start" }}>
            <AlertTriangle size={22} color="#E86F1C" style={{ flexShrink: 0, marginTop: "2px" }} />
            <div>
              <div style={{ fontSize: "13.5px", fontWeight: 700, color: "#0F172A" }}>
                100% Defect Transparency
              </div>
              <div style={{ fontSize: "12px", color: "#64748B", marginTop: "2px" }}>
                Every cosmetic flaw, paint wear, and exact shutter actuation is fully disclosed.
              </div>
            </div>
          </div>

          <div style={{ display: "flex", gap: "10px", alignItems: "flex-start" }}>
            <ShieldCheck size={22} color="#E86F1C" style={{ flexShrink: 0, marginTop: "2px" }} />
            <div>
              <div style={{ fontSize: "13.5px", fontWeight: 700, color: "#0F172A" }}>
                90 to 180 Days Lab Warranty
              </div>
              <div style={{ fontSize: "12px", color: "#64748B", marginTop: "2px" }}>
                Comprehensive workshop warranty covering parts and labor backed by Sharma Video Care.
              </div>
            </div>
          </div>

          <div style={{ display: "flex", gap: "10px", alignItems: "flex-start" }}>
            <RotateCcw size={22} color="#E86F1C" style={{ flexShrink: 0, marginTop: "2px" }} />
            <div>
              <div style={{ fontSize: "13.5px", fontWeight: 700, color: "#0F172A" }}>
                7-Day Inspection Return
              </div>
              <div style={{ fontSize: "12px", color: "#64748B", marginTop: "2px" }}>
                Full refund or replacement if item differs from our written lab inspection report.
              </div>
            </div>
          </div>
        </div>

        {/* Sell / Trade-In Callout Card */}
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
            <span
              style={{
                fontSize: "11.5px",
                fontWeight: 750,
                color: "#E86F1C",
                textTransform: "uppercase",
                letterSpacing: "0.08em",
                display: "block",
                marginBottom: "4px",
              }}
            >
              Sell or Trade-In Your Equipment
            </span>
            <h3 style={{ fontSize: "1.35rem", fontWeight: 800, color: "#FFFFFF", margin: "0 0 0.35rem 0" }}>
              Upgrading your camera setup? Trade in with Sharma Video Care
            </h3>
            <p style={{ fontSize: "13.5px", color: "#94A3B8", margin: 0, maxWidth: "660px" }}>
              Bring or courier your camera, lens, or drone to our Janakpur workshop for an immediate bench
              evaluation. Receive instant cash payout or store credit toward any new or certified pre-owned equipment.
            </p>
          </div>

          <div style={{ display: "flex", gap: "10px", flexWrap: "wrap" }}>
            <Link
              href="/contact"
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
              <span>Request Trade-In Evaluation</span>
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
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
              }}
            >
              <PhoneCall size={14} color="#E86F1C" />
              <span>+977-9854025000</span>
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
