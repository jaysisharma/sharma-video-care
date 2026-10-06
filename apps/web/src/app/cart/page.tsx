"use client";

import React from "react";
import Link from "next/link";
import { useCart } from "../../context/CartContext";
import { useLanguage } from "../../context/LanguageContext";
import { Trash2, ShoppingBag, ArrowRight, ArrowLeft, Truck, Shield } from "lucide-react";

export default function CartPage() {
  const { items, updateQuantity, removeFromCart, clearCart, subtotal, totalCount } = useCart();
  const { language, t } = useLanguage();
  const deliveryFee = items.length > 0 ? 150 : 0;
  const orderTotal = subtotal + deliveryFee;

  if (items.length === 0) {
    return (
      <div className="container" style={{ padding: "5rem 1.25rem", textAlign: "center", maxWidth: "600px" }}>
        <div
          style={{
            width: "72px",
            height: "72px",
            borderRadius: "50%",
            background: "var(--color-primary-soft)",
            color: "var(--color-primary)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            margin: "0 auto 1.5rem auto",
          }}
        >
          <ShoppingBag size={36} />
        </div>
        <h2 style={{ fontSize: "1.75rem", fontWeight: 800, marginBottom: "0.5rem" }}>
          {t("cart.empty")}
        </h2>
        <p style={{ color: "var(--color-muted)", marginBottom: "2rem" }}>
          {language === "ne"
            ? "हाम्रो स्टोर क्याटलग वा प्रमाणित सेकेन्ड-ह्यान्ड क्यामेरा र सामानहरू हेर्नुहोस्।"
            : "Browse our product catalogue or inspected certified second-hand cameras and accessories."}
        </p>
        <div style={{ display: "flex", gap: "1rem", justifyContent: "center" }}>
          <Link href="/shop" className="btn btn-primary">
            {language === "ne" ? "स्टोर हेर्नुहोस्" : "Explore Store"}
          </Link>
          <Link href="/used" className="btn btn-secondary">
            {language === "ne" ? "प्रमाणित सेकेन्ड-ह्यान्ड" : "Certified Second-Hand"}
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="container" style={{ padding: "3rem 1.25rem" }}>
      <h1 style={{ fontSize: "2rem", fontWeight: 800, marginBottom: "1.75rem" }}>
        {language === "ne"
          ? `सपिङ कार्ट (${totalCount} सामान)`
          : `Shopping Cart (${totalCount} ${totalCount === 1 ? "item" : "items"})`}
      </h1>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 360px", gap: "2.5rem", alignItems: "start" }}>
        {/* Items List */}
        <div>
          <div className="table-container" style={{ marginBottom: "1.5rem" }}>
            <table className="table">
              <thead>
                <tr>
                  <th>{language === "ne" ? "सामान" : "Product"}</th>
                  <th>{language === "ne" ? "मूल्य" : "Price"}</th>
                  <th>{language === "ne" ? "संख्या" : "Quantity"}</th>
                  <th>{language === "ne" ? "जम्मा" : "Total"}</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {items.map((item) => (
                  <tr key={item.productId}>
                    <td>
                      <div style={{ display: "flex", alignItems: "center", gap: "1rem" }}>
                        <div
                          style={{
                            width: "56px",
                            height: "56px",
                            background: "#F2EDE4",
                            borderRadius: "var(--radius-sm)",
                            overflow: "hidden",
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                            flexShrink: 0,
                          }}
                        >
                          {item.image ? (
                            <img src={item.image} alt={item.name} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
                          ) : (
                            <ShoppingBag size={20} color="var(--color-muted)" />
                          )}
                        </div>
                        <div>
                          <strong style={{ display: "block", fontSize: "0.95rem" }}>{item.name}</strong>
                          <span className={item.productType === "USED" ? "badge badge-primary" : "badge badge-info"} style={{ fontSize: "0.72rem", marginTop: "0.2rem" }}>
                            {item.productType === "USED"
                              ? (language === "ne" ? "प्रमाणित सेकेन्ड-ह्यान्ड" : "Certified Used")
                              : (language === "ne" ? "नयाँ ब्रान्ड" : "Brand New")}
                          </span>
                        </div>
                      </div>
                    </td>
                    <td style={{ fontWeight: 600 }}>
                      Rs. {item.unitPrice.toLocaleString("en-IN")}
                    </td>
                    <td>
                      {item.productType === "USED" ? (
                        <span>1</span>
                      ) : (
                        <select
                          className="form-select"
                          style={{ width: "65px", padding: "0.3rem" }}
                          value={item.quantity}
                          onChange={(e) => updateQuantity(item.productId, Number(e.target.value))}
                        >
                          {[1, 2, 3, 4, 5].map((q) => (
                            <option key={q} value={q}>
                              {q}
                            </option>
                          ))}
                        </select>
                      )}
                    </td>
                    <td style={{ fontWeight: 700 }}>
                      Rs. {item.totalPrice.toLocaleString("en-IN")}
                    </td>
                    <td>
                      <button
                        onClick={() => removeFromCart(item.productId)}
                        style={{ background: "none", border: "none", color: "var(--color-danger)", padding: "0.4rem" }}
                        title={language === "ne" ? "हटाउनुहोस्" : "Remove item"}
                      >
                        <Trash2 size={16} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <Link href="/shop" style={{ display: "flex", alignItems: "center", gap: "0.4rem", color: "var(--color-muted)", fontSize: "0.9rem" }}>
              <ArrowLeft size={16} /> {language === "ne" ? "किनमेल जारी राख्नुहोस्" : "Continue Shopping"}
            </Link>
            <button onClick={clearCart} className="btn btn-secondary btn-sm" style={{ color: "var(--color-danger)" }}>
              {language === "ne" ? "कार्ट खाली गर्नुहोस्" : "Clear Cart"}
            </button>
          </div>
        </div>

        {/* Order Summary Box */}
        <div className="card">
          <h3 style={{ fontSize: "1.2rem", fontWeight: 700, marginBottom: "1.25rem", borderBottom: "1px solid var(--color-border)", paddingBottom: "0.5rem" }}>
            {language === "ne" ? "अर्डर सारांश" : "Order Summary"}
          </h3>

          <div style={{ display: "flex", flexDirection: "column", gap: "0.85rem", marginBottom: "1.5rem", fontSize: "0.92rem" }}>
            <div style={{ display: "flex", justifyContent: "space-between" }}>
              <span style={{ color: "var(--color-muted)" }}>{language === "ne" ? "उप-योग" : "Subtotal"}</span>
              <strong>Rs. {subtotal.toLocaleString("en-IN")}</strong>
            </div>

            <div style={{ display: "flex", justifyContent: "space-between" }}>
              <span style={{ color: "var(--color-muted)" }}>
                {language === "ne" ? "नेपालभर सुरक्षित डेलिभरी" : "Nationwide Courier Delivery"}
              </span>
              <strong>Rs. {deliveryFee.toLocaleString("en-IN")}</strong>
            </div>

            <div style={{ borderTop: "1px solid var(--color-border)", paddingTop: "0.85rem", display: "flex", justifyContent: "space-between", fontSize: "1.15rem" }}>
              <strong>{language === "ne" ? "कुल जम्मा" : "Total"}</strong>
              <strong style={{ color: "var(--color-ink)" }}>
                Rs. {orderTotal.toLocaleString("en-IN")}
              </strong>
            </div>
          </div>

          <div style={{ marginBottom: "1.5rem", fontSize: "0.82rem", color: "var(--color-muted)", display: "flex", flexDirection: "column", gap: "0.4rem" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "0.4rem" }}>
              <Truck size={14} color="var(--color-primary)" />{" "}
              {language === "ne" ? "नेपालभर आधिकारिक कुरियर मार्फत डेलिभरी" : "Dispatched across Nepal via courier partners"}
            </div>
            <div style={{ display: "flex", alignItems: "center", gap: "0.4rem" }}>
              <Shield size={14} color="var(--color-primary)" />{" "}
              {language === "ne" ? "सामान पाएपछि नगद (COD) र बैंक ट्रान्सफर उपलब्ध" : "Cash on Delivery & Bank Transfer accepted"}
            </div>
          </div>

          <Link href="/checkout" className="btn btn-primary" style={{ width: "100%", padding: "0.85rem", textAlign: "center" }}>
            {language === "ne" ? "चेकआउट गर्नुहोस्" : "Proceed to Checkout"} <ArrowRight size={16} />
          </Link>
        </div>
      </div>
    </div>
  );
}
