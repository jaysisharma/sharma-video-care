"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";

export const PromoBanners: React.FC = () => {
  return (
    <section
      style={{
        width: "100%",
        padding: "0 24px 36px 24px",
      }}
    >
      <div
        style={{
          maxWidth: "1280px",
          margin: "0 auto",
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(320px, 1fr))",
          gap: "16px",
        }}
      >
        {/* Banner 1: AC Repair & Service (Dark) */}
        <Link
          href="/services/request?service=ac"
          style={{
            textDecoration: "none",
            position: "relative",
            borderRadius: "16px",
            background:
              "linear-gradient(135deg, #16110D 0%, #1D1510 50%, #110D0A 100%)",
            border: "1px solid rgba(255, 255, 255, 0.08)",
            boxShadow: "0 4px 16px rgba(0, 0, 0, 0.12)",
            padding: "24px 22px",
            minHeight: "175px",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
            overflow: "hidden",
            transition: "transform 0.2s ease, box-shadow 0.2s ease",
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = "translateY(-3px)";
            e.currentTarget.style.boxShadow =
              "0 8px 24px rgba(0, 0, 0, 0.22)";
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = "translateY(0)";
            e.currentTarget.style.boxShadow =
              "0 4px 16px rgba(0, 0, 0, 0.12)";
          }}
        >
          {/* Left Content */}
          <div style={{ position: "relative", zIndex: 2, maxWidth: "56%" }}>
            <h3
              style={{
                margin: "0 0 6px 0",
                fontSize: "17px",
                fontWeight: 800,
                color: "#FFFFFF",
                letterSpacing: "-0.01em",
              }}
            >
              AC Repair &amp; Service
            </h3>
            <p
              style={{
                margin: "0 0 16px 0",
                fontSize: "12px",
                lineHeight: 1.45,
                color: "#A8A29A",
              }}
            >
              Keep your home cool and comfortable
            </p>
            <div
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
                background: "rgba(255, 255, 255, 0.08)",
                border: "1px solid rgba(255, 255, 255, 0.25)",
                color: "#FFFFFF",
                padding: "7px 16px",
                borderRadius: "9999px",
                fontSize: "12px",
                fontWeight: 650,
                transition: "background 0.15s ease",
              }}
            >
              <span>Book Now</span>
              <svg
                width="13"
                height="13"
                viewBox="0 0 24 24"
                fill="none"
                stroke="#FF7A1A"
                strokeWidth="2.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <line x1="5" y1="12" x2="19" y2="12" />
                <polyline points="12 5 19 12 12 19" />
              </svg>
            </div>
          </div>

          {/* Right Media */}
          <div
            style={{
              position: "absolute",
              right: "-10px",
              bottom: "4px",
              top: "4px",
              width: "48%",
              pointerEvents: "none",
            }}
          >
            <Image
              src="/images/promo_ac.jpg"
              alt="AC Unit Repair"
              fill
              sizes="(max-width: 768px) 45vw, 30vw"
              style={{
                objectFit: "contain",
                objectPosition: "right center",
                maskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.8) 25%, black 100%)",
                WebkitMaskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.8) 25%, black 100%)",
              }}
            />
          </div>
        </Link>

        {/* Banner 2: CCTV Installation (Orange) */}
        <Link
          href="/services/request?service=cctv"
          style={{
            textDecoration: "none",
            position: "relative",
            borderRadius: "16px",
            background:
              "linear-gradient(135deg, #F06A14 0%, #E85B06 50%, #C44300 100%)",
            border: "1px solid #EA580C",
            boxShadow: "0 4px 16px rgba(232, 111, 28, 0.2)",
            padding: "24px 22px",
            minHeight: "175px",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
            overflow: "hidden",
            transition: "transform 0.2s ease, box-shadow 0.2s ease",
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = "translateY(-3px)";
            e.currentTarget.style.boxShadow =
              "0 8px 24px rgba(232, 111, 28, 0.32)";
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = "translateY(0)";
            e.currentTarget.style.boxShadow =
              "0 4px 16px rgba(232, 111, 28, 0.2)";
          }}
        >
          {/* Left Content */}
          <div style={{ position: "relative", zIndex: 2, maxWidth: "56%" }}>
            <h3
              style={{
                margin: "0 0 6px 0",
                fontSize: "17px",
                fontWeight: 800,
                color: "#FFFFFF",
                letterSpacing: "-0.01em",
              }}
            >
              CCTV Installation
            </h3>
            <p
              style={{
                margin: "0 0 16px 0",
                fontSize: "12px",
                lineHeight: 1.45,
                color: "#FFEAD9",
              }}
            >
              Secure your home &amp; business
            </p>
            <div
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
                background: "#FFFFFF",
                color: "#C2410C",
                padding: "7px 16px",
                borderRadius: "9999px",
                fontSize: "12px",
                fontWeight: 700,
                boxShadow: "0 2px 8px rgba(0, 0, 0, 0.12)",
              }}
            >
              <span>Get a Quote</span>
              <svg
                width="13"
                height="13"
                viewBox="0 0 24 24"
                fill="none"
                stroke="#C2410C"
                strokeWidth="2.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <line x1="5" y1="12" x2="19" y2="12" />
                <polyline points="12 5 19 12 12 19" />
              </svg>
            </div>
          </div>

          {/* Right Media */}
          <div
            style={{
              position: "absolute",
              right: "-8px",
              bottom: 0,
              top: 0,
              width: "50%",
              pointerEvents: "none",
            }}
          >
            <Image
              src="/images/promo_cctv.jpg"
              alt="CCTV Installation Kit"
              fill
              sizes="(max-width: 768px) 45vw, 30vw"
              style={{
                objectFit: "cover",
                objectPosition: "left center",
                maskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.8) 25%, black 100%)",
                WebkitMaskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.8) 25%, black 100%)",
              }}
            />
          </div>
        </Link>

        {/* Banner 3: Certified Pre-Owned Devices */}
        <Link
          href="/used"
          style={{
            textDecoration: "none",
            position: "relative",
            borderRadius: "16px",
            background: "linear-gradient(135deg, #FBF6EE 0%, #F5EDE0 100%)",
            border: "1px solid #EADBCC",
            boxShadow: "0 4px 16px rgba(0, 0, 0, 0.04)",
            padding: "24px 22px",
            minHeight: "175px",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
            overflow: "hidden",
            transition: "transform 0.2s ease, box-shadow 0.2s ease",
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = "translateY(-3px)";
            e.currentTarget.style.boxShadow =
              "0 8px 24px rgba(0, 0, 0, 0.08)";
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = "translateY(0)";
            e.currentTarget.style.boxShadow =
              "0 4px 16px rgba(0, 0, 0, 0.04)";
          }}
        >
          {/* Left Content */}
          <div style={{ position: "relative", zIndex: 2, maxWidth: "56%" }}>
            <h3
              style={{
                margin: "0 0 6px 0",
                fontSize: "17px",
                fontWeight: 800,
                color: "#181512",
                letterSpacing: "-0.01em",
              }}
            >
              Certified Pre-Owned Devices
            </h3>
            <p
              style={{
                margin: "0 0 16px 0",
                fontSize: "12px",
                lineHeight: 1.45,
                color: "#6B655D",
              }}
            >
              Tested and verified electronics backed by our store warranty.
            </p>
            <div
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
                background: "#181512",
                color: "#FFFFFF",
                padding: "7px 16px",
                borderRadius: "9999px",
                fontSize: "12px",
                fontWeight: 650,
                boxShadow: "0 2px 6px rgba(0, 0, 0, 0.1)",
              }}
            >
              <span>Explore Deals</span>
              <svg
                width="13"
                height="13"
                viewBox="0 0 24 24"
                fill="none"
                stroke="#FFFFFF"
                strokeWidth="2.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <line x1="5" y1="12" x2="19" y2="12" />
                <polyline points="12 5 19 12 12 19" />
              </svg>
            </div>
          </div>

          {/* Right Media */}
          <div
            style={{
              position: "absolute",
              right: "-6px",
              bottom: 0,
              top: 0,
              width: "48%",
              pointerEvents: "none",
            }}
          >
            <Image
              src="/images/preowned_gear.jpg"
              alt="Certified Pre-Owned Devices"
              fill
              sizes="(max-width: 768px) 45vw, 30vw"
              style={{
                objectFit: "cover",
                objectPosition: "center",
                maskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.8) 25%, black 100%)",
                WebkitMaskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.8) 25%, black 100%)",
              }}
            />
          </div>
        </Link>
      </div>
    </section>
  );
};
