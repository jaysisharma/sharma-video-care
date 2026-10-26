import { uploadToCloudinary } from "../../lib/cloudinary";
"use client";

import React, { useState, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { collection, addDoc } from "firebase/firestore";
import { db } from "../../lib/firebase";
import { useAuth } from "../../context/AuthContext";
import { Search, CheckCircle, ArrowLeft, Upload, ShieldCheck, AlertCircle } from "lucide-react";
import { useSnackbar } from "../../context/SnackbarContext";

function SourceRequestContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const prefilledProduct = searchParams.get("product") || "";

  const { user } = useAuth();

  const [productName, setProductName] = useState(prefilledProduct);
  const [brandOrModel, setBrandOrModel] = useState("");
  const [quantity, setQuantity] = useState(1);
  const [budget, setBudget] = useState("");
  const [notes, setNotes] = useState("");
  const [referenceUrl, setReferenceUrl] = useState("");
  const [uploadingReference, setUploadingReference] = useState(false);
  const [deliveryCity, setDeliveryCity] = useState("Janakpur");
  const [phone, setPhone] = useState(user?.phone || "+977-9801234567");

  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [requestId, setRequestId] = useState("");
  const snackbar = useSnackbar();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!productName.trim()) {
      snackbar.warning("Please specify the product name or equipment model.");
      return;
    }

    setSubmitting(true);

    try {
      const customerId = user ? user.id : `guest-${crypto.randomUUID()}`;
      const customerName = user ? user.name : "Guest Customer";

      const docRef = await addDoc(collection(db, "sourceRequests"), {
        customerId,
        customerName,
        customerPhone: phone,
        productName,
        brandOrModel,
        quantity: Number(quantity),
        budget: budget ? Number(budget) : null,
        notes,
        referenceImages: referenceUrl ? [referenceUrl] : [],
        deliveryCity,
        status: "SUBMITTED",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      });

      // Create linked chat
      // Guests are not signed in, so they cannot be chat participants.
      if (user) {
        await addDoc(collection(db, "conversations"), {
          customerId,
          customerName,
          contextType: "SOURCE_REQUEST",
          contextId: docRef.id,
          contextTitle: `Source Request: ${productName}`,
          participantIds: [customerId],
          status: "OPEN",
          lastMessageText: `New product sourcing request submitted for ${productName}`,
          lastMessageAt: new Date().toISOString(),
          unreadCountCustomer: 0,
          unreadCountStaff: 1,
        });
      }

      setRequestId(docRef.id);
      setSubmitted(true);
    } catch (err: any) {
      console.error(err);
      snackbar.error("Failed to submit sourcing request.");
    } finally {
      setSubmitting(false);
    }
  };

  if (submitted) {
    return (
      <div className="container" style={{ padding: "4rem 1.25rem", maxWidth: "650px", textAlign: "center" }}>
        <div
          style={{
            width: "60px",
            height: "60px",
            borderRadius: "50%",
            background: "#EAF6EE",
            color: "var(--color-success)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            margin: "0 auto 1.5rem auto",
          }}
        >
          <CheckCircle size={32} />
        </div>

        <h1 style={{ fontSize: "2rem", fontWeight: 800, marginBottom: "0.5rem" }}>
          Sourcing Request Submitted!
        </h1>
        <p style={{ color: "var(--color-muted)", fontSize: "1rem", lineHeight: 1.6, marginBottom: "2rem" }}>
          Our procurement desk will check distributor and supplier channels across Nepal and India. You will receive an official price quotation directly in your account.
        </p>

        <div className="card" style={{ textAlign: "left", marginBottom: "2rem" }}>
          <div><strong>Request Reference:</strong> #{requestId.slice(0, 8)}</div>
          <div><strong>Requested Item:</strong> {productName} ({brandOrModel || "Standard"})</div>
          <div><strong>Quantity:</strong> {quantity}</div>
          <div><strong>Destination City:</strong> {deliveryCity}</div>
          <div style={{ marginTop: "1rem", padding: "0.75rem", background: "#F5FAF7", borderRadius: "4px", fontSize: "0.85rem", color: "#165935" }}>
            ✓ <strong>Zero Deposit Required:</strong> You only decide to pay after reviewing and accepting our formal quotation.
          </div>
        </div>

        <div style={{ display: "flex", gap: "1rem", justifyContent: "center" }}>
          <Link href="/account?tab=sourcing" className="btn btn-primary">
            View My Requests
          </Link>
          <Link href={`/chat?contextId=${requestId}`} className="btn btn-secondary">
            Chat with Procurement Desk
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="container" style={{ padding: "3rem 1.25rem", maxWidth: "780px" }}>
      <Link
        href="/shop"
        style={{ display: "inline-flex", alignItems: "center", gap: "0.4rem", color: "var(--color-muted)", fontSize: "0.9rem", marginBottom: "1.5rem" }}
      >
        <ArrowLeft size={16} /> Back to Shop
      </Link>

      <div style={{ marginBottom: "2rem" }}>
        <span className="badge badge-warning" style={{ marginBottom: "0.5rem" }}>
          Zero Deposit Procurement
        </span>
        <h1 style={{ fontSize: "2rem", fontWeight: 800, color: "var(--color-ink)", marginBottom: "0.5rem" }}>
          Source Specialized Equipment on Request
        </h1>
        <p style={{ color: "var(--color-muted)", fontSize: "0.95rem" }}>
          Can’t find the exact camera body, specialized cinema lens, drone replacement module, or studio hardware in Nepal? QuickySewa procures it for you.
        </p>
      </div>

      {/* Confirmed Rule Notice */}
      <div
        className="card"
        style={{
          background: "#F5FAF7",
          border: "1px solid #D1EADE",
          padding: "1.25rem",
          marginBottom: "2rem",
          display: "flex",
          gap: "1rem",
          alignItems: "center",
        }}
      >
        <ShieldCheck size={24} style={{ color: "var(--color-success)", flexShrink: 0 }} />
        <div style={{ fontSize: "0.88rem", color: "#165935" }}>
          <strong>No Advance Deposit:</strong> We do not ask for customer deposits upfront for sourcing requests. We check real availability, give you an exact price quotation, and proceed only upon your confirmed order.
        </div>
      </div>


      <form onSubmit={handleSubmit} className="card" style={{ padding: "2rem" }}>
        <div className="form-group">
          <label className="form-label">Item / Product Name *</label>
          <input
            type="text"
            className="form-input"
            placeholder="e.g. Sony FX3 Cinema Camera, Canon RF 100mm Macro, DJI Matrice Motor Arm"
            value={productName}
            onChange={(e) => setProductName(e.target.value)}
            required
          />
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1rem" }}>
          <div className="form-group">
            <label className="form-label">Brand & Exact Model</label>
            <input
              type="text"
              className="form-input"
              placeholder="e.g. Blackmagic Design, Sony, Godox, Rode"
              value={brandOrModel}
              onChange={(e) => setBrandOrModel(e.target.value)}
            />
          </div>

          <div className="form-group">
            <label className="form-label">Quantity Needed *</label>
            <input
              type="number"
              min={1}
              className="form-input"
              value={quantity}
              onChange={(e) => setQuantity(Number(e.target.value))}
              required
            />
          </div>
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1rem" }}>
          <div className="form-group">
            <label className="form-label">Target Budget (NPR, Optional)</label>
            <input
              type="number"
              className="form-input"
              placeholder="Estimated budget in Rs."
              value={budget}
              onChange={(e) => setBudget(e.target.value)}
            />
          </div>

          <div className="form-group">
            <label className="form-label">Delivery Destination (City in Nepal) *</label>
            <input
              type="text"
              className="form-input"
              placeholder="e.g. Janakpur, Kathmandu, Pokhara, Biratnagar"
              value={deliveryCity}
              onChange={(e) => setDeliveryCity(e.target.value)}
              required
            />
          </div>
        </div>

        <div className="form-group">
          <label className="form-label">Reference Image or Spec Sheet (Cloudinary Upload)</label>
          <div style={{ display: "flex", flexDirection: "column", gap: "0.5rem" }}>
            <label
              style={{
                border: "2px dashed var(--color-border)",
                borderRadius: "var(--radius-md)",
                padding: "1rem",
                textAlign: "center",
                cursor: "pointer",
                background: referenceUrl ? "#F0FDF4" : "#FFFFFF",
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                justifyContent: "center",
                gap: "0.4rem",
              }}
            >
              <Upload size={22} color={referenceUrl ? "var(--color-success)" : "var(--color-primary)"} />
              <span style={{ fontSize: "0.85rem", fontWeight: 600 }}>
                {uploadingReference
                  ? "Uploading reference image to Cloudinary..."
                  : referenceUrl
                  ? "✓ Reference Photo Attached! Click to replace"
                  : "Upload camera/lens reference picture or spec sheet"}
              </span>
              <span style={{ fontSize: "0.75rem", color: "var(--color-muted)" }}>
                Helps our procurement team find the exact match
              </span>
              <input
                type="file"
                accept="image/*"
                style={{ display: "none" }}
                disabled={uploadingReference}
                onChange={async (e) => {
                  const file = e.target.files?.[0];
                  if (!file) return;
                  setUploadingReference(true);
                  try {
                    const url = await uploadToCloudinary(file, "video_care/sourcing");
                    setReferenceUrl(url);
                    snackbar.success("Reference photo uploaded to Cloudinary!");
                  } catch (err: any) {
                    console.error("Reference upload error:", err);
                    snackbar.error(err.message || "Failed to upload reference photo.");
                  } finally {
                    setUploadingReference(false);
                  }
                }}
              />
            </label>

            {referenceUrl && (
              <div style={{ display: "flex", alignItems: "center", gap: "0.75rem", background: "white", padding: "0.5rem", borderRadius: "var(--radius-sm)", border: "1px solid var(--color-border)" }}>
                <img src={referenceUrl} alt="Reference Preview" style={{ width: "48px", height: "48px", objectFit: "cover", borderRadius: "4px" }} />
                <div style={{ flex: 1, minWidth: 0, fontSize: "0.8rem", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                  <span style={{ color: "var(--color-success)", fontWeight: 600 }}>Cloudinary:</span> {referenceUrl}
                </div>
              </div>
            )}

            <input
              type="url"
              className="form-input"
              placeholder="Or paste external manufacturer/store link (https://...)"
              value={referenceUrl}
              onChange={(e) => setReferenceUrl(e.target.value)}
              style={{ fontSize: "0.8rem", padding: "0.4rem 0.6rem" }}
            />
          </div>
        </div>

        <div className="form-group">
          <label className="form-label">Notes, Required Accessories, or Technical Details</label>
          <textarea
            className="form-textarea"
            rows={4}
            placeholder="Specify any mount type, color, specific accessories, or delivery urgency..."
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
          />
        </div>

        <div className="form-group">
          <label className="form-label">Contact Phone Number *</label>
          <input
            type="tel"
            className="form-input"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            required
          />
        </div>

        <button
          type="submit"
          className="btn btn-primary"
          disabled={submitting}
          style={{ width: "100%", padding: "0.9rem", fontSize: "1.05rem", marginTop: "1rem" }}
        >
          {submitting ? "Submitting Sourcing Request..." : "Submit Sourcing Request"}
        </button>
      </form>
    </div>
  );
}

export default function SourceRequestPage() {
  return (
    <Suspense fallback={<div className="container" style={{ padding: "4rem 0", textAlign: "center" }}>Loading form...</div>}>
      <SourceRequestContent />
    </Suspense>
  );
}
