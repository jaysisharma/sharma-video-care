"use client";

import React, { useState, useEffect, useRef, useMemo } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  collection,
  query,
  onSnapshot,
  orderBy,
} from "firebase/firestore";
import { db } from "../lib/firebase";
import { useAuth } from "../context/AuthContext";
import {
  Bell,
  Check,
  CheckCheck,
  ExternalLink,
  Sparkles,
  Tag,
  Wrench,
  Package,
  Shield,
  Info,
  X,
  Users,
  UserCheck,
  UserX,
} from "lucide-react";

export interface WebNotification {
  id: string;
  title: string;
  message: string;
  category?: "offers" | "repairs" | "orders" | "system";
  targetGroup?: "all" | "users" | "guest" | "specific";
  userId?: string;
  actionRoute?: string;
  actionLabel?: string;
  imageUrl?: string;
  createdAt: string;
}

const STORAGE_KEY = "videocare_read_notifs";

export const NotificationBell: React.FC<{ isMobile?: boolean }> = ({ isMobile }) => {
  const router = useRouter();
  const { user, firebaseUser } = useAuth();
  const [notifications, setNotifications] = useState<WebNotification[]>([]);
  const [readIds, setReadIds] = useState<Set<string>>(new Set());
  const [isOpen, setIsOpen] = useState(false);
  const [filter, setFilter] = useState<"all" | "unread">("all");
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Load read notifications from localStorage
  useEffect(() => {
    if (typeof window === "undefined") return;
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) {
        setReadIds(new Set(JSON.parse(stored)));
      }
    } catch {
      // Ignore storage errors
    }
  }, []);

  // Sync notifications from Firestore
  useEffect(() => {
    try {
      const q = query(collection(db, "notifications"), orderBy("createdAt", "desc"));
      const unsubscribe = onSnapshot(
        q,
        (snapshot) => {
          const items: WebNotification[] = [];
          snapshot.forEach((doc) => {
            const data = doc.data();
            items.push({
              id: doc.id,
              title: data.title || "Notification",
              message: data.message || "",
              category: data.category || "system",
              targetGroup: data.targetGroup || "all",
              userId: data.userId,
              actionRoute: data.actionRoute,
              actionLabel: data.actionLabel,
              imageUrl: data.imageUrl,
              createdAt: data.createdAt || new Date().toISOString(),
            });
          });
          setNotifications(items);
        },
        (error) => {
          console.warn("Falling back to client-side sort for notifications:", error.message);
          // Fallback if index on createdAt desc is missing
          const fallbackSub = onSnapshot(collection(db, "notifications"), (snap) => {
            const items: WebNotification[] = [];
            snap.forEach((doc) => {
              const data = doc.data();
              items.push({
                id: doc.id,
                title: data.title || "Notification",
                message: data.message || "",
                category: data.category || "system",
                targetGroup: data.targetGroup || "all",
                userId: data.userId,
                actionRoute: data.actionRoute,
                actionLabel: data.actionLabel,
                imageUrl: data.imageUrl,
                createdAt: data.createdAt || new Date().toISOString(),
              });
            });
            items.sort((a, b) => b.createdAt.localeCompare(a.createdAt));
            setNotifications(items);
          });
          return () => fallbackSub();
        }
      );

      return () => unsubscribe();
    } catch (err) {
      console.error("Error setting up notifications listener:", err);
    }
  }, []);

  // Filter based on audience: All vs Logged-In User vs Guest Visitor
  const targetedNotifications = useMemo(() => {
    const isAuth = !!firebaseUser || !!user;
    const currentUid = firebaseUser?.uid || user?.id;
    const currentEmail = firebaseUser?.email || user?.email;

    return notifications.filter((item) => {
      const target = item.targetGroup || "all";
      const uId = item.userId;

      // Broadcast to everyone
      if (target === "all" || uId === "all") return true;

      if (isAuth) {
        // Authenticated user audience
        if (target === "users" || uId === "users") return true;
        // Specific user targeted
        if (target === "specific" && (uId === currentUid || (currentEmail && uId === currentEmail))) {
          return true;
        }
        return false;
      } else {
        // Guest/anonymous visitor audience
        if (target === "guest" || uId === "guest") return true;
        return false;
      }
    });
  }, [notifications, firebaseUser, user]);

  const unreadCount = useMemo(() => {
    return targetedNotifications.filter((n) => !readIds.has(n.id)).length;
  }, [targetedNotifications, readIds]);

  const displayedNotifications = useMemo(() => {
    if (filter === "unread") {
      return targetedNotifications.filter((n) => !readIds.has(n.id));
    }
    return targetedNotifications;
  }, [targetedNotifications, filter, readIds]);

  const markAsRead = (id: string) => {
    const next = new Set(readIds);
    next.add(id);
    setReadIds(next);
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(Array.from(next)));
    } catch {}
  };

  const markAllAsRead = () => {
    const next = new Set(readIds);
    targetedNotifications.forEach((n) => next.add(n.id));
    setReadIds(next);
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(Array.from(next)));
    } catch {}
  };

  // Close on outside click
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    if (isOpen) {
      document.addEventListener("mousedown", handleClickOutside);
    }
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [isOpen]);

  const getCategoryIcon = (cat?: string) => {
    switch (cat) {
      case "offers":
        return <Tag size={13} style={{ color: "#E86F1C" }} />;
      case "repairs":
        return <Wrench size={13} style={{ color: "#2563EB" }} />;
      case "orders":
        return <Package size={13} style={{ color: "#059669" }} />;
      default:
        return <Info size={13} style={{ color: "#6B7280" }} />;
    }
  };

  const getAudienceBadge = (target?: string) => {
    if (target === "guest") {
      return (
        <span
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: "3px",
            fontSize: "0.68rem",
            fontWeight: 700,
            textTransform: "uppercase",
            letterSpacing: "0.04em",
            padding: "2px 6px",
            borderRadius: "4px",
            background: "#FEF3C7",
            color: "#92400E",
          }}
        >
          <UserX size={10} /> Guest
        </span>
      );
    }
    if (target === "users") {
      return (
        <span
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: "3px",
            fontSize: "0.68rem",
            fontWeight: 700,
            textTransform: "uppercase",
            letterSpacing: "0.04em",
            padding: "2px 6px",
            borderRadius: "4px",
            background: "#DBEAFE",
            color: "#1E40AF",
          }}
        >
          <UserCheck size={10} /> Members
        </span>
      );
    }
    return (
      <span
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: "3px",
          fontSize: "0.68rem",
          fontWeight: 700,
          textTransform: "uppercase",
          letterSpacing: "0.04em",
          padding: "2px 6px",
          borderRadius: "4px",
          background: "#F3F4F6",
          color: "#4B5563",
        }}
      >
        <Users size={10} /> All
      </span>
    );
  };

  const formatRelativeTime = (isoString: string) => {
    try {
      const date = new Date(isoString);
      const diffMs = Date.now() - date.getTime();
      const diffMins = Math.floor(diffMs / (60 * 1000));
      if (diffMins < 1) return "Just now";
      if (diffMins < 60) return `${diffMins}m ago`;
      const diffHours = Math.floor(diffMins / 60);
      if (diffHours < 24) return `${diffHours}h ago`;
      const diffDays = Math.floor(diffHours / 24);
      if (diffDays < 7) return `${diffDays}d ago`;
      return date.toLocaleDateString("en-US", { month: "short", day: "numeric" });
    } catch {
      return "";
    }
  };

  return (
    <div ref={dropdownRef} style={{ position: "relative" }}>
      {/* Bell Button */}
      <button
        type="button"
        title="Notifications"
        aria-label="View notifications"
        onClick={() => setIsOpen((prev) => !prev)}
        style={{
          width: "36px",
          height: "36px",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          borderRadius: "50%",
          color: isOpen ? "#E86F1C" : "#4B443B",
          background: isOpen ? "#FDF4EE" : "transparent",
          border: "none",
          cursor: "pointer",
          position: "relative",
          transition: "all 0.15s ease",
        }}
        onMouseEnter={(e) => {
          if (!isOpen) e.currentTarget.style.background = "#F5F3EF";
        }}
        onMouseLeave={(e) => {
          if (!isOpen) e.currentTarget.style.background = "transparent";
        }}
      >
        <Bell size={18} strokeWidth={1.8} />
        {unreadCount > 0 && (
          <span
            style={{
              position: "absolute",
              top: "4px",
              right: "4px",
              minWidth: "16px",
              height: "16px",
              borderRadius: "8px",
              backgroundColor: "#E86F1C",
              color: "#FFFFFF",
              fontSize: "0.65rem",
              fontWeight: 700,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              padding: "0 3px",
              boxShadow: "0 0 0 2px #FFFFFF",
            }}
          >
            {unreadCount > 9 ? "9+" : unreadCount}
          </span>
        )}
      </button>

      {/* Dropdown Panel */}
      {isOpen && (
        <div
          style={{
            position: "absolute",
            top: "calc(100% + 8px)",
            right: isMobile ? "-60px" : "0px",
            width: "380px",
            maxWidth: "92vw",
            backgroundColor: "#FFFFFF",
            borderRadius: "16px",
            boxShadow: "0 20px 45px -10px rgba(0, 0, 0, 0.18), 0 0 0 1px rgba(0, 0, 0, 0.08)",
            zIndex: 1000,
            overflow: "hidden",
            display: "flex",
            flexDirection: "column",
            animation: "fadeIn 0.15s ease-out",
          }}
        >
          {/* Header */}
          <div
            style={{
              padding: "1rem 1.15rem 0.85rem",
              borderBottom: "1px solid #F0ECE6",
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              backgroundColor: "#FAFAF9",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
              <h3 style={{ margin: 0, fontSize: "0.98rem", fontWeight: 700, color: "#1F2937" }}>
                Notifications
              </h3>
              {unreadCount > 0 && (
                <span
                  style={{
                    background: "#FEE2E2",
                    color: "#DC2626",
                    fontSize: "0.72rem",
                    fontWeight: 700,
                    padding: "2px 7px",
                    borderRadius: "10px",
                  }}
                >
                  {unreadCount} new
                </span>
              )}
            </div>

            <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
              {unreadCount > 0 && (
                <button
                  type="button"
                  onClick={markAllAsRead}
                  style={{
                    background: "none",
                    border: "none",
                    color: "#E86F1C",
                    fontSize: "0.78rem",
                    fontWeight: 600,
                    cursor: "pointer",
                    display: "flex",
                    alignItems: "center",
                    gap: "4px",
                    padding: "4px 6px",
                    borderRadius: "6px",
                  }}
                  onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = "#FEF3C7")}
                  onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = "transparent")}
                >
                  <CheckCheck size={13} /> Mark read
                </button>
              )}
              <button
                type="button"
                onClick={() => setIsOpen(false)}
                style={{
                  background: "none",
                  border: "none",
                  color: "#9CA3AF",
                  cursor: "pointer",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  padding: "4px",
                  borderRadius: "6px",
                }}
              >
                <X size={16} />
              </button>
            </div>
          </div>

          {/* Filter Pills */}
          <div
            style={{
              padding: "0.5rem 1.15rem",
              display: "flex",
              gap: "6px",
              borderBottom: "1px solid #F5F3EF",
              backgroundColor: "#FFFFFF",
            }}
          >
            <button
              type="button"
              onClick={() => setFilter("all")}
              style={{
                border: "none",
                background: filter === "all" ? "#1F2937" : "#F3F4F6",
                color: filter === "all" ? "#FFFFFF" : "#4B5563",
                fontSize: "0.74rem",
                fontWeight: 600,
                padding: "3px 10px",
                borderRadius: "12px",
                cursor: "pointer",
                transition: "all 0.15s ease",
              }}
            >
              All ({targetedNotifications.length})
            </button>
            <button
              type="button"
              onClick={() => setFilter("unread")}
              style={{
                border: "none",
                background: filter === "unread" ? "#1F2937" : "#F3F4F6",
                color: filter === "unread" ? "#FFFFFF" : "#4B5563",
                fontSize: "0.74rem",
                fontWeight: 600,
                padding: "3px 10px",
                borderRadius: "12px",
                cursor: "pointer",
                transition: "all 0.15s ease",
              }}
            >
              Unread ({unreadCount})
            </button>
          </div>

          {/* List of Notifications */}
          <div
            style={{
              maxHeight: "380px",
              overflowY: "auto",
              display: "flex",
              flexDirection: "column",
            }}
          >
            {displayedNotifications.length === 0 ? (
              <div
                style={{
                  padding: "2.5rem 1.5rem",
                  textAlign: "center",
                  display: "flex",
                  flexDirection: "column",
                  alignItems: "center",
                  color: "#9CA3AF",
                }}
              >
                <div
                  style={{
                    width: "48px",
                    height: "48px",
                    borderRadius: "50%",
                    backgroundColor: "#F5F3EF",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    marginBottom: "0.75rem",
                    color: "#D1D5DB",
                  }}
                >
                  <Bell size={24} />
                </div>
                <p style={{ margin: "0 0 4px", fontSize: "0.88rem", fontWeight: 600, color: "#4B5563" }}>
                  {filter === "unread" ? "No unread notifications" : "All caught up!"}
                </p>
                <p style={{ margin: 0, fontSize: "0.76rem", color: "#9CA3AF" }}>
                  {filter === "unread"
                    ? "You have marked all notifications as read."
                    : "New announcements, offers & updates will appear here."}
                </p>
              </div>
            ) : (
              displayedNotifications.map((notif) => {
                const isRead = readIds.has(notif.id);
                const hasAction = !!notif.actionRoute;
                const route = notif.actionRoute
                  ? notif.actionRoute.startsWith("/")
                    ? notif.actionRoute
                    : `/${notif.actionRoute}`
                  : "";

                return (
                  <div
                    key={notif.id}
                    onClick={() => markAsRead(notif.id)}
                    style={{
                      padding: "0.95rem 1.15rem",
                      borderBottom: "1px solid #F5F3EF",
                      backgroundColor: isRead ? "#FFFFFF" : "#FDF8F3",
                      display: "flex",
                      flexDirection: "column",
                      gap: "6px",
                      cursor: "pointer",
                      transition: "background 0.15s ease",
                      position: "relative",
                    }}
                    onMouseEnter={(e) => {
                      if (isRead) e.currentTarget.style.backgroundColor = "#FAF8F5";
                    }}
                    onMouseLeave={(e) => {
                      if (isRead) e.currentTarget.style.backgroundColor = "#FFFFFF";
                    }}
                  >
                    {/* Unread indicator pip */}
                    {!isRead && (
                      <span
                        style={{
                          position: "absolute",
                          left: "8px",
                          top: "16px",
                          width: "6px",
                          height: "6px",
                          borderRadius: "50%",
                          backgroundColor: "#E86F1C",
                        }}
                      />
                    )}

                    {/* Meta bar: Category + Audience + Timestamp */}
                    <div
                      style={{
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "space-between",
                        gap: "6px",
                      }}
                    >
                      <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                        <span
                          style={{
                            display: "inline-flex",
                            alignItems: "center",
                            gap: "3px",
                            fontSize: "0.68rem",
                            fontWeight: 600,
                            textTransform: "capitalize",
                            color: "#4B5563",
                          }}
                        >
                          {getCategoryIcon(notif.category)}
                          {notif.category || "General"}
                        </span>
                        {getAudienceBadge(notif.targetGroup)}
                      </div>
                      <span style={{ fontSize: "0.7rem", color: "#9CA3AF" }}>
                        {formatRelativeTime(notif.createdAt)}
                      </span>
                    </div>

                    {/* Banner Image if present */}
                    {notif.imageUrl && (
                      <div
                        style={{
                          width: "100%",
                          height: "100px",
                          borderRadius: "8px",
                          overflow: "hidden",
                          marginTop: "2px",
                          marginBottom: "4px",
                          backgroundColor: "#F3F4F6",
                        }}
                      >
                        <img
                          src={notif.imageUrl}
                          alt={notif.title}
                          style={{
                            width: "100%",
                            height: "100%",
                            objectFit: "cover",
                          }}
                        />
                      </div>
                    )}

                    {/* Title */}
                    <h4
                      style={{
                        margin: 0,
                        fontSize: "0.85rem",
                        fontWeight: isRead ? 600 : 700,
                        color: "#1F2937",
                        lineHeight: 1.35,
                      }}
                    >
                      {notif.title}
                    </h4>

                    {/* Message Body */}
                    <p
                      style={{
                        margin: 0,
                        fontSize: "0.77rem",
                        color: "#6B7280",
                        lineHeight: 1.45,
                      }}
                    >
                      {notif.message}
                    </p>

                    {/* Deep link Action Button */}
                    {hasAction && (
                      <div style={{ marginTop: "4px", display: "flex", justifyContent: "flex-end" }}>
                        <button
                          type="button"
                          onClick={(e) => {
                            e.stopPropagation();
                            markAsRead(notif.id);
                            setIsOpen(false);
                            router.push(route);
                          }}
                          style={{
                            display: "inline-flex",
                            alignItems: "center",
                            gap: "4px",
                            background: "#E86F1C",
                            color: "#FFFFFF",
                            border: "none",
                            borderRadius: "6px",
                            padding: "4px 10px",
                            fontSize: "0.72rem",
                            fontWeight: 600,
                            cursor: "pointer",
                            transition: "background 0.15s ease",
                          }}
                          onMouseEnter={(e) => (e.currentTarget.style.background = "#D25F12")}
                          onMouseLeave={(e) => (e.currentTarget.style.background = "#E86F1C")}
                        >
                          {notif.actionLabel || "View Details"}
                          <ExternalLink size={11} />
                        </button>
                      </div>
                    )}
                  </div>
                );
              })
            )}
          </div>
        </div>
      )}
    </div>
  );
};
