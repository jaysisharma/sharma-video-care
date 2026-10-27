"use client";

import React, { useState, useEffect, useMemo } from "react";
import {
  collection,
  query,
  onSnapshot,
  addDoc,
  deleteDoc,
  doc,
  orderBy,
  Timestamp,
} from "firebase/firestore";
import { db } from "../../lib/firebase";
import { useSnackbar } from "../../context/SnackbarContext";
import { CloudinaryUpload } from "../CloudinaryUpload";
import {
  Bell,
  Send,
  Trash2,
  Copy,
  Users,
  UserCheck,
  UserX,
  Sparkles,
  Tag,
  Wrench,
  Package,
  Shield,
  Search,
  ExternalLink,
  Smartphone,
  Globe,
  CheckCircle2,
  AlertCircle,
  Plus,
  X,
  Filter,
} from "lucide-react";

export type NotificationTarget = "all" | "users" | "guest" | "specific";
export type NotificationCategory = "offers" | "repairs" | "orders" | "system";

export interface AdminNotificationRecord {
  id: string;
  title: string;
  message: string;
  category: NotificationCategory;
  targetGroup: NotificationTarget;
  userId?: string;
  actionRoute?: string;
  actionLabel?: string;
  imageUrl?: string;
  createdAt: string;
  createdBy?: string;
  isRead?: boolean;
}

const TEMPLATE_PRESETS = [
  {
    label: "Festive Promo",
    target: "all" as NotificationTarget,
    category: "offers" as NotificationCategory,
    title: "Festival Offer: Free Optical Cleaning with Every DSLR Repair",
    message: "Bring your camera or lens to Station Road, Janakpur for 45-point inspection & receive complimentary ultrasonic sensor cleaning.",
    actionRoute: "services",
    actionLabel: "Book Inspection",
  },
  {
    label: "New Gear Drop",
    target: "all" as NotificationTarget,
    category: "orders" as NotificationCategory,
    title: "Fresh Certified Pre-Owned Sony & Canon Bodies Just Arrived",
    message: "Inspected by bench technicians with 90-day warranty. Sony A7 IV and Canon R6 Mark II now in stock with cash/trade-in discount.",
    actionRoute: "shop",
    actionLabel: "View Equipment",
  },
  {
    label: "Guest Welcome",
    target: "guest" as NotificationTarget,
    category: "system" as NotificationCategory,
    title: "Welcome to QuickySewa Janakpur",
    message: "Need instant camera diagnostics or trade-in appraisal? Create an account or chat with our lab team for Rs. 0 initial diagnosis.",
    actionRoute: "account",
    actionLabel: "Join Free",
  },
  {
    label: "Trade-In Bonus",
    target: "users" as NotificationTarget,
    category: "offers" as NotificationCategory,
    title: "Exclusive Member Bonus: +10% Extra Store Credit on Trade-In",
    message: "Upgrade your DSLR or mirrorless body this month and receive an additional 10% credit payout toward new cinema gear.",
    actionRoute: "tradein",
    actionLabel: "Value My Gear",
  },
];

