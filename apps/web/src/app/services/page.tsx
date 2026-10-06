"use client";

import React, { useState, useMemo } from "react";
import Link from "next/link";
import Image from "next/image";
import {
  ArrowRight,
  PlusCircle,
  Clock,
  Shield,
  Search,
  Phone,
  MessageCircle,
  FileCheck2,
  Sparkles,
  CheckCircle2,
  Wrench,
} from "lucide-react";

interface ServiceCategoryCard {
  id: string;
  slug: string;
  name: string;
  shortDesc: string;
  image: string;
  turnaround: string;
  tags: string[];
  isComingSoon?: boolean;
}

const SERVICE_CARDS: ServiceCategoryCard[] = [
  {
    id: "cat-camera",
    slug: "camera",
    name: "Cameras & DSLRs / Mirrorless",
    shortDesc: "Sensor swab cleaning, shutter rebuilds, EVF/LCD repairs & circuit diagnostics.",
    image: "/images/services/camera_repair.jpg",
    turnaround: "Same-Day to 48h",
    tags: ["Sensor Clean", "Shutter ERR", "Board Repair"],
  },
  {
    id: "cat-lens",
    slug: "lens",
    name: "Optical Lenses & Zoom Barrels",
    shortDesc: "Ultrasonic fungus removal, aperture iris ribbon fix, autofocus sync & mount alignment.",
    image: "/images/services/lens_repair.jpg",
    turnaround: "24 – 72 Hours",
    tags: ["Fungus Cleaning", "Iris Ribbon", "AF Motor Sync"],
  },
  {
    id: "cat-drone",
    slug: "drone",
    name: "Drones & Aerial Gimbal Systems",
    shortDesc: "Gimbal ribbon replacement, motor ESC board sync & crash damage shell repair.",
    image: "/images/services/drone_repair.jpg",
    turnaround: "2 – 4 Days",
    tags: ["Gimbal Overload", "ESC Sync", "Arm Rebuild"],
  },
  {
    id: "cat-plumbing",
    slug: "plumbing",
    name: "Plumbing & Sanitary Services",
    shortDesc: "Pipeline leak detection, bathroom fittings, water pump repair & drainage line clearing in Janakpur.",
    image: "/images/services/cctv_repair.jpg",
    turnaround: "Launching Soon",
    tags: ["Pipe Leaks", "Sanitary Fittings", "Pump Repair"],
    isComingSoon: true,
  },
  {
    id: "cat-furniture",
    slug: "furniture",
    name: "Furniture & Carpentry Works",
    shortDesc: "Wooden furniture assembly, modular kitchen fitting, sofa upholstery & door lock repair.",
    image: "/images/services/installation_repair.jpg",
    turnaround: "Launching Soon",
    tags: ["Wood Carpentry", "Sofa Repair", "Modular Assembly"],
    isComingSoon: true,
  },
  {
    id: "cat-tv",
    slug: "tv",
    name: "Smart TVs & 4K OLED Displays",
    shortDesc: "LED backlight strip replacement, motherboard diagnostics & display panel fixes.",
    image: "/images/services/tv_repair.jpg",
    turnaround: "Same-Day / Home Visit",
    tags: ["Black Screen", "LED Strips", "Motherboard"],
  },
  {
    id: "cat-cctv",
    slug: "cctv",
    name: "CCTV & Security Surveillance",
    shortDesc: "DVR/NVR storage recovery, IP camera reconnection & night-vision IR servicing.",
    image: "/images/services/cctv_repair.jpg",
    turnaround: "Same-Day Inspection",
    tags: ["HDD Recovery", "Offline Cameras", "Night Vision"],
  },
  {
    id: "cat-installation",
    slug: "installation-setup",
    name: "Custom Technical Installations",
    shortDesc: "Home theater 5.1/7.1 acoustic setup, studio lighting rigging & heavy TV wall mounting.",
    image: "/images/services/installation_repair.jpg",
    turnaround: "By Appointment",
    tags: ["Home Theater", "Studio Rigging", "Wall Mounts"],
  },
];

