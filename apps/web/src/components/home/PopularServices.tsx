"use client";

import React from "react";
import Link from "next/link";
import {
  ACIcon,
  WashingMachineIcon,
  TVIcon,
  CameraIcon,
  LaptopIcon,
  CCTVIcon,
  MobileIcon,
  HomeApplianceIcon,
  TVWallMountIcon,
  OtherServicesIcon,
  PlumberIcon,
  FurnitureIcon,
} from "@/components/ServiceIcons";
import { useLanguage } from "../../context/LanguageContext";

interface PopularServiceItem {
  title: string;
  icon: React.ReactNode;
  href: string;
  isComingSoon?: boolean;
}

const SERVICES: PopularServiceItem[] = [
  {
    title: "AC Repair",
    icon: <ACIcon size={40} />,
    href: "/services/request?service=ac",
  },
  {
    title: "Washing Machine Repair",
    icon: <WashingMachineIcon size={40} />,
    href: "/services/request?service=washing_machine",
  },
  {
    title: "TV Repair",
    icon: <TVIcon size={40} />,
    href: "/services/request?service=tv",
  },
  {
    title: "Camera Repair",
    icon: <CameraIcon size={40} />,
    href: "/services/request?service=camera",
  },
  {
    title: "Laptop Repair",
    icon: <LaptopIcon size={40} />,
    href: "/services/request?service=laptop",
  },
  {
    title: "Plumber",
    icon: <PlumberIcon size={40} />,
    href: "/services#plumbing",
    isComingSoon: true,
  },
  {
    title: "Furniture",
    icon: <FurnitureIcon size={40} />,
    href: "/services#furniture",
    isComingSoon: true,
  },
  {
    title: "CCTV Installation",
    icon: <CCTVIcon size={40} />,
    href: "/services/request?service=cctv",
  },
  {
    title: "Mobile Repair",
    icon: <MobileIcon size={40} />,
    href: "/services/request?service=mobile",
  },
  {
    title: "Home Appliance",
    icon: <HomeApplianceIcon size={40} />,
    href: "/services/request?service=home_appliance",
  },
  {
    title: "TV Wall Mounting",
    icon: <TVWallMountIcon size={40} />,
    href: "/services/request?service=tv_wall_mount",
  },
  {
    title: "Other Services",
    icon: <OtherServicesIcon size={40} />,
    href: "/services/custom",
  },
];

export const PopularServices: React.FC = () => {
  const { t, language } = useLanguage();

  const serviceTitle = (key: string, fallback: string) => {
    return t(key) || fallback;
  };

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
        }}
      >
        {/* Section Header */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            marginBottom: "16px",
          }}
        >
          <h2
            style={{
              fontSize: "20px",
              fontWeight: 800,
              color: "#181512",
              letterSpacing: "-0.015em",
              margin: 0,
            }}
          >
            {t("services.popularTitle")}
          </h2>
          <Link
            href="/services"
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
              fontSize: "13px",
              fontWeight: 650,
              color: "#4B443B",
              textDecoration: "none",
              transition: "color 0.15s ease",
            }}
            onMouseEnter={(e) => (e.currentTarget.style.color = "#E86F1C")}
            onMouseLeave={(e) => (e.currentTarget.style.color = "#4B443B")}
          >
            <span>{t("services.viewAll")}</span>
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
          </Link>
        </div>

        {/* 10 Services Grid */}
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(105px, 1fr))",
            gap: "12px",
          }}
        >
          {SERVICES.map((service, index) => (
            <Link
              key={index}
              href={service.href}
              style={{
                position: "relative",
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                justifyContent: "center",
                textAlign: "center",
                padding: "16px 8px 14px 8px",
                background: "#FFFFFF",
                border: "1px solid #EBE7DF",
                borderRadius: "14px",
                textDecoration: "none",
                boxShadow: "0 1px 3px rgba(0, 0, 0, 0.02)",
                transition: "all 0.15s ease",
                cursor: "pointer",
                minHeight: "110px",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.borderColor = "#E86F1C";
                e.currentTarget.style.transform = "translateY(-2px)";
                e.currentTarget.style.boxShadow =
                  "0 6px 16px rgba(232, 111, 28, 0.12)";
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.borderColor = "#EBE7DF";
                e.currentTarget.style.transform = "translateY(0)";
                e.currentTarget.style.boxShadow =
                  "0 1px 3px rgba(0, 0, 0, 0.02)";
              }}
            >
              {service.isComingSoon && (
                <span
                  style={{
                    position: "absolute",
                    top: "6px",
                    right: "6px",
                    background: "#FEF3C7",
                    color: "#92400E",
                    fontSize: "9px",
                    fontWeight: 750,
                    padding: "2px 5px",
                    borderRadius: "4px",
                    letterSpacing: "0.02em",
                    border: "1px solid #FDE68A",
                  }}
                >
                  SOON
                </span>
              )}

              <div
                style={{
                  height: "44px",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  marginBottom: "8px",
                }}
              >
                {service.icon}
              </div>
              <span
                style={{
                  fontSize: "12px",
                  fontWeight: 650,
                  color: "#24201D",
                  lineHeight: 1.25,
                  maxWidth: "95px",
                  wordBreak: "break-word",
                }}
              >
                {service.title === "AC Repair"
                  ? t("services.ac")
                  : service.title === "Washing Machine Repair"
                  ? t("services.washingMachine")
                  : service.title === "TV Repair"
                  ? t("services.tv")
                  : service.title === "Camera Repair"
                  ? t("services.camera")
                  : service.title === "Laptop Repair"
                  ? t("services.laptop")
                  : service.title === "Plumber"
                  ? t("services.plumber")
                  : service.title === "Furniture"
                  ? t("services.furniture")
                  : service.title === "CCTV Installation"
                  ? t("services.cctv")
                  : service.title === "Mobile Repair"
                  ? t("services.mobile")
                  : service.title === "Home Appliance"
                  ? t("services.appliance")
                  : service.title === "TV Wall Mounting"
                  ? t("services.wallMount")
                  : t("services.other")}
              </span>
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
};
