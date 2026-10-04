"use client";

import React from "react";
import Link from "next/link";
import { MessageSquare, CheckCircle, XCircle } from "lucide-react";
import { ServiceRequest, ServiceQuote } from "@sharmavideocare/shared";

interface RepairsTabProps {
  repairs: ServiceRequest[];
  quotes: Record<string, ServiceQuote>;
  highlightedId?: string;
  onQuoteResponse: (
    serviceReqId: string,
    quoteId: string,
    accept: boolean
  ) => void;
}

export const RepairsTab: React.FC<RepairsTabProps> = ({
  repairs,
  quotes,
  highlightedId,
  onQuoteResponse,
}) => {
  if (repairs.length === 0) {
    return (
      <div
        className="card"
        style={{ textAlign: "center", padding: "4rem 2rem" }}
      >
        <h3>No active repair or service requests.</h3>
        <p
          style={{
            color: "var(--color-muted)",
            margin: "0.5rem 0 1.5rem 0",
          }}
        >
          Need a camera cleaned, drone fixed, or appliance serviced?
        </p>
        <Link href="/services" className="btn btn-primary">
          Book Free Inspection
        </Link>
      </div>
    );
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "1.5rem" }}>
      {repairs.map((req) => {
        const quote = quotes[req.id];
        const isHighlighted = req.id === highlightedId;

        return (
          <div
            key={req.id}
            className="card"
            style={{
              border: isHighlighted
                ? "2px solid var(--color-primary)"
                : "1px solid var(--color-border)",
            }}
          >
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
                  Ref #{req.id.slice(0, 8)} •{" "}
                  {new Date(req.createdAt).toLocaleDateString()}
                </span>
                <h3
                  style={{
                    fontSize: "1.2rem",
                    fontWeight: 700,
                    color: "var(--color-ink)",
                    marginTop: "0.2rem",
                  }}
                >
                  {req.title}
                </h3>
              </div>

              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "0.75rem",
                }}
              >
                <span
                  className={
                    req.status === "COMPLETED"
                      ? "badge badge-success"
                      : req.status === "CUSTOMER_APPROVED" ||
                        req.status === "IN_PROGRESS"
                      ? "badge badge-info"
                      : req.status === "QUOTE_SENT"
                      ? "badge badge-warning"
                      : "badge badge-muted"
                  }
                >
                  {req.status.replace("_", " ")}
                </span>

                <Link
                  href={`/chat?contextId=${req.id}`}
                  className="btn btn-secondary btn-sm"
                >
                  <MessageSquare size={14} /> Job Chat
                </Link>
              </div>
            </div>

            <p
              style={{
                fontSize: "0.9rem",
                color: "var(--color-muted)",
                marginBottom: "1rem",
              }}
            >
              {req.description}
            </p>

            <div
              style={{
                display: "flex",
                flexWrap: "wrap",
                gap: "1.5rem",
                fontSize: "0.85rem",
                color: "var(--color-ink)",
                background: "var(--color-canvas)",
                padding: "0.75rem 1rem",
                borderRadius: "var(--radius-sm)",
                marginBottom: "1rem",
              }}
            >
              <div>
                <span style={{ color: "var(--color-muted)" }}>
                  Assigned Technician:{" "}
                </span>
                <strong>
                  {req.assignedTechnicianName ||
                    "Pending Assignment (Janakpur Hub)"}
                </strong>
              </div>
              <div>
                <span style={{ color: "var(--color-muted)" }}>Schedule: </span>
                <strong>
                  {req.preferredSchedule?.preferredDate} (
                  {req.preferredSchedule?.preferredTimeSlot || "Standard"})
                </strong>
              </div>
              <div>
                <span style={{ color: "var(--color-muted)" }}>
                  Inspection / Visit Fee:{" "}
                </span>
                <strong style={{ color: "var(--color-success)" }}>
                  Rs. 0 (Free)
                </strong>
              </div>
            </div>

            {/* Official Quotation Card if generated */}
            {quote && (
              <div
                style={{
                  background: "#FFFFFF",
                  border: "2px solid #E86F1C",
                  borderRadius: "var(--radius-sm)",
                  padding: "1.25rem",
                  marginTop: "1rem",
                }}
              >
                <div
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    marginBottom: "0.75rem",
                  }}
                >
                  <div>
                    <span
                      className="badge badge-primary"
                      style={{ marginBottom: "0.3rem" }}
                    >
                      Official Diagnostic Quote
                    </span>
                    <div
                      style={{
                        fontSize: "0.82rem",
                        color: "var(--color-muted)",
                      }}
                    >
                      Valid until: {quote.validUntil}
                    </div>
                  </div>

                  <div style={{ textAlign: "right" }}>
                    <span className="stat-label">Total Quote</span>
                    <div
                      className="stat-value"
                      style={{
                        fontSize: "1.35rem",
                        color: "var(--color-ink)",
                      }}
                    >
                      Rs. {quote.total.toLocaleString("en-IN")}
                    </div>
                  </div>
                </div>

                {/* Breakdown */}
                <div
                  style={{
                    fontSize: "0.88rem",
                    display: "flex",
                    flexDirection: "column",
                    gap: "0.4rem",
                    borderTop: "1px solid var(--color-border)",
                    paddingTop: "0.75rem",
                    marginBottom: "1rem",
                  }}
                >
                  <div
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                    }}
                  >
                    <span>Labour / Diagnostic Servicing:</span>
                    <strong>
                      Rs. {quote.labourTotal.toLocaleString("en-IN")}
                    </strong>
                  </div>
                  <div
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                    }}
                  >
                    <span>Replacement Parts:</span>
                    <strong>
                      Rs. {quote.partsTotal.toLocaleString("en-IN")}
                    </strong>
                  </div>
                  {quote.warrantyTerms && (
                    <div
                      style={{
                        fontSize: "0.82rem",
                        color: "var(--color-success)",
                        marginTop: "0.2rem",
                      }}
                    >
                      🛡️ Service Warranty: {quote.warrantyTerms}
                    </div>
                  )}
                  {quote.notes && (
                    <div
                      style={{
                        fontSize: "0.82rem",
                        color: "var(--color-muted)",
                        marginTop: "0.2rem",
                      }}
                    >
                      Note: {quote.notes}
                    </div>
                  )}
                </div>

                {/* Approval / Rejection Actions */}
                {quote.status === "SENT" && (
                  <div
                    style={{
                      display: "flex",
                      gap: "1rem",
                      borderTop: "1px solid var(--color-border)",
                      paddingTop: "1rem",
                    }}
                  >
                    <button
                      type="button"
                      onClick={() =>
                        onQuoteResponse(req.id, quote.id, true)
                      }
                      className="btn btn-primary"
                      style={{ flex: 1, padding: "0.65rem" }}
                    >
                      <CheckCircle size={16} /> Approve Quote &amp; Begin Repair
                    </button>
                    <button
                      type="button"
                      onClick={() =>
                        onQuoteResponse(req.id, quote.id, false)
                      }
                      className="btn btn-secondary"
                      style={{
                        flex: 1,
                        padding: "0.65rem",
                        color: "var(--color-danger)",
                      }}
                    >
                      <XCircle size={16} /> Decline Quote
                    </button>
                  </div>
                )}

                {quote.status === "ACCEPTED" && (
                  <div
                    style={{
                      padding: "0.5rem",
                      background: "#EAF6EE",
                      color: "var(--color-success)",
                      borderRadius: "4px",
                      fontSize: "0.85rem",
                      textAlign: "center",
                      fontWeight: 600,
                    }}
                  >
                    ✓ Quotation Accepted on{" "}
                    {new Date(quote.acceptedAt || "").toLocaleDateString()} —
                    Repair in progress.
                  </div>
                )}

                {quote.status === "REJECTED" && (
                  <div
                    style={{
                      padding: "0.5rem",
                      background: "#FDF0F0",
                      color: "var(--color-danger)",
                      borderRadius: "4px",
                      fontSize: "0.85rem",
                      textAlign: "center",
                      fontWeight: 600,
                    }}
                  >
                    ✕ Quotation Declined — No repair will be carried out.
                  </div>
                )}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
};
