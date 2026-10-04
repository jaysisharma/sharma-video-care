"use client";

import React from "react";
import Link from "next/link";
import { MessageSquare } from "lucide-react";
import { SourceRequest } from "@sharmavideocare/shared";

interface SourcingTabProps {
  sourcing: SourceRequest[];
}

export const SourcingTab: React.FC<SourcingTabProps> = ({ sourcing }) => {
  if (sourcing.length === 0) {
    return (
      <div
        className="card"
        style={{ textAlign: "center", padding: "4rem 2rem" }}
      >
        <h3>No active special requests.</h3>
        <p
          style={{
            color: "var(--color-muted)",
            margin: "0.5rem 0 1.5rem 0",
          }}
        >
          Browse our catalogue to explore available electronics and equipment.
        </p>
        <Link href="/shop" className="btn btn-primary">
          Explore Products
        </Link>
      </div>
    );
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "1.5rem" }}>
      {sourcing.map((src) => (
        <div key={src.id} className="card">
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "flex-start",
              flexWrap: "wrap",
              gap: "1rem",
              marginBottom: "0.75rem",
            }}
          >
            <div>
              <span
                style={{
                  fontSize: "0.8rem",
                  color: "var(--color-muted)",
                }}
              >
                Request #{src.id.slice(0, 8)} •{" "}
                {new Date(src.createdAt).toLocaleDateString()}
              </span>
              <h3
                style={{
                  fontSize: "1.2rem",
                  fontWeight: 700,
                  color: "var(--color-ink)",
                  marginTop: "0.2rem",
                }}
              >
                {src.productName} ({src.brandOrModel || "Standard"})
              </h3>
            </div>

            <div style={{ display: "flex", gap: "0.5rem", alignItems: "center" }}>
              <span className="badge badge-warning">{src.status}</span>
              <Link
                href={`/chat?contextId=${src.id}`}
                className="btn btn-secondary btn-sm"
              >
                <MessageSquare size={14} /> Chat
              </Link>
            </div>
          </div>

          <p
            style={{
              fontSize: "0.9rem",
              color: "var(--color-muted)",
              marginBottom: "0.75rem",
            }}
          >
            Quantity: {src.quantity} • Target Budget:{" "}
            {src.budget ? `Rs. ${src.budget.toLocaleString("en-IN")}` : "Unspecified"}{" "}
            • Destination: {src.deliveryCity}
          </p>

          {src.notes && (
            <div
              style={{
                fontSize: "0.85rem",
                color: "var(--color-muted)",
                marginBottom: "0.75rem",
              }}
            >
              Notes: {src.notes}
            </div>
          )}

          {src.quoteAmount && (
            <div
              style={{
                padding: "0.85rem 1rem",
                background: "var(--color-primary-soft)",
                borderRadius: "var(--radius-sm)",
                border: "1px solid #FCDAC1",
              }}
            >
              <div
                style={{
                  fontWeight: 700,
                  color: "var(--color-primary-dark)",
                }}
              >
                Price Quote: Rs. {src.quoteAmount.toLocaleString("en-IN")}
              </div>
              <div
                style={{
                  fontSize: "0.82rem",
                  color: "var(--color-muted)",
                  marginTop: "0.25rem",
                }}
              >
                {src.quoteNotes ||
                  "Stock confirmed. Ready for fulfillment upon order confirmation."}
              </div>
            </div>
          )}
        </div>
      ))}
    </div>
  );
};
