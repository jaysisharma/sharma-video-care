"use client";

import React from "react";
import Link from "next/link";

export const JanakpurHub: React.FC = () => {
  return (
    <section
      style={{
        width: "100%",
        padding: "0 24px 60px 24px",
      }}
    >
      <div
        style={{
          maxWidth: "1280px",
          margin: "0 auto",
        }}
      >
        <div
          style={{
            position: "relative",
            borderRadius: "20px",
            overflow: "hidden",
            background:
              "linear-gradient(135deg, #17110D 0%, #221812 50%, #150E0A 100%)",
            border: "1px solid rgba(255, 255, 255, 0.08)",
            boxShadow: "0 16px 40px rgba(0, 0, 0, 0.16)",
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(320px, 1fr))",
            gap: "36px",
            padding: "40px",
            alignItems: "center",
          }}
        >
          {/* Left Column: Center Details & Actions */}
          <div>
            {/* Kicker */}
            <div
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "8px",
                fontSize: "11px",
                fontWeight: 700,
                letterSpacing: "1.8px",
                textTransform: "uppercase",
                color: "#FF7A1A",
                marginBottom: "12px",
              }}
            >
              <span>JANAKPURDHAM TECH HUB</span>
              <span style={{ opacity: 0.5 }}>•</span>
              <span>DIRECT SUPPORT</span>
            </div>

            {/* Title */}
            <h2
              style={{
                fontSize: "clamp(24px, 2.8vw, 34px)",
                fontWeight: 800,
                color: "#FFFFFF",
                letterSpacing: "-0.02em",
                lineHeight: 1.2,
                margin: "0 0 12px 0",
              }}
            >
              Visit Our Main Service Center
            </h2>

            <p
              style={{
                fontSize: "14px",
                lineHeight: 1.6,
                color: "#B0A9A0",
                margin: "0 0 26px 0",
                maxWidth: "520px",
              }}
            >
              Need immediate repair, hands-on device inspection, or want to
              test certified equipment in person? Visit our Janakpur headquarters
              or reach our master technicians directly.
            </p>

            {/* Info Rows */}
            <div
              style={{
                display: "flex",
                flexDirection: "column",
                gap: "14px",
                marginBottom: "28px",
              }}
            >
              {/* Location */}
              <div style={{ display: "flex", alignItems: "flex-start", gap: "12px" }}>
                <div
                  style={{
                    width: "36px",
                    height: "36px",
                    borderRadius: "10px",
                    background: "rgba(255, 255, 255, 0.06)",
                    border: "1px solid rgba(255, 255, 255, 0.12)",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    flexShrink: 0,
                  }}
                >
                  <svg
                    width="18"
                    height="18"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="#FF7A1A"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  >
                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                    <circle cx="12" cy="10" r="3" />
                  </svg>
                </div>
                <div>
                  <div style={{ fontSize: "14px", fontWeight: 700, color: "#FFFFFF" }}>
                    Station Road (Near Ramanand Chowk)
                  </div>
                  <div style={{ fontSize: "12.5px", color: "#8E8880", marginTop: "2px" }}>
                    Janakpurdham, Dhanusha, Madhesh Province, Nepal
                  </div>
                </div>
              </div>

              {/* Hours */}
              <div style={{ display: "flex", alignItems: "flex-start", gap: "12px" }}>
                <div
                  style={{
                    width: "36px",
                    height: "36px",
                    borderRadius: "10px",
                    background: "rgba(255, 255, 255, 0.06)",
                    border: "1px solid rgba(255, 255, 255, 0.12)",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    flexShrink: 0,
                  }}
                >
                  <svg
                    width="18"
                    height="18"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="#FF7A1A"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  >
                    <circle cx="12" cy="12" r="10" />
                    <polyline points="12 6 12 12 16 14" />
                  </svg>
                </div>
                <div>
                  <div style={{ fontSize: "14px", fontWeight: 700, color: "#FFFFFF" }}>
                    Sunday – Friday: 9:00 AM – 7:30 PM
                  </div>
                  <div style={{ fontSize: "12.5px", color: "#8E8880", marginTop: "2px" }}>
                    Saturday: On-call emergency dispatch available
                  </div>
                </div>
              </div>

              {/* Contact Hotline */}
              <div style={{ display: "flex", alignItems: "flex-start", gap: "12px" }}>
                <div
                  style={{
                    width: "36px",
                    height: "36px",
                    borderRadius: "10px",
                    background: "rgba(255, 255, 255, 0.06)",
                    border: "1px solid rgba(255, 255, 255, 0.12)",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    flexShrink: 0,
                  }}
                >
                  <svg
                    width="18"
                    height="18"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="#FF7A1A"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  >
                    <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
                  </svg>
                </div>
                <div>
                  <div style={{ fontSize: "14px", fontWeight: 700, color: "#FFFFFF" }}>
                    +977 985-4022200 / 041-520000
                  </div>
                  <div style={{ fontSize: "12.5px", color: "#8E8880", marginTop: "2px" }}>
                    Instant phone support &amp; consultation
                  </div>
                </div>
              </div>
            </div>

            {/* Action Buttons */}
            <div
              style={{
                display: "flex",
                alignItems: "center",
                flexWrap: "wrap",
                gap: "12px",
              }}
            >
              {/* WhatsApp Chat */}
              <a
                href="https://wa.me/9779854022200?text=Hello%20Sharma%20Video%20Care%2C%20I%20need%20assistance%20with%20a%20repair%20or%20product."
                target="_blank"
                rel="noopener noreferrer"
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "8px",
                  background: "#25D366",
                  color: "#FFFFFF",
                  padding: "10px 20px",
                  borderRadius: "10px",
                  fontSize: "13.5px",
                  fontWeight: 700,
                  textDecoration: "none",
                  boxShadow: "0 4px 14px rgba(37, 211, 102, 0.25)",
                  transition: "transform 0.15s ease, background 0.15s ease",
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.background = "#20BA5A";
                  e.currentTarget.style.transform = "translateY(-1px)";
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.background = "#25D366";
                  e.currentTarget.style.transform = "translateY(0)";
                }}
              >
                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12.031 6.172c-3.181 0-5.767 2.586-5.768 5.766-.001 1.298.38 2.27 1.019 3.287l-.582 2.128 2.182-.573c.978.58 1.911.928 3.145.929 3.178 0 5.767-2.587 5.768-5.766.001-3.187-2.575-5.77-5.764-5.771zm3.392 8.244c-.144.405-.837.774-1.17.824-.312.045-.694.067-1.111-.067-.27-.086-.606-.217-1.042-.406-1.849-.803-3.048-2.67-3.14-2.793-.093-.123-.745-.992-.745-1.892s.472-1.343.64-1.528c.168-.186.368-.232.49-.232.123 0 .246.002.353.007.113.006.262-.043.411.314.154.37.525 1.282.571 1.376.046.094.077.203.015.326-.062.123-.092.2-.184.308-.093.108-.194.24-.277.323-.093.093-.19.195-.082.38.108.185.48 1.155 1.34 1.92 1.107.986 2.04 1.293 2.33 1.416.29.123.46.108.63-.077.17-.185.733-.852.928-1.144.195-.292.39-.244.656-.145.267.098 1.696.8 1.988.946.292.146.487.218.558.341.071.123.071.714-.073 1.119z" />
                </svg>
                <span>Chat on WhatsApp</span>
              </a>

              {/* Book Service Online */}
              <Link
                href="/services/request"
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "8px",
                  background: "rgba(255, 255, 255, 0.08)",
                  border: "1px solid rgba(255, 255, 255, 0.2)",
                  color: "#FFFFFF",
                  padding: "10px 20px",
                  borderRadius: "10px",
                  fontSize: "13.5px",
                  fontWeight: 650,
                  textDecoration: "none",
                  transition: "all 0.15s ease",
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.background = "rgba(255, 255, 255, 0.14)";
                  e.currentTarget.style.borderColor = "#FF7A1A";
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.background = "rgba(255, 255, 255, 0.08)";
                  e.currentTarget.style.borderColor = "rgba(255, 255, 255, 0.2)";
                }}
              >
                <span>Book In-Person Diagnostic</span>
                <svg
                  width="14"
                  height="14"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2.2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <line x1="5" y1="12" x2="19" y2="12" />
                  <polyline points="12 5 19 12 12 19" />
                </svg>
              </Link>
            </div>
          </div>

          {/* Right Column: Diagnostic & Service Center Guarantee Card */}
          <div
            style={{
              background: "rgba(255, 255, 255, 0.04)",
              border: "1px solid rgba(255, 255, 255, 0.1)",
              borderRadius: "16px",
              padding: "28px 24px",
              display: "flex",
              flexDirection: "column",
              gap: "20px",
            }}
          >
            {/* Header Status */}
            <div
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                borderBottom: "1px solid rgba(255, 255, 255, 0.08)",
                paddingBottom: "16px",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                <div
                  style={{
                    width: "10px",
                    height: "10px",
                    borderRadius: "50%",
                    backgroundColor: "#22C55E",
                    boxShadow: "0 0 10px #22C55E",
                  }}
                />
                <span
                  style={{
                    fontSize: "13px",
                    fontWeight: 700,
                    color: "#FFFFFF",
                    letterSpacing: "0.2px",
                  }}
                >
                  Janakpur Hub Active
                </span>
              </div>
              <span
                style={{
                  fontSize: "11.5px",
                  color: "#9E988F",
                  background: "rgba(255, 255, 255, 0.06)",
                  padding: "3px 8px",
                  borderRadius: "4px",
                }}
              >
                Walk-ins Welcome
              </span>
            </div>

            {/* Guarantees List */}
            <div style={{ display: "flex", flexDirection: "column", gap: "14px" }}>
              {[
                {
                  title: "100% Free Initial Physical Inspection",
                  desc: "Zero diagnosis fees or upfront deposit before service quotation.",
                },
                {
                  title: "Genuine OEM Tested Spare Parts",
                  desc: "Authentic replacement components with direct factory warranty.",
                },
                {
                  title: "90-Day Sharma Video Care Warranty",
                  desc: "Complete post-service coverage and free follow-up inspection.",
                },
                {
                  title: "Nationwide Secure Courier Return",
                  desc: "Safe doorstep delivery back to any district across Nepal.",
                },
              ].map((item, idx) => (
                <div key={idx} style={{ display: "flex", alignItems: "flex-start", gap: "10px" }}>
                  <div
                    style={{
                      width: "20px",
                      height: "20px",
                      borderRadius: "50%",
                      background: "rgba(255, 122, 26, 0.15)",
                      color: "#FF7A1A",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      flexShrink: 0,
                      marginTop: "1px",
                    }}
                  >
                    <svg
                      width="12"
                      height="12"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="#FF7A1A"
                      strokeWidth="3"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <polyline points="20 6 9 17 4 12" />
                    </svg>
                  </div>
                  <div>
                    <div
                      style={{
                        fontSize: "13px",
                        fontWeight: 700,
                        color: "#F3EDE5",
                        lineHeight: 1.3,
                      }}
                    >
                      {item.title}
                    </div>
                    <div
                      style={{
                        fontSize: "12px",
                        color: "#9E988F",
                        marginTop: "2px",
                        lineHeight: 1.4,
                      }}
                    >
                      {item.desc}
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* Janakpur Local Pickup CTA */}
            <div
              style={{
                borderTop: "1px solid rgba(255, 255, 255, 0.08)",
                paddingTop: "16px",
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
              }}
            >
              <div style={{ fontSize: "12px", color: "#B3ADA4" }}>
                In Janakpur city area?
              </div>
              <Link
                href="/services/request"
                style={{
                  fontSize: "12.5px",
                  fontWeight: 700,
                  color: "#FF7A1A",
                  textDecoration: "none",
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "4px",
                }}
                onMouseEnter={(e) => (e.currentTarget.style.textDecoration = "underline")}
                onMouseLeave={(e) => (e.currentTarget.style.textDecoration = "none")}
              >
                <span>Request Pickup</span>
                <svg
                  width="12"
                  height="12"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <line x1="5" y1="12" x2="19" y2="12" />
                  <polyline points="12 5 19 12 12 19" />
                </svg>
              </Link>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};