export default function ServicesPage() {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedFilter, setSelectedFilter] = useState("all");

  const filteredServices = useMemo(() => {
    return SERVICE_CARDS.filter((item) => {
      const matchesSearch =
        item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.shortDesc.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.tags.some((t) => t.toLowerCase().includes(searchQuery.toLowerCase()));

      if (selectedFilter === "all") return matchesSearch;
      return matchesSearch && item.slug === selectedFilter;
    });
  }, [searchQuery, selectedFilter]);

  return (
    <div style={{ backgroundColor: "#F8FAFC", minHeight: "100vh", padding: "3rem 1.25rem 5rem" }}>
      <div className="container" style={{ maxWidth: "1160px", margin: "0 auto" }}>
        
        {/* Punchy Visual Hero Header */}
        <div style={{ textAlign: "center", maxWidth: "760px", margin: "0 auto 2.5rem auto" }}>
          <div
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "0.45rem",
              backgroundColor: "#FFF1E6",
              color: "#C9570E",
              padding: "0.3rem 0.75rem",
              borderRadius: "6px",
              fontSize: "0.8rem",
              fontWeight: 700,
              textTransform: "uppercase",
              letterSpacing: "0.06em",
              marginBottom: "0.85rem",
            }}
          >
            <span>Janakpur Central Technical Lab</span>
          </div>

          <h1
            style={{
              fontSize: "clamp(2.1rem, 4vw, 3rem)",
              fontWeight: 800,
              color: "#0F172A",
              lineHeight: 1.15,
              letterSpacing: "-0.025em",
              marginBottom: "0.65rem",
            }}
          >
            What device can we fix for you?
          </h1>

          <p style={{ color: "#64748B", fontSize: "1.05rem", lineHeight: 1.5, margin: "0 auto 1.75rem auto" }}>
            Select your hardware category for free bench diagnostics in Janakpur and courier pickup nationwide.
          </p>

          {/* 3-Step Simple Process Strip */}
          <div
            style={{
              display: "inline-flex",
              alignItems: "center",
              justifyContent: "center",
              flexWrap: "wrap",
              gap: "1.5rem",
              padding: "0.75rem 1.25rem",
              backgroundColor: "#FFFFFF",
              borderRadius: "10px",
              border: "1px solid #E2E8F0",
              boxShadow: "0 2px 8px rgba(15, 23, 42, 0.04)",
              fontSize: "0.84rem",
              fontWeight: 600,
              color: "#334155",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: "0.4rem" }}>
              <span style={{ width: "20px", height: "20px", borderRadius: "50%", backgroundColor: "#FFF1E6", color: "#C9570E", display: "inline-flex", alignItems: "center", justifyContent: "center", fontSize: "0.75rem", fontWeight: 700 }}>1</span>
              <span>Select Device</span>
            </div>
            <span style={{ color: "#CBD5E1" }}>→</span>
            <div style={{ display: "flex", alignItems: "center", gap: "0.4rem" }}>
              <span style={{ width: "20px", height: "20px", borderRadius: "50%", backgroundColor: "#FFF1E6", color: "#C9570E", display: "inline-flex", alignItems: "center", justifyContent: "center", fontSize: "0.75rem", fontWeight: 700 }}>2</span>
              <span>0 NPR Free Inspection</span>
            </div>
            <span style={{ color: "#CBD5E1" }}>→</span>
            <div style={{ display: "flex", alignItems: "center", gap: "0.4rem" }}>
              <span style={{ width: "20px", height: "20px", borderRadius: "50%", backgroundColor: "#EAF6EE", color: "#16A34A", display: "inline-flex", alignItems: "center", justifyContent: "center", fontSize: "0.75rem", fontWeight: 700 }}>3</span>
              <span>90-Day Warranty Repair</span>
            </div>
          </div>
        </div>

        {/* Filter Chips & Search Bar */}
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            gap: "0.85rem",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: "2rem",
          }}
        >
          {/* Quick Filters */}
          <div style={{ display: "flex", flexWrap: "wrap", gap: "0.4rem" }}>
            {[
              { id: "all", label: "All Services" },
              { id: "camera", label: "Cameras" },
              { id: "lens", label: "Lenses" },
              { id: "drone", label: "Drones" },
              { id: "plumbing", label: "Plumber (Soon)" },
              { id: "furniture", label: "Furniture (Soon)" },
              { id: "tv", label: "Smart TVs" },
              { id: "cctv", label: "CCTV" },
              { id: "installation-setup", label: "Installations" },
            ].map((tab) => (
              <button
                key={tab.id}
                type="button"
                onClick={() => setSelectedFilter(tab.id)}
                style={{
                  padding: "0.45rem 0.85rem",
                  fontSize: "0.84rem",
                  fontWeight: 600,
                  borderRadius: "6px",
                  border: "1px solid",
                  borderColor: selectedFilter === tab.id ? "var(--color-primary)" : "#E2E8F0",
                  backgroundColor: selectedFilter === tab.id ? "var(--color-primary)" : "#FFFFFF",
                  color: selectedFilter === tab.id ? "#FFFFFF" : "#475569",
                  cursor: "pointer",
                  transition: "all 0.15s ease",
                }}
              >
                {tab.label}
              </button>
            ))}
          </div>

          {/* Search Bar */}
          <div style={{ position: "relative", minWidth: "260px" }}>
            <input
              type="text"
              placeholder="Search devices or issues (e.g. sensor, iris)..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              style={{
                width: "100%",
                height: "38px",
                padding: "0 1rem 0 2.25rem",
                fontSize: "0.85rem",
                borderRadius: "8px",
                border: "1px solid #CBD5E1",
                backgroundColor: "#FFFFFF",
                color: "#0F172A",
                outline: "none",
                boxSizing: "border-box",
              }}
            />
            <Search
              size={15}
              style={{
                position: "absolute",
                left: "10px",
                top: "50%",
                transform: "translateY(-50%)",
                color: "#94A3B8",
              }}
            />
          </div>
        </div>

        {/* Visual Hardware Grid (Photos + Clean Details) */}
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(330px, 1fr))",
            gap: "1.75rem",
            marginBottom: "3.5rem",
          }}
        >
          {filteredServices.map((item) => (
            <div
              key={item.id}
              style={{
                backgroundColor: "#FFFFFF",
                border: "1px solid #E2E8F0",
                borderRadius: "14px",
                overflow: "hidden",
                display: "flex",
                flexDirection: "column",
                boxShadow: "0 4px 16px -2px rgba(15, 23, 42, 0.05)",
                transition: "transform 0.15s ease, box-shadow 0.15s ease",
              }}
            >
              {/* Photo Area with Turnaround Badge */}
              <div style={{ position: "relative", width: "100%", height: "200px", backgroundColor: "#0F172A" }}>
                <Image
                  src={item.image}
                  alt={item.name}
                  fill
                  sizes="(max-width: 768px) 100vw, 360px"
                  style={{ objectFit: "cover" }}
                />
                
                {/* Turnaround Badge over photo */}
                <div
                  style={{
                    position: "absolute",
                    top: "12px",
                    right: "12px",
                    backgroundColor: item.isComingSoon ? "rgba(245, 158, 11, 0.95)" : "rgba(15, 23, 42, 0.85)",
                    backdropFilter: "blur(6px)",
                    color: item.isComingSoon ? "#78350F" : "#FFFFFF",
                    padding: "0.3rem 0.65rem",
                    borderRadius: "6px",
                    fontSize: "0.74rem",
                    fontWeight: 700,
                    display: "flex",
                    alignItems: "center",
                    gap: "0.35rem",
                  }}
                >
                  <Clock size={12} color={item.isComingSoon ? "#78350F" : "#FDBA74"} />
                  <span>{item.turnaround}</span>
                </div>
              </div>

              {/* Card Body */}
              <div style={{ padding: "1.5rem", flex: 1, display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
                <div>
                  <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "0.4rem" }}>
                    <h3
                      style={{
                        fontSize: "1.2rem",
                        fontWeight: 700,
                        color: "#0F172A",
                        margin: 0,
                        lineHeight: 1.3,
                      }}
                    >
                      {item.name}
                    </h3>
                    {item.isComingSoon && (
                      <span
                        style={{
                          background: "#FEF3C7",
                          color: "#92400E",
                          fontSize: "10px",
                          fontWeight: 750,
                          padding: "2px 6px",
                          borderRadius: "4px",
                          border: "1px solid #FDE68A",
                        }}
                      >
                        COMING SOON
                      </span>
                    )}
                  </div>

                  <p
                    style={{
                      fontSize: "0.88rem",
                      color: "#64748B",
                      lineHeight: 1.5,
                      marginBottom: "1rem",
                    }}
                  >
                    {item.shortDesc}
                  </p>

                  {/* Clean Tags */}
                  <div style={{ display: "flex", flexWrap: "wrap", gap: "0.35rem", marginBottom: "1.5rem" }}>
                    {item.tags.map((tag) => (
                      <span
                        key={tag}
                        style={{
                          fontSize: "0.74rem",
                          backgroundColor: "#F1F5F9",
                          color: "#334155",
                          padding: "0.2rem 0.55rem",
                          borderRadius: "4px",
                          fontWeight: 500,
                        }}
                      >
                        #{tag}
                      </span>
                    ))}
                  </div>
                </div>

                {/* Direct Action Buttons */}
                <div style={{ borderTop: "1px solid #F1F5F9", paddingTop: "1.1rem", display: "flex", alignItems: "center", gap: "0.65rem" }}>
                  {item.isComingSoon ? (
                    <a
                      href={`https://wa.me/9779854022200?text=${encodeURIComponent(`Hello Sharma Video Care, I am interested in your upcoming ${item.name} in Janakpur.`)}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="btn btn-primary"
                      style={{
                        flex: 1,
                        height: "40px",
                        fontSize: "0.86rem",
                        textDecoration: "none",
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "center",
                        gap: "0.4rem",
                        backgroundColor: "#E86F1C",
                        borderColor: "#D96010",
                      }}
                    >
                      <Sparkles size={14} />
                      <span>Pre-Register / Inquire</span>
                    </a>
                  ) : (
                    <>
                      <Link
                        href={`/services/request?category=${item.slug}&title=${encodeURIComponent(item.name)}`}
                        className="btn btn-primary"
                        style={{
                          flex: 1,
                          height: "40px",
                          fontSize: "0.88rem",
                          textDecoration: "none",
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                          gap: "0.4rem",
                        }}
                      >
                        <span>Book Inspection</span>
                        <ArrowRight size={15} />
                      </Link>

                      <Link
                        href={`/services/${item.slug}`}
                        className="btn btn-secondary"
                        style={{
                          height: "40px",
                          fontSize: "0.84rem",
                          textDecoration: "none",
                          padding: "0 0.85rem",
                          color: "#475569",
                        }}
                      >
                        Details
                      </Link>
                    </>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Coming Soon Services Spotlight Banner */}
        <div
          id="coming-soon"
          style={{
            background: "linear-gradient(135deg, #FFFBEB 0%, #FEF3C7 100%)",
            border: "1px solid #FDE68A",
            borderRadius: "16px",
            padding: "2rem",
            marginBottom: "3.5rem",
            boxShadow: "0 4px 20px -2px rgba(245, 158, 11, 0.08)",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "0.5rem" }}>
            <span
              style={{
                background: "#F59E0B",
                color: "#FFFFFF",
                fontSize: "11px",
                fontWeight: 800,
                padding: "3px 8px",
                borderRadius: "9999px",
                letterSpacing: "0.06em",
                textTransform: "uppercase",
              }}
            >
              Expansion In Janakpur
            </span>
            <span style={{ fontSize: "13px", fontWeight: 700, color: "#92400E" }}>
              Launching Very Soon
            </span>
          </div>

          <h3
            style={{
              fontSize: "1.45rem",
              fontWeight: 800,
              color: "#78350F",
              margin: "0 0 0.5rem 0",
              letterSpacing: "-0.015em",
            }}
          >
            Expanding Home &amp; Facility Care: Professional Plumber &amp; Furniture Works
          </h3>

          <p
            style={{
              fontSize: "0.92rem",
              color: "#92400E",
              lineHeight: 1.6,
              maxWidth: "760px",
              margin: "0 0 1.5rem 0",
            }}
          >
            Sharma Video Care is onboarding verified licensed plumbers and master carpenters in Janakpurdham. Get the same transparent pricing, background-checked technicians, and warranty-backed service for your home sanitary and woodwork.
          </p>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
              gap: "1.25rem",
              marginBottom: "1.5rem",
            }}
          >
            {/* Plumber Service Card */}
            <div
              id="plumbing"
              style={{
                background: "#FFFFFF",
                borderRadius: "12px",
                border: "1px solid #FDE68A",
                padding: "1.25rem",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "10px", marginBottom: "0.75rem" }}>
                <div
                  style={{
                    width: "40px",
                    height: "40px",
                    borderRadius: "10px",
                    background: "#EFF6FF",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    color: "#2563EB",
                    flexShrink: 0,
                  }}
                >
                  <Wrench size={20} />
                </div>
                <div>
                  <h4 style={{ fontSize: "1.05rem", fontWeight: 750, color: "#0F172A", margin: 0 }}>
                    Professional Plumbing
                  </h4>
                  <span style={{ fontSize: "11px", color: "#2563EB", fontWeight: 650 }}>
                    Bathroom, Kitchen &amp; Water Systems
                  </span>
                </div>
              </div>
              <ul style={{ fontSize: "12.5px", color: "#475569", lineHeight: 1.6, margin: 0, paddingLeft: "1.1rem" }}>
                <li>Concealed pipe leak diagnosis &amp; high-pressure testing</li>
                <li>Water motor pump installation &amp; capacitor repairs</li>
                <li>Overhead water tank automatic sensor &amp; plumbing lines</li>
                <li>Sanitary commode, taps, showers &amp; geyser fittings</li>
              </ul>
            </div>

            {/* Furniture Service Card */}
            <div
              id="furniture"
              style={{
                background: "#FFFFFF",
                borderRadius: "12px",
                border: "1px solid #FDE68A",
                padding: "1.25rem",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "10px", marginBottom: "0.75rem" }}>
                <div
                  style={{
                    width: "40px",
                    height: "40px",
                    borderRadius: "10px",
                    background: "#FEF3C7",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    color: "#D97706",
                    flexShrink: 0,
                  }}
                >
                  <Sparkles size={20} />
                </div>
                <div>
                  <h4 style={{ fontSize: "1.05rem", fontWeight: 750, color: "#0F172A", margin: 0 }}>
                    Furniture &amp; Carpentry
                  </h4>
                  <span style={{ fontSize: "11px", color: "#D97706", fontWeight: 650 }}>
                    Custom Woodwork &amp; Furniture Fixes
                  </span>
                </div>
              </div>
              <ul style={{ fontSize: "12.5px", color: "#475569", lineHeight: 1.6, margin: 0, paddingLeft: "1.1rem" }}>
                <li>Bed, wardrobe, study table custom design &amp; assembly</li>
                <li>Sofa upholstery foam replacement &amp; fabric tuning</li>
                <li>Modular kitchen cabinet hinges, drawer channels &amp; locks</li>
                <li>Door alignment, hydraulic closer &amp; security mortise locks</li>
              </ul>
            </div>
          </div>

          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", flexWrap: "wrap", gap: "1rem" }}>
            <div style={{ fontSize: "12.5px", color: "#78350F", fontWeight: 600 }}>
              Need urgent plumbing or carpentry assistance in Janakpur ahead of the official rollout?
            </div>
            <a
              href="https://wa.me/9779854022200?text=Hello%20Sharma%20Video%20Care,%20I%20need%20plumber/furniture%20service%20in%20Janakpur."
              target="_blank"
              rel="noopener noreferrer"
              style={{
                background: "#B45309",
                color: "#FFFFFF",
                padding: "8px 16px",
                borderRadius: "8px",
                fontSize: "12.5px",
                fontWeight: 700,
                textDecoration: "none",
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
              }}
            >
              <span>Priority WhatsApp Inquire</span>
              <ArrowRight size={14} />
            </a>
          </div>
        </div>

        {/* WhatsApp & Hotline Quick Bar */}
        <div
          style={{
            backgroundColor: "#FFFFFF",
            border: "1px solid #E2E8F0",
            borderRadius: "12px",
            padding: "1.75rem 2rem",
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            flexWrap: "wrap",
            gap: "1.25rem",
            boxShadow: "0 2px 10px rgba(15, 23, 42, 0.04)",
          }}
        >
          <div>
            <h4 style={{ fontSize: "1.15rem", fontWeight: 700, color: "#0F172A", marginBottom: "0.25rem" }}>
              Have an urgent question or broken device in Janakpur?
            </h4>
            <p style={{ color: "#64748B", fontSize: "0.88rem", margin: 0 }}>
              Send a photo of the fault or error code on WhatsApp for an immediate technician response.
            </p>
          </div>

          <div style={{ display: "flex", gap: "0.75rem", flexWrap: "wrap" }}>
            <a
              href="https://wa.me/9779854022200"
              target="_blank"
              rel="noopener noreferrer"
              className="btn btn-primary"
              style={{
                backgroundColor: "#22c55e",
                borderColor: "#16a34a",
                textDecoration: "none",
                display: "inline-flex",
                alignItems: "center",
                gap: "0.45rem",
              }}
            >
              <MessageCircle size={17} />
              <span>Chat on WhatsApp</span>
            </a>

            <Link
              href="/services/custom"
              className="btn btn-secondary"
              style={{ textDecoration: "none", display: "inline-flex", alignItems: "center", gap: "0.45rem" }}
            >
              <PlusCircle size={16} />
              <span>Custom Project</span>
            </Link>
          </div>
        </div>

      </div>
    </div>
  );
}
