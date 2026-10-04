import React from "react";
import Link from "next/link";
import { REPAIR_PRICE_NOTICE } from "@sharmavideocare/shared";

export default function TermsPage() {
  return (
    <div className="container" style={{ padding: "4rem 1.25rem", maxWidth: "800px" }}>
      <h1 style={{ fontSize: "2.25rem", fontWeight: 800, marginBottom: "0.5rem" }}>
        Terms of Service
      </h1>
      <p style={{ color: "var(--color-muted)", fontSize: "0.9rem", marginBottom: "2rem" }}>
        Last Updated: October 2026 • Governed under the laws of Nepal, including the Electronic Commerce Act 2081 and Consumer Protection Act 2075.
      </p>

      <div className="card" style={{ display: "flex", flexDirection: "column", gap: "1.75rem", lineHeight: 1.7, fontSize: "0.95rem" }}>
        <section>
          <h2 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "0.5rem" }}>1. About Sharma Video Care</h2>
          <p>
            Sharma Video Care is a registered technology service and electronic sales business headquartered in Janakpur, Dhanusha, Nepal. We provide specialized diagnostic electronics repairs, equipment servicing, custom installations, retail sales of new electronic goods, and certified pre-owned equipment.
          </p>
        </section>

        <section>
          <h2 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "0.5rem" }}>2. Repair & Inspection Services</h2>
          <p>
            <strong>Service Area:</strong> Repair and on-site servicing operations are initially centered in the Janakpur Sub-Metropolitan region.
          </p>
          <p>
            <strong>Free Inspection & Diagnostic Principle:</strong> Initial hardware inspection and initial technician visits in Janakpur are free of charge. Where technical diagnosis is required, the final repair quotation is formulated after physical examination. <em>({REPAIR_PRICE_NOTICE})</em> No repair work commences without explicit customer approval.
          </p>
        </section>

        <section>
          <h2 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "0.5rem" }}>3. Product Sales & Delivery</h2>
          <p>
            Products listed in our catalogue are shipped nationwide across Nepal via contracted courier partners. Deliveries are accompanied by a unique tracking reference. Customers may pay via Cash on Delivery (COD) or verified Bank Transfer.
          </p>
        </section>

        <section>
          <h2 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "0.5rem" }}>4. Special Orders & Product Availability</h2>
          <p>
            All products displayed in our store are available for purchase and fulfillment. For specialized or extended delivery items, Sharma Video Care confirms inventory availability and delivery schedules directly with you before dispatch.
          </p>
        </section>

        <section>
          <h2 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "0.5rem" }}>5. Certified Second-Hand Equipment</h2>
          <p>
            Only Sharma Video Care is authorized to list second-hand merchandise on this platform. Peer-to-peer or unauthorized third-party listings are strictly prohibited. Each pre-owned item is bench-tested by our technicians, with cosmetic condition, known marks, included accessories, and service warranty clearly disclosed.
          </p>
        </section>

        <section>
          <h2 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "0.5rem" }}>6. User Conduct & Security</h2>
          <p>
            Users agree not to submit fraudulent orders, falsify bank deposit vouchers, upload malicious media, or misuse communication channels. Unauthorized attempts to alter quotes, invoices, or system databases are punishable under Nepal’s Electronic Transactions Act 2063 and Penal Code.
          </p>
        </section>
      </div>
    </div>
  );
}
