"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { collection, addDoc } from "firebase/firestore";
import { db } from "../../lib/firebase";
import { useAuth } from "../../context/AuthContext";
import { useCart } from "../../context/CartContext";
import { PaymentMethod, OrderRecord, OrderStatus } from "@sharmavideocare/shared";
import { ArrowLeft, CheckCircle2, Shield, Truck, AlertCircle, Building2, Banknote } from "lucide-react";

export default function CheckoutPage() {
  const router = useRouter();
  const { user } = useAuth();
  const { items, subtotal, clearCart } = useCart();

  const deliveryFee = 150;
  const orderTotal = subtotal + deliveryFee;

  const [recipientName, setRecipientName] = useState(user?.name || "");
  const [phoneNumber, setPhoneNumber] = useState(user?.phone || "");
  const [province, setProvince] = useState("Madhesh Province");
  const [city, setCity] = useState("Janakpur");
  const [wardNumber, setWardNumber] = useState("Ward 4");
  const [streetAddress, setStreetAddress] = useState("Station Road, Near Railway Station");
  const [landmarks, setLandmarks] = useState("Opposite Ram Janaki Guest House");

  const [paymentMethod, setPaymentMethod] = useState<PaymentMethod>("COD");
  const [agreedToPolicy, setAgreedToPolicy] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  if (items.length === 0) {
    return (
      <div className="container" style={{ padding: "4rem 1.25rem", textAlign: "center" }}>
        <h2>Your cart is empty</h2>
        <Link href="/shop" className="btn btn-secondary" style={{ marginTop: "1rem" }}>
          Return to Shop
        </Link>
      </div>
    );
  }

  const handlePlaceOrder = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!agreedToPolicy) {
      setError("Please review and agree to the delivery, return, and warranty terms.");
      return;
    }

    setSubmitting(true);
    setError("");

    try {
      const customerId = user ? user.id : "cust-janakpur-01";
      const customerName = user ? user.name : recipientName;

      const orderData: Omit<OrderRecord, "id"> = {
        customerId,
        customerName,
        customerPhone: phoneNumber,
        items,
        subtotal,
        deliveryFee,
        discount: 0,
        total: orderTotal,
        paymentMethod,
        paymentStatus: paymentMethod === "COD" ? "PENDING" : "PENDING_VERIFICATION",
        orderStatus: "PENDING_PAYMENT",
        shippingAddress: {
          id: `addr-${Date.now()}`,
          label: "Shipping Address",
          recipientName,
          phoneNumber,
          province,
          city,
          wardNumber,
          streetAddress,
          landmarks,
        },
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      const docRef = await addDoc(collection(db, "orders"), orderData);

      // Create linked chat for order updates
      await addDoc(collection(db, "conversations"), {
        customerId,
        customerName,
        contextType: "ORDER",
        contextId: docRef.id,
        contextTitle: `Order #${docRef.id.slice(0, 8)} (${items.length} items)`,
        participantIds: [customerId, "admin-svc-01"],
        status: "OPEN",
        lastMessageText: `New order placed for Rs. ${orderTotal.toLocaleString("en-IN")}`,
        lastMessageAt: new Date().toISOString(),
        unreadCountCustomer: 0,
        unreadCountStaff: 1,
      });

      clearCart();
      router.push(`/orders/success/${docRef.id}`);
    } catch (err: any) {
      console.error(err);
      setError(err?.message || "Failed to process order. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="container" style={{ padding: "3rem 1.25rem", maxWidth: "900px" }}>
      <Link
        href="/cart"
        style={{ display: "inline-flex", alignItems: "center", gap: "0.4rem", color: "var(--color-muted)", fontSize: "0.9rem", marginBottom: "1.5rem" }}
      >
        <ArrowLeft size={16} /> Back to Cart
      </Link>

      <h1 style={{ fontSize: "2rem", fontWeight: 800, marginBottom: "2rem" }}>
        Secure Checkout
      </h1>

      {error && (
        <div style={{ padding: "0.85rem 1rem", background: "#FDF0F0", border: "1px solid var(--color-danger)", color: "var(--color-danger)", borderRadius: "var(--radius-sm)", marginBottom: "1.5rem", display: "flex", alignItems: "center", gap: "0.5rem" }}>
          <AlertCircle size={18} /> {error}
        </div>
      )}

      <form onSubmit={handlePlaceOrder}>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 340px", gap: "2.5rem", alignItems: "start" }}>
          {/* Left Form Column */}
          <div>
            {/* 1. Delivery Address */}
            <div className="card" style={{ marginBottom: "2rem" }}>
              <h3 style={{ fontSize: "1.15rem", fontWeight: 700, marginBottom: "1.2rem", display: "flex", alignItems: "center", gap: "0.5rem" }}>
                <Truck size={18} color="var(--color-primary)" /> 1. Shipping Address (Nationwide Nepal)
              </h3>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1rem" }}>
                <div className="form-group">
                  <label className="form-label">Recipient Full Name *</label>
                  <input
                    type="text"
                    className="form-input"
                    value={recipientName}
                    onChange={(e) => setRecipientName(e.target.value)}
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Contact Phone Number *</label>
                  <input
                    type="tel"
                    className="form-input"
                    value={phoneNumber}
                    onChange={(e) => setPhoneNumber(e.target.value)}
                    required
                  />
                </div>
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1rem" }}>
                <div className="form-group">
                  <label className="form-label">Province *</label>
                  <select
                    className="form-select"
                    value={province}
                    onChange={(e) => setProvince(e.target.value)}
                  >
                    <option value="Madhesh Province">Madhesh Province</option>
                    <option value="Bagmati Province">Bagmati Province</option>
                    <option value="Koshi Province">Koshi Province</option>
                    <option value="Gandaki Province">Gandaki Province</option>
                    <option value="Lumbini Province">Lumbini Province</option>
                    <option value="Karnali Province">Karnali Province</option>
                    <option value="Sudurpashchim Province">Sudurpashchim Province</option>
                  </select>
                </div>

                <div className="form-group">
                  <label className="form-label">City / District *</label>
                  <input
                    type="text"
                    className="form-input"
                    placeholder="e.g. Janakpur, Kathmandu, Pokhara, Biratnagar"
                    value={city}
                    onChange={(e) => setCity(e.target.value)}
                    required
                  />
                </div>
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 2fr", gap: "1rem" }}>
                <div className="form-group">
                  <label className="form-label">Ward / Area</label>
                  <input
                    type="text"
                    className="form-input"
                    placeholder="e.g. Ward 4"
                    value={wardNumber}
                    onChange={(e) => setWardNumber(e.target.value)}
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Street Address *</label>
                  <input
                    type="text"
                    className="form-input"
                    placeholder="Exact street, house/office number"
                    value={streetAddress}
                    onChange={(e) => setStreetAddress(e.target.value)}
                    required
                  />
                </div>
              </div>

              <div className="form-group" style={{ marginBottom: 0 }}>
                <label className="form-label">Landmarks / Delivery Instructions</label>
                <input
                  type="text"
                  className="form-input"
                  placeholder="e.g. Near Ramananda Chowk, opposite bank"
                  value={landmarks}
                  onChange={(e) => setLandmarks(e.target.value)}
                />
              </div>
            </div>

            {/* 2. Payment Method */}
            <div className="card" style={{ marginBottom: "2rem" }}>
              <h3 style={{ fontSize: "1.15rem", fontWeight: 700, marginBottom: "1.2rem" }}>
                2. Select Payment Method
              </h3>

              <div style={{ display: "flex", flexDirection: "column", gap: "1rem" }}>
                {/* Cash on Delivery */}
                <label
                  style={{
                    display: "flex",
                    alignItems: "flex-start",
                    gap: "1rem",
                    padding: "1rem",
                    border: paymentMethod === "COD" ? "2px solid var(--color-primary)" : "1px solid var(--color-border)",
                    borderRadius: "var(--radius-sm)",
                    background: paymentMethod === "COD" ? "var(--color-primary-soft)" : "var(--color-surface)",
                    cursor: "pointer",
                  }}
                >
                  <input
                    type="radio"
                    name="paymentMethod"
                    checked={paymentMethod === "COD"}
                    onChange={() => setPaymentMethod("COD")}
                    style={{ marginTop: "0.25rem" }}
                  />
                  <div>
                    <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", fontWeight: 700, fontSize: "0.95rem" }}>
                      <Banknote size={18} /> Cash on Delivery (COD)
                    </div>
                    <p style={{ fontSize: "0.85rem", color: "var(--color-muted)", marginTop: "0.25rem" }}>
                      Pay in cash directly to the courier partner upon physical delivery at your doorstep anywhere in Nepal.
                    </p>
                  </div>
                </label>

                {/* Bank Transfer */}
                <label
                  style={{
                    display: "flex",
                    alignItems: "flex-start",
                    gap: "1rem",
                    padding: "1rem",
                    border: paymentMethod === "BANK_TRANSFER" ? "2px solid var(--color-primary)" : "1px solid var(--color-border)",
                    borderRadius: "var(--radius-sm)",
                    background: paymentMethod === "BANK_TRANSFER" ? "var(--color-primary-soft)" : "var(--color-surface)",
                    cursor: "pointer",
                  }}
                >
                  <input
                    type="radio"
                    name="paymentMethod"
                    checked={paymentMethod === "BANK_TRANSFER"}
                    onChange={() => setPaymentMethod("BANK_TRANSFER")}
                    style={{ marginTop: "0.25rem" }}
                  />
                  <div>
                    <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", fontWeight: 700, fontSize: "0.95rem" }}>
                      <Building2 size={18} /> Bank Transfer (Direct Deposit / Mobile Banking)
                    </div>
                    <p style={{ fontSize: "0.85rem", color: "var(--color-muted)", marginTop: "0.25rem" }}>
                      Transfer directly to the Sharma Video Care corporate account. You will submit your deposit voucher/screenshot for admin verification.
                    </p>
                  </div>
                </label>
              </div>
            </div>

            {/* Mandatory Terms & Policy Agreement */}
            <div
              style={{
                padding: "1.25rem",
                background: "var(--color-surface)",
                border: "1px solid var(--color-border)",
                borderRadius: "var(--radius-sm)",
                marginBottom: "2rem",
              }}
            >
              <label style={{ display: "flex", alignItems: "flex-start", gap: "0.75rem", cursor: "pointer", fontSize: "0.88rem" }}>
                <input
                  type="checkbox"
                  checked={agreedToPolicy}
                  onChange={(e) => setAgreedToPolicy(e.target.checked)}
                  style={{ marginTop: "0.25rem" }}
                  required
                />
                <span style={{ color: "var(--color-ink)", lineHeight: 1.5 }}>
                  I confirm my order and agree to the <strong>Sharma Video Care Terms of Service</strong>, <strong>Nationwide Courier Delivery Policy</strong>, and <strong>Product-Specific Warranty & Return Terms</strong> under Nepal Electronic Commerce Act 2081 guidelines.
                </span>
              </label>
            </div>
          </div>

          {/* Right Summary Sidebar */}
          <div className="card" style={{ position: "sticky", top: "90px" }}>
            <h3 style={{ fontSize: "1.15rem", fontWeight: 700, marginBottom: "1rem", borderBottom: "1px solid var(--color-border)", paddingBottom: "0.5rem" }}>
              Order Review
            </h3>

            <div style={{ display: "flex", flexDirection: "column", gap: "0.75rem", marginBottom: "1.25rem", fontSize: "0.85rem", maxHeight: "200px", overflowY: "auto" }}>
              {items.map((i) => (
                <div key={i.productId} style={{ display: "flex", justifyContent: "space-between" }}>
                  <span style={{ color: "var(--color-muted)", maxWidth: "180px", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                    {i.quantity}x {i.name}
                  </span>
                  <strong>Rs. {i.totalPrice.toLocaleString("en-IN")}</strong>
                </div>
              ))}
            </div>

            <div style={{ borderTop: "1px solid var(--color-border)", paddingTop: "0.75rem", display: "flex", flexDirection: "column", gap: "0.5rem", fontSize: "0.9rem", marginBottom: "1.5rem" }}>
              <div style={{ display: "flex", justifyContent: "space-between" }}>
                <span style={{ color: "var(--color-muted)" }}>Subtotal</span>
                <span>Rs. {subtotal.toLocaleString("en-IN")}</span>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between" }}>
                <span style={{ color: "var(--color-muted)" }}>Courier Delivery (Nepal)</span>
                <span>Rs. {deliveryFee.toLocaleString("en-IN")}</span>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: "1.15rem", fontWeight: 800, borderTop: "1px solid var(--color-border)", paddingTop: "0.5rem" }}>
                <span>Total Due</span>
                <span>Rs. {orderTotal.toLocaleString("en-IN")}</span>
              </div>
            </div>

            <button
              type="submit"
              className="btn btn-primary"
              disabled={submitting}
              style={{ width: "100%", padding: "0.85rem", fontSize: "1rem" }}
            >
              {submitting ? "Placing Order..." : "Confirm & Place Order"}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
}
