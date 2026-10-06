"use client";

import React, { useState } from "react";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { useLanguage } from "../../context/LanguageContext";

export const HeroSection: React.FC = () => {
  const router = useRouter();
  const { t, language } = useLanguage();
  const [heroSearchQuery, setHeroSearchQuery] = useState("");

  const handleHeroSearch = (e: React.FormEvent) => {
    e.preventDefault();
    const query = heroSearchQuery.trim();
    if (query) {
      router.push(`/shop?q=${encodeURIComponent(query)}`);
    } else {
      router.push("/shop");
    }
  };

  return (
    <section
      style={{
        width: "100%",
        padding: "20px 24px 28px 24px",
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
              "linear-gradient(135deg, #130D09 0%, #1A120D 40%, #140E0A 100%)",
            border: "1px solid rgba(255, 255, 255, 0.08)",
            boxShadow: "0 16px 40px rgba(0, 0, 0, 0.18)",
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(320px, 1fr))",
            alignItems: "center",
            minHeight: "480px",
          }}
        >
          {/* Left Content Column */}
          <div
            style={{
              padding: "44px 36px 40px 48px",
              display: "flex",
              flexDirection: "column",
              zIndex: 2,
            }}
          >
            {/* Kicker Tag */}
            <div
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "8px",
                fontSize: "11px",
                fontWeight: 700,
                letterSpacing: "2px",
                textTransform: "uppercase",
                color: "#FF7A1A",
                marginBottom: "14px",
              }}
            >
              <span>REPAIR</span>
              <span style={{ opacity: 0.6 }}>•</span>
              <span>BUY</span>
              <span style={{ opacity: 0.6 }}>•</span>
              <span>INSTALL</span>
              <span style={{ opacity: 0.6 }}>•</span>
              <span>MAINTAIN</span>
            </div>

            {/* Main Headline */}
            <h1
              style={{
                fontSize: "clamp(28px, 3.5vw, 42px)",
                fontWeight: 800,
                lineHeight: 1.2,
                letterSpacing: "-0.025em",
                color: "#FFFFFF",
                margin: "0 0 14px 0",
              }}
            >
              {language === "ne" ? (
                <>
                  <span style={{ color: "#FF7A1A", display: "inline-block" }}>
                    शर्मा भिडियो केयर
                  </span>
                  {" "}— विश्वसनीय मर्मत र प्रामाणिक गियर
                </>
              ) : (
                <>
                  Get It Done with{" "}
                  <span style={{ color: "#FF7A1A", display: "inline-block" }}>
                    Sharma Video Care
                  </span>
                </>
              )}
            </h1>

            {/* Subtitle */}
            <p
              style={{
                fontSize: "15px",
                lineHeight: 1.55,
                color: "#B3ACA3",
                margin: "0 0 26px 0",
                maxWidth: "480px",
              }}
            >
              {t("hero.sub")}
            </p>

            {/* Hero Search Bar */}
            <form
              onSubmit={handleHeroSearch}
              style={{
                display: "flex",
                alignItems: "center",
                background: "#FFFFFF",
                borderRadius: "12px",
                padding: "6px 6px 6px 14px",
                maxWidth: "480px",
                boxShadow: "0 10px 25px rgba(0, 0, 0, 0.25)",
                marginBottom: "32px",
                border: "1px solid rgba(255, 255, 255, 0.2)",
              }}
            >
              <svg
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="none"
                stroke="#716D67"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                style={{ flexShrink: 0, marginRight: "8px" }}
              >
                <circle cx="11" cy="11" r="8" />
                <line x1="21" y1="21" x2="16.65" y2="16.65" />
              </svg>
              <input
                type="text"
                value={heroSearchQuery}
                onChange={(e) => setHeroSearchQuery(e.target.value)}
                placeholder={language === "ne" ? "के सेवा वा उपकरण खोज्दै हुनुहुन्छ?" : "What do you need help with?"}
                style={{
                  flex: 1,
                  border: "none",
                  outline: "none",
                  fontSize: "14px",
                  color: "#181614",
                  background: "transparent",
                  padding: "6px 4px",
                }}
              />
              <button
                type="submit"
                style={{
                  background: "#E86F1C",
                  color: "#FFFFFF",
                  border: "none",
                  borderRadius: "8px",
                  padding: "9px 20px",
                  fontSize: "14px",
                  fontWeight: 600,
                  cursor: "pointer",
                  transition: "background 0.15s ease",
                  whiteSpace: "nowrap",
                }}
                onMouseEnter={(e) =>
                  (e.currentTarget.style.background = "#D25F14")
                }
                onMouseLeave={(e) =>
                  (e.currentTarget.style.background = "#E86F1C")
                }
              >
                Search
              </button>
            </form>

            {/* Trust Badges */}
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fit, minmax(110px, 1fr))",
                gap: "14px",
                maxWidth: "520px",
                borderTop: "1px solid rgba(255, 255, 255, 0.08)",
                paddingTop: "20px",
              }}
            >
              {/* 1. Repair Services in Janakpur */}
              <div style={{ display: "flex", alignItems: "flex-start", gap: "9px" }}>
                <svg
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="#FF7A1A"
                  strokeWidth="1.9"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  style={{ flexShrink: 0, marginTop: "1px" }}
                >
                  <rect x="1" y="3" width="15" height="13" rx="1" />
                  <polygon points="16 8 20 8 23 11 23 16 16 16 16 8" />
                  <circle cx="5.5" cy="18.5" r="2.5" />
                  <circle cx="18.5" cy="18.5" r="2.5" />
                </svg>
                <div style={{ fontSize: "12px", color: "#DDD7CF", lineHeight: 1.3, fontWeight: 500 }}>
                  Repair Services <br />
                  <span style={{ color: "#9E988F", fontSize: "11px" }}>in Janakpur</span>
                </div>
              </div>

              {/* 2. Product Delivery Nationwide */}
              <div style={{ display: "flex", alignItems: "flex-start", gap: "9px" }}>
                <svg
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="#FF7A1A"
                  strokeWidth="1.9"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  style={{ flexShrink: 0, marginTop: "1px" }}
                >
                  <line x1="16.5" y1="9.4" x2="7.5" y2="4.21" />
                  <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
                  <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
                  <line x1="12" y1="22.08" x2="12" y2="12" />
                </svg>
                <div style={{ fontSize: "12px", color: "#DDD7CF", lineHeight: 1.3, fontWeight: 500 }}>
                  Product Delivery <br />
                  <span style={{ color: "#9E988F", fontSize: "11px" }}>Nationwide</span>
                </div>
              </div>

              {/* 3. Trusted Service & Quality */}
              <div style={{ display: "flex", alignItems: "flex-start", gap: "9px" }}>
                <svg
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="#FF7A1A"
                  strokeWidth="1.9"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  style={{ flexShrink: 0, marginTop: "1px" }}
                >
                  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                  <polyline points="9 12 11 14 15 10" />
                </svg>
                <div style={{ fontSize: "12px", color: "#DDD7CF", lineHeight: 1.3, fontWeight: 500 }}>
                  Trusted Service <br />
                  <span style={{ color: "#9E988F", fontSize: "11px" }}>&amp; Quality</span>
                </div>
              </div>

              {/* 4. Chat with Our Team */}
              <div style={{ display: "flex", alignItems: "flex-start", gap: "9px" }}>
                <svg
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="#FF7A1A"
                  strokeWidth="1.9"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  style={{ flexShrink: 0, marginTop: "1px" }}
                >
                  <path d="M3 18v-6a9 9 0 0 1 18 0v6" />
                  <path d="M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3zM3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z" />
                </svg>
                <div style={{ fontSize: "12px", color: "#DDD7CF", lineHeight: 1.3, fontWeight: 500 }}>
                  Chat with <br />
                  <span style={{ color: "#9E988F", fontSize: "11px" }}>Our Team</span>
                </div>
              </div>
            </div>
          </div>

          {/* Right Media Column */}
          <div
            style={{
              position: "relative",
              height: "100%",
              minHeight: "440px",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              overflow: "hidden",
            }}
          >
            {/* Handwritten "Your Trusted Tech Partner" Badge */}
            <div
              style={{
                position: "absolute",
                top: "24px",
                left: "24px",
                zIndex: 3,
                display: "flex",
                alignItems: "center",
                gap: "6px",
                pointerEvents: "none",
              }}
            >
              <span
                style={{
                  fontFamily:
                    "'Caveat', 'Segoe Script', 'Bradley Hand', 'Brush Script MT', cursive, sans-serif",
                  fontSize: "20px",
                  fontWeight: 600,
                  color: "#F7D59A",
                  letterSpacing: "0.5px",
                  transform: "rotate(-6deg)",
                  textShadow: "0 2px 8px rgba(0,0,0,0.6)",
                }}
              >
                Your Trusted Tech Partner
              </span>
              <svg
                width="28"
                height="20"
                viewBox="0 0 40 28"
                fill="none"
                stroke="#F7D59A"
                strokeWidth="2"
                strokeLinecap="round"
                style={{ transform: "rotate(10deg) translate(-2px, 8px)" }}
              >
                <path d="M2 14 Q 18 2 34 16" />
                <path d="M28 14 L 34 16 L 32 24" />
              </svg>
            </div>

            {/* Tech Equipment Composite Image */}
            <div
              style={{
                position: "relative",
                width: "100%",
                height: "100%",
                minHeight: "440px",
              }}
            >
              <Image
                src="/images/hero_tech_gear.jpg"
                alt="Tech repair, appliances, gadgets and equipment"
                fill
                priority
                sizes="(max-width: 768px) 100vw, 55vw"
                style={{
                  objectFit: "cover",
                  objectPosition: "center",
                }}
              />
              {/* Soft gradient fade for seamless integration */}
              <div
                style={{
                  position: "absolute",
                  inset: 0,
                  background:
                    "linear-gradient(to right, rgba(19, 13, 9, 0.95) 0%, rgba(19, 13, 9, 0.4) 18%, rgba(19, 13, 9, 0) 45%)",
                  pointerEvents: "none",
                }}
              />
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};
