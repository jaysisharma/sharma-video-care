"use client";

import React from "react";
import Link from "next/link";
import Image from "next/image";

export const CategoryCards: React.FC = () => {
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
          gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))",
          gap: "16px",
        }}
      >
        {/* Card 1: Repair Services */}
        <Link
          href="/services"
          style={{
            textDecoration: "none",
            position: "relative",
            borderRadius: "16px",
            background: "linear-gradient(135deg, #FFF7F2 0%, #FEEFE6 100%)",
            border: "1px solid #FED7AA",
            boxShadow: "0 2px 8px rgba(232, 111, 28, 0.06)",
            padding: "20px 18px",
            minHeight: "165px",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
            overflow: "hidden",
            transition: "transform 0.2s ease, box-shadow 0.2s ease",
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = "translateY(-3px)";
            e.currentTarget.style.boxShadow =
              "0 8px 24px rgba(232, 111, 28, 0.14)";
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = "translateY(0)";
            e.currentTarget.style.boxShadow =
              "0 2px 8px rgba(232, 111, 28, 0.06)";
          }}
        >
          {/* Left Content */}
          <div style={{ position: "relative", zIndex: 2, maxWidth: "58%" }}>
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: "10px",
                marginBottom: "8px",
              }}
            >
              <div
                style={{
                  width: "34px",
                  height: "34px",
                  borderRadius: "10px",
                  background: "#E86F1C",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  flexShrink: 0,
                  boxShadow: "0 2px 6px rgba(232, 111, 28, 0.3)",
                }}
              >
                <svg
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="#FFFFFF"
                  strokeWidth="2.2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z" />
                </svg>
              </div>
              <h3
                style={{
                  margin: 0,
                  fontSize: "16px",
                  fontWeight: 750,
                  color: "#181512",
                  letterSpacing: "-0.01em",
                }}
              >
                Repair Services
              </h3>
            </div>
            <p
              style={{
                margin: "0 0 14px 0",
                fontSize: "12px",
                lineHeight: 1.45,
                color: "#6B655D",
                fontWeight: 450,
              }}
            >
              AC, TV, Camera, Laptop, Washing Machine and more
            </p>
          </div>

          {/* Bottom Arrow Action Button */}
          <div
            style={{
              position: "relative",
              zIndex: 2,
              width: "28px",
              height: "28px",
              borderRadius: "50%",
              background: "#FFFFFF",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              boxShadow: "0 2px 6px rgba(0, 0, 0, 0.08)",
              color: "#E86F1C",
            }}
          >
            <svg
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.4"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <line x1="5" y1="12" x2="19" y2="12" />
              <polyline points="12 5 19 12 12 19" />
            </svg>
          </div>

          {/* Right Cutout Image */}
          <div
            style={{
              position: "absolute",
              right: "-6px",
              bottom: "-6px",
              top: "4px",
              width: "48%",
              pointerEvents: "none",
            }}
          >
            <Image
              src="/images/card_repair.jpg"
              alt="Repair technician"
              fill
              sizes="(max-width: 600px) 45vw, 25vw"
              style={{
                objectFit: "cover",
                objectPosition: "left center",
                maskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.85) 30%, black 100%)",
                WebkitMaskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.85) 30%, black 100%)",
              }}
            />
          </div>
        </Link>

        {/* Card 2: Shop Products */}
        <Link
          href="/shop"
          style={{
            textDecoration: "none",
            position: "relative",
            borderRadius: "16px",
            background: "linear-gradient(135deg, #F0F7FF 0%, #E2EEFD 100%)",
            border: "1px solid #BFDBFE",
            boxShadow: "0 2px 8px rgba(37, 99, 235, 0.06)",
            padding: "20px 18px",
            minHeight: "165px",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
            overflow: "hidden",
            transition: "transform 0.2s ease, box-shadow 0.2s ease",
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = "translateY(-3px)";
            e.currentTarget.style.boxShadow =
              "0 8px 24px rgba(37, 99, 235, 0.14)";
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = "translateY(0)";
            e.currentTarget.style.boxShadow =
              "0 2px 8px rgba(37, 99, 235, 0.06)";
          }}
        >
          {/* Left Content */}
          <div style={{ position: "relative", zIndex: 2, maxWidth: "58%" }}>
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: "10px",
                marginBottom: "8px",
              }}
            >
              <div
                style={{
                  width: "34px",
                  height: "34px",
                  borderRadius: "10px",
                  background: "#2563EB",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  flexShrink: 0,
                  boxShadow: "0 2px 6px rgba(37, 99, 235, 0.3)",
                }}
              >
                <svg
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="#FFFFFF"
                  strokeWidth="2.2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <circle cx="9" cy="21" r="1" />
                  <circle cx="20" cy="21" r="1" />
                  <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6" />
                </svg>
              </div>
              <h3
                style={{
                  margin: 0,
                  fontSize: "16px",
                  fontWeight: 750,
                  color: "#181512",
                  letterSpacing: "-0.01em",
                }}
              >
                Shop Products
              </h3>
            </div>
            <p
              style={{
                margin: "0 0 14px 0",
                fontSize: "12px",
                lineHeight: 1.45,
                color: "#6B655D",
                fontWeight: 450,
              }}
            >
              New electronics, accessories and more
            </p>
          </div>

          {/* Bottom Arrow Action Button */}
          <div
            style={{
              position: "relative",
              zIndex: 2,
              width: "28px",
              height: "28px",
              borderRadius: "50%",
              background: "#FFFFFF",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              boxShadow: "0 2px 6px rgba(0, 0, 0, 0.08)",
              color: "#2563EB",
            }}
          >
            <svg
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.4"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <line x1="5" y1="12" x2="19" y2="12" />
              <polyline points="12 5 19 12 12 19" />
            </svg>
          </div>

          {/* Right Cutout Image */}
          <div
            style={{
              position: "absolute",
              right: "-6px",
              bottom: "-6px",
              top: "4px",
              width: "48%",
              pointerEvents: "none",
            }}
          >
            <Image
              src="/images/card_shop.jpg"
              alt="Shop electronics"
              fill
              sizes="(max-width: 600px) 45vw, 25vw"
              style={{
                objectFit: "cover",
                objectPosition: "left center",
                maskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.85) 30%, black 100%)",
                WebkitMaskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.85) 30%, black 100%)",
              }}
            />
          </div>
        </Link>

        {/* Card 3: Used Products */}
        <Link
          href="/used"
          style={{
            textDecoration: "none",
            position: "relative",
            borderRadius: "16px",
            background: "linear-gradient(135deg, #F0FDF4 0%, #DDFCE8 100%)",
            border: "1px solid #BBF7D0",
            boxShadow: "0 2px 8px rgba(22, 163, 74, 0.06)",
            padding: "20px 18px",
            minHeight: "165px",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
            overflow: "hidden",
            transition: "transform 0.2s ease, box-shadow 0.2s ease",
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = "translateY(-3px)";
            e.currentTarget.style.boxShadow =
              "0 8px 24px rgba(22, 163, 74, 0.14)";
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = "translateY(0)";
            e.currentTarget.style.boxShadow =
              "0 2px 8px rgba(22, 163, 74, 0.06)";
          }}
        >
          {/* Left Content */}
          <div style={{ position: "relative", zIndex: 2, maxWidth: "58%" }}>
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: "10px",
                marginBottom: "8px",
              }}
            >
              <div
                style={{
                  width: "34px",
                  height: "34px",
                  borderRadius: "10px",
                  background: "#16A34A",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  flexShrink: 0,
                  boxShadow: "0 2px 6px rgba(22, 163, 74, 0.3)",
                }}
              >
                <svg
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="#FFFFFF"
                  strokeWidth="2.2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <polyline points="23 4 23 10 17 10" />
                  <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10" />
                </svg>
              </div>
              <h3
                style={{
                  margin: 0,
                  fontSize: "16px",
                  fontWeight: 750,
                  color: "#181512",
                  letterSpacing: "-0.01em",
                }}
              >
                Used Products
              </h3>
            </div>
            <p
              style={{
                margin: "0 0 14px 0",
                fontSize: "12px",
                lineHeight: 1.45,
                color: "#6B655D",
                fontWeight: 450,
              }}
            >
              Quality second-hand items at great prices
            </p>
          </div>

          {/* Bottom Arrow Action Button */}
          <div
            style={{
              position: "relative",
              zIndex: 2,
              width: "28px",
              height: "28px",
              borderRadius: "50%",
              background: "#FFFFFF",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              boxShadow: "0 2px 6px rgba(0, 0, 0, 0.08)",
              color: "#16A34A",
            }}
          >
            <svg
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.4"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <line x1="5" y1="12" x2="19" y2="12" />
              <polyline points="12 5 19 12 12 19" />
            </svg>
          </div>

          {/* Right Cutout Image */}
          <div
            style={{
              position: "absolute",
              right: "-6px",
              bottom: "-6px",
              top: "4px",
              width: "48%",
              pointerEvents: "none",
            }}
          >
            <Image
              src="/images/preowned_gear.jpg"
              alt="Pre-owned certified electronics"
              fill
              sizes="(max-width: 600px) 45vw, 25vw"
              style={{
                objectFit: "cover",
                objectPosition: "center",
                maskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.85) 30%, black 100%)",
                WebkitMaskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.85) 30%, black 100%)",
              }}
            />
          </div>
        </Link>

        {/* Card 4: CCTV & Security */}
        <Link
          href="/services/request?service=cctv"
          style={{
            textDecoration: "none",
            position: "relative",
            borderRadius: "16px",
            background: "linear-gradient(135deg, #FAF5FF 0%, #F3E8FF 100%)",
            border: "1px solid #E9D5FF",
            boxShadow: "0 2px 8px rgba(139, 92, 246, 0.06)",
            padding: "20px 18px",
            minHeight: "165px",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
            overflow: "hidden",
            transition: "transform 0.2s ease, box-shadow 0.2s ease",
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = "translateY(-3px)";
            e.currentTarget.style.boxShadow =
              "0 8px 24px rgba(139, 92, 246, 0.14)";
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = "translateY(0)";
            e.currentTarget.style.boxShadow =
              "0 2px 8px rgba(139, 92, 246, 0.06)";
          }}
        >
          {/* Left Content */}
          <div style={{ position: "relative", zIndex: 2, maxWidth: "58%" }}>
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: "10px",
                marginBottom: "8px",
              }}
            >
              <div
                style={{
                  width: "34px",
                  height: "34px",
                  borderRadius: "10px",
                  background: "#8B5CF6",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  flexShrink: 0,
                  boxShadow: "0 2px 6px rgba(139, 92, 246, 0.3)",
                }}
              >
                <svg
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="#FFFFFF"
                  strokeWidth="2.2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                </svg>
              </div>
              <h3
                style={{
                  margin: 0,
                  fontSize: "16px",
                  fontWeight: 750,
                  color: "#181512",
                  letterSpacing: "-0.01em",
                }}
              >
                CCTV &amp; Security
              </h3>
            </div>
            <p
              style={{
                margin: "0 0 14px 0",
                fontSize: "12px",
                lineHeight: 1.45,
                color: "#6B655D",
                fontWeight: 450,
              }}
            >
              Complete surveillance camera setup and maintenance
            </p>
          </div>

          {/* Bottom Arrow Action Button */}
          <div
            style={{
              position: "relative",
              zIndex: 2,
              width: "28px",
              height: "28px",
              borderRadius: "50%",
              background: "#FFFFFF",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              boxShadow: "0 2px 6px rgba(0, 0, 0, 0.08)",
              color: "#8B5CF6",
            }}
          >
            <svg
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.4"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <line x1="5" y1="12" x2="19" y2="12" />
              <polyline points="12 5 19 12 12 19" />
            </svg>
          </div>

          {/* Right Cutout Image */}
          <div
            style={{
              position: "absolute",
              right: "-6px",
              bottom: "-6px",
              top: "4px",
              width: "48%",
              pointerEvents: "none",
            }}
          >
            <Image
              src="/images/promo_cctv.jpg"
              alt="CCTV Security Installation"
              fill
              sizes="(max-width: 600px) 45vw, 25vw"
              style={{
                objectFit: "cover",
                objectPosition: "left center",
                maskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.85) 30%, black 100%)",
                WebkitMaskImage:
                  "linear-gradient(to right, transparent 0%, rgba(0,0,0,0.85) 30%, black 100%)",
              }}
            />
          </div>
        </Link>
      </div>
    </section>
  );
};
