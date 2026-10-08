"use client";

import React, { useState, useRef, useEffect } from "react";
import Link from "next/link";
import { useRouter, usePathname } from "next/navigation";
import { useAuth } from "../context/AuthContext";
import { useCart } from "../context/CartContext";
import { Logo } from "./Logo";
import {
  Search,
  User,
  ShoppingCart,
  ChevronDown,
  ShieldAlert,
  Hammer,
  LogOut,
  LogIn,
  ArrowRight,
  Menu,
  X,
  Wrench,
  ShoppingBag,
  RotateCcw,
  Home,
  MessageSquare,
  Bell,
  Headphones,
  Languages,
  Calculator,
} from "lucide-react";
import { SHOP_PRODUCTS } from "@/data/shopProducts";
import { useLanguage } from "../context/LanguageContext";

export const Navbar: React.FC = () => {
  const router = useRouter();
  const pathname = usePathname();
  const { user, role, firebaseUser, signOut } = useAuth();
  const { totalCount } = useCart();
  const { language, setLanguage, toggleLanguage, t } = useLanguage();

  const [searchQuery, setSearchQuery] = useState("");
  const [searchFocused, setSearchFocused] = useState(false);
  const [profileOpen, setProfileOpen] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const profileRef = useRef<HTMLDivElement>(null);
  const searchContainerRef = useRef<HTMLDivElement>(null);

  // Suggestions for autocomplete
  const suggestions = React.useMemo(() => {
    const q = searchQuery.toLowerCase().trim();
    if (!q || q.length < 2) return [];
    return SHOP_PRODUCTS.filter((p) => {
      return (
        p.title.toLowerCase().includes(q) ||
        (p.brand && p.brand.toLowerCase().includes(q)) ||
        (p.category && p.category.toLowerCase().includes(q)) ||
        (p.model && p.model.toLowerCase().includes(q))
      );
    }).slice(0, 5);
  }, [searchQuery]);

  // Close menus and search dropdown on outside click
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      const target = event.target as Node;
      if (profileRef.current && !profileRef.current.contains(target)) {
        setProfileOpen(false);
      }
      if (searchContainerRef.current && !searchContainerRef.current.contains(target)) {
        setSearchFocused(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Close menus and search on route change
  useEffect(() => {
    setProfileOpen(false);
    setMobileMenuOpen(false);
    setSearchFocused(false);
  }, [pathname]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      router.push(`/shop?q=${encodeURIComponent(searchQuery.trim())}`);
      setMobileMenuOpen(false);
      setSearchFocused(false);
    }
  };

  const isHome = pathname === "/" || pathname === "";
  const isRepair = pathname.startsWith("/services");
  const isEstimator = pathname.startsWith("/estimator");
  const isShop = pathname.startsWith("/shop");
  const isPreowned = pathname.startsWith("/used");

  const isLoggedIn = !!(user || firebaseUser);
  const displayName = isLoggedIn
    ? user?.name || (firebaseUser?.email ? firebaseUser.email.split("@")[0] : "Customer")
    : null;
  const initial = displayName ? displayName.charAt(0).toUpperCase() : null;

  return (
    <header
      style={{
        position: "sticky",
        top: 0,
        zIndex: 200,
        background: "#FFFFFF",
        boxShadow: "0 1px 3px rgba(0, 0, 0, 0.04)",
      }}
    >
      {/* ──────────────── TOP BAR (ROW 1): BRAND + SEARCH + ACTIONS ──────────────── */}
      <div
        style={{
          borderBottom: "1px solid #F0ECE4",
          background: "#FFFFFF",
        }}
      >
        <div
          className="container"
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            height: "60px",
            padding: "0 1.25rem",
            gap: "1.5rem",
          }}
        >
          {/* Left: Brand Logo */}
          <Link
            href="/"
            style={{
              display: "flex",
              alignItems: "center",
              textDecoration: "none",
              flexShrink: 0,
            }}
          >
            <Logo size={38} />
          </Link>

          {/* Center: Open Prominent Search Bar (Desktop) */}
          <div
            ref={searchContainerRef}
            className="nav-desktop-only"
            style={{
              flex: 1,
              maxWidth: "540px",
              position: "relative",
            }}
          >
            <form onSubmit={handleSearch} style={{ position: "relative", width: "100%" }}>
              <Search
                size={16}
                strokeWidth={1.8}
                style={{
                  position: "absolute",
                  left: "14px",
                  top: "50%",
                  transform: "translateY(-50%)",
                  color: "#9A9389",
                  pointerEvents: "none",
                }}
              />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => {
                  setSearchQuery(e.target.value);
                  setSearchFocused(true);
                }}
                onFocus={(e) => {
                  setSearchFocused(true);
                  e.currentTarget.style.borderColor = "#E86F1C";
                  e.currentTarget.style.background = "#FFFFFF";
                  e.currentTarget.style.boxShadow = "0 0 0 3px rgba(232, 111, 28, 0.1)";
                }}
                onBlur={(e) => {
                  e.currentTarget.style.borderColor = "#E6E1D8";
                  e.currentTarget.style.background = "#F7F5F0";
                  e.currentTarget.style.boxShadow = "none";
                }}
                placeholder="Search cameras, lenses, drones, repairs..."
                style={{
                  width: "100%",
                  padding: "0.55rem 2.2rem 0.55rem 2.45rem",
                  background: "#F7F5F0",
                  border: "1px solid #E6E1D8",
                  borderRadius: "9999px",
                  fontSize: "0.88rem",
                  color: "#1A1A1A",
                  outline: "none",
                  transition: "all 0.15s ease",
                }}
              />
              {searchQuery && (
                <button
                  type="button"
                  onClick={() => setSearchQuery("")}
                  aria-label="Clear query"
                  style={{
                    position: "absolute",
                    right: "12px",
                    top: "50%",
                    transform: "translateY(-50%)",
                    background: "none",
                    border: "none",
                    cursor: "pointer",
                    padding: "2px",
                    color: "#9CA3AF",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                  }}
                >
                  <X size={15} />
                </button>
              )}
            </form>

            {/* Suggestions Popover */}
            {searchFocused && searchQuery.trim().length >= 2 && suggestions.length > 0 && (
              <div
                style={{
                  position: "absolute",
                  top: "calc(100% + 8px)",
                  left: 0,
                  right: 0,
                  background: "#FFFFFF",
                  border: "1px solid #E2E8F0",
                  borderRadius: "12px",
                  boxShadow: "0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05)",
                  zIndex: 300,
                  overflow: "hidden",
                }}
              >
                <div
                  style={{
                    padding: "8px 14px",
                    background: "#F8FAFC",
                    borderBottom: "1px solid #F1F5F9",
                    fontSize: "11.5px",
                    fontWeight: 700,
                    color: "#64748B",
                    textTransform: "uppercase",
                    letterSpacing: "0.05em",
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                  }}
                >
                  <span>Product Suggestions</span>
                  <span>Press Enter to search all</span>
                </div>

                <div style={{ maxHeight: "320px", overflowY: "auto" }}>
                  {suggestions.map((item) => (
                    <Link
                      key={item.id}
                      href={`/shop/${item.id}`}
                      onClick={() => setSearchFocused(false)}
                      style={{
                        display: "flex",
                        alignItems: "center",
                        gap: "12px",
                        padding: "10px 14px",
                        borderBottom: "1px solid #F8FAFC",
                        textDecoration: "none",
                        transition: "background 0.12s ease",
                      }}
                      onMouseEnter={(e) => (e.currentTarget.style.background = "#F8FAFC")}
                      onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}
                    >
                      {/* Image Thumbnail */}
                      <div
                        style={{
                          width: "40px",
                          height: "40px",
                          borderRadius: "6px",
                          background: "#F1F5F9",
                          overflow: "hidden",
                          flexShrink: 0,
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                        }}
                      >
                        {item.image ? (
                          <img
                            src={item.image}
                            alt={item.title}
                            style={{ width: "100%", height: "100%", objectFit: "cover" }}
                          />
                        ) : (
                          <ShoppingBag size={18} color="#94A3B8" />
                        )}
                      </div>

                      {/* Info */}
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div
                          style={{
                            fontSize: "13px",
                            fontWeight: 650,
                            color: "#0F172A",
                            whiteSpace: "nowrap",
                            overflow: "hidden",
                            textOverflow: "ellipsis",
                          }}
                        >
                          {item.title}
                        </div>
                        <div style={{ fontSize: "11.5px", color: "#64748B", display: "flex", gap: "6px" }}>
                          <span>{item.brand}</span>
                          <span>•</span>
                          <span>{item.category}</span>
                        </div>
                      </div>

                      {/* Price */}
                      <div
                        style={{
                          fontSize: "13px",
                          fontWeight: 700,
                          color: "#E86F1C",
                          flexShrink: 0,
                        }}
                      >
                        NPR {item.price.toLocaleString("en-IN")}
                      </div>
                    </Link>
                  ))}
                </div>

                {/* Bottom View All Link */}
                <button
                  type="button"
                  onClick={() => {
                    router.push(`/shop?q=${encodeURIComponent(searchQuery.trim())}`);
                    setSearchFocused(false);
                  }}
                  style={{
                    width: "100%",
                    padding: "10px 14px",
                    background: "#FAFAFA",
                    border: "none",
                    borderTop: "1px solid #E2E8F0",
                    fontSize: "12.5px",
                    fontWeight: 650,
                    color: "#0F172A",
                    textAlign: "center",
                    cursor: "pointer",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    gap: "6px",
                  }}
                  onMouseEnter={(e) => (e.currentTarget.style.background = "#F1F5F9")}
                  onMouseLeave={(e) => (e.currentTarget.style.background = "#FAFAFA")}
                >
                  <span>View all results for &ldquo;{searchQuery.trim()}&rdquo;</span>
                  <ArrowRight size={14} color="#E86F1C" />
                </button>
              </div>
            )}
          </div>

          {/* Right Area: Logged-in Bell/Chat + Cart + Account + Get Help Button */}
          <div style={{ display: "flex", alignItems: "center", gap: "0.75rem", flexShrink: 0 }}>
            {/* Show notifications & chat ONLY when logged in */}
            {isLoggedIn && (
              <>
                <button
                  type="button"
                  className="nav-desktop-only"
                  title="Notifications"
                  style={{
                    width: "36px",
                    height: "36px",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    borderRadius: "50%",
                    color: "#4B443B",
                    background: "transparent",
                    border: "none",
                    cursor: "pointer",
                    position: "relative",
                  }}
                  onMouseEnter={(e) => (e.currentTarget.style.background = "#F5F3EF")}
                  onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}
                >
                  <Bell size={18} strokeWidth={1.8} />
                  <span
                    style={{
                      position: "absolute",
                      top: "7px",
                      right: "8px",
                      width: "7px",
                      height: "7px",
                      borderRadius: "50%",
                      backgroundColor: "#E86F1C",
                    }}
                  />
                </button>

                <Link
                  href="/chat"
                  className="nav-desktop-only"
                  title="Messages"
                  style={{
                    width: "36px",
                    height: "36px",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    borderRadius: "50%",
                    color: "#4B443B",
                    textDecoration: "none",
                    transition: "background 0.15s ease",
                  }}
                  onMouseEnter={(e) => (e.currentTarget.style.background = "#F5F3EF")}
                  onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}
                >
                  <MessageSquare size={18} strokeWidth={1.8} />
                </Link>
              </>
            )}

            {/* Language Switcher (EN / नेपाली) */}
            <button
              type="button"
              onClick={toggleLanguage}
              title={language === "en" ? "नेपाली भाषामा हेर्नुहोस्" : "Switch to English"}
              aria-label="Switch Language"
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "5px",
                height: "34px",
                padding: "0 10px",
                borderRadius: "8px",
                background: language === "ne" ? "#FEF3C7" : "#F7F5F0",
                border: language === "ne" ? "1px solid #FDE68A" : "1px solid #E6E1D8",
                color: language === "ne" ? "#92400E" : "#4B443B",
                fontSize: "12.5px",
                fontWeight: 700,
                cursor: "pointer",
                transition: "all 0.15s ease",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.borderColor = "#E86F1C";
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.borderColor = language === "ne" ? "#FDE68A" : "#E6E1D8";
              }}
            >
              <Languages size={15} color={language === "ne" ? "#D97706" : "#E86F1C"} />
              <span>{language === "en" ? "नेपाली" : "English"}</span>
            </button>

            {/* Shopping Cart */}
            <Link
              href="/cart"
              title="Shopping Cart"
              aria-label="Shopping Cart"
              style={{
                position: "relative",
                width: "36px",
                height: "36px",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                borderRadius: "8px",
                color: "#4B443B",
                textDecoration: "none",
                transition: "background 0.15s ease",
              }}
              onMouseEnter={(e) => (e.currentTarget.style.background = "#F5F3EF")}
              onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}
            >
              <ShoppingCart size={18} strokeWidth={1.8} />
              {totalCount > 0 && (
                <span
                  style={{
                    position: "absolute",
                    top: "2px",
                    right: "2px",
                    background: "#E86F1C",
                    color: "#FFFFFF",
                    borderRadius: "9999px",
                    fontSize: "0.68rem",
                    fontWeight: 800,
                    minWidth: "17px",
                    height: "17px",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    padding: "0 4px",
                    border: "2px solid #FFFFFF",
                    boxShadow: "0 1px 3px rgba(0,0,0,0.1)",
                  }}
                >
                  {totalCount}
                </span>
              )}
            </Link>

            {/* Account 👤 (Dropdown when logged in, Sign In when logged out) */}
            <div style={{ position: "relative" }} ref={profileRef}>
              {isLoggedIn ? (
                <button
                  type="button"
                  onClick={() => setProfileOpen(!profileOpen)}
                  style={{
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "0.45rem",
                    padding: "0.3rem 0.6rem 0.3rem 0.35rem",
                    borderRadius: "9999px",
                    background: profileOpen ? "#F5F2EC" : "transparent",
                    border: "1px solid",
                    borderColor: profileOpen ? "#E5E0D6" : "#EBE6DF",
                    cursor: "pointer",
                    transition: "all 0.15s ease",
                  }}
                  onMouseEnter={(e) => {
                    if (!profileOpen) e.currentTarget.style.background = "#F9F8F5";
                  }}
                  onMouseLeave={(e) => {
                    if (!profileOpen) e.currentTarget.style.background = "transparent";
                  }}
                >
                  <div
                    style={{
                      width: "28px",
                      height: "28px",
                      borderRadius: "50%",
                      background: "#E86F1C",
                      color: "#FFFFFF",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontWeight: 750,
                      fontSize: "0.82rem",
                    }}
                  >
                    {initial}
                  </div>
                  <span
                    className="nav-desktop-only"
                    style={{
                      fontSize: "0.85rem",
                      fontWeight: 600,
                      color: "#1F2937",
                      maxWidth: "90px",
                      overflow: "hidden",
                      textOverflow: "ellipsis",
                      whiteSpace: "nowrap",
                    }}
                  >
                    Account
                  </span>
                  <ChevronDown size={13} strokeWidth={2} color="#6B7280" />
                </button>
              ) : (
                <Link
                  href="/login"
                  style={{
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "0.35rem",
                    padding: "0.42rem 0.8rem",
                    borderRadius: "6px",
                    fontSize: "0.88rem",
                    fontWeight: 600,
                    color: "#4B443B",
                    textDecoration: "none",
                    transition: "all 0.15s ease",
                  }}
                  onMouseEnter={(e) => {
                    e.currentTarget.style.background = "#F5F3EF";
                    e.currentTarget.style.color = "#E86F1C";
                  }}
                  onMouseLeave={(e) => {
                    e.currentTarget.style.background = "transparent";
                    e.currentTarget.style.color = "#4B443B";
                  }}
                >
                  <User size={16} strokeWidth={1.8} />
                  <span>Login</span>
                </Link>
              )}

              {/* Profile Dropdown Menu */}
              {isLoggedIn && profileOpen && (
                <div
                  style={{
                    position: "absolute",
                    right: 0,
                    top: "calc(100% + 8px)",
                    background: "#FFFFFF",
                    border: "1px solid #EAE5DE",
                    borderRadius: "12px",
                    boxShadow: "0 12px 32px -4px rgba(0, 0, 0, 0.12), 0 0 0 1px rgba(0, 0, 0, 0.04)",
                    minWidth: "210px",
                    padding: "0.5rem 0",
                    zIndex: 300,
                  }}
                >
                  <div style={{ padding: "0.75rem 1rem", borderBottom: "1px solid #F5F1EB" }}>
                    <div style={{ fontWeight: 750, fontSize: "0.92rem", color: "#111827" }}>
                      {displayName}
                    </div>
                    <div style={{ fontSize: "0.78rem", color: "#6B7280", marginTop: "1px" }}>
                      {user?.email || firebaseUser?.email}
                    </div>
                  </div>

                  <div style={{ padding: "0.35rem 0" }}>
                    <Link
                      href="/account"
                      style={{
                        display: "flex",
                        alignItems: "center",
                        gap: "0.65rem",
                        padding: "0.55rem 1rem",
                        fontSize: "0.88rem",
                        color: "#374151",
                        textDecoration: "none",
                      }}
                      onMouseEnter={(e) => (e.currentTarget.style.background = "#F9F8F5")}
                      onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}
                    >
                      <User size={15} color="#6B7280" strokeWidth={1.8} /> My Account &amp; Orders
                    </Link>

                    {role === "admin" && (
                      <Link
                        href="/admin"
                        style={{
                          display: "flex",
                          alignItems: "center",
                          gap: "0.65rem",
                          padding: "0.55rem 1rem",
                          fontSize: "0.88rem",
                          color: "var(--color-warning)",
                          fontWeight: 650,
                          textDecoration: "none",
                        }}
                        onMouseEnter={(e) => (e.currentTarget.style.background = "#F9F8F5")}
                        onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}
                      >
                        <ShieldAlert size={15} strokeWidth={1.8} /> Admin Console
                      </Link>
                    )}

                    {role === "technician" && (
                      <Link
                        href="/technician"
                        style={{
                          display: "flex",
                          alignItems: "center",
                          gap: "0.65rem",
                          padding: "0.55rem 1rem",
                          fontSize: "0.88rem",
                          color: "var(--color-info)",
                          fontWeight: 650,
                          textDecoration: "none",
                        }}
                        onMouseEnter={(e) => (e.currentTarget.style.background = "#F9F8F5")}
                        onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}
                      >
                        <Hammer size={15} strokeWidth={1.8} /> Technician Portal
                      </Link>
                    )}

                    <div style={{ borderTop: "1px solid #F5F1EB", marginTop: "4px" }}>
                      <button
                        type="button"
                        onClick={() => {
                          setProfileOpen(false);
                          signOut();
                        }}
                        style={{
                          width: "100%",
                          textAlign: "left",
                          background: "none",
                          border: "none",
                          display: "flex",
                          alignItems: "center",
                          gap: "0.65rem",
                          padding: "0.55rem 1rem",
                          fontSize: "0.88rem",
                          color: "var(--color-danger)",
                          cursor: "pointer",
                        }}
                        onMouseEnter={(e) => (e.currentTarget.style.background = "#FEF2F2")}
                        onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}
                      >
                        <LogOut size={15} strokeWidth={1.8} /> Sign Out
                      </button>
                    </div>
                  </div>
                </div>
              )}
            </div>
            {/* Mobile Menu Button */}
            <button
              type="button"
              className="nav-mobile-only"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              aria-label="Toggle navigation menu"
              style={{
                width: "36px",
                height: "36px",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                background: "transparent",
                border: "none",
                color: "#1F2937",
                cursor: "pointer",
              }}
            >
              {mobileMenuOpen ? <X size={22} /> : <Menu size={22} />}
            </button>
          </div>
        </div>
      </div>

      {/* ──────────────── DOWN BAR (ROW 2): NAVIGATION WITH BORDER BOTTOM SELECTION ──────────────── */}
      <div
        className="nav-desktop-only"
        style={{
          borderBottom: "1px solid #ECE7E0",
          background: "#FFFFFF",
        }}
      >
        <div
          className="container"
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            height: "44px",
            padding: "0 1.25rem",
          }}
        >
          {/* Main 5 Navigation Links with Clean Border Bottom Indicator */}
          <nav
            style={{
              display: "flex",
              alignItems: "center",
              gap: "0.75rem",
              height: "44px",
            }}
          >
            <Link
              href="/"
              style={{
                display: "inline-flex",
                alignItems: "center",
                height: "44px",
                padding: "0 0.85rem",
                fontSize: "0.88rem",
                fontWeight: isHome ? 700 : 500,
                color: isHome ? "#E86F1C" : "#374151",
                background: "transparent",
                borderBottom: isHome ? "2.5px solid #E86F1C" : "2.5px solid transparent",
                textDecoration: "none",
                transition: "color 0.15s ease, border-color 0.15s ease",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.color = "#E86F1C";
                if (!isHome) e.currentTarget.style.borderBottomColor = "#FED7AA";
              }}
              onMouseLeave={(e) => {
                if (!isHome) {
                  e.currentTarget.style.color = "#374151";
                  e.currentTarget.style.borderBottomColor = "transparent";
                }
              }}
            >
              {t("nav.home")}
            </Link>

            <Link
              href="/services"
              style={{
                display: "inline-flex",
                alignItems: "center",
                height: "44px",
                padding: "0 0.85rem",
                fontSize: "0.88rem",
                fontWeight: isRepair ? 700 : 500,
                color: isRepair ? "#E86F1C" : "#374151",
                background: "transparent",
                borderBottom: isRepair ? "2.5px solid #E86F1C" : "2.5px solid transparent",
                textDecoration: "none",
                transition: "color 0.15s ease, border-color 0.15s ease",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.color = "#E86F1C";
                if (!isRepair) e.currentTarget.style.borderBottomColor = "#FED7AA";
              }}
              onMouseLeave={(e) => {
                if (!isRepair) {
                  e.currentTarget.style.color = "#374151";
                  e.currentTarget.style.borderBottomColor = "transparent";
                }
              }}
            >
              {t("nav.repair")}
            </Link>

            {/* Cost Estimator */}
            <Link
              href="/estimator"
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
                height: "44px",
                padding: "0 0.85rem",
                fontSize: "0.88rem",
                fontWeight: isEstimator ? 700 : 500,
                color: isEstimator ? "#E86F1C" : "#374151",
                background: "transparent",
                borderBottom: isEstimator ? "2.5px solid #E86F1C" : "2.5px solid transparent",
                textDecoration: "none",
                transition: "color 0.15s ease, border-color 0.15s ease",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.color = "#E86F1C";
                if (!isEstimator) e.currentTarget.style.borderBottomColor = "#FED7AA";
              }}
              onMouseLeave={(e) => {
                if (!isEstimator) {
                  e.currentTarget.style.color = "#374151";
                  e.currentTarget.style.borderBottomColor = "transparent";
                }
              }}
            >
              <span>{t("nav.estimator")}</span>
              <span
                style={{
                  fontSize: "9.5px",
                  fontWeight: 750,
                  background: "#FFF3EA",
                  color: "#E86F1C",
                  border: "1px solid #FED7AA",
                  padding: "1px 5px",
                  borderRadius: "999px",
                  letterSpacing: "0.02em",
                }}
              >
                FREE
              </span>
            </Link>

            <Link
              href="/shop"
              style={{
                display: "inline-flex",
                alignItems: "center",
                height: "44px",
                padding: "0 0.85rem",
                fontSize: "0.88rem",
                fontWeight: isShop ? 700 : 500,
                color: isShop ? "#E86F1C" : "#374151",
                background: "transparent",
                borderBottom: isShop ? "2.5px solid #E86F1C" : "2.5px solid transparent",
                textDecoration: "none",
                transition: "color 0.15s ease, border-color 0.15s ease",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.color = "#E86F1C";
                if (!isShop) e.currentTarget.style.borderBottomColor = "#FED7AA";
              }}
              onMouseLeave={(e) => {
                if (!isShop) {
                  e.currentTarget.style.color = "#374151";
                  e.currentTarget.style.borderBottomColor = "transparent";
                }
              }}
            >
              {t("nav.shop")}
            </Link>

            <Link
              href="/used"
              style={{
                display: "inline-flex",
                alignItems: "center",
                height: "44px",
                padding: "0 0.85rem",
                fontSize: "0.88rem",
                fontWeight: isPreowned ? 700 : 500,
                color: isPreowned ? "#E86F1C" : "#374151",
                background: "transparent",
                borderBottom: isPreowned ? "2.5px solid #E86F1C" : "2.5px solid transparent",
                textDecoration: "none",
                transition: "color 0.15s ease, border-color 0.15s ease",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.color = "#E86F1C";
                if (!isPreowned) e.currentTarget.style.borderBottomColor = "#FED7AA";
              }}
              onMouseLeave={(e) => {
                if (!isPreowned) {
                  e.currentTarget.style.color = "#374151";
                  e.currentTarget.style.borderBottomColor = "transparent";
                }
              }}
            >
              {t("nav.preowned")}
            </Link>
          </nav>

          {/* Right Sub-text / Guarantee Note */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "0.5rem",
              fontSize: "0.78rem",
              color: "#8E877F",
            }}
          >
            <span>{t("nav.janakpurCenter")}</span>
            <span style={{ color: "#D1C7BD" }}>•</span>
            <span style={{ color: "#E86F1C", fontWeight: 600 }}>{t("nav.freeInspection")}</span>
          </div>
        </div>
      </div>

      {/* ──────────────── MOBILE DRAWER ──────────────── */}
      {mobileMenuOpen && (
        <div
          className="nav-mobile-only"
          style={{
            flexDirection: "column",
            background: "#FFFFFF",
            borderTop: "1px solid #ECE7E0",
            padding: "1rem 1.25rem 1.5rem 1.25rem",
            boxShadow: "0 10px 20px rgba(0,0,0,0.05)",
          }}
        >
          {/* Mobile Search */}
          <form onSubmit={handleSearch} style={{ position: "relative", marginBottom: "1rem" }}>
            <Search
              size={17}
              strokeWidth={1.8}
              style={{
                position: "absolute",
                left: "12px",
                top: "50%",
                transform: "translateY(-50%)",
                color: "#9CA3AF",
              }}
            />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search cameras, lenses, drones..."
              style={{
                width: "100%",
                padding: "0.65rem 2.2rem 0.65rem 2.4rem",
                background: "#F7F5F0",
                border: "1px solid #E6E1D8",
                borderRadius: "8px",
                fontSize: "0.9rem",
                color: "#111827",
                outline: "none",
              }}
            />
            {searchQuery && (
              <button
                type="button"
                onClick={() => setSearchQuery("")}
                aria-label="Clear query"
                style={{
                  position: "absolute",
                  right: "10px",
                  top: "50%",
                  transform: "translateY(-50%)",
                  background: "none",
                  border: "none",
                  cursor: "pointer",
                  padding: "4px",
                  color: "#9CA3AF",
                  display: "flex",
                }}
              >
                <X size={16} />
              </button>
            )}
          </form>

          {/* Navigation Links Mobile */}
          <div style={{ display: "flex", flexDirection: "column", gap: "0.25rem" }}>
            <Link
              href="/"
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                padding: "0.65rem 0.75rem",
                borderRadius: "4px",
                textDecoration: "none",
                fontSize: "0.92rem",
                fontWeight: isHome ? 700 : 500,
                color: isHome ? "#E86F1C" : "#1F2937",
                background: "transparent",
                borderLeft: isHome ? "3px solid #E86F1C" : "3px solid transparent",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "0.6rem" }}>
                <Home size={18} strokeWidth={1.8} color={isHome ? "#E86F1C" : "#6B7280"} />
                <span>Home</span>
              </div>
              <ArrowRight size={14} color="#9CA3AF" />
            </Link>

            <Link
              href="/services"
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                padding: "0.65rem 0.75rem",
                borderRadius: "4px",
                textDecoration: "none",
                fontSize: "0.92rem",
                fontWeight: isRepair ? 700 : 500,
                color: isRepair ? "#E86F1C" : "#1F2937",
                background: "transparent",
                borderLeft: isRepair ? "3px solid #E86F1C" : "3px solid transparent",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "0.6rem" }}>
                <Wrench size={18} strokeWidth={1.8} color={isRepair ? "#E86F1C" : "#6B7280"} />
                <span>{t("nav.repair")}</span>
              </div>
              <ArrowRight size={14} color="#9CA3AF" />
            </Link>

            <Link
              href="/estimator"
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                padding: "0.65rem 0.75rem",
                borderRadius: "4px",
                textDecoration: "none",
                fontSize: "0.92rem",
                fontWeight: isEstimator ? 700 : 500,
                color: isEstimator ? "#E86F1C" : "#1F2937",
                background: "transparent",
                borderLeft: isEstimator ? "3px solid #E86F1C" : "3px solid transparent",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "0.6rem" }}>
                <Calculator size={18} strokeWidth={1.8} color={isEstimator ? "#E86F1C" : "#6B7280"} />
                <span>{t("nav.estimator")}</span>
              </div>
              <span
                style={{
                  fontSize: "9.5px",
                  fontWeight: 750,
                  background: "#FFF3EA",
                  color: "#E86F1C",
                  border: "1px solid #FED7AA",
                  padding: "1px 6px",
                  borderRadius: "999px",
                }}
              >
                FREE
              </span>
            </Link>

            <Link
              href="/shop"
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                padding: "0.65rem 0.75rem",
                borderRadius: "4px",
                textDecoration: "none",
                fontSize: "0.92rem",
                fontWeight: isShop ? 700 : 500,
                color: isShop ? "#E86F1C" : "#1F2937",
                background: "transparent",
                borderLeft: isShop ? "3px solid #E86F1C" : "3px solid transparent",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "0.6rem" }}>
                <ShoppingBag size={18} strokeWidth={1.8} color={isShop ? "#E86F1C" : "#6B7280"} />
                <span>Shop</span>
              </div>
              <ArrowRight size={14} color="#9CA3AF" />
            </Link>

            <Link
              href="/used"
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                padding: "0.65rem 0.75rem",
                borderRadius: "4px",
                textDecoration: "none",
                fontSize: "0.92rem",
                fontWeight: isPreowned ? 700 : 500,
                color: isPreowned ? "#E86F1C" : "#1F2937",
                background: "transparent",
                borderLeft: isPreowned ? "3px solid #E86F1C" : "3px solid transparent",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "0.6rem" }}>
                <RotateCcw size={18} strokeWidth={1.8} color={isPreowned ? "#E86F1C" : "#6B7280"} />
                <span>Pre-owned</span>
              </div>
              <ArrowRight size={14} color="#9CA3AF" />
            </Link>

            <div style={{ height: "1px", background: "#F3F4F6", margin: "0.5rem 0" }} />

            {/* Mobile Account */}
            {isLoggedIn ? (
              <Link
                href="/account"
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "0.6rem",
                  padding: "0.65rem 0.75rem",
                  borderRadius: "8px",
                  textDecoration: "none",
                  fontSize: "0.9rem",
                  color: "#4B5563",
                  fontWeight: 500,
                }}
              >
                <User size={17} strokeWidth={1.8} color="#6B7280" />
                <span>Account ({displayName})</span>
              </Link>
            ) : (
              <Link
                href="/login"
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "0.6rem",
                  padding: "0.65rem 0.75rem",
                  borderRadius: "8px",
                  textDecoration: "none",
                  fontSize: "0.9rem",
                  color: "#E86F1C",
                  fontWeight: 700,
                }}
              >
                <LogIn size={17} strokeWidth={1.8} color="#E86F1C" />
                <span>Login</span>
              </Link>
            )}
          </div>
        </div>
      )}
    </header>
  );
};
