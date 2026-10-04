import React from "react";
import Link from "next/link";
import { Shield, RotateCcw, AlertTriangle } from "lucide-react";

export default function PoliciesPage() {
  return (
    <div className="container" style={{ padding: "4rem 1.25rem", maxWidth: "800px" }}>
      <h1 style={{ fontSize: "2.25rem", fontWeight: 800, marginBottom: "0.5rem" }}>
        Warranty & Returns Policy
      </h1>
      <p style={{ color: "var(--color-muted)", fontSize: "0.9rem", marginBottom: "2rem" }}>
        Product and Service-Specific Policies • In accordance with the Consumer Protection Act 2075.
      </p>

      <div className="card" style={{ display: "flex", flexDirection: "column", gap: "2rem", lineHeight: 1.7, fontSize: "0.95rem" }}>
        <section>
          <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", marginBottom: "0.5rem" }}>
            <Shield size={22} color="var(--color-primary)" />
            <h2 style={{ fontSize: "1.25rem", fontWeight: 700 }}>1. Product-Specific Policy Principle</h2>
          </div>
          <p>
            Because Sharma Video Care deals in precision optics, sensitive electronics, commercial surveillance, and second-hand items, warranties and return windows vary according to the product category and condition grade. Terms are displayed explicitly on each product listing prior to purchase.
          </p>
        </section>

        <section>
          <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", marginBottom: "0.5rem" }}>
            <RotateCcw size={22} color="var(--color-success)" />
            <h2 style={{ fontSize: "1.25rem", fontWeight: 700 }}>2. Brand-New Merchandise</h2>
          </div>
          <p>
            <strong>Manufacturer Warranty:</strong> Brand new cameras, lenses, drones, and CCTV hardware carry authorized manufacturer or importer warranties (typically 1 to 2 years).
          </p>
          <p>
            <strong>7-Day Dead-On-Arrival (DOA) Return:</strong> If a brand-new sealed product arrives with a manufacturing defect, report it within 7 days of courier delivery for verification and replacement.
          </p>
        </section>

        <section>
          <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", marginBottom: "0.5rem" }}>
            <Shield size={22} color="var(--color-primary)" />
            <h2 style={{ fontSize: "1.25rem", fontWeight: 700 }}>3. Certified Second-Hand Equipment</h2>
          </div>
          <p>
            All pre-owned equipment is inspected and graded exclusively by Sharma Video Care.
          </p>
          <ul style={{ paddingLeft: "1.25rem", marginTop: "0.5rem" }}>
            <li><strong>Service Warranty:</strong> 60 to 90 days limited service warranty covering functional defects.</li>
            <li><strong>7-Day Functional Return Window:</strong> If an undisclosed functional fault occurs within 7 days, you are eligible for full technical repair or return.</li>
            <li><strong>Cosmetic Exclusions:</strong> Pre-disclosed cosmetic marks (clearly listed on the product page before purchase) are excluded from return claims.</li>
          </ul>
        </section>

        <section>
          <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", marginBottom: "0.5rem" }}>
            <AlertTriangle size={22} color="var(--color-warning)" />
            <h2 style={{ fontSize: "1.25rem", fontWeight: 700 }}>4. Repair & Servicing Warranty</h2>
          </div>
          <p>
            Repaired units carry a 30 to 90 day warranty on the specific work completed and replacement parts installed, stated directly on your accepted diagnostic quotation. Water ingress, subsequent drop impact, or tampering by unauthorized third parties voids this warranty.
          </p>
        </section>
      </div>
    </div>
  );
}
