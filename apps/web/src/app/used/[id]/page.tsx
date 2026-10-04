"use client";

import React, { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import { doc, getDoc } from "firebase/firestore";
import { db } from "../../../lib/firebase";
import { UsedProductListing } from "@sharmavideocare/shared";
import { useCart } from "../../../context/CartContext";
import { ShieldCheck, CheckCircle, ArrowLeft, ShoppingCart, Check, AlertTriangle, Package, Calendar } from "lucide-react";

export default function UsedProductDetailPage() {
  const params = useParams();
  const id = params?.id as string;
  const router = useRouter();

  const [item, setItem] = useState<UsedProductListing | null>(null);
  const [loading, setLoading] = useState(true);
  const [added, setAdded] = useState(false);

  const { addToCart } = useCart();

  useEffect(() => {
    async function loadItem() {
      try {
        const snap = await getDoc(doc(db, "usedProducts", id));
        if (snap.exists()) {
          setItem({ id: snap.id, ...snap.data() } as UsedProductListing);
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    if (id) loadItem();
  }, [id]);

  if (loading) {
    return (
      <div className="container" style={{ padding: "4rem 1.25rem", textAlign: "center" }}>
        Loading certified inspection report...
      </div>
    );
  }

  if (!item) {
    return (
      <div className="container" style={{ padding: "4rem 1.25rem", textAlign: "center" }}>
        <h2>Product Not Found</h2>
        <Link href="/used" className="btn btn-secondary" style={{ marginTop: "1rem" }}>
          <ArrowLeft size={16} /> Back to Used Equipment
        </Link>
      </div>
    );
  }

  const handleAddToCart = () => {
    addToCart({
      productId: item.id,
      productType: "USED",
      name: item.name,
      image: item.images?.[0],
      unitPrice: item.price,
      quantity: 1,
      totalPrice: item.price,
      warrantySummary: item.warrantyDetails,
    });
    setAdded(true);
    setTimeout(() => setAdded(false), 2000);
  };

  return (
    <div className="container" style={{ padding: "3rem 1.25rem" }}>
      <Link
        href="/used"
        style={{ display: "inline-flex", alignItems: "center", gap: "0.4rem", color: "var(--color-muted)", fontSize: "0.9rem", marginBottom: "1.5rem" }}
      >
        <ArrowLeft size={16} /> Back to Certified Inventory
      </Link>

      <div style={{ display: "grid", gridTemplateColumns: "minmax(320px, 460px) 1fr", gap: "3.5rem", alignItems: "start" }}>
        {/* Left: Product Image & Grade Badge */}
        <div>
          <div
            style={{
              width: "100%",
              height: "400px",
              background: "#F2EDE4",
              borderRadius: "var(--radius-md)",
              overflow: "hidden",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              border: "1px solid var(--color-border)",
              marginBottom: "1rem",
            }}
          >
            {item.images && item.images[0] ? (
              <img
                src={item.images[0]}
                alt={item.name}
                style={{ width: "100%", height: "100%", objectFit: "cover" }}
              />
            ) : (
              <div>No Image</div>
            )}
          </div>

          <div className="card" style={{ background: "#FBF9F5" }}>
            <h4 style={{ fontSize: "0.95rem", fontWeight: 700, marginBottom: "0.5rem" }}>
              Authenticity & Serial Disclosure
            </h4>
            <div style={{ fontSize: "0.85rem", color: "var(--color-muted)", display: "flex", flexDirection: "column", gap: "0.3rem" }}>
              <div>Serial Number (Masked): <strong>{item.serialNumberMasked || "Verified on File"}</strong></div>
              <div>Origin: Inspected & Serviced by Sharma Video Care, Janakpur</div>
            </div>
          </div>
        </div>

        {/* Right: Inspection Checklist & Details */}
        <div>
          <div style={{ display: "flex", gap: "0.75rem", alignItems: "center", marginBottom: "0.75rem" }}>
            <span className="badge badge-primary">
              Condition Grade: {item.conditionGrade.replace("_", " ")}
            </span>
            <span className="badge badge-success">
              ✓ Tested Fully Functional
            </span>
          </div>

          <h1 style={{ fontSize: "2rem", fontWeight: 800, color: "var(--color-ink)", marginBottom: "0.75rem", lineHeight: 1.25 }}>
            {item.name}
          </h1>

          <div style={{ fontSize: "1.85rem", fontWeight: 800, color: "var(--color-ink)", marginBottom: "1.5rem" }}>
            Rs. {item.price.toLocaleString("en-IN")}
          </div>

          {/* Condition Description */}
          <div style={{ marginBottom: "1.75rem" }}>
            <h3 style={{ fontSize: "1.05rem", fontWeight: 700, marginBottom: "0.4rem" }}>
              Condition Assessment
            </h3>
            <p style={{ color: "var(--color-muted)", fontSize: "0.95rem", lineHeight: 1.6 }}>
              {item.conditionDescription}
            </p>
          </div>

          {/* Known Defects (Truth in Advertising) */}
          <div
            style={{
              padding: "1rem 1.25rem",
              background: "#FFF8ED",
              border: "1px solid #F8E2C2",
              borderRadius: "var(--radius-sm)",
              marginBottom: "1.75rem",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", fontWeight: 700, color: "#925A12", marginBottom: "0.4rem", fontSize: "0.95rem" }}>
              <AlertTriangle size={18} /> Disclosed Cosmetic or Functional Marks
            </div>
            <ul style={{ paddingLeft: "1.25rem", color: "#6C4512", fontSize: "0.88rem", lineHeight: 1.5 }}>
              {item.knownDefects && item.knownDefects.map((d, i) => (
                <li key={i}>{d}</li>
              ))}
            </ul>
          </div>

          {/* Lab Test Notes */}
          <div style={{ marginBottom: "1.75rem" }}>
            <h3 style={{ fontSize: "1.05rem", fontWeight: 700, marginBottom: "0.4rem" }}>
              Technician Bench Test Report
            </h3>
            <p style={{ color: "var(--color-muted)", fontSize: "0.9rem", lineHeight: 1.5, background: "var(--color-surface)", padding: "0.85rem", borderRadius: "var(--radius-sm)", border: "1px solid var(--color-border)" }}>
              {item.testNotes}
            </p>
          </div>

          {/* Included Accessories */}
          <div style={{ marginBottom: "2rem" }}>
            <h3 style={{ fontSize: "1.05rem", fontWeight: 700, marginBottom: "0.5rem", display: "flex", alignItems: "center", gap: "0.5rem" }}>
              <Package size={18} /> Included Accessories in Package
            </h3>
            <div style={{ display: "flex", flexWrap: "wrap", gap: "0.5rem" }}>
              {item.includedAccessories && item.includedAccessories.map((acc, i) => (
                <span
                  key={i}
                  style={{
                    background: "var(--color-surface)",
                    border: "1px solid var(--color-border)",
                    padding: "0.35rem 0.75rem",
                    borderRadius: "4px",
                    fontSize: "0.85rem",
                  }}
                >
                  ✓ {acc}
                </span>
              ))}
            </div>
          </div>

          {/* Purchase Box */}
          <div className="card" style={{ marginBottom: "2rem" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "1rem", fontSize: "0.88rem" }}>
              <span>Service Warranty: <strong>{item.warrantyDetails}</strong></span>
              <span>Return Window: <strong>{item.returnWindowDays} Days Verified Defect</strong></span>
            </div>

            <div style={{ display: "flex", gap: "1rem" }}>
              <button
                onClick={handleAddToCart}
                className="btn btn-primary"
                style={{ flex: 1, padding: "0.85rem" }}
              >
                {added ? (
                  <>
                    <Check size={18} /> Added to Cart!
                  </>
                ) : (
                  <>
                    <ShoppingCart size={18} /> Add Certified Item to Cart
                  </>
                )}
              </button>

              <button
                onClick={() => {
                  handleAddToCart();
                  router.push("/cart");
                }}
                className="btn btn-secondary"
                style={{ padding: "0.85rem 1.25rem" }}
              >
                Buy Now
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
