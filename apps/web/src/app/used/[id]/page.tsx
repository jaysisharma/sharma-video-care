"use client";

import React, { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { doc, getDoc } from "firebase/firestore";
import { db } from "../../../lib/firebase";
import { useCart } from "../../../context/CartContext";
import { CERTIFIED_USED_PRODUCTS, CertifiedUsedItem } from "@/data/usedProducts";
import {
  ShieldCheck,
  CheckCircle2,
  ArrowLeft,
  ShoppingCart,
  Check,
  AlertTriangle,
  Package,
  RotateCcw,
  PhoneCall,
  FileCheck,
  Camera,
  Compass,
} from "lucide-react";

export default function UsedProductDetailPage() {
  const params = useParams();
  const id = params?.id as string;
  const router = useRouter();

  const [item, setItem] = useState<CertifiedUsedItem | null>(null);
  const [loading, setLoading] = useState(true);
  const [added, setAdded] = useState(false);

  const { addToCart } = useCart();

  useEffect(() => {
    async function loadItem() {
      try {
        const snap = await getDoc(doc(db, "usedProducts", id));
        if (snap.exists()) {
          const data = snap.data();
          setItem({
            id: snap.id,
            ...data,
            usageMetric: data.usageMetric || "Tested & Certified",
            metricType: data.metricType || "SHUTTER",
          } as CertifiedUsedItem);
        } else {
          const fallback = CERTIFIED_USED_PRODUCTS.find((p) => p.id === id);
          if (fallback) setItem(fallback);
        }
      } catch (err) {
        console.warn("Using offline item fallback:", err);
        const fallback = CERTIFIED_USED_PRODUCTS.find((p) => p.id === id);
        if (fallback) setItem(fallback);
      } finally {
        setLoading(false);
      }
    }
    if (id) loadItem();
  }, [id]);

  if (loading) {
    return (
      <div style={{ background: "#F8FAFC", minHeight: "80vh", padding: "4rem 1.25rem" }}>
        <div style={{ maxWidth: "1200px", margin: "0 auto", textAlign: "center", color: "#64748B" }}>
          Loading certified inspection report...
        </div>
      </div>
    );
  }

  if (!item) {
    return (
      <div style={{ background: "#F8FAFC", minHeight: "80vh", padding: "4rem 1.25rem" }}>
        <div
          style={{
            maxWidth: "600px",
            margin: "0 auto",
            textAlign: "center",
            background: "#FFFFFF",
            padding: "3rem 2rem",
            borderRadius: "14px",
            border: "1px solid #E2E8F0",
          }}
        >
          <h2 style={{ fontSize: "1.5rem", fontWeight: 800, color: "#0F172A", margin: "0 0 0.75rem 0" }}>
            Certified Unit Not Found
          </h2>
          <p style={{ color: "#64748B", fontSize: "14px", margin: "0 0 1.5rem 0" }}>
            This pre-owned item may have been sold or archived. Explore our current certified inventory.
          </p>
          <Link
            href="/used"
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "8px",
              background: "#E86F1C",
              color: "#FFFFFF",
              textDecoration: "none",
              padding: "10px 20px",
              borderRadius: "8px",
              fontSize: "14px",
              fontWeight: 650,
            }}
          >
            <ArrowLeft size={16} /> Back to Certified Inventory
          </Link>
        </div>
      </div>
    );
  }

  const handleAddToCart = () => {
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
    setAdded(true);
    setTimeout(() => setAdded(false), 2000);
  };

  const handleBuyNow = () => {
    handleAddToCart();
    router.push("/cart");
  };

  const getGradeInfo = (grade: string) => {
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

  const gradeInfo = getGradeInfo(item.conditionGrade);
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
    <div style={{ background: "#F8FAFC", minHeight: "100vh", padding: "2rem 1.25rem 4rem 1.25rem" }}>
      <div style={{ maxWidth: "1280px", margin: "0 auto" }}>
        {/* Navigation Breadcrumb */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: "8px",
            fontSize: "13px",
            color: "#64748B",
            marginBottom: "1.5rem",
          }}
        >
          <Link href="/used" style={{ display: "inline-flex", alignItems: "center", gap: "6px", color: "#64748B", textDecoration: "none" }}>
            <ArrowLeft size={15} /> Back to Certified Inventory
          </Link>
          <span>/</span>
          <span>{item.categoryName}</span>
          <span>/</span>
          <span style={{ color: "#0F172A", fontWeight: 600 }}>{item.name}</span>
        </div>

        {/* Main 2-Column Product Layout */}
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(360px, 1fr))",
            gap: "3rem",
            alignItems: "start",
          }}
        >
          {/* Left Column: Image Canvas & Origin Disclosure */}
          <div>
            <div
              style={{
                width: "100%",
                height: "440px",
                background: "#FFFFFF",
                borderRadius: "14px",
                overflow: "hidden",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                border: "1px solid #E2E8F0",
                position: "relative",
                padding: "24px",
                boxShadow: "0 2px 8px rgba(0, 0, 0, 0.03)",
                marginBottom: "1.25rem",
              }}
            >
              {/* Condition Grade Badge */}
              <span
                style={{
                  position: "absolute",
                  top: "16px",
                  left: "16px",
                  zIndex: 2,
                  background: gradeInfo.bg,
                  color: gradeInfo.text,
                  border: `1px solid ${gradeInfo.border}`,
                  padding: "4px 10px",
                  borderRadius: "6px",
                  fontSize: "12px",
                  fontWeight: 750,
                  letterSpacing: "0.02em",
                }}
              >
                {gradeInfo.label}
              </span>

              {/* Bench Tested Badge */}
              <span
                style={{
                  position: "absolute",
                  top: "16px",
                  right: "16px",
                  zIndex: 2,
                  background: "#0F172A",
                  color: "#FFFFFF",
                  padding: "4px 10px",
                  borderRadius: "6px",
                  fontSize: "11px",
                  fontWeight: 700,
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "4px",
                }}
              >
                <CheckCircle2 size={13} color="#10B981" />
                <span>Verified Working</span>
              </span>

              <div style={{ position: "relative", width: "100%", height: "100%" }}>
                <Image
                  src={imageSrc}
                  alt={item.name}
                  fill
                  priority
                  style={{ objectFit: "contain", objectPosition: "center" }}
                />
              </div>
            </div>

            {/* Authenticity & Serial Disclosure Card */}
            <div
              style={{
                background: "#FFFFFF",
                borderRadius: "12px",
                border: "1px solid #E2E8F0",
                padding: "16px",
              }}
            >
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                  fontSize: "13.5px",
                  fontWeight: 750,
                  color: "#0F172A",
                  marginBottom: "8px",
                }}
              >
                <FileCheck size={18} color="#E86F1C" />
                <span>Lab Verification & Serial Disclosure</span>
              </div>
              <div style={{ fontSize: "13px", color: "#64748B", display: "flex", flexDirection: "column", gap: "6px" }}>
                <div>
                  Serial Number (Masked):{" "}
                  <strong style={{ color: "#0F172A" }}>{item.serialNumberMasked || "Verified on Lab Registry"}</strong>
                </div>
                <div>
                  Facility:{" "}
                  <strong style={{ color: "#0F172A" }}>Sharma Video Care Workshop, Janakpur</strong>
                </div>
                <div>
                  Inventory Type:{" "}
                  <strong style={{ color: "#059669" }}>100% In-House Owned (Single Unit in Stock)</strong>
                </div>
              </div>
            </div>
          </div>

          {/* Right Column: Inspection Checklist, Pricing, Order */}
          <div>
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
                marginBottom: "0.5rem",
                flexWrap: "wrap",
                gap: "8px",
              }}
            >
              <span
                style={{
                  fontSize: "12px",
                  fontWeight: 750,
                  color: "#E86F1C",
                  textTransform: "uppercase",
                  letterSpacing: "0.06em",
                }}
              >
                {item.brand} • {item.model}
              </span>

              {/* Shutter Count / Usage Metric Pill */}
              <span
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "4px",
                  background: "#F1F5F9",
                  color: "#0F172A",
                  padding: "3px 10px",
                  borderRadius: "6px",
                  fontSize: "12px",
                  fontWeight: 700,
                }}
              >
                {item.metricType === "SHUTTER" ? (
                  <Camera size={13} color="#0F172A" />
                ) : (
                  <Compass size={13} color="#0F172A" />
                )}
                <span>{item.usageMetric}</span>
              </span>
            </div>

            <h1
              style={{
                fontSize: "2rem",
                fontWeight: 800,
                color: "#0F172A",
                margin: "0 0 0.75rem 0",
                lineHeight: 1.25,
                letterSpacing: "-0.02em",
              }}
            >
              {item.name}
            </h1>

            {/* Price with Original New Price & Savings */}
            <div
              style={{
                display: "flex",
                alignItems: "baseline",
                gap: "10px",
                marginBottom: "1.25rem",
                flexWrap: "wrap",
              }}
            >
              <div
                style={{
                  fontSize: "2rem",
                  fontWeight: 800,
                  color: "#0F172A",
                  letterSpacing: "-0.02em",
                }}
              >
                Rs. {item.price.toLocaleString("en-IN")}
              </div>

              {item.originalNewPrice && (
                <div
                  style={{
                    fontSize: "1.1rem",
                    color: "#94A3B8",
                    textDecoration: "line-through",
                  }}
                >
                  Rs. {item.originalNewPrice.toLocaleString("en-IN")}
                </div>
              )}

              {savings > 0 && (
                <div
                  style={{
                    fontSize: "12px",
                    fontWeight: 700,
                    color: "#15803D",
                    background: "#EAF6EE",
                    padding: "2px 8px",
                    borderRadius: "4px",
                  }}
                >
                  Save Rs. {savings.toLocaleString("en-IN")} ({savingsPercent}% Off New)
                </div>
              )}
            </div>

            {/* Condition Assessment */}
            <div
              style={{
                background: "#FFFFFF",
                borderRadius: "12px",
                border: "1px solid #E2E8F0",
                padding: "1.25rem",
                marginBottom: "1.25rem",
              }}
            >
              <h3
                style={{
                  fontSize: "14px",
                  fontWeight: 750,
                  color: "#0F172A",
                  margin: "0 0 6px 0",
                  textTransform: "uppercase",
                  letterSpacing: "0.04em",
                }}
              >
                Condition Assessment
              </h3>
              <p
                style={{
                  fontSize: "13.5px",
                  color: "#475569",
                  lineHeight: 1.6,
                  margin: 0,
                }}
              >
                {item.conditionDescription}
              </p>
            </div>

            {/* Disclosed Marks (Truth in Advertising) */}
            {item.knownDefects && item.knownDefects.length > 0 && (
              <div
                style={{
                  background: "#FFFBEB",
                  border: "1px solid #FDE68A",
                  borderRadius: "12px",
                  padding: "1.25rem",
                  marginBottom: "1.25rem",
                }}
              >
                <div
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: "8px",
                    fontWeight: 750,
                    color: "#92400E",
                    marginBottom: "8px",
                    fontSize: "14px",
                  }}
                >
                  <AlertTriangle size={18} color="#D97706" />
                  <span>Disclosed Marks & Wear</span>
                </div>
                <ul
                  style={{
                    margin: 0,
                    paddingLeft: "1.25rem",
                    color: "#78350F",
                    fontSize: "13px",
                    lineHeight: 1.6,
                  }}
                >
                  {item.knownDefects.map((d, i) => (
                    <li key={i}>{d}</li>
                  ))}
                </ul>
              </div>
            )}

            {/* Technician Bench Test Report */}
            <div
              style={{
                background: "#FFFFFF",
                borderRadius: "12px",
                border: "1px solid #E2E8F0",
                padding: "1.25rem",
                marginBottom: "1.25rem",
              }}
            >
              <h3
                style={{
                  fontSize: "14px",
                  fontWeight: 750,
                  color: "#0F172A",
                  margin: "0 0 6px 0",
                  textTransform: "uppercase",
                  letterSpacing: "0.04em",
                }}
              >
                Janakpur Workshop Bench Test
              </h3>
              <p
                style={{
                  fontSize: "13px",
                  color: "#475569",
                  lineHeight: 1.6,
                  margin: 0,
                  background: "#F8FAFC",
                  padding: "10px 12px",
                  borderRadius: "6px",
                  border: "1px solid #E2E8F0",
                }}
              >
                {item.testNotes}
              </p>
            </div>

            {/* Included Accessories */}
            {item.includedAccessories && item.includedAccessories.length > 0 && (
              <div
                style={{
                  background: "#FFFFFF",
                  borderRadius: "12px",
                  border: "1px solid #E2E8F0",
                  padding: "1.25rem",
                  marginBottom: "1.5rem",
                }}
              >
                <h3
                  style={{
                    fontSize: "14px",
                    fontWeight: 750,
                    color: "#0F172A",
                    margin: "0 0 10px 0",
                    display: "flex",
                    alignItems: "center",
                    gap: "6px",
                  }}
                >
                  <Package size={17} color="#E86F1C" />
                  <span>Included in Package</span>
                </h3>
                <div style={{ display: "flex", flexWrap: "wrap", gap: "8px" }}>
                  {item.includedAccessories.map((acc, i) => (
                    <span
                      key={i}
                      style={{
                        background: "#F8FAFC",
                        border: "1px solid #E2E8F0",
                        padding: "4px 10px",
                        borderRadius: "6px",
                        fontSize: "12.5px",
                        fontWeight: 600,
                        color: "#334155",
                      }}
                    >
                      ✓ {acc}
                    </span>
                  ))}
                </div>
              </div>
            )}

            {/* Action Box */}
            <div
              style={{
                background: "#FFFFFF",
                borderRadius: "12px",
                border: "1px solid #E2E8F0",
                padding: "1.5rem",
                marginBottom: "2rem",
                boxShadow: "0 1px 3px rgba(0, 0, 0, 0.02)",
              }}
            >
              <div
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  fontSize: "13px",
                  color: "#64748B",
                  marginBottom: "1rem",
                  paddingBottom: "10px",
                  borderBottom: "1px solid #F1F5F9",
                }}
              >
                <span>
                  Warranty: <strong style={{ color: "#0F172A" }}>{item.warrantyDetails}</strong>
                </span>
                <span>
                  Return Window: <strong style={{ color: "#0F172A" }}>{item.returnWindowDays} Days Inspection</strong>
                </span>
              </div>

              <div style={{ display: "flex", gap: "12px", flexWrap: "wrap" }}>
                <button
                  type="button"
                  onClick={handleAddToCart}
                  style={{
                    flex: 1,
                    minWidth: "180px",
                    height: "44px",
                    display: "inline-flex",
                    alignItems: "center",
                    justifyContent: "center",
                    gap: "8px",
                    background: added ? "#16A34A" : "#E86F1C",
                    color: "#FFFFFF",
                    border: "none",
                    borderRadius: "8px",
                    fontSize: "14px",
                    fontWeight: 700,
                    cursor: "pointer",
                    transition: "background 0.15s ease",
                  }}
                >
                  {added ? (
                    <>
                      <Check size={18} /> Added to Cart!
                    </>
                  ) : (
                    <>
                      <ShoppingCart size={18} /> Buy This Unit
                    </>
                  )}
                </button>

                <button
                  type="button"
                  onClick={handleBuyNow}
                  style={{
                    height: "44px",
                    padding: "0 24px",
                    background: "#0F172A",
                    color: "#FFFFFF",
                    border: "none",
                    borderRadius: "8px",
                    fontSize: "14px",
                    fontWeight: 700,
                    cursor: "pointer",
                  }}
                >
                  Instant Checkout
                </button>
              </div>
            </div>

            {/* Assistance Box */}
            <div
              style={{
                display: "flex",
                flexDirection: "column",
                gap: "1rem",
                background: "#FFFFFF",
                borderRadius: "12px",
                border: "1px solid #E2E8F0",
                padding: "1.25rem",
              }}
            >
              <div style={{ display: "flex", gap: "10px", alignItems: "flex-start" }}>
                <ShieldCheck size={20} color="#E86F1C" style={{ flexShrink: 0, marginTop: "2px" }} />
                <div>
                  <div style={{ fontSize: "13.5px", fontWeight: 700, color: "#0F172A" }}>
                    {item.warrantyDetails}
                  </div>
                  <div style={{ fontSize: "12.5px", color: "#64748B", marginTop: "2px" }}>
                    Covers internal mechanical and electronic components serviced by Sharma Video Care.
                  </div>
                </div>
              </div>

              <div style={{ display: "flex", gap: "10px", alignItems: "flex-start" }}>
                <RotateCcw size={20} color="#E86F1C" style={{ flexShrink: 0, marginTop: "2px" }} />
                <div>
                  <div style={{ fontSize: "13.5px", fontWeight: 700, color: "#0F172A" }}>
                    {item.returnWindowDays}-Day Verification Window
                  </div>
                  <div style={{ fontSize: "12.5px", color: "#64748B", marginTop: "2px" }}>
                    If the physical condition differs from our written lab inspection report, return for full refund.
                  </div>
                </div>
              </div>

              <div style={{ display: "flex", gap: "10px", alignItems: "flex-start" }}>
                <PhoneCall size={20} color="#E86F1C" style={{ flexShrink: 0, marginTop: "2px" }} />
                <div>
                  <div style={{ fontSize: "13.5px", fontWeight: 700, color: "#0F172A" }}>
                    Speak with the Inspecting Technician
                  </div>
                  <div style={{ fontSize: "12.5px", color: "#64748B", marginTop: "2px" }}>
                    Call our Janakpur workshop at{" "}
                    <a
                      href="tel:+9779854025000"
                      style={{ color: "#E86F1C", fontWeight: 700, textDecoration: "none" }}
                    >
                      +977-9854025000
                    </a>{" "}
                    to discuss this unit.
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
