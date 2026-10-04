import React from "react";

export default function PrivacyPage() {
  return (
    <div className="container" style={{ padding: "4rem 1.25rem", maxWidth: "800px" }}>
      <h1 style={{ fontSize: "2.25rem", fontWeight: 800, marginBottom: "0.5rem" }}>
        Privacy Policy
      </h1>
      <p style={{ color: "var(--color-muted)", fontSize: "0.9rem", marginBottom: "2rem" }}>
        Last Updated: October 2026 • Compliant with the Individual Privacy Act 2075 of Nepal.
      </p>

      <div className="card" style={{ display: "flex", flexDirection: "column", gap: "1.75rem", lineHeight: 1.7, fontSize: "0.95rem" }}>
        <section>
          <h2 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "0.5rem" }}>1. Information We Collect</h2>
          <p>
            Sharma Video Care collects personal information required solely for delivering services and fulfilling orders:
          </p>
          <ul style={{ paddingLeft: "1.25rem", marginTop: "0.5rem" }}>
            <li>Contact details: Name, phone number, email address.</li>
            <li>Location details: Service address in Janakpur or delivery address in Nepal.</li>
            <li>Service information: Photos/videos of equipment defects, technical diagnostic logs.</li>
            <li>Transaction information: Payment methods, deposit vouchers for bank transfers.</li>
            <li>Communications: Messages between customers, staff, and assigned technicians.</li>
          </ul>
        </section>

        <section>
          <h2 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "0.5rem" }}>2. Purpose of Collection</h2>
          <p>
            Your information is used strictly to:
          </p>
          <ul style={{ paddingLeft: "1.25rem", marginTop: "0.5rem" }}>
            <li>Dispatch qualified technicians to your location for physical inspection.</li>
            <li>Process, package, and deliver merchandise via courier partners across Nepal.</li>
            <li>Send order confirmations and updates via WhatsApp and Email (no promotional SMS spam).</li>
            <li>Verify bank transfer payments and maintain financial records required by Nepal revenue laws.</li>
          </ul>
        </section>

        <section>
          <h2 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "0.5rem" }}>3. Data Sharing & Security</h2>
          <p>
            We do not sell, rent, or monetize your personal data. Data is shared exclusively on a need-to-know basis with:
          </p>
          <ul style={{ paddingLeft: "1.25rem", marginTop: "0.5rem" }}>
            <li>Assigned technicians (who only see customer contact details for their specific assigned jobs).</li>
            <li>Courier logistics partners (for parcel delivery address and phone number).</li>
          </ul>
        </section>
      </div>
    </div>
  );
}
