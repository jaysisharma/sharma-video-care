"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { collection, addDoc } from "firebase/firestore";
import { db } from "../../../lib/firebase";
import { useAuth } from "../../../context/AuthContext";
import { REPAIR_PRICE_NOTICE, ServiceRequest } from "@sharmavideocare/shared";
import { Hammer, CheckCircle, ArrowLeft, AlertCircle } from "lucide-react";

export default function CustomServicePage() {
  const router = useRouter();
  const { user } = useAuth();

  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [recipientName, setRecipientName] = useState(user?.name || "");
  const [phone, setPhone] = useState(user?.phone || "");
  const [streetAddress, setStreetAddress] = useState("");
  const [ward, setWard] = useState("");
  const [preferredDate, setPreferredDate] = useState(
    new Date(Date.now() + 86400000).toISOString().split("T")[0]
  );
  const [agreedToNotice, setAgreedToNotice] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!agreedToNotice) {
      setError("Please confirm the inspection and diagnosis rule.");
      return;
    }
    if (!title.trim() || !description.trim()) {
      setError("Please describe the custom service or installation required.");
      return;
    }

    setSubmitting(true);
    setError("");

    try {
      const customerId = user ? user.id : "cust-janakpur-01";
      const customerName = user ? user.name : recipientName;

      const reqData: Omit<ServiceRequest, "id"> = {
        customerId,
        customerName,
        customerPhone: phone,
        categoryId: "custom",
        categoryName: "Custom Service / Installation",
        type: "CUSTOM",
        title: `Custom Work: ${title}`,
        description,
        mediaUrls: [],
        address: {
          id: `addr-${Date.now()}`,
          label: "Service Location",
          recipientName,
          phoneNumber: phone,
          city: "Janakpur",
          wardNumber: ward,
          streetAddress,
        },
        preferredSchedule: {
          preferredDate,
        },
        status: "REQUESTED",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      const docRef = await addDoc(collection(db, "serviceRequests"), reqData);

      // Create linked chat
      await addDoc(collection(db, "conversations"), {
        customerId,
        customerName,
        contextType: "SERVICE_REQUEST",
        contextId: docRef.id,
        contextTitle: `Custom Service: ${title}`,
        participantIds: [customerId, "admin-svc-01"],
        status: "OPEN",
        lastMessageText: `New custom work requested: ${title}`,
        lastMessageAt: new Date().toISOString(),
        unreadCountCustomer: 0,
        unreadCountStaff: 1,
      });

      router.push(`/services/success/${docRef.id}`);
    } catch (err: any) {
      console.error(err);
      setError(err?.message || "Failed to submit custom request.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="container" style={{ padding: "3rem 1.25rem", maxWidth: "800px" }}>
      <Link
        href="/services"
        style={{ display: "inline-flex", alignItems: "center", gap: "0.4rem", color: "var(--color-muted)", fontSize: "0.9rem", marginBottom: "1.5rem" }}
      >
        <ArrowLeft size={16} /> Back to Services
      </Link>

      <div style={{ marginBottom: "2rem" }}>
        <span className="badge badge-warning" style={{ marginBottom: "0.5rem" }}>
          Custom Technical Job
        </span>
        <h1 style={{ fontSize: "2rem", fontWeight: 800, color: "var(--color-ink)", marginBottom: "0.5rem" }}>
          Request Custom Installation or Technical Service
        </h1>
        <p style={{ color: "var(--color-muted)", fontSize: "0.95rem" }}>
          Have TV wall mounting, CCTV configuration, studio sound setup, or unlisted equipment? Submit your requirements for a free site assessment in Janakpur.
        </p>
      </div>

      <div className="notice-box" style={{ marginBottom: "2rem" }}>
        <CheckCircle size={22} style={{ flexShrink: 0 }} />
        <div>
          <strong>Custom Pricing Rule:</strong> {REPAIR_PRICE_NOTICE}
        </div>
      </div>

      {error && (
        <div style={{ padding: "0.85rem 1rem", background: "#FDF0F0", border: "1px solid var(--color-danger)", color: "var(--color-danger)", borderRadius: "var(--radius-sm)", marginBottom: "1.5rem" }}>
          {error}
        </div>
      )}

      <form onSubmit={handleSubmit} className="card" style={{ padding: "2rem" }}>
        <div className="form-group">
          <label className="form-label">Job Title / Summary *</label>
          <input
            type="text"
            className="form-input"
            placeholder="e.g. 65-inch OLED TV Wall Mount, 8-Camera CCTV Wiring, Church Sound Setup"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            required
          />
        </div>

        <div className="form-group">
          <label className="form-label">Detailed Requirements & Scope *</label>
          <textarea
            className="form-textarea"
            rows={5}
            placeholder="Describe what you want done, existing wiring, wall type (concrete/brick/drywall), special tools or brackets needed..."
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            required
          />
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1rem" }}>
          <div className="form-group">
            <label className="form-label">Contact Person *</label>
            <input
              type="text"
              className="form-input"
              value={recipientName}
              onChange={(e) => setRecipientName(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label className="form-label">Phone Number *</label>
            <input
              type="tel"
              className="form-input"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              required
            />
          </div>
        </div>

        <div className="form-group">
          <label className="form-label">Janakpur Address & Location Details *</label>
          <input
            type="text"
            className="form-input"
            placeholder="Street address, ward, landmarks in Janakpur"
            value={streetAddress}
            onChange={(e) => setStreetAddress(e.target.value)}
            required
          />
        </div>

        <div className="form-group">
          <label className="form-label">Preferred Date *</label>
          <input
            type="date"
            className="form-input"
            value={preferredDate}
            onChange={(e) => setPreferredDate(e.target.value)}
            required
          />
        </div>

        <div style={{ margin: "2rem 0 1.5rem 0", padding: "1rem", background: "var(--color-primary-soft)", borderRadius: "var(--radius-sm)", border: "1px solid #FCDAC1" }}>
          <label style={{ display: "flex", alignItems: "flex-start", gap: "0.75rem", cursor: "pointer", fontSize: "0.9rem" }}>
            <input
              type="checkbox"
              checked={agreedToNotice}
              onChange={(e) => setAgreedToNotice(e.target.checked)}
              style={{ marginTop: "0.25rem" }}
              required
            />
            <span style={{ color: "var(--color-ink)", fontWeight: 500 }}>
              I agree that <strong>inspection and visit in Janakpur are free</strong>, and the <strong>quotation will be provided after on-site evaluation</strong>.
            </span>
          </label>
        </div>

        <button
          type="submit"
          className="btn btn-primary"
          disabled={submitting}
          style={{ width: "100%", padding: "0.9rem", fontSize: "1.05rem" }}
        >
          {submitting ? "Submitting Custom Request..." : "Submit Custom Job Request"}
        </button>
      </form>
    </div>
  );
}
