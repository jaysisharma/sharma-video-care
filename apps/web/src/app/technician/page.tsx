"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
import { collection, query, where, onSnapshot, doc, updateDoc, addDoc, getDoc } from "firebase/firestore";
import { db } from "../../lib/firebase";
import { useAuth } from "../../context/AuthContext";
import {
  ServiceRequest,
  InspectionRecord,
  CommercialSettings,
  DEFAULT_TECH_COMMISSION_PCT,
  REPAIR_PRICE_NOTICE,
} from "@sharmavideocare/shared";
import {
  Hammer,
  Clock,
  CheckCircle2,
  MapPin,
  MessageSquare,
  AlertCircle,
  FileText,
  DollarSign,
  ChevronRight,
  Shield,
} from "lucide-react";

export default function TechnicianPortalPage() {
  const { user, role, technicianType, switchPersona } = useAuth();
  const technicianId = user?.id || "tech-svc-int-01";

  const [assignedJobs, setAssignedJobs] = useState<ServiceRequest[]>([]);
  const [selectedJob, setSelectedJob] = useState<ServiceRequest | null>(null);
  const [loading, setLoading] = useState(true);

  // Inspection form modal state
  const [showInspectionModal, setShowInspectionModal] = useState(false);
  const [findings, setFindings] = useState("");
  const [diagnosis, setDiagnosis] = useState("");
  const [recommendedWork, setRecommendedWork] = useState("");
  const [partsRequired, setPartsRequired] = useState("");
  const [estimatedHours, setEstimatedHours] = useState("2");
  const [submittingInspection, setSubmittingInspection] = useState(false);

  // Settings for commercial commission
  const [commSettings, setCommSettings] = useState<CommercialSettings | null>(null);

  useEffect(() => {
    // Fetch commercial settings for technician commission rate
    async function loadSettings() {
      try {
        const snap = await getDoc(doc(db, "settings", "commercial"));
        if (snap.exists()) {
          setCommSettings(snap.data() as CommercialSettings);
        }
      } catch (e) {
        console.error(e);
      }
    }
    loadSettings();

    // Listen to jobs assigned to this technician
    const qJobs = query(
      collection(db, "serviceRequests"),
      where("assignedTechnicianId", "==", technicianId)
    );

    const unsub = onSnapshot(qJobs, (snap) => {
      const list: ServiceRequest[] = [];
      snap.forEach((d) => list.push({ id: d.id, ...d.data() } as ServiceRequest));
      setAssignedJobs(list.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()));
      setLoading(false);
    });

    return () => unsub();
  }, [technicianId]);

  const handleUpdateStatus = async (jobId: string, newStatus: any) => {
    try {
      await updateDoc(doc(db, "serviceRequests", jobId), {
        status: newStatus,
        updatedAt: new Date().toISOString(),
      });
    } catch (e) {
      console.error(e);
    }
  };

  const handleSaveInspection = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedJob) return;

    setSubmittingInspection(true);
    try {
      const partsList = partsRequired
        .split("\n")
        .filter((p) => p.trim())
        .map((p) => ({ name: p.trim() }));

      const inspData: Omit<InspectionRecord, "id"> = {
        serviceRequestId: selectedJob.id,
        technicianId: user?.id || technicianId,
        technicianName: user?.name || "Technician",
        findings,
        diagnosis,
        recommendedWork,
        mediaUrls: [],
        partsRequired: partsList,
        estimatedLabourHours: Number(estimatedHours),
        inspectionFee: 0, // Confirmed free
        completedAt: new Date().toISOString(),
      };

      const docRef = await addDoc(collection(db, "inspections"), inspData);

      // Advance job status to QUOTE_PENDING so admin can formulate the quote
      await updateDoc(doc(db, "serviceRequests", selectedJob.id), {
        inspectionId: docRef.id,
        status: "QUOTE_PENDING",
        updatedAt: new Date().toISOString(),
      });

      setShowInspectionModal(false);
      setSelectedJob(null);
      setFindings("");
      setDiagnosis("");
      setRecommendedWork("");
      setPartsRequired("");
    } catch (e) {
      console.error(e);
    } finally {
      setSubmittingInspection(false);
    }
  };

  const techPct = commSettings?.externalTechnicianCommissionPct || DEFAULT_TECH_COMMISSION_PCT;

  if (role !== "technician" && role !== "admin") {
    return (
      <div className="container" style={{ padding: "5rem 1.25rem", maxWidth: "560px", textAlign: "center" }}>
        <div className="card" style={{ padding: "3rem 2rem" }}>
          <div
            style={{
              width: "48px",
              height: "48px",
              borderRadius: "4px",
              background: "#EBF4FC",
              color: "var(--color-info)",
              display: "inline-flex",
              alignItems: "center",
              justifyContent: "center",
              marginBottom: "1.2rem",
            }}
          >
            <Hammer size={26} />
          </div>
          <h2 style={{ fontSize: "1.5rem", fontWeight: 800, color: "var(--color-ink)", marginBottom: "0.5rem" }}>
            Technician Access Required
          </h2>
          <p style={{ color: "var(--color-muted)", fontSize: "0.92rem", lineHeight: 1.5, marginBottom: "2rem" }}>
            The Technician Portal is restricted to authorized field service personnel.
            You are currently browsing as <strong>{user?.name || "Guest"}</strong> ({role}).
          </p>
          <div style={{ display: "flex", gap: "0.75rem", justifyContent: "center", flexWrap: "wrap" }}>
            <Link href="/login?redirect=/technician" className="btn btn-primary btn-sm">
              Sign In as Technician
            </Link>
            <button
              type="button"
              onClick={() => switchPersona("tech-svc-int-01")}
              className="btn btn-secondary btn-sm"
            >
              Switch to Internal Tech Role
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="container" style={{ padding: "3rem 1.25rem" }}>
      {/* Technician Portal Header */}
      <div
        className="card"
        style={{
          padding: "1.75rem",
          marginBottom: "2rem",
          background: "linear-gradient(90deg, #FFFFFF 0%, #F9F6F0 100%)",
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          flexWrap: "wrap",
          gap: "1.5rem",
        }}
      >
        <div>
          <div style={{ display: "flex", alignItems: "center", gap: "0.5rem", marginBottom: "0.4rem" }}>
            <span className="badge badge-info">
              {user?.technicianType === "EXTERNAL" ? "External Technician Partner" : "In-House Service Technician"}
            </span>
            <span className="badge badge-primary">Janakpur Center</span>
          </div>
          <h1 style={{ fontSize: "1.75rem", fontWeight: 800, color: "var(--color-ink)" }}>
            {user ? user.name : "Technician Portal"}
          </h1>
          <p style={{ color: "var(--color-muted)", fontSize: "0.88rem" }}>
            Assigned diagnostics, on-site inspections, parts logging, and service completion.
          </p>
        </div>

        {/* Technician-Eligible Payout Card (Strict isolation: hides company margin) */}
        {user?.technicianType === "EXTERNAL" && (
          <div style={{ background: "var(--color-surface)", padding: "1rem 1.25rem", borderRadius: "var(--radius-sm)", border: "1px solid var(--color-border)", minWidth: "220px" }}>
            <span className="stat-label" style={{ display: "block" }}>
              Contract Commission Rate
            </span>
            <div className="stat-value" style={{ fontSize: "1.25rem", color: "var(--color-success)" }}>
              {techPct}% Payout
            </div>
            <span style={{ fontSize: "0.75rem", color: "var(--color-muted)" }}>
              Per completed eligible job
            </span>
          </div>
        )}
      </div>

      <div style={{ marginBottom: "1.5rem" }}>
        <h2 style={{ fontSize: "1.35rem", fontWeight: 700 }}>
          Assigned Repair & Inspection Jobs ({assignedJobs.length})
        </h2>
        <p style={{ color: "var(--color-muted)", fontSize: "0.88rem" }}>
          You only have access to jobs assigned directly to you by the dispatch team.
        </p>
      </div>

      {loading ? (
        <div style={{ textAlign: "center", padding: "4rem 0" }}>Loading assigned jobs...</div>
      ) : assignedJobs.length === 0 ? (
        <div className="card" style={{ textAlign: "center", padding: "4rem 2rem" }}>
          <Hammer size={40} color="var(--color-muted)" style={{ margin: "0 auto 1rem auto" }} />
          <h3>No assigned jobs at the moment</h3>
          <p style={{ color: "var(--color-muted)", marginTop: "0.5rem" }}>
            When the Janakpur dispatch team assigns a repair or inspection to your profile, it will appear here in real-time.
          </p>
        </div>
      ) : (
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(360px, 1fr))", gap: "1.5rem" }}>
          {assignedJobs.map((job) => (
            <div key={job.id} className="card" style={{ display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
              <div>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: "0.75rem" }}>
                  <span style={{ fontSize: "0.78rem", color: "var(--color-muted)" }}>
                    Ref #{job.id.slice(0, 8)}
                  </span>
                  <span
                    className={
                      job.status === "COMPLETED"
                        ? "badge badge-success"
                        : job.status === "IN_PROGRESS" || job.status === "CUSTOMER_APPROVED"
                        ? "badge badge-info"
                        : "badge badge-warning"
                    }
                  >
                    {job.status.replace("_", " ")}
                  </span>
                </div>

                <h3 style={{ fontSize: "1.15rem", fontWeight: 700, marginBottom: "0.4rem", color: "var(--color-ink)" }}>
                  {job.title}
                </h3>

                <p style={{ fontSize: "0.88rem", color: "var(--color-muted)", marginBottom: "1rem", lineHeight: 1.5 }}>
                  {job.description}
                </p>

                {/* Customer and Schedule Info */}
                <div style={{ background: "var(--color-canvas)", padding: "0.85rem", borderRadius: "var(--radius-sm)", fontSize: "0.85rem", display: "flex", flexDirection: "column", gap: "0.35rem", marginBottom: "1.2rem" }}>
                  <div>
                    <MapPin size={14} style={{ display: "inline", marginRight: "4px" }} />
                    <strong>Location:</strong> {job.address?.streetAddress}, {job.address?.city}
                  </div>
                  <div>
                    <Clock size={14} style={{ display: "inline", marginRight: "4px" }} />
                    <strong>Preferred Slot:</strong> {job.preferredSchedule?.preferredDate} ({job.preferredSchedule?.preferredTimeSlot || "Morning"})
                  </div>
                  <div>
                    <strong>Customer:</strong> {job.customerName} ({job.customerPhone})
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div style={{ borderTop: "1px solid var(--color-border)", paddingTop: "1rem", display: "flex", flexDirection: "column", gap: "0.5rem" }}>
                {/* Step 1: Start Inspection */}
                {job.status === "REQUESTED" || job.status === "INSPECTION_SCHEDULED" ? (
                  <button
                    onClick={() => handleUpdateStatus(job.id, "INSPECTION_IN_PROGRESS")}
                    className="btn btn-primary btn-sm"
                    style={{ width: "100%" }}
                  >
                    Mark "Inspection In Progress"
                  </button>
                ) : null}

                {/* Step 2: Record Diagnosis */}
                {job.status === "INSPECTION_IN_PROGRESS" && (
                  <button
                    onClick={() => {
                      setSelectedJob(job);
                      setShowInspectionModal(true);
                    }}
                    className="btn btn-primary btn-sm"
                    style={{ width: "100%" }}
                  >
                    Record Diagnosis & Required Parts
                  </button>
                )}

                {/* Step 3: Work in progress -> Complete */}
                {job.status === "CUSTOMER_APPROVED" && (
                  <button
                    onClick={() => handleUpdateStatus(job.id, "IN_PROGRESS")}
                    className="btn btn-primary btn-sm"
                    style={{ width: "100%" }}
                  >
                    Begin Approved Repair Work
                  </button>
                )}

                {job.status === "IN_PROGRESS" && (
                  <button
                    onClick={() => handleUpdateStatus(job.id, "COMPLETED")}
                    className="btn btn-success btn-sm"
                    style={{ width: "100%" }}
                  >
                    <CheckCircle2 size={16} /> Mark Job Completed
                  </button>
                )}

                <div style={{ display: "flex", gap: "0.5rem" }}>
                  <Link href={`/chat?contextId=${job.id}`} className="btn btn-secondary btn-sm" style={{ flex: 1, textAlign: "center" }}>
                    <MessageSquare size={14} /> Job Chat
                  </Link>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Inspection & Diagnosis Modal */}
      {showInspectionModal && selectedJob && (
        <div className="modal-overlay">
          <div className="modal-content">
            <h3 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "0.5rem" }}>
              Inspection & Diagnosis: {selectedJob.title}
            </h3>
            <p style={{ color: "var(--color-muted)", fontSize: "0.88rem", marginBottom: "1.5rem" }}>
              Record technical findings. Your diagnosis will be forwarded to the Admin desk to generate an itemized quote for the customer.
            </p>

            <form onSubmit={handleSaveInspection}>
              <div className="form-group">
                <label className="form-label">Physical Inspection Findings *</label>
                <textarea
                  className="form-textarea"
                  rows={3}
                  placeholder="e.g. Broken shutter curtain blade, heavy fungus on element 3, burnt power capacitor..."
                  value={findings}
                  onChange={(e) => setFindings(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Exact Technical Diagnosis *</label>
                <textarea
                  className="form-textarea"
                  rows={3}
                  placeholder="e.g. Shutter mechanism lock due to impact; requires shutter assembly replacement and sensor realignment."
                  value={diagnosis}
                  onChange={(e) => setDiagnosis(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Recommended Work / Scope *</label>
                <textarea
                  className="form-textarea"
                  rows={2}
                  placeholder="e.g. Disassemble body, replace shutter module, clean optical chamber, calibrate AF."
                  value={recommendedWork}
                  onChange={(e) => setRecommendedWork(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Parts Required (One per line)</label>
                <textarea
                  className="form-textarea"
                  rows={2}
                  placeholder="e.g. Sony A7 III Shutter Unit (Part #1-847-920)&#10;Conductive Rubber Gasket"
                  value={partsRequired}
                  onChange={(e) => setPartsRequired(e.target.value)}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Estimated Labour Duration (Hours)</label>
                <input
                  type="number"
                  min="0.5"
                  step="0.5"
                  className="form-input"
                  value={estimatedHours}
                  onChange={(e) => setEstimatedHours(e.target.value)}
                  required
                />
              </div>

              <div style={{ display: "flex", gap: "1rem", marginTop: "1.5rem" }}>
                <button
                  type="button"
                  onClick={() => setShowInspectionModal(false)}
                  className="btn btn-secondary"
                  style={{ flex: 1 }}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="btn btn-primary"
                  disabled={submittingInspection}
                  style={{ flex: 1 }}
                >
                  {submittingInspection ? "Submitting..." : "Submit Diagnosis to Admin"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
