import { uploadToCloudinary } from "../../../../lib/cloudinary";
"use client";

import React, { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import { doc, getDoc, updateDoc, addDoc, collection } from "firebase/firestore";
import { db } from "../../../../lib/firebase";
import { OrderRecord, PaymentProof } from "@sharmavideocare/shared";
import { CheckCircle2, Building2, Upload, ArrowRight, MessageSquare, Truck, Banknote, ShieldCheck } from "lucide-react";
import { useSnackbar } from "../../../../context/SnackbarContext";

export default function OrderSuccessPage() {
  const params = useParams();
  const orderId = params?.id as string;

  const [order, setOrder] = useState<OrderRecord | null>(null);
  const [loading, setLoading] = useState(true);

  // Bank transfer submission state
  const [txnRef, setTxnRef] = useState("");
  const [proofUrl, setProofUrl] = useState("");
  const [submittingProof, setSubmittingProof] = useState(false);
  const [uploadingProof, setUploadingProof] = useState(false);
  const [proofSubmitted, setProofSubmitted] = useState(false);
  const snackbar = useSnackbar();

  useEffect(() => {
    async function loadOrder() {
      try {
        const snap = await getDoc(doc(db, "orders", orderId));
        if (snap.exists()) {
          setOrder({ id: snap.id, ...snap.data() } as OrderRecord);
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    if (orderId) loadOrder();
  }, [orderId]);

  const handleBankProofSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!txnRef.trim() || !order) return;

    setSubmittingProof(true);
    try {
      const paymentData: Omit<PaymentProof, "id"> = {
        orderId,
        customerId: order.customerId,
        method: "BANK_TRANSFER",
        amount: order.total,
        referenceNumber: txnRef,
        proofImageUrl: proofUrl || "https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=400&q=80",
        status: "PENDING_VERIFICATION",
        submittedAt: new Date().toISOString(),
      };

      await addDoc(collection(db, "payments"), paymentData);

      await updateDoc(doc(db, "orders", orderId), {
        paymentStatus: "PENDING_VERIFICATION",
        orderStatus: "PAYMENT_SUBMITTED",
        updatedAt: new Date().toISOString(),
      });

      setProofSubmitted(true);
      snackbar.success("Payment proof submitted. We'll verify it shortly.");
      setOrder((prev) => prev ? { ...prev, paymentStatus: "PENDING_VERIFICATION", orderStatus: "PAYMENT_SUBMITTED" } : null);
    } catch (err) {
      console.error("Proof submission error:", err);
      snackbar.error("Couldn't submit payment proof. Please try again.");
    } finally {
      setSubmittingProof(false);
    }
  };

  return (
    <div className="container" style={{ padding: "4rem 1.25rem", maxWidth: "760px" }}>
      <div style={{ textAlign: "center", marginBottom: "2.5rem" }}>
        <div
          style={{
            width: "64px",
            height: "64px",
            borderRadius: "50%",
            background: "#EAF6EE",
            color: "var(--color-success)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            margin: "0 auto 1.5rem auto",
          }}
        >
          <CheckCircle2 size={36} />
        </div>

        <h1 style={{ fontSize: "2rem", fontWeight: 800, marginBottom: "0.5rem" }}>
          Order Confirmed!
        </h1>
        <p style={{ color: "var(--color-muted)", fontSize: "1rem" }}>
          Thank you for choosing QuickySewa. Your order reference is <strong>#{orderId?.slice(0, 8)}</strong>.
        </p>
      </div>

      {/* Order Summary Card */}
      <div className="card" style={{ marginBottom: "2rem" }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", borderBottom: "1px solid var(--color-border)", paddingBottom: "1rem", marginBottom: "1rem" }}>
          <div>
            <span style={{ fontSize: "0.8rem", color: "var(--color-muted)" }}>Payment Method</span>
            <div style={{ fontWeight: 700, fontSize: "1rem", display: "flex", alignItems: "center", gap: "0.4rem" }}>
              {order?.paymentMethod === "COD" ? <Banknote size={16} /> : <Building2 size={16} />}
              {order?.paymentMethod === "COD" ? "Cash on Delivery" : "Bank Transfer"}
            </div>
          </div>

          <div style={{ textAlign: "right" }}>
            <span style={{ fontSize: "0.8rem", color: "var(--color-muted)" }}>Total Due</span>
            <div style={{ fontWeight: 800, fontSize: "1.2rem", color: "var(--color-primary)" }}>
              Rs. {order?.total?.toLocaleString("en-IN")}
            </div>
          </div>
        </div>

        <div style={{ fontSize: "0.9rem", color: "var(--color-muted)", display: "flex", flexDirection: "column", gap: "0.4rem" }}>
          <div><strong>Recipient:</strong> {order?.shippingAddress?.recipientName} ({order?.shippingAddress?.phoneNumber})</div>
          <div><strong>Delivery Address:</strong> {order?.shippingAddress?.streetAddress}, {order?.shippingAddress?.city}, {order?.shippingAddress?.province}</div>
          <div><strong>Delivery Mode:</strong> Courier partner dispatch across Nepal (Tracking provided upon dispatch)</div>
        </div>
      </div>

      {/* Bank Transfer Instructions & Proof Submission Box */}
      {order?.paymentMethod === "BANK_TRANSFER" && (
        <div className="card" style={{ marginBottom: "2rem", border: "2px solid #E4DED6", background: "#FAF8F5" }}>
          <h3 style={{ fontSize: "1.15rem", fontWeight: 700, marginBottom: "1rem", display: "flex", alignItems: "center", gap: "0.5rem" }}>
            <Building2 size={20} color="var(--color-primary)" /> QuickySewa Official Bank Account
          </h3>

          <div style={{ background: "var(--color-surface)", padding: "1.25rem", borderRadius: "var(--radius-sm)", border: "1px solid var(--color-border)", marginBottom: "1.5rem", fontSize: "0.9rem" }}>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "0.75rem" }}>
              <div>Bank Name: <strong>Rastriya Banijya Bank</strong></div>
              <div>Branch: <strong>Janakpur Branch</strong></div>
              <div>Account Name: <strong>QuickySewa</strong></div>
              <div>Account Number: <strong>10400019283748</strong></div>
            </div>
            <div style={{ marginTop: "0.85rem", fontSize: "0.8rem", color: "var(--color-muted)" }}>
              * You can transfer using ConnectIPS, Mobile Banking (eSewa / Khalti / Bank App), or Counter Deposit.
            </div>
          </div>

          {proofSubmitted || order?.paymentStatus === "PENDING_VERIFICATION" ? (
            <div style={{ padding: "1rem", background: "#EAF6EE", border: "1px solid #C4E6D2", borderRadius: "var(--radius-sm)", color: "var(--color-success)" }}>
              <strong>✓ Payment Proof Submitted!</strong> Our admin team will verify the deposit voucher against our bank statement before dispatching your order.
            </div>
          ) : (
            <form onSubmit={handleBankProofSubmit}>
              <h4 style={{ fontSize: "1rem", fontWeight: 700, marginBottom: "0.75rem" }}>
                Submit Your Transfer Reference / Voucher
              </h4>

              <div className="form-group">
                <label className="form-label">Transaction Reference Number / Voucher ID *</label>
                <input
                  type="text"
                  className="form-input"
                  placeholder="e.g. TXN-984029103 or Deposit Voucher Slip No."
                  value={txnRef}
                  onChange={(e) => setTxnRef(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Deposit Voucher / Transfer Slip (Cloudinary Upload)</label>
                <div style={{ display: "flex", flexDirection: "column", gap: "0.5rem" }}>
                  <label
                    style={{
                      border: "2px dashed var(--color-border)",
                      borderRadius: "var(--radius-md)",
                      padding: "1.25rem",
                      textAlign: "center",
                      cursor: "pointer",
                      background: proofUrl ? "#F0FDF4" : "#FFFFFF",
                      display: "flex",
                      flexDirection: "column",
                      alignItems: "center",
                      justifyContent: "center",
                      gap: "0.5rem",
                    }}
                  >
                    <Upload size={24} color={proofUrl ? "var(--color-success)" : "var(--color-primary)"} />
                    <span style={{ fontSize: "0.9rem", fontWeight: 600 }}>
                      {uploadingProof
                        ? "Uploading receipt to Cloudinary..."
                        : proofUrl
                        ? "✓ Voucher Attached! Click to replace"
                        : "Click to upload voucher screenshot or photo"}
                    </span>
                    <span style={{ fontSize: "0.75rem", color: "var(--color-muted)" }}>
                      PNG, JPG, WebP up to 10MB
                    </span>
                    <input
                      type="file"
                      accept="image/*"
                      style={{ display: "none" }}
                      disabled={uploadingProof}
                      onChange={async (e) => {
                        const file = e.target.files?.[0];
                        if (!file) return;
                        setUploadingProof(true);
                        try {
                          const url = await uploadToCloudinary(file, "video_care/payments");
                          setProofUrl(url);
                          snackbar.success("Payment voucher uploaded to Cloudinary!");
                        } catch (err: any) {
                          console.error("Voucher upload error:", err);
                          snackbar.error(err.message || "Failed to upload receipt.");
                        } finally {
                          setUploadingProof(false);
                        }
                      }}
                    />
                  </label>

                  {proofUrl && (
                    <div style={{ display: "flex", alignItems: "center", gap: "0.75rem", background: "white", padding: "0.5rem", borderRadius: "var(--radius-sm)", border: "1px solid var(--color-border)" }}>
                      <img src={proofUrl} alt="Voucher Preview" style={{ width: "48px", height: "48px", objectFit: "cover", borderRadius: "4px" }} />
                      <div style={{ flex: 1, minWidth: 0, fontSize: "0.8rem", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                        <span style={{ color: "var(--color-success)", fontWeight: 600 }}>Cloudinary:</span> {proofUrl}
                      </div>
                    </div>
                  )}

                  <input
                    type="url"
                    className="form-input"
                    placeholder="Or paste voucher URL (https://...)"
                    value={proofUrl}
                    onChange={(e) => setProofUrl(e.target.value)}
                    style={{ fontSize: "0.8rem", padding: "0.4rem 0.6rem" }}
                  />
                </div>
              </div>

              <button
                type="submit"
                className="btn btn-primary"
                disabled={submittingProof}
                style={{ width: "100%", padding: "0.75rem" }}
              >
                {submittingProof ? "Submitting..." : "Submit Payment Proof for Verification"}
              </button>
            </form>
          )}
        </div>
      )}

      {/* COD Notice */}
      {order?.paymentMethod === "COD" && (
        <div className="notice-box" style={{ marginBottom: "2rem" }}>
          <ShieldCheck size={24} style={{ flexShrink: 0 }} />
          <div>
            <strong>Cash on Delivery:</strong> Please keep the exact amount of Rs. {order?.total?.toLocaleString("en-IN")} ready. Our courier partner will collect cash upon physical inspection of package seal at delivery.
          </div>
        </div>
      )}

      <div style={{ display: "flex", gap: "1rem", justifyContent: "center", flexWrap: "wrap" }}>
        <Link href={`/account?tab=orders&id=${orderId}`} className="btn btn-primary">
          <Truck size={16} /> Track Order in Account
        </Link>
        <Link href={`/chat?contextId=${orderId}`} className="btn btn-secondary">
          <MessageSquare size={16} /> Contact Support Regarding Order
        </Link>
      </div>
    </div>
  );
}
