"use client";

import React from "react";
import Link from "next/link";
import { Logo } from "./Logo";

export const Footer: React.FC = () => {
  return (
    <footer
      style={{
        background: "#140F0B",
        color: "#E2DDD6",
        borderTop: "1px solid #261F1A",
        paddingTop: "3.5rem",
        paddingBottom: "2rem",
      }}
    >
      <div
        className="container"
        style={{
          maxWidth: "1280px",
          margin: "0 auto",
          padding: "0 1.5rem",
        }}
      >
        {/* Main 4-Column Grid */}
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(230px, 1fr))",
            gap: "2.5rem",
            marginBottom: "3rem",
          }}
        >
          {/* Column 1: Brand & Overview */}
          <div>
            <div style={{ marginBottom: "1.2rem" }}>
              <Logo size={40} inverted={true} showSubtitle={true} />
            </div>
            <p
              style={{
                fontSize: "0.88rem",
                color: "#9C948A",
                marginBottom: "1.25rem",
                lineHeight: 1.6,
              }}
            >
              Nepal&apos;s trusted destination for professional electronics repair,
              appliance servicing, genuine tech equipment, and certified pre-owned
              devices with physical diagnosis in Janakpur and nationwide doorstep
              delivery.
            </p>
            <div
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
                fontSize: "0.78rem",
                fontWeight: 700,
                color: "#FF7A1A",
                letterSpacing: "1px",
                textTransform: "uppercase",
              }}
            >
              <span>REPAIR</span>
              <span>•</span>
              <span>BUY</span>
              <span>•</span>
              <span>INSTALL</span>
              <span>•</span>
              <span>MAINTAIN</span>
            </div>
          </div>

          {/* Column 2: Repair Services */}
          <div>
            <h4
              style={{
                color: "#FFFFFF",
                fontSize: "0.92rem",
                fontWeight: 700,
                marginBottom: "1.1rem",
                textTransform: "uppercase",
                letterSpacing: "0.06em",
              }}
            >
              Repair Services
            </h4>
            <ul
              style={{
                listStyle: "none",
                fontSize: "0.88rem",
                color: "#A8A196",
                display: "flex",
                flexDirection: "column",
                gap: "0.65rem",
                padding: 0,
                margin: 0,
              }}
            >
              {[
                { label: "AC Repair & Gas Refill", href: "/services/request?service=ac" },
                { label: "Washing Machine Maintenance", href: "/services/request?service=washing_machine" },
                { label: "TV Panel & Board Repair", href: "/services/request?service=tv" },
                { label: "DSLR Camera & Lens Service", href: "/services/request?service=camera" },
                { label: "MacBook & Laptop Servicing", href: "/services/request?service=laptop" },
                { label: "CCTV Installation & Setup", href: "/services/request?service=cctv" },
                { label: "Custom Repair Inquiry", href: "/services/custom" },
              ].map((item, idx) => (
                <li key={idx}>
                  <Link
                    href={item.href}
                    style={{
                      color: "#A8A196",
                      textDecoration: "none",
                      transition: "color 0.15s ease",
                    }}
                    onMouseEnter={(e) => (e.currentTarget.style.color = "#FF7A1A")}
                    onMouseLeave={(e) => (e.currentTarget.style.color = "#A8A196")}
                  >
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Column 3: Shop & Catalog */}
          <div>
            <h4
              style={{
                color: "#FFFFFF",
                fontSize: "0.92rem",
                fontWeight: 700,
                marginBottom: "1.1rem",
                textTransform: "uppercase",
                letterSpacing: "0.06em",
              }}
            >
              Shop &amp; Equipment
            </h4>
            <ul
              style={{
                listStyle: "none",
                fontSize: "0.88rem",
                color: "#A8A196",
                display: "flex",
                flexDirection: "column",
                gap: "0.65rem",
                padding: 0,
                margin: 0,
              }}
            >
              {[
                { label: "Cameras & Photography Equipment", href: "/shop" },
                { label: "Laptops & Computing", href: "/shop" },
                { label: "Surveillance & Security Systems", href: "/shop" },
                { label: "Certified Pre-Owned Devices", href: "/used" },
                { label: "CCTV & Security Solutions", href: "/services" },
                { label: "Track Active Order", href: "/orders" },
              ].map((item, idx) => (
                <li key={idx}>
                  <Link
                    href={item.href}
                    style={{
                      color: "#A8A196",
                      textDecoration: "none",
                      transition: "color 0.15s ease",
                    }}
                    onMouseEnter={(e) => (e.currentTarget.style.color = "#FF7A1A")}
                    onMouseLeave={(e) => (e.currentTarget.style.color = "#A8A196")}
                  >
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Column 4: Contact & Janakpur Hub */}
          <div>
            <h4
              style={{
                color: "#FFFFFF",
                fontSize: "0.92rem",
                fontWeight: 700,
                marginBottom: "1.1rem",
                textTransform: "uppercase",
                letterSpacing: "0.06em",
              }}
            >
              Janakpur Center &amp; Support
            </h4>
            <div
              style={{
                display: "flex",
                flexDirection: "column",
                gap: "0.8rem",
                fontSize: "0.88rem",
                color: "#A8A196",
              }}
            >
              <div>
                <div style={{ color: "#E0DBD2", fontWeight: 650 }}>Service Center:</div>
                <div style={{ fontSize: "0.82rem", color: "#8E8880", marginTop: "2px" }}>
                  Station Road (Near Ramanand Chowk), Janakpurdham, Nepal
                </div>
              </div>

              <div>
                <div style={{ color: "#E0DBD2", fontWeight: 650 }}>Working Hours:</div>
                <div style={{ fontSize: "0.82rem", color: "#8E8880", marginTop: "2px" }}>
                  Sun – Fri: 9:00 AM – 7:30 PM (Sat: On-call)
                </div>
              </div>

              <div>
                <div style={{ color: "#E0DBD2", fontWeight: 650 }}>Hotlines:</div>
                <div style={{ fontSize: "0.82rem", color: "#FF7A1A", marginTop: "2px", fontWeight: 700 }}>
                  +977 985-4022200 / 041-520000
                </div>
              </div>

              <div style={{ marginTop: "4px" }}>
                <a
                  href="https://wa.me/9779854022200"
                  target="_blank"
                  rel="noopener noreferrer"
                  style={{
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "6px",
                    background: "rgba(37, 211, 102, 0.12)",
                    border: "1px solid rgba(37, 211, 102, 0.3)",
                    color: "#25D366",
                    padding: "6px 12px",
                    borderRadius: "6px",
                    fontSize: "0.82rem",
                    fontWeight: 700,
                    textDecoration: "none",
                  }}
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12.031 6.172c-3.181 0-5.767 2.586-5.768 5.766-.001 1.298.38 2.27 1.019 3.287l-.582 2.128 2.182-.573c.978.58 1.911.928 3.145.929 3.178 0 5.767-2.587 5.768-5.766.001-3.187-2.575-5.77-5.764-5.771zm3.392 8.244c-.144.405-.837.774-1.17.824-.312.045-.694.067-1.111-.067-.27-.086-.606-.217-1.042-.406-1.849-.803-3.048-2.67-3.14-2.793-.093-.123-.745-.992-.745-1.892s.472-1.343.64-1.528c.168-.186.368-.232.49-.232.123 0 .246.002.353.007.113.006.262-.043.411.314.154.37.525 1.282.571 1.376.046.094.077.203.015.326-.062.123-.092.2-.184.308-.093.108-.194.24-.277.323-.093.093-.19.195-.082.38.108.185.48 1.155 1.34 1.92 1.107.986 2.04 1.293 2.33 1.416.29.123.46.108.63-.077.17-.185.733-.852.928-1.144.195-.292.39-.244.656-.145.267.098 1.696.8 1.988.946.292.146.487.218.558.341.071.123.071.714-.073 1.119z" />
                  </svg>
                  <span>WhatsApp Live Support</span>
                </a>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom Trust & Compliance Bar */}
        <div
          style={{
            borderTop: "1px solid #231D18",
            paddingTop: "1.5rem",
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            flexWrap: "wrap",
            gap: "1rem",
            fontSize: "0.8rem",
            color: "#7E776F",
          }}
        >
          <div>
            © {new Date().getFullYear()} <strong>Sharma Video Care</strong>. All rights reserved. Station Road, Janakpurdham, Nepal.
          </div>

          <div style={{ display: "flex", alignItems: "center", gap: "1.2rem", flexWrap: "wrap" }}>
            <Link
              href="/terms"
              style={{ color: "#7E776F", textDecoration: "none" }}
              onMouseEnter={(e) => (e.currentTarget.style.color = "#E2DDD6")}
              onMouseLeave={(e) => (e.currentTarget.style.color = "#7E776F")}
            >
              Terms of Service
            </Link>
            <span>•</span>
            <Link
              href="/privacy"
              style={{ color: "#7E776F", textDecoration: "none" }}
              onMouseEnter={(e) => (e.currentTarget.style.color = "#E2DDD6")}
              onMouseLeave={(e) => (e.currentTarget.style.color = "#7E776F")}
            >
              Privacy Policy
            </Link>
            <span>•</span>
            <Link
              href="/policies"
              style={{ color: "#7E776F", textDecoration: "none" }}
              onMouseEnter={(e) => (e.currentTarget.style.color = "#E2DDD6")}
              onMouseLeave={(e) => (e.currentTarget.style.color = "#7E776F")}
            >
              90-Day Warranty Guidelines
            </Link>
          </div>
        </div>
      </div>
    </footer>
  );
};
