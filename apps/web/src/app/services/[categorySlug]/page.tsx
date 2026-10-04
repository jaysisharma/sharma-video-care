"use client";

import React, { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import { collection, query, where, getDocs } from "firebase/firestore";
import { db } from "../../../lib/firebase";
import { ServiceCategory, REPAIR_PRICE_NOTICE } from "@sharmavideocare/shared";
import {
  Wrench,
  Camera,
  Aperture,
  Tv,
  ShieldCheck,
  Sliders,
  CheckCircle2,
  ArrowLeft,
  ArrowRight,
  Clock,
  Shield,
  Phone,
  MessageCircle,
  FileCheck2,
} from "lucide-react";

const DEFAULT_CATEGORIES: Record<string, ServiceCategory> = {
  camera: {
    id: "cat-camera",
    slug: "camera",
    name: "Cameras & DSLRs / Mirrorless",
    description: "Sensor cleaning, shutter mechanism rebuilds, LCD panel replacements, and motherboard circuit diagnostics.",
    displayOrder: 1,
    active: true,
  },
  lens: {
    id: "cat-lens",
    slug: "lens",
    name: "Optical Lenses & Zoom Barrels",
    description: "Deep optical fungus & haze ultrasonic removal, aperture ribbon soldering, autofocus motor recalibration, and mount alignment.",
    displayOrder: 2,
    active: true,
  },
  drone: {
    id: "cat-drone",
    slug: "drone",
    name: "Drones & Aerial Gimbal Systems",
    description: "Gimbal ribbon repair, motor ESC board sync, obstacle avoidance calibration, and crash damage shell replacement.",
    displayOrder: 3,
    active: true,
  },
  tv: {
    id: "cat-tv",
    slug: "tv",
    name: "Smart TVs & 4K / OLED Displays",
    description: "LED backlight replacement, motherboard and power board repair, display panel lines, and audio power amp restoration.",
    displayOrder: 4,
    active: true,
  },
  cctv: {
    id: "cat-cctv",
    slug: "cctv",
    name: "CCTV & Security Surveillance Systems",
    description: "DVR/NVR hard drive data recovery, infrared night vision sensor repair, coaxial/CAT6 cabling, and remote view setup.",
    displayOrder: 5,
    active: true,
  },
  "installation-setup": {
    id: "cat-installation",
    slug: "installation-setup",
    name: "Custom Technical Installations",
    description: "Acoustic audio wiring, 5.1/7.1 home theater setups, continuous studio lighting rigging, and heavy-duty TV mounting.",
    displayOrder: 6,
    active: true,
  },
};

export default function CategoryDetailPage() {
  const params = useParams();
  const slug = params?.categorySlug as string;

  const [category, setCategory] = useState<ServiceCategory | null>(null);
  const [loading, setLoading] = useState(true);

  const commonIssuesMap: Record<string, string[]> = {
    camera: [
      "Sensor cleaning & dust spots removal",
      "Autofocus mechanism failure / hunting",
      "Shutter blade error / ERR message",
      "LCD / EVF display glitch or black screen",
      "Battery drain or power circuitry fault",
      "SD / CFexpress card slot repair",
    ],
    lens: [
      "Internal optical fungus & haze cleaning",
      "Aperture ring jammed or iris ribbon cable torn",
      "Image stabilization (IS/VR/OS) motor failure",
      "Zoom ring rubber replacement & barrel alignment",
      "Bayonet mount replacement",
    ],
    drone: [
      "Gimbal overload or ribbon cable break",
      "Motor desync / ESC board burn",
      "Obstacle avoidance sensor error",
      "Firmware crash & compass calibration failure",
      "Shell / arm replacement",
    ],
    cctv: [
      "DVR / NVR hard disk read error",
      "No video signal on monitor / channel black",
      "Infrared night vision LED burnout",
      "PTZ camera motor rotation failure",
      "Coaxial / CAT6 cabling diagnostics",
    ],
    tv: [
      "Sound working but screen is black (Backlight failure)",
      "Horizontal / vertical lines on display",
      "TV not turning on / red standby light blinking",
      "HDMI port damaged / no input signal",
      "Motherboard or power supply board fault",
    ],
    "installation-setup": [
      'Wall mounting for 32" to 85" Smart/OLED TVs',
      "Home theater 5.1 / 7.1 audio setup and hidden wiring",
      "CCTV multi-camera commercial installation",
      "Studio continuous video lighting rigging",
      "Custom appliance electrical testing",
    ],
  };

  useEffect(() => {
    async function loadCategory() {
      try {
        const q = query(collection(db, "serviceCategories"), where("slug", "==", slug));
        const snap = await getDocs(q);
        if (!snap.empty) {
          const doc = snap.docs[0];
          setCategory({ id: doc.id, ...doc.data() } as ServiceCategory);
        } else if (DEFAULT_CATEGORIES[slug]) {
          setCategory(DEFAULT_CATEGORIES[slug]);
        }
      } catch (err) {
        console.warn("Using fallback category:", err);
        if (DEFAULT_CATEGORIES[slug]) {
          setCategory(DEFAULT_CATEGORIES[slug]);
        }
      } finally {
        setLoading(false);
      }
    }
    loadCategory();
  }, [slug]);

  const issues = commonIssuesMap[slug] || [
    "General hardware diagnosis and repair",
    "Power issues and circuit inspection",
    "Physical damage or replacement parts",
    "Routine preventative servicing",
  ];

  const renderIcon = () => {
    switch (slug) {
      case "camera":
        return <Camera size={26} />;
      case "lens":
        return <Aperture size={26} />;
      case "drone":
        return <Wrench size={26} />;
      case "tv":
        return <Tv size={26} />;
      case "cctv":
        return <ShieldCheck size={26} />;
      case "installation-setup":
        return <Sliders size={26} />;
      default:
        return <Wrench size={26} />;
    }
  };

  if (loading) {
    return (
      <div className="container" style={{ padding: "4rem 1.25rem", textAlign: "center", color: "#64748B" }}>
        Loading category details...
      </div>
    );
  }

  if (!category) {
    return (
      <div className="container" style={{ padding: "4rem 1.25rem", textAlign: "center" }}>
        <h2 style={{ fontSize: "1.5rem", fontWeight: 700, marginBottom: "0.5rem" }}>Category Not Found</h2>
        <p style={{ color: "#64748B", marginBottom: "1.5rem" }}>
          The requested service category could not be located.
        </p>
        <Link href="/services" className="btn btn-secondary">
          <ArrowLeft size={16} /> Back to All Services
        </Link>
      </div>
    );
  }

  return (
    <div style={{ backgroundColor: "#F8FAFC", minHeight: "100vh", padding: "2.5rem 1.25rem 5rem" }}>
      <div className="container">
        <Link
          href="/services"
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: "0.4rem",
            color: "#64748B",
            fontSize: "0.88rem",
            fontWeight: 500,
            textDecoration: "none",
            marginBottom: "1.75rem",
          }}
        >
          <ArrowLeft size={16} /> All Services
        </Link>

        <div style={{ display: "grid", gridTemplateColumns: "1fr 360px", gap: "2.5rem", alignItems: "start" }}>
          <div>
            <div style={{ display: "flex", alignItems: "center", gap: "0.75rem", marginBottom: "0.75rem" }}>
              <div
                style={{
                  width: "44px",
                  height: "44px",
                  borderRadius: "10px",
                  backgroundColor: "#FFF1E6",
                  color: "var(--color-primary)",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                }}
              >
                {renderIcon()}
              </div>

              <span
                style={{
                  fontSize: "0.8rem",
                  fontWeight: 700,
                  textTransform: "uppercase",
                  color: "#C9570E",
                  backgroundColor: "#FFF1E6",
                  padding: "0.25rem 0.65rem",
                  borderRadius: "4px",
                }}
              >
                Janakpur Technical Service
              </span>
            </div>

            <h1
              style={{
                fontSize: "clamp(1.85rem, 3.2vw, 2.35rem)",
                fontWeight: 800,
                color: "#0F172A",
                marginBottom: "0.75rem",
                letterSpacing: "-0.02em",
              }}
            >
              {category.name} Repair & Calibration
            </h1>

            <p style={{ color: "#475569", fontSize: "1.05rem", lineHeight: 1.6, marginBottom: "2rem" }}>
              {category.description}
            </p>

            {/* Pricing Policy Box */}
            <div
              style={{
                backgroundColor: "#FFFFFF",
                border: "1px solid #CBD5E1",
                borderRadius: "10px",
                padding: "1.25rem 1.5rem",
                marginBottom: "2.25rem",
                display: "flex",
                alignItems: "flex-start",
                gap: "0.85rem",
              }}
            >
              <CheckCircle2 size={22} style={{ color: "#16A34A", flexShrink: 0, marginTop: "2px" }} />
              <div style={{ fontSize: "0.88rem", color: "#334155", lineHeight: 1.55 }}>
                <strong style={{ color: "#0F172A" }}>Pricing Transparency:</strong>{" "}
                {REPAIR_PRICE_NOTICE} Initial bench inspection in our Janakpur workshop is 100% free. You receive an itemized quote before any repair proceeds.
              </div>
            </div>

            <h3 style={{ fontSize: "1.25rem", fontWeight: 700, color: "#0F172A", marginBottom: "1rem" }}>
              Frequently Diagnosed Faults & Bench Tasks
            </h3>

            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))", gap: "0.75rem", marginBottom: "2.5rem" }}>
              {issues.map((issue, idx) => (
                <div
                  key={idx}
                  style={{
                    padding: "0.85rem 1rem",
                    backgroundColor: "#FFFFFF",
                    border: "1px solid #E2E8F0",
                    borderRadius: "8px",
                    fontSize: "0.88rem",
                    color: "#334155",
                    display: "flex",
                    alignItems: "center",
                    gap: "0.6rem",
                  }}
                >
                  <div style={{ width: "6px", height: "6px", borderRadius: "50%", backgroundColor: "var(--color-primary)", flexShrink: 0 }} />
                  <span>{issue}</span>
                </div>
              ))}
            </div>

            <div style={{ backgroundColor: "#FFFFFF", border: "1px solid #E2E8F0", borderRadius: "10px", padding: "1.5rem" }}>
              <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", color: "#16A34A", marginBottom: "0.5rem" }}>
                <Shield size={18} />
                <h4 style={{ fontSize: "1.05rem", fontWeight: 700, color: "#0F172A", margin: 0 }}>
                  Sharma Video Care Diagnostic Guarantee
                </h4>
              </div>
              <p style={{ fontSize: "0.88rem", color: "#64748B", lineHeight: 1.6, margin: 0 }}>
                Every repair job uses verified OEM or top-grade replacement components. Replaced parts carry an unconditional 90-day warranty. If the fault recurs, we service it at zero cost.
              </p>
            </div>
          </div>

          {/* Booking Card Sidebar */}
          <div
            style={{
              backgroundColor: "#FFFFFF",
              border: "1px solid #E2E8F0",
              borderRadius: "12px",
              padding: "1.75rem",
              boxShadow: "0 4px 16px rgba(15, 23, 42, 0.05)",
              position: "sticky",
              top: "90px",
            }}
          >
            <h3 style={{ fontSize: "1.2rem", fontWeight: 700, color: "#0F172A", marginBottom: "0.5rem" }}>
              Book Free Inspection
            </h3>
            <p style={{ fontSize: "0.85rem", color: "#64748B", lineHeight: 1.5, marginBottom: "1.5rem" }}>
              Drop off your equipment at our Janakpur center or request courier dispatch pickup.
            </p>

            <div style={{ display: "flex", flexDirection: "column", gap: "0.75rem", marginBottom: "1.5rem", fontSize: "0.84rem", color: "#334155" }}>
              <div style={{ display: "flex", alignItems: "center", gap: "0.5rem" }}>
                <FileCheck2 size={16} color="var(--color-primary)" />
                <span>Zero Inspection Fee</span>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: "0.5rem" }}>
                <Clock size={16} color="var(--color-primary)" />
                <span>Fast 24-48h Diagnostic Report</span>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: "0.5rem" }}>
                <Shield size={16} color="var(--color-primary)" />
                <span>90-Day Parts Warranty</span>
              </div>
            </div>

            <Link
              href={`/services/request?category=${category.slug}&title=${encodeURIComponent(category.name)}`}
              className="btn btn-primary"
              style={{ width: "100%", padding: "0.75rem", fontSize: "0.92rem", textDecoration: "none", marginBottom: "0.75rem" }}
            >
              <span>Continue to Booking</span>
              <ArrowRight size={16} />
            </Link>

            <a
              href="https://wa.me/9779854022200"
              target="_blank"
              rel="noopener noreferrer"
              className="btn btn-secondary"
              style={{ width: "100%", padding: "0.65rem", fontSize: "0.86rem", textDecoration: "none", color: "#0F172A" }}
            >
              <MessageCircle size={16} color="#25D366" />
              <span>Ask Technician on WhatsApp</span>
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
