"use client";

import React, { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import { doc, getDoc } from "firebase/firestore";
import { db } from "../../../../lib/firebase";
import { ServiceRequest, REPAIR_PRICE_NOTICE } from "@sharmavideocare/shared";
import { CheckCircle2, ArrowRight, MessageSquare, Clock, MapPin, Wrench } from "lucide-react";

export default function ServiceSuccessPage() {
  const params = useParams();
  const id = params?.id as string;
  const [request, setRequest] = useState<ServiceRequest | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadRequest() {
      try {
        const snap = await getDoc(doc(db, "serviceRequests", id));
        if (snap.exists()) {
          setRequest({ id: snap.id, ...snap.data() } as ServiceRequest);
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    if (id) loadRequest();
  }, [id]);

  return (
    <div className="container" style={{ padding: "4rem 1.25rem", maxWidth: "680px", textAlign: "center" }}>
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

      <h1 style={{ fontSize: "2rem", fontWeight: 800, color: "var(--color-ink)", marginBottom: "0.5rem" }}>
        Service Request Received!
      </h1>
      <p style={{ color: "var(--color-muted)", fontSize: "1rem", lineHeight: 1.6, marginBottom: "2rem" }}>
        Your request has been routed to the Sharma Video Care technical team in Janakpur. We will assign a technician to schedule your free inspection.
      </p>

      {/* Request Summary Card */}
      <div className="card" style={{ textAlign: "left", marginBottom: "2rem" }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "1rem", borderBottom: "1px solid var(--color-border)", paddingBottom: "0.75rem" }}>
          <div>
            <span style={{ fontSize: "0.8rem", color: "var(--color-muted)" }}>Request Reference</span>
            <div style={{ fontWeight: 700, fontSize: "1.05rem" }}>#{id.slice(0, 8)}</div>
          </div>
          <span className="badge badge-warning">
            {request?.status || "REQUESTED"}
          </span>
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: "0.75rem", fontSize: "0.9rem" }}>
          <div>
            <strong style={{ color: "var(--color-ink)" }}>Item:</strong>{" "}
            <span style={{ color: "var(--color-muted)" }}>{request?.title || "Equipment Repair"}</span>
          </div>
          <div>
            <strong style={{ color: "var(--color-ink)" }}>Description:</strong>{" "}
            <span style={{ color: "var(--color-muted)" }}>{request?.description}</span>
          </div>
          <div>
            <strong style={{ color: "var(--color-ink)" }}>Location:</strong>{" "}
            <span style={{ color: "var(--color-muted)" }}>
              {request?.address?.streetAddress}, {request?.address?.city}
            </span>
          </div>
          <div>
            <strong style={{ color: "var(--color-ink)" }}>Preferred Schedule:</strong>{" "}
            <span style={{ color: "var(--color-muted)" }}>
              {request?.preferredSchedule?.preferredDate} ({request?.preferredSchedule?.preferredTimeSlot})
            </span>
          </div>
        </div>

        <div style={{ marginTop: "1.25rem", padding: "0.85rem", background: "var(--color-canvas)", borderRadius: "var(--radius-sm)", fontSize: "0.85rem", color: "var(--color-primary-dark)" }}>
          ℹ️ {REPAIR_PRICE_NOTICE} Initial inspection & visit are Rs. 0.
        </div>
      </div>

      <div style={{ display: "flex", gap: "1rem", justifyContent: "center", flexWrap: "wrap" }}>
        <Link href={`/account?tab=repairs&id=${id}`} className="btn btn-primary">
          <Clock size={16} /> Track Request Status
        </Link>
        <Link href={`/chat?contextId=${id}`} className="btn btn-secondary">
          <MessageSquare size={16} /> Chat with Support
        </Link>
      </div>
    </div>
  );
}