export function AdminNotificationsTab() {
  const snackbar = useSnackbar();
  const [notifications, setNotifications] = useState<AdminNotificationRecord[]>([]);
  const [loading, setLoading] = useState(true);

  // Filter state
  const [targetFilter, setTargetFilter] = useState<string>("all-targets");
  const [categoryFilter, setCategoryFilter] = useState<string>("all-cats");
  const [searchQuery, setSearchQuery] = useState("");

  // Modal / Composer state
  const [isComposerOpen, setIsComposerOpen] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  // Form fields
  const [title, setTitle] = useState("");
  const [message, setMessage] = useState("");
  const [category, setCategory] = useState<NotificationCategory>("offers");
  const [targetGroup, setTargetGroup] = useState<NotificationTarget>("all");
  const [specificUserId, setSpecificUserId] = useState("");
  const [actionRoute, setActionRoute] = useState("services");
  const [actionLabel, setActionLabel] = useState("Explore Now");
  const [imageUrl, setImageUrl] = useState("");
  const [previewDevice, setPreviewDevice] = useState<"mobile" | "web">("mobile");

  // Subscribe to notifications collection
  useEffect(() => {
    const q = query(collection(db, "notifications"));
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const items = snapshot.docs.map((d) => {
          const data = d.data();
          return {
            id: d.id,
            title: data.title || "",
            message: data.message || "",
            category: (data.category as NotificationCategory) || "system",
            targetGroup: (data.targetGroup as NotificationTarget) || "all",
            userId: data.userId,
            actionRoute: data.actionRoute,
            actionLabel: data.actionLabel,
            imageUrl: data.imageUrl,
            createdAt: data.createdAt || new Date().toISOString(),
            createdBy: data.createdBy,
            isRead: !!data.isRead,
          };
        });

        // Sort descending by creation date
        items.sort(
          (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
        );
        setNotifications(items);
        setLoading(false);
      },
      (err) => {
        console.error("Error fetching notifications:", err);
        setLoading(false);
      }
    );

    return () => unsubscribe();
  }, []);

  // Stats calculation
  const stats = useMemo(() => {
    return {
      total: notifications.length,
      all: notifications.filter((n) => n.targetGroup === "all").length,
      users: notifications.filter((n) => n.targetGroup === "users").length,
      guest: notifications.filter((n) => n.targetGroup === "guest").length,
      specific: notifications.filter((n) => n.targetGroup === "specific").length,
    };
  }, [notifications]);

  // Filtered notifications
  const filteredNotifications = useMemo(() => {
    return notifications.filter((n) => {
      if (targetFilter !== "all-targets" && n.targetGroup !== targetFilter) {
        return false;
      }
      if (categoryFilter !== "all-cats" && n.category !== categoryFilter) {
        return false;
      }
      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase();
        return (
          n.title.toLowerCase().includes(q) ||
          n.message.toLowerCase().includes(q) ||
          (n.actionLabel && n.actionLabel.toLowerCase().includes(q))
        );
      }
      return true;
    });
  }, [notifications, targetFilter, categoryFilter, searchQuery]);

  const handleApplyPreset = (preset: (typeof TEMPLATE_PRESETS)[0]) => {
    setTitle(preset.title);
    setMessage(preset.message);
    setCategory(preset.category);
    setTargetGroup(preset.target);
    setActionRoute(preset.actionRoute);
    setActionLabel(preset.actionLabel);
  };

  const handleSendNotification = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !message.trim()) {
      snackbar.error("Please provide both a Title and Message.");
      return;
    }

    if (targetGroup === "specific" && !specificUserId.trim()) {
      snackbar.error("Please provide the specific User ID or Email.");
      return;
    }

    setSubmitting(true);
    try {
      const now = new Date().toISOString();
      const payload: Record<string, any> = {
        title: title.trim(),
        message: message.trim(),
        category,
        targetGroup,
        userId: targetGroup === "specific" ? specificUserId.trim() : targetGroup,
        actionRoute: actionRoute.trim() || null,
        actionLabel: actionLabel.trim() || null,
        imageUrl: imageUrl.trim() || null,
        createdAt: now,
        createdBy: "admin",
        isRead: false,
      };

      await addDoc(collection(db, "notifications"), payload);

      snackbar.success(
        targetGroup === "all"
          ? "Notification broadcasted to ALL users & guests!"
          : targetGroup === "users"
          ? "Notification sent to all REGISTERED users!"
          : targetGroup === "guest"
          ? "Notification sent to GUEST users!"
          : `Notification sent to user ${specificUserId}!`
      );

      // Reset form
      setTitle("");
      setMessage("");
      setImageUrl("");
      setIsComposerOpen(false);
    } catch (err: any) {
      console.error("Failed to broadcast notification:", err);
      snackbar.error(err.message || "Failed to send notification.");
    } finally {
      setSubmitting(false);
    }
  };

  const handleDeleteNotification = async (id: string, itemTitle: string) => {
    if (!window.confirm(`Revoke and delete notification "${itemTitle}"?`)) {
      return;
    }

    try {
      await deleteDoc(doc(db, "notifications", id));
      snackbar.success("Notification removed.");
    } catch (err: any) {
      console.error("Error deleting notification:", err);
      snackbar.error("Could not delete notification.");
    }
  };

  const handleDuplicate = (n: AdminNotificationRecord) => {
    setTitle(n.title);
    setMessage(n.message);
    setCategory(n.category);
    setTargetGroup(n.targetGroup);
    if (n.targetGroup === "specific" && n.userId) {
      setSpecificUserId(n.userId);
    }
    if (n.actionRoute) setActionRoute(n.actionRoute);
    if (n.actionLabel) setActionLabel(n.actionLabel);
    if (n.imageUrl) setImageUrl(n.imageUrl);
    setIsComposerOpen(true);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const getTargetBadge = (target: NotificationTarget) => {
    switch (target) {
      case "all":
        return {
          label: "All Users & Guests",
          bg: "#ECFDF5",
          color: "#059669",
          border: "#A7F3D0",
          icon: Globe,
        };
      case "users":
        return {
          label: "Registered Users",
          bg: "#EFF6FF",
          color: "#2563EB",
          border: "#BFDBFE",
          icon: UserCheck,
        };
      case "guest":
        return {
          label: "Guest Users",
          bg: "#FAF5FF",
          color: "#7E22CE",
          border: "#E9D5FF",
          icon: UserX,
        };
      case "specific":
        return {
          label: "Single Customer",
          bg: "#FFFBEB",
          color: "#D97706",
          border: "#FDE68A",
          icon: Users,
        };
    }
  };

  const getCategoryBadge = (cat: NotificationCategory) => {
    switch (cat) {
      case "offers":
        return { label: "Offers & Promos", color: "#EA580C", icon: Tag };
      case "repairs":
        return { label: "Repairs & Lab", color: "#2563EB", icon: Wrench };
      case "orders":
        return { label: "Orders & Shipping", color: "#059669", icon: Package };
      case "system":
        return { label: "System Alerts", color: "#6B21A8", icon: Shield };
    }
  };

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
      {/* Top Header Card */}
      <div
        className="admin-card"
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          flexWrap: "wrap",
          gap: "16px",
          padding: "20px 24px",
        }}
      >
        <div>
          <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
            <div
              style={{
                width: "40px",
                height: "40px",
                borderRadius: "10px",
                background: "#FFF7ED",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                color: "#E86F1C",
              }}
            >
              <Bell size={20} />
            </div>
            <div>
              <h2 style={{ fontSize: "1.25rem", fontWeight: 800, margin: 0, color: "#0F172A" }}>
                Push &amp; In-App Notifications Broadcast
              </h2>
              <p style={{ margin: "2px 0 0 0", fontSize: "0.85rem", color: "#64748B" }}>
                Target announcements to all users, registered customers, or guest browsers across Mobile &amp; Web.
              </p>
            </div>
          </div>
        </div>

        <button
          type="button"
          className="admin-btn admin-btn-primary"
          onClick={() => setIsComposerOpen(true)}
          style={{ display: "inline-flex", alignItems: "center", gap: "8px" }}
        >
          <Plus size={16} />
          <span>New Notification Broadcast</span>
        </button>
      </div>

      {/* Stats Counters */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
          gap: "14px",
        }}
      >
        <div className="admin-card" style={{ padding: "16px" }}>
          <div style={{ fontSize: "0.8rem", fontWeight: 650, color: "#64748B", textTransform: "uppercase" }}>
            Total Broadcasts
          </div>
          <div style={{ fontSize: "1.75rem", fontWeight: 850, color: "#0F172A", marginTop: "4px" }}>
            {stats.total}
          </div>
          <div style={{ fontSize: "0.75rem", color: "#94A3B8", marginTop: "2px" }}>
            Active &amp; historic broadcasts
          </div>
        </div>

        <div className="admin-card" style={{ padding: "16px", borderLeft: "4px solid #10B981" }}>
          <div style={{ fontSize: "0.8rem", fontWeight: 650, color: "#059669", textTransform: "uppercase" }}>
            🌐 To All (Everyone)
          </div>
          <div style={{ fontSize: "1.75rem", fontWeight: 850, color: "#059669", marginTop: "4px" }}>
            {stats.all}
          </div>
          <div style={{ fontSize: "0.75rem", color: "#64748B", marginTop: "2px" }}>
            Broadcast across all sessions
          </div>
        </div>

        <div className="admin-card" style={{ padding: "16px", borderLeft: "4px solid #2563EB" }}>
          <div style={{ fontSize: "0.8rem", fontWeight: 650, color: "#2563EB", textTransform: "uppercase" }}>
            👤 Registered Users
          </div>
          <div style={{ fontSize: "1.75rem", fontWeight: 850, color: "#2563EB", marginTop: "4px" }}>
            {stats.users}
          </div>
          <div style={{ fontSize: "0.75rem", color: "#64748B", marginTop: "2px" }}>
            Exclusive member announcements
          </div>
        </div>

        <div className="admin-card" style={{ padding: "16px", borderLeft: "4px solid #7E22CE" }}>
          <div style={{ fontSize: "0.8rem", fontWeight: 650, color: "#7E22CE", textTransform: "uppercase" }}>
            🧳 Guest Browsers
          </div>
          <div style={{ fontSize: "1.75rem", fontWeight: 850, color: "#7E22CE", marginTop: "4px" }}>
            {stats.guest}
          </div>
          <div style={{ fontSize: "0.75rem", color: "#64748B", marginTop: "2px" }}>
            Targeted onboarding alerts
          </div>
        </div>
      </div>

      {/* Composer Modal / Drawer */}
      {isComposerOpen && (
        <div
          style={{
            background: "#FFFFFF",
            border: "1.5px solid #E2E8F0",
            borderRadius: "16px",
            boxShadow: "0 10px 25px rgba(0, 0, 0, 0.08)",
            padding: "24px",
          }}
        >
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              marginBottom: "18px",
              paddingBottom: "14px",
              borderBottom: "1px solid #E2E8F0",
            }}
          >
            <div>
              <h3 style={{ margin: 0, fontSize: "1.15rem", fontWeight: 800, color: "#0F172A" }}>
                Compose Notification Broadcast
              </h3>
              <p style={{ margin: "2px 0 0 0", fontSize: "0.8rem", color: "#64748B" }}>
                Configure the audience target, message copy, and optional media banner.
              </p>
            </div>
            <button
              type="button"
              onClick={() => setIsComposerOpen(false)}
              style={{
                background: "#F1F5F9",
                border: "none",
                borderRadius: "50%",
                width: "32px",
                height: "32px",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                cursor: "pointer",
                color: "#64748B",
              }}
            >
              <X size={18} />
            </button>
          </div>

          {/* Quick Presets Bar */}
          <div style={{ marginBottom: "20px" }}>
            <div style={{ fontSize: "0.75rem", fontWeight: 700, color: "#64748B", textTransform: "uppercase", marginBottom: "8px" }}>
              ⚡ Quick Presets &amp; Templates
            </div>
            <div style={{ display: "flex", gap: "8px", flexWrap: "wrap" }}>
              {TEMPLATE_PRESETS.map((p, idx) => (
                <button
                  key={idx}
                  type="button"
                  onClick={() => handleApplyPreset(p)}
                  style={{
                    background: "#F8FAFC",
                    border: "1px solid #CBD5E1",
                    borderRadius: "20px",
                    padding: "6px 12px",
                    fontSize: "0.78rem",
                    fontWeight: 650,
                    color: "#334155",
                    cursor: "pointer",
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "6px",
                  }}
                >
                  <Sparkles size={12} color="#E86F1C" />
                  <span>{p.label}</span>
                </button>
              ))}
            </div>
          </div>

          <form onSubmit={handleSendNotification}>
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fit, minmax(320px, 1fr))",
                gap: "24px",
              }}
            >
              {/* Form Controls Column */}
              <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
                {/* 1. Target Audience Selection */}
                <div>
                  <label className="admin-label" style={{ display: "block", marginBottom: "8px" }}>
                    Target Audience *
                  </label>
                  <div
                    style={{
                      display: "grid",
                      gridTemplateColumns: "repeat(auto-fit, minmax(130px, 1fr))",
                      gap: "8px",
                    }}
                  >
                    {[
                      { id: "all", label: "🌐 All (Everyone)", desc: "Web + Mobile visitors" },
                      { id: "users", label: "👤 Registered Users", desc: "Logged in accounts" },
                      { id: "guest", label: "🧳 Guest Browsers", desc: "First-time visitors" },
                      { id: "specific", label: "🎯 Specific User", desc: "Select UID / Email" },
                    ].map((opt) => {
                      const selected = targetGroup === opt.id;
                      return (
                        <div
                          key={opt.id}
                          onClick={() => setTargetGroup(opt.id as NotificationTarget)}
                          style={{
                            border: `1.5px solid ${selected ? "#E86F1C" : "#E2E8F0"}`,
                            background: selected ? "#FFF7ED" : "#FFFFFF",
                            borderRadius: "10px",
                            padding: "10px",
                            cursor: "pointer",
                            transition: "all 0.15s ease",
                          }}
                        >
                          <div
                            style={{
                              fontSize: "0.82rem",
                              fontWeight: 750,
                              color: selected ? "#E86F1C" : "#1E293B",
                            }}
                          >
                            {opt.label}
                          </div>
                          <div style={{ fontSize: "0.7rem", color: "#64748B", marginTop: "2px" }}>
                            {opt.desc}
                          </div>
                        </div>
                      );
                    })}
                  </div>
                </div>

                {targetGroup === "specific" && (
                  <div className="admin-form-group">
                    <label className="admin-label">User ID or Phone/Email *</label>
                    <input
                      type="text"
                      className="admin-input"
                      value={specificUserId}
                      onChange={(e) => setSpecificUserId(e.target.value)}
                      placeholder="e.g. usr_12345 or user@example.com"
                      required
                    />
                  </div>
                )}

                {/* 2. Category */}
                <div className="admin-form-group">
                  <label className="admin-label">Notification Category</label>
                  <select
                    className="admin-input"
                    value={category}
                    onChange={(e) => setCategory(e.target.value as NotificationCategory)}
                  >
                    <option value="offers">🎁 Offers &amp; Promotions</option>
                    <option value="repairs">🔧 Repairs &amp; Lab Bench Status</option>
                    <option value="orders">📦 Orders, Shipping &amp; Inventory</option>
                    <option value="system">🛡️ System &amp; Service Bench Announcements</option>
                  </select>
                </div>

                {/* 3. Title */}
                <div className="admin-form-group">
                  <label className="admin-label">Notification Title *</label>
                  <input
                    type="text"
                    className="admin-input"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    placeholder="e.g. Dashain Discount: 15% Off Camera Sensor Cleaning"
                    maxLength={100}
                    required
                  />
                  <div style={{ fontSize: "0.7rem", color: "#94A3B8", textAlign: "right", marginTop: "2px" }}>
                    {title.length}/100 characters
                  </div>
                </div>

                {/* 4. Message Body */}
                <div className="admin-form-group">
                  <label className="admin-label">Message Body *</label>
                  <textarea
                    className="admin-input"
                    rows={3}
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    placeholder="Enter detailed notification content..."
                    maxLength={300}
                    required
                  />
                  <div style={{ fontSize: "0.7rem", color: "#94A3B8", textAlign: "right", marginTop: "2px" }}>
                    {message.length}/300 characters
                  </div>
                </div>

                {/* 5. Deep Link / Action Route */}
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "10px" }}>
                  <div className="admin-form-group">
                    <label className="admin-label">Action Route (Deep Link)</label>
                    <select
                      className="admin-input"
                      value={actionRoute}
                      onChange={(e) => setActionRoute(e.target.value)}
                    >
                      <option value="services">Repair Services (/services)</option>
                      <option value="shop">Store &amp; Catalog (/shop)</option>
                      <option value="tradein">Trade-In Valuation (/trade-in)</option>
                      <option value="chat">Live Support Chat (/chat)</option>
                      <option value="account">Account &amp; Security (/account)</option>
                      <option value="cart">Cart (/cart)</option>
                    </select>
                  </div>

                  <div className="admin-form-group">
                    <label className="admin-label">Button Label</label>
                    <input
                      type="text"
                      className="admin-input"
                      value={actionLabel}
                      onChange={(e) => setActionLabel(e.target.value)}
                      placeholder="e.g. Book Inspection, View Offer"
                    />
                  </div>
                </div>

                {/* 6. Media / Cloudinary Upload */}
                <div>
                  <CloudinaryUpload
                    value={imageUrl}
                    onChange={(url) => setImageUrl(url)}
                    onRemove={() => setImageUrl("")}
                    folder="video_care/notifications"
                    label="Promo Image / Banner (Optional)"
                    helperText="Upload an eye-catching banner for mobile & web preview"
                  />
                </div>
              </div>

              {/* Preview & Delivery Details Column */}
              <div
                style={{
                  background: "#F8FAFC",
                  borderRadius: "14px",
                  padding: "18px",
                  border: "1px solid #E2E8F0",
                  display: "flex",
                  flexDirection: "column",
                  justifyContent: "space-between",
                }}
              >
                <div>
                  <div
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                      marginBottom: "14px",
                    }}
                  >
                    <div style={{ fontSize: "0.85rem", fontWeight: 750, color: "#1E293B" }}>
                      📱 Live Notification Preview
                    </div>
                    <div style={{ display: "flex", gap: "4px" }}>
                      <button
                        type="button"
                        onClick={() => setPreviewDevice("mobile")}
                        style={{
                          background: previewDevice === "mobile" ? "#FFFFFF" : "transparent",
                          border: `1px solid ${previewDevice === "mobile" ? "#CBD5E1" : "transparent"}`,
                          borderRadius: "6px",
                          padding: "4px 8px",
                          fontSize: "0.72rem",
                          fontWeight: 650,
                          cursor: "pointer",
                        }}
                      >
                        Mobile App
                      </button>
                      <button
                        type="button"
                        onClick={() => setPreviewDevice("web")}
                        style={{
                          background: previewDevice === "web" ? "#FFFFFF" : "transparent",
                          border: `1px solid ${previewDevice === "web" ? "#CBD5E1" : "transparent"}`,
                          borderRadius: "6px",
                          padding: "4px 8px",
                          fontSize: "0.72rem",
                          fontWeight: 650,
                          cursor: "pointer",
                        }}
                      >
                        Web Navbar
                      </button>
                    </div>
                  </div>

                  {/* Preview Render Box */}
                  <div
                    style={{
                      background: "#FFFFFF",
                      borderRadius: "14px",
                      border: "1px solid #E2E8F0",
                      padding: "16px",
                      boxShadow: "0 4px 12px rgba(0, 0, 0, 0.05)",
                    }}
                  >
                    {/* Badge row */}
                    <div
                      style={{
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "space-between",
                        marginBottom: "10px",
                      }}
                    >
                      <span
                        style={{
                          fontSize: "0.7rem",
                          fontWeight: 750,
                          color: getCategoryBadge(category).color,
                          textTransform: "uppercase",
                          letterSpacing: "0.4px",
                        }}
                      >
                        {category.toUpperCase()}
                      </span>
                      <span
                        style={{
                          fontSize: "0.7rem",
                          fontWeight: 650,
                          padding: "2px 8px",
                          borderRadius: "12px",
                          background: getTargetBadge(targetGroup).bg,
                          color: getTargetBadge(targetGroup).color,
                          border: `1px solid ${getTargetBadge(targetGroup).border}`,
                        }}
                      >
                        {getTargetBadge(targetGroup).label}
                      </span>
                    </div>

                    {/* Image Banner if present */}
                    {imageUrl && (
                      <div
                        style={{
                          marginBottom: "10px",
                          borderRadius: "8px",
                          overflow: "hidden",
                          maxHeight: "140px",
                          border: "1px solid #E2E8F0",
                        }}
                      >
                        <img
                          src={imageUrl}
                          alt="Banner Preview"
                          style={{ width: "100%", height: "140px", objectFit: "cover" }}
                        />
                      </div>
                    )}

                    <div style={{ fontSize: "0.95rem", fontWeight: 750, color: "#0F172A", marginBottom: "4px" }}>
                      {title || "Your Notification Title Will Appear Here"}
                    </div>
                    <div style={{ fontSize: "0.8rem", color: "#475569", lineHeight: 1.45, marginBottom: "12px" }}>
                      {message || "Enter notification body text to see the live formatting in this preview box."}
                    </div>

                    {actionLabel && (
                      <div
                        style={{
                          display: "inline-flex",
                          alignItems: "center",
                          gap: "4px",
                          fontSize: "0.78rem",
                          fontWeight: 750,
                          color: "#EA580C",
                        }}
                      >
                        <span>{actionLabel}</span>
                        <span>→</span>
                      </div>
                    )}
                  </div>

                  {/* Target explanation pill */}
                  <div
                    style={{
                      marginTop: "16px",
                      padding: "10px 12px",
                      borderRadius: "8px",
                      background: "#FFFFFF",
                      border: "1px solid #E2E8F0",
                      fontSize: "0.78rem",
                      color: "#475569",
                      display: "flex",
                      alignItems: "flex-start",
                      gap: "8px",
                    }}
                  >
                    <CheckCircle2 size={16} color="#059669" style={{ flexShrink: 0, marginTop: "2px" }} />
                    <div>
                      <strong>Audience Policy:</strong>{" "}
                      {targetGroup === "all"
                        ? "Visible on all user accounts and guest browsers across Nepal."
                        : targetGroup === "users"
                        ? "Visible only after sign-in. Guests will not see this broadcast."
                        : targetGroup === "guest"
                        ? "Shown to non-signed-in guests to drive registrations and first repairs."
                        : `Delivered exclusively to target user ${specificUserId}.`}
                    </div>
                  </div>
                </div>

                {/* Submit Actions */}
                <div style={{ display: "flex", gap: "10px", marginTop: "24px" }}>
                  <button
                    type="button"
                    className="admin-btn admin-btn-outline"
                    onClick={() => setIsComposerOpen(false)}
                    style={{ flex: 1 }}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    disabled={submitting}
                    className="admin-btn admin-btn-primary"
                    style={{ flex: 2, display: "inline-flex", alignItems: "center", justifyContent: "center", gap: "8px" }}
                  >
                    <Send size={15} />
                    <span>{submitting ? "Broadcasting..." : "Broadcast Notification"}</span>
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      )}

      {/* Notification Filter & History Section */}
      <div className="admin-card" style={{ padding: "20px" }}>
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            flexWrap: "wrap",
            gap: "14px",
            marginBottom: "18px",
            paddingBottom: "14px",
            borderBottom: "1px solid #E2E8F0",
          }}
        >
          <div>
            <div style={{ fontSize: "1.05rem", fontWeight: 800, color: "#0F172A" }}>
              Notification Broadcast History
            </div>
            <div style={{ fontSize: "0.8rem", color: "#64748B" }}>
              Showing {filteredNotifications.length} of {notifications.length} broadcasts
            </div>
          </div>

          {/* Filters Bar */}
          <div style={{ display: "flex", gap: "8px", flexWrap: "wrap", alignItems: "center" }}>
            <div style={{ position: "relative" }}>
              <Search
                size={14}
                style={{ position: "absolute", left: "10px", top: "50%", transform: "translateY(-50%)", color: "#94A3B8" }}
              />
              <input
                type="text"
                placeholder="Search notifications..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{
                  padding: "6px 12px 6px 30px",
                  borderRadius: "8px",
                  border: "1px solid #CBD5E1",
                  fontSize: "0.8rem",
                  outline: "none",
                }}
              />
            </div>

            <select
              value={targetFilter}
              onChange={(e) => setTargetFilter(e.target.value)}
              style={{
                padding: "6px 10px",
                borderRadius: "8px",
                border: "1px solid #CBD5E1",
                fontSize: "0.8rem",
                background: "#FFFFFF",
              }}
            >
              <option value="all-targets">All Audiences</option>
              <option value="all">🌐 All (Broadcast)</option>
              <option value="users">👤 Registered Users</option>
              <option value="guest">🧳 Guest Users</option>
              <option value="specific">🎯 Specific User</option>
            </select>

            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              style={{
                padding: "6px 10px",
                borderRadius: "8px",
                border: "1px solid #CBD5E1",
                fontSize: "0.8rem",
                background: "#FFFFFF",
              }}
            >
              <option value="all-cats">All Categories</option>
              <option value="offers">Offers</option>
              <option value="repairs">Repairs</option>
              <option value="orders">Orders</option>
              <option value="system">System</option>
            </select>
          </div>
        </div>

        {/* History Table / Cards */}
        {loading ? (
          <div style={{ textAlign: "center", padding: "40px", color: "#64748B" }}>
            Loading notification broadcasts...
          </div>
        ) : filteredNotifications.length === 0 ? (
          <div style={{ textAlign: "center", padding: "40px", color: "#64748B" }}>
            <AlertCircle size={36} color="#CBD5E1" style={{ margin: "0 auto 8px auto" }} />
            <div style={{ fontWeight: 650 }}>No notifications found</div>
            <p style={{ fontSize: "0.8rem", margin: "4px 0 16px 0" }}>
              {notifications.length === 0
                ? "Click 'New Notification Broadcast' above to create your first notification."
                : "Try adjusting your audience or category filters."}
            </p>
          </div>
        ) : (
          <div style={{ display: "flex", flexDirection: "column", gap: "10px" }}>
            {filteredNotifications.map((item) => {
              const targetBadge = getTargetBadge(item.targetGroup);
              const catBadge = getCategoryBadge(item.category);
              const TargetIcon = targetBadge.icon;
              const formattedDate = new Date(item.createdAt).toLocaleString("en-IN", {
                month: "short",
                day: "numeric",
                year: "numeric",
                hour: "2-digit",
                minute: "2-digit",
              });

              return (
                <div
                  key={item.id}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "space-between",
                    padding: "14px 16px",
                    background: "#FFFFFF",
                    border: "1px solid #E2E8F0",
                    borderRadius: "10px",
                    gap: "14px",
                    flexWrap: "wrap",
                  }}
                >
                  {/* Left: Thumbnail & Content */}
                  <div style={{ display: "flex", alignItems: "flex-start", gap: "14px", flex: 1, minWidth: "280px" }}>
                    {item.imageUrl ? (
                      <img
                        src={item.imageUrl}
                        alt="Notification Banner"
                        style={{
                          width: "56px",
                          height: "56px",
                          borderRadius: "8px",
                          objectFit: "cover",
                          border: "1px solid #E2E8F0",
                          flexShrink: 0,
                        }}
                      />
                    ) : (
                      <div
                        style={{
                          width: "48px",
                          height: "48px",
                          borderRadius: "8px",
                          background: "#F8FAFC",
                          border: "1px solid #E2E8F0",
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                          color: catBadge.color,
                          flexShrink: 0,
                        }}
                      >
                        <catBadge.icon size={20} />
                      </div>
                    )}

                    <div>
                      {/* Badge line */}
                      <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "4px" }}>
                        <span
                          style={{
                            fontSize: "0.7rem",
                            fontWeight: 700,
                            padding: "2px 8px",
                            borderRadius: "12px",
                            background: targetBadge.bg,
                            color: targetBadge.color,
                            border: `1px solid ${targetBadge.border}`,
                            display: "inline-flex",
                            alignItems: "center",
                            gap: "4px",
                          }}
                        >
                          <TargetIcon size={11} />
                          {targetBadge.label}
                        </span>

                        <span
                          style={{
                            fontSize: "0.7rem",
                            fontWeight: 700,
                            color: catBadge.color,
                            textTransform: "uppercase",
                          }}
                        >
                          {catBadge.label}
                        </span>

                        <span style={{ fontSize: "0.72rem", color: "#94A3B8" }}>
                          • {formattedDate}
                        </span>
                      </div>

                      <div style={{ fontSize: "0.92rem", fontWeight: 750, color: "#0F172A" }}>
                        {item.title}
                      </div>
                      <div style={{ fontSize: "0.8rem", color: "#475569", marginTop: "2px", lineHeight: 1.4 }}>
                        {item.message}
                      </div>

                      {item.actionLabel && (
                        <div style={{ marginTop: "6px", fontSize: "0.75rem", color: "#EA580C", fontWeight: 700 }}>
                          Action: {item.actionLabel} ({item.actionRoute})
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Right: Actions */}
                  <div style={{ display: "flex", alignItems: "center", gap: "8px", flexShrink: 0 }}>
                    <button
                      type="button"
                      onClick={() => handleDuplicate(item)}
                      title="Duplicate & Re-broadcast"
                      style={{
                        background: "#F8FAFC",
                        border: "1px solid #CBD5E1",
                        borderRadius: "8px",
                        padding: "6px 10px",
                        fontSize: "0.75rem",
                        fontWeight: 650,
                        color: "#334155",
                        cursor: "pointer",
                        display: "inline-flex",
                        alignItems: "center",
                        gap: "4px",
                      }}
                    >
                      <Copy size={13} />
                      <span>Duplicate</span>
                    </button>

                    <button
                      type="button"
                      onClick={() => handleDeleteNotification(item.id, item.title)}
                      title="Revoke and delete notification"
                      style={{
                        background: "#FEF2F2",
                        border: "1px solid #FCA5A5",
                        borderRadius: "8px",
                        padding: "6px 10px",
                        fontSize: "0.75rem",
                        fontWeight: 650,
                        color: "#DC2626",
                        cursor: "pointer",
                        display: "inline-flex",
                        alignItems: "center",
                        gap: "4px",
                      }}
                    >
                      <Trash2 size={13} />
                      <span>Delete</span>
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
