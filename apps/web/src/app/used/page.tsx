"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../../lib/firebase";
import { UsedProductListing } from "@sharmavideocare/shared";
import { ShieldCheck, CheckCircle2, ShoppingBag, ArrowRight } from "lucide-react";

export default function UsedProductsPage() {
  const [listings, setListings] = useState<UsedProductListing[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadUsedProducts() {
      try {
        const snap = await getDocs(collection(db, "usedProducts"));
        const list: UsedProductListing[] = [];
        snap.forEach((d) => list.push({ id: d.id, ...d.data() } as UsedProductListing));
        setListings(list);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    loadUsedProducts();
  }, []);

  return (
    <div className="container" style={{ padding: "3rem 1.25rem" }}>
      {/* Header */}
      <div style={{ maxWidth: "820px", marginBottom: "2.5rem" }}>
        <span className="badge badge-success" style={{ marginBottom: "0.5rem" }}>
          Sharma Video Care Certified Pre-Owned
        </span>
        <h1 style={{ fontSize: "2.25rem", fontWeight: 800, color: "var(--color-ink)", marginBottom: "0.5rem" }}>
          Certified Second-Hand Equipment
        </h1>
        <p style={{ color: "var(--color-muted)", fontSize: "1.05rem", lineHeight: 1.6 }}>
          Each item is inspected, bench-tested, and graded by our in-house technicians in Janakpur. We disclose every cosmetic mark and include service warranties.
        </p>
      </div>

      {/* Confirmed Policy Box */}
      <div
        className="card"
        style={{
          background: "#F5FAF7",
          border: "1px solid #D1EADE",
          padding: "1.5rem",
          marginBottom: "2.5rem",
          display: "flex",
          gap: "1rem",
          alignItems: "center",
        }}
      >
        <ShieldCheck size={28} style={{ color: "var(--color-success)", flexShrink: 0 }} />
        <div>
          <strong style={{ color: "#165935", fontSize: "0.95rem" }}>
            Sharma Video Care Exclusive Inventory:
          </strong>{" "}
          <span style={{ fontSize: "0.9rem", color: "#2B5E41" }}>
            We do not host open peer-to-peer or third-party listings. All second-hand products belong to Sharma Video Care, tested in our laboratory, and dispatched nationwide across Nepal.
          </span>
        </div>
      </div>

      {loading ? (
        <div style={{ textAlign: "center", padding: "4rem 0" }}>Loading certified equipment...</div>
      ) : listings.length === 0 ? (
        <div className="card" style={{ textAlign: "center", padding: "4rem 2rem" }}>
          <h3>No certified pre-owned equipment listed right now.</h3>
          <p style={{ color: "var(--color-muted)", marginTop: "0.5rem" }}>
            Check back soon for new certified pre-owned arrivals.
          </p>
        </div>
      ) : (
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(320px, 1fr))", gap: "2rem" }}>
          {listings.map((item) => (
            <Link
              key={item.id}
              href={`/used/${item.id}`}
              className="card card-hover"
              style={{ display: "flex", flexDirection: "column", justifyContent: "space-between", textDecoration: "none" }}
            >
              <div>
                {/* Image */}
                <div
                  style={{
                    height: "220px",
                    background: "#F2EDE4",
                    borderRadius: "var(--radius-sm)",
                    overflow: "hidden",
                    marginBottom: "1.2rem",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                  }}
                >
                  {item.images && item.images[0] ? (
                    <img
                      src={item.images[0]}
                      alt={item.name}
                      style={{ width: "100%", height: "100%", objectFit: "cover" }}
                    />
                  ) : (
                    <ShoppingBag size={40} color="var(--color-muted)" />
                  )}
                </div>

                {/* Grade and Verification */}
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "0.6rem" }}>
                  <span className="badge badge-primary">
                    Grade: {item.conditionGrade.replace("_", " ")}
                  </span>
                  <span style={{ fontSize: "0.8rem", color: "var(--color-success)", fontWeight: 600, display: "flex", alignItems: "center", gap: "0.25rem" }}>
                    <CheckCircle2 size={14} /> Fully Tested
                  </span>
                </div>

                <h3 style={{ fontSize: "1.15rem", fontWeight: 700, color: "var(--color-ink)", marginBottom: "0.5rem", lineHeight: 1.3 }}>
                  {item.name}
                </h3>

                <p style={{ fontSize: "0.88rem", color: "var(--color-muted)", lineHeight: 1.5, marginBottom: "1rem" }}>
                  {item.conditionDescription}
                </p>

                {/* Defect disclosure snippet */}
                {item.knownDefects && item.knownDefects.length > 0 && (
                  <div style={{ fontSize: "0.8rem", color: "#8E5A17", background: "#FEF9EF", padding: "0.5rem 0.75rem", borderRadius: "4px", marginBottom: "1rem", border: "1px solid #F8ECCF" }}>
                    <strong>Disclosed:</strong> {item.knownDefects[0]}
                  </div>
                )}
              </div>

              <div>
                <div style={{ borderTop: "1px solid var(--color-border)", paddingTop: "1rem", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                  <div>
                    <span style={{ fontSize: "0.75rem", color: "var(--color-muted)", display: "block" }}>
                      Certified Price
                    </span>
                    <strong style={{ fontSize: "1.25rem", color: "var(--color-ink)" }}>
                      Rs. {item.price.toLocaleString("en-IN")}
                    </strong>
                  </div>

                  <span className="btn btn-secondary btn-sm" style={{ display: "flex", alignItems: "center", gap: "0.3rem" }}>
                    View Inspection <ArrowRight size={14} />
                  </span>
                </div>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
