"use client";

import React from "react";

interface LogoProps {
  variant?: "full" | "icon" | "stacked";
  size?: number;
  showSubtitle?: boolean;
  inverted?: boolean;
}

export const Logo: React.FC<LogoProps> = ({
  variant = "full",
  size = 40,
  showSubtitle = false,
  inverted = false,
}) => {
  // Brand Emblem for Sharma Video Care
  const emblem = (
    <div
      style={{
        width: size,
        height: size,
        borderRadius: "10px",
        background: "linear-gradient(135deg, #FF8A3D 0%, #E86F1C 100%)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        color: "#FFFFFF",
        boxShadow: "0 2px 8px rgba(232, 111, 28, 0.25)",
        flexShrink: 0,
      }}
    >
      <svg width={size * 0.58} height={size * 0.58} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"/>
        <circle cx="12" cy="13" r="3"/>
      </svg>
    </div>
  );

  if (variant === "icon") {
    return emblem;
  }

  const textColorMain = inverted ? "#FFFFFF" : "#111827";

  return (
    <div style={{ display: "inline-flex", alignItems: "center", gap: "0.65rem", textDecoration: "none" }}>
      {emblem}
      <div style={{ display: "flex", flexDirection: "column", lineHeight: 1 }}>
        <span
          style={{
            fontFamily: "var(--font-heading, inherit)",
            fontSize: "1.05rem",
            fontWeight: 850,
            letterSpacing: "-0.01em",
            color: textColorMain,
          }}
        >
          SHARMA
        </span>
        <span
          style={{
            fontFamily: "var(--font-heading, inherit)",
            fontSize: "0.75rem",
            fontWeight: 800,
            letterSpacing: "0.06em",
            color: "var(--color-primary, #E86F1C)",
            marginTop: "2px",
          }}
        >
          VIDEO CARE
        </span>
      </div>
    </div>
  );
};
