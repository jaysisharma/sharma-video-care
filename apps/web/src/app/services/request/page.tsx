"use client";

import React, { useState, useEffect, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { collection, addDoc, doc, setDoc } from "firebase/firestore";
import { db } from "../../../lib/firebase";
import { useAuth } from "../../../context/AuthContext";
import { REPAIR_PRICE_NOTICE, ServiceRequest, ServiceStatus } from "@sharmavideocare/shared";
import { Wrench, CheckCircle, ArrowLeft, Upload, Calendar, MapPin, AlertCircle } from "lucide-react";

function ServiceRequestContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const categorySlug = searchParams.get("category") || "general";
  const categoryTitle = searchParams.get("title") || "General Equipment";
  const initialModel = searchParams.get("model") || "";
  const initialSymptom = searchParams.get("symptom") || "";
  const initialEstimate = searchParams.get("estimate") || "";

  const { user } = useAuth();

  const [deviceModel, setDeviceModel] = useState(initialModel);
  const [description, setDescription] = useState(
    initialSymptom
      ? `${initialSymptom}${initialEstimate ? `\n[Online Pre-Estimate: ${initialEstimate}]` : ""}`
      : ""
  );
  const [evidenceUrl, setEvidenceUrl] = useState("");
  const [recipientName, setRecipientName] = useState(user?.name || "");
  const [phone, setPhone] = useState(user?.phone || "");
  const [streetAddress, setStreetAddress] = useState("");
  const [ward, setWard] = useState("");
  const [landmark, setLandmark] = useState("");
  const [preferredDate, setPreferredDate] = useState(
    new Date(Date.now() + 86400000).toISOString().split("T")[0]
  );
  const [timeSlot, setTimeSlot] = useState("Morning (10:00 AM - 01:00 PM)");
  const [agreedToNotice, setAgreedToNotice] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (user) {
      setRecipientName(user.name);
      if (user.phone) setPhone(user.phone);
    }
  }, [user]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!agreedToNotice) {
      setError("Please confirm that you understand the inspection and diagnosis pricing rule.");
      return;
    }
    if (!deviceModel.trim() || !description.trim()) {
      setError("Please specify the equipment model and describe the problem.");
      return;
    }

    setSubmitting(true);
    setError("");

    try {
      const customerId = user ? user.id : "cust-janakpur-01";
      const customerName = user ? user.name : recipientName;

      // Create Service Request document
      const reqData: Omit<ServiceRequest, "id"> = {
        customerId,
        customerName,
        customerPhone: phone,
        categoryId: categorySlug,
        categoryName: categoryTitle,
        type: "STANDARD",
        title: `${categoryTitle}: ${deviceModel}`,
        description,
        mediaUrls: evidenceUrl ? [evidenceUrl] : [],
        address: {
          id: `addr-${Date.now()}`,
          label: "Service Location",
          recipientName,
          phoneNumber: phone,
          city: "Janakpur",
          wardNumber: ward,
          streetAddress,
          landmarks: landmark,
        },
        preferredSchedule: {
          preferredDate,
          preferredTimeSlot: timeSlot,
        },
        status: "REQUESTED",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      const docRef = await addDoc(collection(db, "serviceRequests"), reqData);

      // Create linked support conversation
      await addDoc(collection(db, "conversations"), {
        customerId,
        customerName,
        contextType: "SERVICE_REQUEST",
        contextId: docRef.id,
        contextTitle: `Repair Request: ${deviceModel}`,
        participantIds: [customerId, "admin-svc-01"],
        status: "OPEN",
        lastMessageText: `New repair requested: ${description.slice(0, 50)}...`,
        lastMessageAt: new Date().toISOString(),
        unreadCountCustomer: 0,
        unreadCountStaff: 1,
      });

      router.push(`/services/success/${docRef.id}`);
    } catch (err: any) {
      console.error("Submission failed:", err);
      setError(err?.message || "Failed to submit request. Please try again.");
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
        <span className="badge badge-primary" style={{ marginBottom: "0.5rem" }}>
          Free Inspection in Janakpur
        </span>
        <h1 style={{ fontSize: "2rem", fontWeight: 800, color: "var(--color-ink)", marginBottom: "0.5rem" }}>
          Book Repair for {categoryTitle}
        </h1>
        <p style={{ color: "var(--color-muted)", fontSize: "0.95rem" }}>
          Submit your equipment details. Our Janakpur technician will inspect the hardware and provide an exact quotation.
        </p>
      </div>

      {/* Online Estimator Pre-fill Banner */}
      {initialEstimate && (
        <div
          style={{
            marginBottom: "1.25rem",
            background: "#FFF8F2",
            border: "1px solid #FED7AA",
            borderRadius: "10px",
            padding: "12px 16px",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            flexWrap: "wrap",
            gap: "10px",
          }}
        >
          <div>
            <div style={{ fontSize: "11.5px", fontWeight: 700, color: "#E86F1C", textTransform: "uppercase" }}>
              Pre-calculated Online Estimate
            </div>
            <div style={{ fontSize: "15px", fontWeight: 800, color: "#181512" }}>
              {initialModel ? `${initialModel} • ` : ""}
              {initialEstimate}
            </div>
          </div>
          <Link
            href="/estimator"
            style={{ fontSize: "12px", color: "#E86F1C", fontWeight: 700, textDecoration: "none" }}
          >
            Change Estimate ↺
          </Link>
        </div>
      )}

      {/* Pricing Rule Confirmation Banner */}
      <div className="notice-box" style={{ marginBottom: "2rem" }}>
        <CheckCircle size={22} style={{ flexShrink: 0 }} />
        <div>
          <strong>Standard Pricing Rule:</strong> {REPAIR_PRICE_NOTICE}
        </div>
      </div>

      {error && (
        <div style={{ padding: "0.85rem 1rem", background: "#FDF0F0", border: "1px solid var(--color-danger)", color: "var(--color-danger)", borderRadius: "var(--radius-sm)", marginBottom: "1.5rem", display: "flex", alignItems: "center", gap: "0.5rem" }}>
          <AlertCircle size={18} /> {error}
        </div>
      )}

      <form onSubmit={handleSubmit} className="card" style={{ padding: "2rem" }}>
        {/* Step 1: Device Details */}
        <h3 style={{ fontSize: "1.15rem", fontWeight: 700, marginBottom: "1.2rem", borderBottom: "1px solid var(--color-border)", paddingBottom: "0.5rem" }}>
          1. Equipment & Defect Details
        </h3>

        <div className="form-group">
          <label className="form-label">Brand & Model Name *</label>
          <input
            type="text"
            className="form-input"
            placeholder="e.g. Canon EOS 5D Mark IV, Sony 24-70mm GM, LG 55-inch OLED"
            value={deviceModel}
            onChange={(e) => setDeviceModel(e.target.value)}
            required
          />
        </div>

        <div className="form-group">
          <label className="form-label">Describe the Problem & Symptoms *</label>
          <textarea
            className="form-textarea"
            rows={4}
            placeholder="Describe what happened: error codes, strange noises, when the issue occurs, water damage, drop, etc."
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            required
          />
        </div>

        <div className="form-group">
          <label className="form-label">Photo or Video Evidence (URL or link)</label>
          <input
            type="url"
            className="form-input"
            placeholder="https://... (Optional cloud link or photo reference)"
            value={evidenceUrl}
            onChange={(e) => setEvidenceUrl(e.target.value)}
          />
          <div className="form-hint">
            You can also send photo/video attachments directly in the support chat after submission.
          </div>
        </div>

        {/* Step 2: Location in Janakpur */}
        <h3 style={{ fontSize: "1.15rem", fontWeight: 700, marginTop: "2rem", marginBottom: "1.2rem", borderBottom: "1px solid var(--color-border)", paddingBottom: "0.5rem" }}>
          2. Janakpur Inspection Location
        </h3>

        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1rem" }}>
          <div className="form-group">
            <label className="form-label">Contact Person Name *</label>
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

        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1rem" }}>
          <div className="form-group">
            <label className="form-label">City</label>
            <input
              type="text"
              className="form-input"
              value="Janakpur (Sub-Metropolitan)"
              readOnly
              style={{ background: "#F6F4EF", cursor: "not-allowed" }}
            />
          </div>

          <div className="form-group">
            <label className="form-label">Ward / Tole *</label>
            <input
              type="text"
              className="form-input"
              placeholder="e.g. Ward 4, Ramananda Chowk"
              value={ward}
              onChange={(e) => setWard(e.target.value)}
              required
            />
          </div>
        </div>

        <div className="form-group">
          <label className="form-label">Street Address & Landmarks *</label>
          <input
            type="text"
            className="form-input"
            placeholder="Exact house/building name, street, landmarks"
            value={streetAddress}
            onChange={(e) => setStreetAddress(e.target.value)}
            required
          />
        </div>

        {/* Step 3: Preferred Schedule */}
        <h3 style={{ fontSize: "1.15rem", fontWeight: 700, marginTop: "2rem", marginBottom: "1.2rem", borderBottom: "1px solid var(--color-border)", paddingBottom: "0.5rem" }}>
          3. Preferred Inspection Slot
        </h3>

        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1rem" }}>
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

          <div className="form-group">
            <label className="form-label">Preferred Time Window *</label>
            <select
              className="form-select"
              value={timeSlot}
              onChange={(e) => setTimeSlot(e.target.value)}
            >
              <option value="Morning (10:00 AM - 01:00 PM)">Morning (10:00 AM - 01:00 PM)</option>
              <option value="Afternoon (01:00 PM - 05:00 PM)">Afternoon (01:00 PM - 05:00 PM)</option>
              <option value="Evening (05:00 PM - 07:00 PM)">Evening (05:00 PM - 07:00 PM)</option>
            </select>
          </div>
        </div>

        {/* Mandatory Agreement */}
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
              I agree that <strong>inspection and initial technician visit in Janakpur are free</strong>, and that <strong>final repair pricing will be quoted after physical diagnosis</strong>. No repair work will start without my explicit quotation approval.
            </span>
          </label>
        </div>

        <button
          type="submit"
          className="btn btn-primary"
          disabled={submitting}
          style={{ width: "100%", padding: "0.9rem", fontSize: "1.05rem" }}
        >
          {submitting ? "Submitting Request..." : "Submit Repair Request"}
        </button>
      </form>
    </div>
  );
}

export default function ServiceRequestFormPage() {
  return (
    <Suspense fallback={<div className="container" style={{ padding: "4rem 0", textAlign: "center" }}>Loading request form...</div>}>
      <ServiceRequestContent />
    </Suspense>
  );
}
