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
} from "lucide-react";

export const Navbar: React.FC = () => {
  const router = useRouter();
  const pathname = usePathname();
  const { user, role, firebaseUser, signOut } = useAuth();
  const { totalCount } = useCart();

  const [searchQuery, setSearchQuery] = useState("");
  const [profileOpen, setProfileOpen] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const profileRef = useRef<HTMLDivElement>(null);

  // Close menus on outside click
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      const target = event.target as Node;
      if (profileRef.current && !profileRef.current.contains(target)) {
        setProfileOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Close menus on route change
  useEffect(() => {
    setProfileOpen(false);
    setMobileMenuOpen(false);
  }, [pathname]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      router.push(`/shop?q=${encodeURIComponent(searchQuery.trim())}`);
      setMobileMenuOpen(false);
    }
  };

  const isHome = pathname === "/" || pathname === "";
  const isRepair = pathname.startsWith("/services");
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
          <form
            onSubmit={handleSearch}
            className="nav-desktop-only"
            style={{
              flex: 1,
              maxWidth: "540px",
              position: "relative",
            }}
          >
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
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search products, repairs, certified equipment..."
              style={{
                width: "100%",
                padding: "0.55rem 1rem 0.55rem 2.45rem",
                background: "#F7F5F0",
                border: "1px solid #E6E1D8",
                borderRadius: "9999px",
                fontSize: "0.88rem",
                color: "#1A1A1A",
                outline: "none",
                transition: "all 0.15s ease",
              }}
              onFocus={(e) => {
                e.currentTarget.style.borderColor = "#E86F1C";
                e.currentTarget.style.background = "#FFFFFF";
                e.currentTarget.style.boxShadow = "0 0 0 3px rgba(232, 111, 28, 0.1)";
              }}
              onBlur={(e) => {
                e.currentTarget.style.borderColor = "#E6E1D8";
                e.currentTarget.style.background = "#F7F5F0";
                e.currentTarget.style.boxShadow = "none";
              }}
            />
          </form>

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
              Home
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
              Repair
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
              Shop
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
              Pre-owned
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
            <span>Janakpur Center</span>
            <span style={{ color: "#D1C7BD" }}>•</span>
            <span style={{ color: "#E86F1C", fontWeight: 600 }}>Free Physical Inspection</span>
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
              placeholder="Search products, repairs, certified equipment..."
              style={{
                width: "100%",
                padding: "0.65rem 1rem 0.65rem 2.4rem",
                background: "#F7F5F0",
                border: "1px solid #E6E1D8",
                borderRadius: "8px",
                fontSize: "0.9rem",
                color: "#111827",
                outline: "none",
              }}
            />
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
                <span>Repair</span>
              </div>
              <ArrowRight size={14} color="#9CA3AF" />
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
