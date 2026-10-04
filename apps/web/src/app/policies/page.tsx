import React from "react";
import Link from "next/link";
import { Shield, RotateCcw, AlertTriangle, Truck, Banknote, HelpCircle, CheckCircle2 } from "lucide-react";

export const metadata = {
  title: "Official Store Policies — Shipping, Returns & Warranty",
  description: "Comprehensive customer policies for Sharma Video Care: nationwide courier transit, 7-day inspection window, authorized warranties, and diagnostic terms.",
};

export default function PoliciesPage() {
  return (
    <div style={{ background: "#F8FAFC", minHeight: "100vh", padding: "3rem 1.25rem 5rem 1.25rem" }}>
      <div style={{ maxWidth: "860px", margin: "0 auto" }}>
        {/* Breadcrumb */}
        <div style={{ fontSize: "13px", color: "#64748B", marginBottom: "0.75rem" }}>
          <Link href="/" style={{ color: "#64748B", textDecoration: "none" }}>Home</Link>
          {" "}/ <span style={{ color: "#0F172A", fontWeight: 600 }}>Store Policies</span>
        </div>

        <h1 style={{ fontSize: "2.25rem", fontWeight: 800, color: "#0F172A", margin: "0 0 0.5rem 0", letterSpacing: "-0.02em" }}>
          Official Store Policies
        </h1>
        <p style={{ color: "#64748B", fontSize: "14px", margin: "0 0 2rem 0", lineHeight: 1.6 }}>
          Transparent terms governing nationwide deliveries, physical bench inspections in Janakpur, official manufacturer warranties, and customer rights under the Nepal Consumer Protection Act 2075.
        </p>

        {/* Quick Highlights Grid */}
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))",
            gap: "16px",
            marginBottom: "2.5rem",
          }}
        >
          <div style={{ background: "#FFFFFF", padding: "18px", borderRadius: "10px", border: "1px solid #E2E8F0" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "8px", fontWeight: 700, fontSize: "14px", color: "#0F172A", marginBottom: "6px" }}>
              <Truck size={18} color="#E86F1C" /> Nationwide Transit
            </div>
            <div style={{ fontSize: "12.5px", color: "#64748B", lineHeight: 1.5 }}>
              Courier dispatch across all 7 provinces with tracking reference and insured transit protection.
            </div>
          </div>

          <div style={{ background: "#FFFFFF", padding: "18px", borderRadius: "10px", border: "1px solid #E2E8F0" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "8px", fontWeight: 700, fontSize: "14px", color: "#0F172A", marginBottom: "6px" }}>
              <RotateCcw size={18} color="#16A34A" /> 7-Day Replacement
            </div>
            <div style={{ fontSize: "12.5px", color: "#64748B", lineHeight: 1.5 }}>
              Dead-on-arrival or functional fault coverage with hassle-free exchange or lab resolution.
            </div>
          </div>

          <div style={{ background: "#FFFFFF", padding: "18px", borderRadius: "10px", border: "1px solid #E2E8F0" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "8px", fontWeight: 700, fontSize: "14px", color: "#0F172A", marginBottom: "6px" }}>
              <Shield size={18} color="#2563EB" /> 100% Genuine Guarantee
            </div>
            <div style={{ fontSize: "12.5px", color: "#64748B", lineHeight: 1.5 }}>
              Authorized importer sourcing, official VAT invoices, and genuine manufacturer serials.
            </div>
          </div>
        </div>

        {/* Detailed Sections Container */}
        <div style={{ display: "flex", flexDirection: "column", gap: "20px" }}>
          {/* Section 1: Shipping & Delivery */}
          <section style={{ background: "#FFFFFF", padding: "24px", borderRadius: "12px", border: "1px solid #E2E8F0" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "10px", marginBottom: "12px" }}>
              <div style={{ width: "32px", height: "32px", borderRadius: "6px", background: "#FFF7ED", display: "flex", alignItems: "center", justifyContent: "center" }}>
                <Truck size={18} color="#E86F1C" />
              </div>
              <h2 style={{ fontSize: "1.2rem", fontWeight: 750, color: "#0F172A", margin: 0 }}>
                1. Shipping & Courier Delivery Policy
              </h2>
            </div>
            <p style={{ fontSize: "13.5px", color: "#475569", lineHeight: 1.6, margin: "0 0 12px 0" }}>
              We partner with Nepal Can Move, Sundar Courier, and leading logistics networks to dispatch tech gear securely across Nepal.
            </p>
            <ul style={{ fontSize: "13px", color: "#475569", lineHeight: 1.7, margin: 0, paddingLeft: "20px" }}>
              <li><strong>Delivery Timelines:</strong> Janakpur local delivery within 24 hours. Major hubs (Kathmandu, Pokhara, Biratnagar, Birgunj, Chitwan) within 24–48 hours. Remote areas within 2–4 business days.</li>
              <li><strong>Flat Shipping Rate:</strong> Nominal flat delivery fee of NPR 150 across Nepal for standard packages.</li>
              <li><strong>Insured Transit:</strong> All optical lenses, drone transmitters, and camera bodies are bubble-shielded and insured against transit breakage or loss.</li>
              <li><strong>Verification Upon Delivery:</strong> Customers are encouraged to inspect physical outer packaging before signing the courier dispatch sheet.</li>
            </ul>
          </section>

          {/* Section 2: Returns & Replacements */}
          <section style={{ background: "#FFFFFF", padding: "24px", borderRadius: "12px", border: "1px solid #E2E8F0" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "10px", marginBottom: "12px" }}>
              <div style={{ width: "32px", height: "32px", borderRadius: "6px", background: "#ECFDF5", display: "flex", alignItems: "center", justifyContent: "center" }}>
                <RotateCcw size={18} color="#16A34A" />
              </div>
              <h2 style={{ fontSize: "1.2rem", fontWeight: 750, color: "#0F172A", margin: 0 }}>
                2. 7-Day Replacement & Return Policy
              </h2>
            </div>
            <p style={{ fontSize: "13.5px", color: "#475569", lineHeight: 1.6, margin: "0 0 12px 0" }}>
              To ensure complete peace of mind when ordering sensitive imaging and electronics gear:
            </p>
            <ul style={{ fontSize: "13px", color: "#475569", lineHeight: 1.7, margin: 0, paddingLeft: "20px" }}>
              <li><strong>Dead-on-Arrival (DOA):</strong> If an item arrives defective or fails to power on, contact our Janakpur workshop via phone or WhatsApp within 7 calendar days of delivery for an immediate direct replacement.</li>
              <li><strong>Return Eligibility:</strong> Items must include all original packaging, factory manuals, accessories, batteries, and the purchase bill/receipt.</li>
              <li><strong>Exclusions:</strong> Items damaged by physical dropping, liquid spills, unauthorized third-party disassembly, or electrical surge are not eligible for standard return claims.</li>
            </ul>
          </section>

          {/* Section 3: Certified Pre-Owned Warranty */}
          <section style={{ background: "#FFFFFF", padding: "24px", borderRadius: "12px", border: "1px solid #E2E8F0" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "10px", marginBottom: "12px" }}>
              <div style={{ width: "32px", height: "32px", borderRadius: "6px", background: "#EFF6FF", display: "flex", alignItems: "center", justifyContent: "center" }}>
                <Shield size={18} color="#2563EB" />
              </div>
              <h2 style={{ fontSize: "1.2rem", fontWeight: 750, color: "#0F172A", margin: 0 }}>
                3. Certified Second-Hand Equipment Policy
              </h2>
            </div>
            <p style={{ fontSize: "13.5px", color: "#475569", lineHeight: 1.6, margin: "0 0 12px 0" }}>
              Every used camera body, prime lens, or cinema accessory sold by Sharma Video Care undergoes our mandatory 45-point workshop bench test.
            </p>
            <ul style={{ fontSize: "13px", color: "#475569", lineHeight: 1.7, margin: 0, paddingLeft: "20px" }}>
              <li><strong>Workshop Warranty:</strong> Covered by a 60-to-180 day Sharma Video Care repair lab warranty on functional parts and mechanics.</li>
              <li><strong>Shutter Actuation & Cosmetic Transparency:</strong> Exact shutter counts and cosmetic condition grades (A+, A, B) are fully stated on the product page before payment.</li>
              <li><strong>Guaranteed Clean Optics:</strong> Lenses are inspected under microscope lighting to certify zero mold, fungus, or element separation.</li>
            </ul>
          </section>

          {/* Section 4: Workshop Diagnostic Rule */}
          <section style={{ background: "#FFFFFF", padding: "24px", borderRadius: "12px", border: "1px solid #E2E8F0" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "10px", marginBottom: "12px" }}>
              <div style={{ width: "32px", height: "32px", borderRadius: "6px", background: "#FEF2F2", display: "flex", alignItems: "center", justifyContent: "center" }}>
                <AlertTriangle size={18} color="#DC2626" />
              </div>
              <h2 style={{ fontSize: "1.2rem", fontWeight: 750, color: "#0F172A", margin: 0 }}>
                4. Repair Diagnostics & Pricing Principles
              </h2>
            </div>
            <p style={{ fontSize: "13.5px", color: "#475569", lineHeight: 1.6, margin: "0 0 12px 0" }}>
              We uphold strict ethical repair standards centered at our Janakpur service facility:
            </p>
            <ul style={{ fontSize: "13px", color: "#475569", lineHeight: 1.7, margin: 0, paddingLeft: "20px" }}>
              <li><strong>Free Physical Inspection:</strong> There is never an upfront fee for bench evaluation or initial fault diagnosis in Janakpur.</li>
              <li><strong>No Surprise Bills:</strong> The final quote is issued only after physical bench inspection and technician teardown. No repair proceeds without your explicit approval.</li>
              <li><strong>Repair Guarantee:</strong> All completed repair jobs include a 30 to 90-day warranty on replaced parts and workmanship.</li>
            </ul>
          </section>
        </div>

        {/* Contact Strip */}
        <div
          style={{
            marginTop: "2.5rem",
            background: "#0F172A",
            color: "#FFFFFF",
            padding: "20px 24px",
            borderRadius: "12px",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            flexWrap: "wrap",
            gap: "16px",
          }}
        >
          <div>
            <div style={{ fontSize: "14px", fontWeight: 750 }}>Have questions regarding an order or warranty?</div>
            <div style={{ fontSize: "12.5px", color: "#94A3B8", marginTop: "2px" }}>
              Contact our Janakpur workshop directly via phone or WhatsApp.
            </div>
          </div>
          <div style={{ display: "flex", gap: "10px" }}>
            <a
              href="https://wa.me/9779854022200"
              target="_blank"
              rel="noopener noreferrer"
              style={{
                background: "#25D366",
                color: "#FFFFFF",
                padding: "8px 14px",
                borderRadius: "6px",
                fontSize: "12.5px",
                fontWeight: 700,
                textDecoration: "none",
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
              }}
            >
              WhatsApp Us
            </a>
            <Link
              href="/shop"
              style={{
                background: "#E86F1C",
                color: "#FFFFFF",
                padding: "8px 14px",
                borderRadius: "6px",
                fontSize: "12.5px",
                fontWeight: 700,
                textDecoration: "none",
              }}
            >
              Browse Shop
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
