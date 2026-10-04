"use client";

import React from "react";
import Link from "next/link";
import { MessageSquare } from "lucide-react";
import { OrderRecord } from "@sharmavideocare/shared";

interface OrdersTabProps {
  orders: OrderRecord[];
}

export const OrdersTab: React.FC<OrdersTabProps> = ({ orders }) => {
  if (orders.length === 0) {
    return (
      <div
        className="card"
        style={{ textAlign: "center", padding: "4rem 2rem" }}
      >
        <h3>No merchandise orders found.</h3>
        <p
          style={{
            color: "var(--color-muted)",
            margin: "0.5rem 0 1.5rem 0",
          }}
        >
          Browse our brand-new products or certified pre-owned electronics.
        </p>
        <Link href="/shop" className="btn btn-primary">
          Explore Store
        </Link>
      </div>
    );
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "1.5rem" }}>
      {orders.map((ord) => (
        <div key={ord.id} className="card">
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "flex-start",
              flexWrap: "wrap",
              gap: "1rem",
              marginBottom: "1rem",
            }}
          >
            <div>
              <span
                style={{
                  fontSize: "0.8rem",
                  color: "var(--color-muted)",
                }}
              >
                Order #{ord.id.slice(0, 8)} • Placed{" "}
                {new Date(ord.createdAt).toLocaleDateString()}
              </span>
              <div
                className="stat-value"
                style={{
                  fontSize: "1.15rem",
                  color: "var(--color-ink)",
                  marginTop: "0.2rem",
                }}
              >
                Rs. {ord.total.toLocaleString("en-IN")} (
                {ord.paymentMethod === "COD"
                  ? "Cash on Delivery"
                  : "Bank Transfer"}
                )
              </div>
            </div>

            <div style={{ display: "flex", gap: "0.5rem", alignItems: "center" }}>
              <span className="badge badge-info">
                {ord.orderStatus.replace("_", " ")}
              </span>
              <span
                className={
                  ord.paymentStatus === "VERIFIED"
                    ? "badge badge-success"
                    : "badge badge-warning"
                }
              >
                Payment: {ord.paymentStatus.replace("_", " ")}
              </span>
              <Link
                href={`/chat?contextId=${ord.id}`}
                className="btn btn-secondary btn-sm"
              >
                <MessageSquare size={14} /> Support
              </Link>
            </div>
          </div>

          <div
            style={{
              display: "flex",
              flexDirection: "column",
              gap: "0.5rem",
              borderTop: "1px solid var(--color-border)",
              paddingTop: "0.85rem",
              marginBottom: "1rem",
            }}
          >
            {ord.items.map((i, idx) => (
              <div
                key={idx}
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  fontSize: "0.9rem",
                }}
              >
                <span>
                  {i.quantity}x {i.name}
                </span>
                <strong>Rs. {i.totalPrice.toLocaleString("en-IN")}</strong>
              </div>
            ))}
          </div>

          {/* Courier tracking information */}
          <div
            style={{
              background: "var(--color-canvas)",
              padding: "0.85rem 1rem",
              borderRadius: "var(--radius-sm)",
              fontSize: "0.85rem",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              flexWrap: "wrap",
              gap: "0.5rem",
            }}
          >
            <div>
              <span style={{ color: "var(--color-muted)" }}>
                Courier Partner:{" "}
              </span>
              <strong>
                {ord.courierDetails?.partnerName || "Assigned upon dispatch"}
              </strong>
            </div>
            <div>
              <span style={{ color: "var(--color-muted)" }}>
                Tracking Number:{" "}
              </span>
              <strong>
                {ord.courierDetails?.trackingNumber ||
                  "Available once shipped"}
              </strong>
            </div>
            <div>
              <span style={{ color: "var(--color-muted)" }}>
                Delivery Destination:{" "}
              </span>
              <strong>
                {ord.shippingAddress?.city}, {ord.shippingAddress?.province}
              </strong>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
};
