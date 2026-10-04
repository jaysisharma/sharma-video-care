"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
import {
  collection,
  query,
  getDocs,
  doc,
  updateDoc,
  addDoc,
  onSnapshot,
  setDoc,
  getDoc,
} from "firebase/firestore";
import { db } from "../../lib/firebase";
import { useAuth, DEMO_PERSONAS } from "../../context/AuthContext";
import {
  ServiceRequest,
  OrderRecord,
  PaymentProof,
  InspectionRecord,
  ProductItem,
  UsedProductListing,
  CommercialSettings,
  DEFAULT_TECH_COMMISSION_PCT,
  DEFAULT_SVC_COMMISSION_PCT,
} from "@sharmavideocare/shared";
import {
  ShieldAlert,
  Wrench,
  ShoppingBag,
  Building2,
  Settings,
  CheckCircle2,
  XCircle,
  Truck,
  Plus,
  Send,
  UserCheck,
  Eye,
  MessageSquare,
} from "lucide-react";

export default function AdminConsolePage() {
  const { user, role, switchPersona } = useAuth();
  const [activeTab, setActiveTab] = useState<"repairs" | "orders" | "payments" | "products" | "settings">("repairs");

  // Realtime datasets
  const [serviceRequests, setServiceRequests] = useState<ServiceRequest[]>([]);
  const [orders, setOrders] = useState<OrderRecord[]>([]);
  const [payments, setPayments] = useState<PaymentProof[]>([]);
  const [products, setProducts] = useState<ProductItem[]>([]);
  const [usedProducts, setUsedProducts] = useState<UsedProductListing[]>([]);
  const [commercialSettings, setCommercialSettings] = useState<CommercialSettings | null>(null);

  // Modals state
  const [selectedRequest, setSelectedRequest] = useState<ServiceRequest | null>(null);
  const [selectedInspection, setSelectedInspection] = useState<InspectionRecord | null>(null);
  const [showAssignModal, setShowAssignModal] = useState(false);
  const [selectedTechId, setSelectedTechId] = useState("tech-svc-int-01");

  const [showQuoteModal, setShowQuoteModal] = useState(false);
  const [labourAmount, setLabourAmount] = useState("2500");
  const [partsAmount, setPartsAmount] = useState("4500");
  const [quoteWarranty, setQuoteWarranty] = useState("90 Days Service Warranty");
  const [quoteNotes, setQuoteNotes] = useState("Includes complete sensor cleaning and shutter replacement.");

  // Courier fulfillment modal
  const [selectedOrder, setSelectedOrder] = useState<OrderRecord | null>(null);
  const [courierPartner, setCourierPartner] = useState("Nepal Can Move");
  const [trackingNumber, setTrackingNumber] = useState("");
  const [showDispatchModal, setShowDispatchModal] = useState(false);

  // Settings form
  const [techSplit, setTechSplit] = useState(DEFAULT_TECH_COMMISSION_PCT);
  const [svcSplit, setSvcSplit] = useState(DEFAULT_SVC_COMMISSION_PCT);
  const [deliveryFee, setDeliveryFee] = useState(150);
  const [savingSettings, setSavingSettings] = useState(false);

  useEffect(() => {
    // Service Requests
    const unsubReqs = onSnapshot(collection(db, "serviceRequests"), (snap) => {
      const list: ServiceRequest[] = [];
      snap.forEach((d) => list.push({ id: d.id, ...d.data() } as ServiceRequest));
      setServiceRequests(list.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()));
    });

    // Orders
    const unsubOrders = onSnapshot(collection(db, "orders"), (snap) => {
      const list: OrderRecord[] = [];
      snap.forEach((d) => list.push({ id: d.id, ...d.data() } as OrderRecord));
      setOrders(list.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()));
    });

    // Payments
    const unsubPayments = onSnapshot(collection(db, "payments"), (snap) => {
      const list: PaymentProof[] = [];
      snap.forEach((d) => list.push({ id: d.id, ...d.data() } as PaymentProof));
      setPayments(list.sort((a, b) => new Date(b.submittedAt).getTime() - new Date(a.submittedAt).getTime()));
    });

    // Products
    const unsubProducts = onSnapshot(collection(db, "products"), (snap) => {
      const list: ProductItem[] = [];
      snap.forEach((d) => list.push({ id: d.id, ...d.data() } as ProductItem));
      setProducts(list);
    });

    // Commercial settings
    getDoc(doc(db, "settings", "commercial")).then((snap) => {
      if (snap.exists()) {
        const data = snap.data() as CommercialSettings;
        setCommercialSettings(data);
        if (data.externalTechnicianCommissionPct) setTechSplit(data.externalTechnicianCommissionPct);
        if (data.sharmaVideoCareCommissionPct) setSvcSplit(data.sharmaVideoCareCommissionPct);
        if (data.deliveryNationwideFeeDefault) setDeliveryFee(data.deliveryNationwideFeeDefault);
      }
    });

    return () => {
      unsubReqs();
      unsubOrders();
      unsubPayments();
      unsubProducts();
    };
  }, []);

  // Technician assignment
  const handleAssignTechnician = async () => {
    if (!selectedRequest) return;
    const techPersona = DEMO_PERSONAS.find((p) => p.id === selectedTechId);

    try {
      await updateDoc(doc(db, "serviceRequests", selectedRequest.id), {
        assignedTechnicianId: selectedTechId,
        assignedTechnicianName: techPersona?.name || "Assigned Technician",
        status: "INSPECTION_SCHEDULED",
        updatedAt: new Date().toISOString(),
      });

      // Also ensure technician is added to chat participants
      const qConv = query(collection(db, "conversations"));
      const snap = await getDocs(qConv);
      snap.forEach(async (d) => {
        if (d.data().contextId === selectedRequest.id) {
          const currentParts: string[] = d.data().participantIds || [];
          if (!currentParts.includes(selectedTechId)) {
            await updateDoc(doc(db, "conversations", d.id), {
              participantIds: [...currentParts, selectedTechId],
            });
          }
        }
      });

      setShowAssignModal(false);
      setSelectedRequest(null);
    } catch (e) {
      console.error(e);
    }
  };

  // View inspection findings before sending quote
  const handleViewInspectionAndQuote = async (req: ServiceRequest) => {
    setSelectedRequest(req);
    if (req.inspectionId) {
      try {
        const snap = await getDoc(doc(db, "inspections", req.inspectionId));
        if (snap.exists()) {
          setSelectedInspection({ id: snap.id, ...snap.data() } as InspectionRecord);
        }
      } catch (e) {
        console.error(e);
      }
    }
    setShowQuoteModal(true);
  };

  // Submit quote
  const handleSendQuotation = async () => {
    if (!selectedRequest) return;
    try {
      const labour = Number(labourAmount);
      const parts = Number(partsAmount);
      const total = labour + parts;

      const quoteData = {
        serviceRequestId: selectedRequest.id,
        customerId: selectedRequest.customerId,
        items: [
          { id: "item-1", description: "Technical Labour & Diagnosis", type: "LABOUR", amount: labour },
          { id: "item-2", description: "Hardware Components & Parts", type: "PART", amount: parts },
        ],
        labourTotal: labour,
        partsTotal: parts,
        inspectionFee: 0,
        visitFee: 0,
        discount: 0,
        total,
        currency: "NPR",
        notes: quoteNotes,
        warrantyTerms: quoteWarranty,
        validUntil: new Date(Date.now() + 7 * 86400000).toISOString().split("T")[0],
        status: "SENT",
        createdBy: user?.name || "Admin Desk",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      const quoteRef = await addDoc(collection(db, "quotes"), quoteData);

      await updateDoc(doc(db, "serviceRequests", selectedRequest.id), {
        quoteId: quoteRef.id,
        status: "QUOTE_SENT",
        updatedAt: new Date().toISOString(),
      });

      setShowQuoteModal(false);
      setSelectedRequest(null);
    } catch (e) {
      console.error(e);
    }
  };

  // Verify Bank Transfer
  const handleVerifyPayment = async (payment: PaymentProof) => {
    try {
      await updateDoc(doc(db, "payments", payment.id), {
        status: "VERIFIED",
        verifiedBy: user?.name || "Sharma Admin",
        verifiedAt: new Date().toISOString(),
      });

      await updateDoc(doc(db, "orders", payment.orderId), {
        paymentStatus: "VERIFIED",
        orderStatus: "CONFIRMED",
        updatedAt: new Date().toISOString(),
      });
    } catch (e) {
      console.error(e);
    }
  };

  // Reject Bank Transfer
  const handleRejectPayment = async (payment: PaymentProof) => {
    try {
      await updateDoc(doc(db, "payments", payment.id), {
        status: "REJECTED",
        rejectionReason: "Voucher reference not matched in bank statement.",
        verifiedBy: user?.name || "Sharma Admin",
        verifiedAt: new Date().toISOString(),
      });

      await updateDoc(doc(db, "orders", payment.orderId), {
        paymentStatus: "REJECTED",
        updatedAt: new Date().toISOString(),
      });
    } catch (e) {
      console.error(e);
    }
  };

  // Courier Dispatch
  const handleDispatchOrder = async () => {
    if (!selectedOrder) return;
    try {
      await updateDoc(doc(db, "orders", selectedOrder.id), {
        orderStatus: "DISPATCHED",
        courierDetails: {
          partnerName: courierPartner,
          trackingNumber: trackingNumber || `TRK-SVC-${Math.floor(100000 + Math.random() * 900000)}`,
          dispatchedAt: new Date().toISOString(),
        },
        updatedAt: new Date().toISOString(),
      });

      setShowDispatchModal(false);
      setSelectedOrder(null);
      setTrackingNumber("");
    } catch (e) {
      console.error(e);
    }
  };

  // Mark Delivered
  const handleMarkDelivered = async (orderId: string) => {
    try {
      await updateDoc(doc(db, "orders", orderId), {
        orderStatus: "DELIVERED",
        paymentStatus: "VERIFIED", // for COD orders, delivery completes payment
        updatedAt: new Date().toISOString(),
      });
    } catch (e) {
      console.error(e);
    }
  };

  // Save Settings
  const handleSaveSettings = async (e: React.FormEvent) => {
    e.preventDefault();
    setSavingSettings(true);
    try {
      await setDoc(
        doc(db, "settings", "commercial"),
        {
          externalTechnicianCommissionPct: Number(techSplit),
          sharmaVideoCareCommissionPct: Number(svcSplit),
          deliveryNationwideFeeDefault: Number(deliveryFee),
          updatedAt: new Date().toISOString(),
        },
        { merge: true }
      );
      alert("Commercial settings updated successfully!");
    } catch (e) {
      console.error(e);
    } finally {
      setSavingSettings(false);
    }
  };

  if (role !== "admin") {
    return (
      <div className="container" style={{ padding: "5rem 1.25rem", maxWidth: "560px", textAlign: "center" }}>
        <div className="card" style={{ padding: "3rem 2rem" }}>
          <div
            style={{
              width: "48px",
              height: "48px",
              borderRadius: "4px",
              background: "#FEF6E7",
              color: "var(--color-warning)",
              display: "inline-flex",
              alignItems: "center",
              justifyContent: "center",
              marginBottom: "1.2rem",
            }}
          >
            <ShieldAlert size={26} />
          </div>
          <h2 style={{ fontSize: "1.5rem", fontWeight: 800, color: "var(--color-ink)", marginBottom: "0.5rem" }}>
            Administrator Access Required
          </h2>
          <p style={{ color: "var(--color-muted)", fontSize: "0.92rem", lineHeight: 1.5, marginBottom: "2rem" }}>
            The Central Operations Console is restricted to authorized administrative staff.
            You are currently browsing as <strong>{user?.name || "Guest"}</strong> ({role}).
          </p>
          <div style={{ display: "flex", gap: "0.75rem", justifyContent: "center", flexWrap: "wrap" }}>
            <Link href="/login?redirect=/admin" className="btn btn-primary btn-sm">
              Sign In as Admin
            </Link>
            <button
              type="button"
              onClick={() => switchPersona("admin-svc-01")}
              className="btn btn-secondary btn-sm"
            >
              Switch to Admin Role
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="container" style={{ padding: "3rem 1.25rem" }}>
      {/* Admin Title */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "2rem", flexWrap: "wrap", gap: "1rem" }}>
        <div>
          <span className="badge badge-warning" style={{ marginBottom: "0.4rem" }}>
            <ShieldAlert size={14} style={{ display: "inline", marginRight: "4px" }} /> Operational Master Console
          </span>
          <h1 style={{ fontSize: "2rem", fontWeight: 800, color: "var(--color-ink)" }}>
            Sharma Video Care Central Operations
          </h1>
          <p style={{ color: "var(--color-muted)", fontSize: "0.9rem" }}>
            Janakpur Service Center dispatch, diagnostic quotations, nationwide fulfillment, and payment verification.
          </p>
        </div>
      </div>

      {/* Overview Stat Cards */}
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: "1rem", marginBottom: "2.5rem" }}>
        <div className="card" style={{ borderLeft: "3px solid var(--color-primary)" }}>
          <span className="stat-label">Active Service Requests</span>
          <div className="stat-value" style={{ fontSize: "1.75rem", marginTop: "0.2rem" }}>
            {serviceRequests.filter((r) => r.status !== "COMPLETED" && r.status !== "CANCELLED").length}
          </div>
        </div>

        <div className="card" style={{ borderLeft: "3px solid var(--color-warning)" }}>
          <span className="stat-label">Quotes Pending Preparation</span>
          <div className="stat-value" style={{ fontSize: "1.75rem", marginTop: "0.2rem" }}>
            {serviceRequests.filter((r) => r.status === "QUOTE_PENDING").length}
          </div>
        </div>

        <div className="card" style={{ borderLeft: "3px solid var(--color-info)" }}>
          <span className="stat-label">Pending Bank Transfers</span>
          <div className="stat-value" style={{ fontSize: "1.75rem", marginTop: "0.2rem" }}>
            {payments.filter((p) => p.status === "PENDING_VERIFICATION").length}
          </div>
        </div>

        <div className="card" style={{ borderLeft: "3px solid var(--color-success)" }}>
          <span className="stat-label">Orders Awaiting Dispatch</span>
          <div className="stat-value" style={{ fontSize: "1.75rem", marginTop: "0.2rem" }}>
            {orders.filter((o) => o.orderStatus === "CONFIRMED" || o.orderStatus === "PAYMENT_SUBMITTED").length}
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div style={{ display: "flex", gap: "0.5rem", borderBottom: "1px solid var(--color-border)", marginBottom: "2rem", overflowX: "auto" }}>
        <button
          onClick={() => setActiveTab("repairs")}
          style={{
            padding: "0.75rem 1.25rem",
            background: "none",
            border: "none",
            borderBottom: activeTab === "repairs" ? "3px solid var(--color-primary)" : "3px solid transparent",
            fontWeight: activeTab === "repairs" ? 700 : 500,
            color: activeTab === "repairs" ? "var(--color-primary)" : "var(--color-muted)",
            fontSize: "0.95rem",
            whiteSpace: "nowrap",
          }}
        >
          Service Requests & Dispatch ({serviceRequests.length})
        </button>

        <button
          onClick={() => setActiveTab("orders")}
          style={{
            padding: "0.75rem 1.25rem",
            background: "none",
            border: "none",
            borderBottom: activeTab === "orders" ? "3px solid var(--color-primary)" : "3px solid transparent",
            fontWeight: activeTab === "orders" ? 700 : 500,
            color: activeTab === "orders" ? "var(--color-primary)" : "var(--color-muted)",
            fontSize: "0.95rem",
            whiteSpace: "nowrap",
          }}
        >
          Orders & Courier Dispatch ({orders.length})
        </button>

        <button
          onClick={() => setActiveTab("payments")}
          style={{
            padding: "0.75rem 1.25rem",
            background: "none",
            border: "none",
            borderBottom: activeTab === "payments" ? "3px solid var(--color-primary)" : "3px solid transparent",
            fontWeight: activeTab === "payments" ? 700 : 500,
            color: activeTab === "payments" ? "var(--color-primary)" : "var(--color-muted)",
            fontSize: "0.95rem",
            whiteSpace: "nowrap",
          }}
        >
          Bank Verification ({payments.filter((p) => p.status === "PENDING_VERIFICATION").length})
        </button>

        <button
          onClick={() => setActiveTab("products")}
          style={{
            padding: "0.75rem 1.25rem",
            background: "none",
            border: "none",
            borderBottom: activeTab === "products" ? "3px solid var(--color-primary)" : "3px solid transparent",
            fontWeight: activeTab === "products" ? 700 : 500,
            color: activeTab === "products" ? "var(--color-primary)" : "var(--color-muted)",
            fontSize: "0.95rem",
            whiteSpace: "nowrap",
          }}
        >
          Catalogue & Inventory ({products.length})
        </button>

        <button
          onClick={() => setActiveTab("settings")}
          style={{
            padding: "0.75rem 1.25rem",
            background: "none",
            border: "none",
            borderBottom: activeTab === "settings" ? "3px solid var(--color-primary)" : "3px solid transparent",
            fontWeight: activeTab === "settings" ? 700 : 500,
            color: activeTab === "settings" ? "var(--color-primary)" : "var(--color-muted)",
            fontSize: "0.95rem",
            whiteSpace: "nowrap",
          }}
        >
          Commercial Split & Settings
        </button>
      </div>

      {/* Tab 1: Service Requests & Dispatch */}
      {activeTab === "repairs" && (
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>Request / Item</th>
                <th>Customer & Location</th>
                <th>Technician</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {serviceRequests.map((req) => (
                <tr key={req.id}>
                  <td>
                    <strong>{req.title}</strong>
                    <div style={{ fontSize: "0.8rem", color: "var(--color-muted)" }}>
                      Ref #{req.id.slice(0, 8)} • Slot: {req.preferredSchedule?.preferredDate}
                    </div>
                  </td>
                  <td>
                    <div>{req.customerName}</div>
                    <div style={{ fontSize: "0.8rem", color: "var(--color-muted)" }}>
                      {req.address?.streetAddress}, {req.address?.city} ({req.customerPhone})
                    </div>
                  </td>
                  <td>
                    {req.assignedTechnicianName ? (
                      <span className="badge badge-info">{req.assignedTechnicianName}</span>
                    ) : (
                      <span className="badge badge-muted">Unassigned</span>
                    )}
                  </td>
                  <td>
                    <span
                      className={
                        req.status === "COMPLETED"
                          ? "badge badge-success"
                          : req.status === "CUSTOMER_APPROVED" || req.status === "IN_PROGRESS"
                          ? "badge badge-info"
                          : req.status === "QUOTE_PENDING"
                          ? "badge badge-warning"
                          : "badge badge-muted"
                      }
                    >
                      {req.status.replace("_", " ")}
                    </span>
                  </td>
                  <td>
                    <div style={{ display: "flex", gap: "0.4rem", flexWrap: "wrap" }}>
                      {/* Assign button */}
                      <button
                        onClick={() => {
                          setSelectedRequest(req);
                          setShowAssignModal(true);
                        }}
                        className="btn btn-secondary btn-sm"
                        title="Assign Technician"
                      >
                        <UserCheck size={14} /> Assign
                      </button>

                      {/* Quote button if diagnosis ready */}
                      {req.status === "QUOTE_PENDING" && (
                        <button
                          onClick={() => handleViewInspectionAndQuote(req)}
                          className="btn btn-primary btn-sm"
                        >
                          <Send size={14} /> Send Quote
                        </button>
                      )}

                      <Link href={`/chat?contextId=${req.id}`} className="btn btn-secondary btn-sm">
                        <MessageSquare size={14} />
                      </Link>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Tab 2: Orders & Courier Dispatch */}
      {activeTab === "orders" && (
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>Order Ref</th>
                <th>Destination</th>
                <th>Items & Total</th>
                <th>Payment</th>
                <th>Status</th>
                <th>Fulfillment Action</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((ord) => (
                <tr key={ord.id}>
                  <td>
                    <strong>#{ord.id.slice(0, 8)}</strong>
                    <div style={{ fontSize: "0.78rem", color: "var(--color-muted)" }}>
                      {new Date(ord.createdAt).toLocaleDateString()}
                    </div>
                  </td>
                  <td>
                    <div>{ord.shippingAddress?.recipientName}</div>
                    <div style={{ fontSize: "0.8rem", color: "var(--color-muted)" }}>
                      {ord.shippingAddress?.city}, {ord.shippingAddress?.province}
                    </div>
                  </td>
                  <td>
                    <div style={{ fontSize: "0.85rem" }}>{ord.items.length} items</div>
                    <strong>Rs. {ord.total.toLocaleString("en-IN")}</strong>
                  </td>
                  <td>
                    <span className={ord.paymentStatus === "VERIFIED" ? "badge badge-success" : "badge badge-warning"}>
                      {ord.paymentMethod}: {ord.paymentStatus}
                    </span>
                  </td>
                  <td>
                    <span className="badge badge-info">{ord.orderStatus}</span>
                  </td>
                  <td>
                    <div style={{ display: "flex", gap: "0.4rem" }}>
                      {ord.orderStatus !== "DISPATCHED" && ord.orderStatus !== "DELIVERED" ? (
                        <button
                          onClick={() => {
                            setSelectedOrder(ord);
                            setShowDispatchModal(true);
                          }}
                          className="btn btn-primary btn-sm"
                        >
                          <Truck size={14} /> Dispatch Courier
                        </button>
                      ) : ord.orderStatus === "DISPATCHED" ? (
                        <button
                          onClick={() => handleMarkDelivered(ord.id)}
                          className="btn btn-success btn-sm"
                        >
                          <CheckCircle2 size={14} /> Mark Delivered
                        </button>
                      ) : (
                        <span style={{ fontSize: "0.82rem", color: "var(--color-success)", fontWeight: 600 }}>
                          ✓ Completed
                        </span>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Tab 3: Bank Transfer Payment Verification */}
      {activeTab === "payments" && (
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>Order Reference</th>
                <th>Submitted Amount</th>
                <th>Bank Reference / Voucher</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {payments.map((p) => (
                <tr key={p.id}>
                  <td>
                    <strong>Order #{p.orderId.slice(0, 8)}</strong>
                    <div style={{ fontSize: "0.78rem", color: "var(--color-muted)" }}>
                      Submitted {new Date(p.submittedAt).toLocaleTimeString()}
                    </div>
                  </td>
                  <td style={{ fontWeight: 700 }}>
                    Rs. {p.amount.toLocaleString("en-IN")}
                  </td>
                  <td>
                    <div style={{ fontFamily: "'JetBrains Mono', ui-monospace, monospace", fontWeight: 600, fontSize: "0.88rem" }}>{p.referenceNumber}</div>
                    {p.proofImageUrl && (
                      <a href={p.proofImageUrl} target="_blank" rel="noreferrer" style={{ fontSize: "0.8rem", color: "var(--color-primary)", textDecoration: "underline" }}>
                        View Voucher Image ↗
                      </a>
                    )}
                  </td>
                  <td>
                    <span className={p.status === "VERIFIED" ? "badge badge-success" : p.status === "REJECTED" ? "badge badge-danger" : "badge badge-warning"}>
                      {p.status}
                    </span>
                  </td>
                  <td>
                    {p.status === "PENDING_VERIFICATION" && (
                      <div style={{ display: "flex", gap: "0.4rem" }}>
                        <button
                          onClick={() => handleVerifyPayment(p)}
                          className="btn btn-success btn-sm"
                        >
                          <CheckCircle2 size={14} /> Approve & Confirm
                        </button>
                        <button
                          onClick={() => handleRejectPayment(p)}
                          className="btn btn-danger btn-sm"
                        >
                          <XCircle size={14} /> Reject
                        </button>
                      </div>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Tab 4: Catalogue & Inventory */}
      {activeTab === "products" && (
        <div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: "1.25rem" }}>
            {products.map((p) => (
              <div key={p.id} className="card" style={{ display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
                <div>
                  <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "0.4rem" }}>
                    <span style={{ fontSize: "0.78rem", color: "var(--color-muted)" }}>{p.brand}</span>
                    <span className={p.availabilityType === "IN_STOCK" ? "badge badge-success" : "badge badge-warning"}>
                      {p.availabilityType}
                    </span>
                  </div>
                  <h4 style={{ fontSize: "1rem", fontWeight: 700, marginBottom: "0.3rem" }}>{p.name}</h4>
                  <div style={{ fontWeight: 800, color: "var(--color-primary)", fontSize: "1.1rem" }}>
                    Rs. {p.price.toLocaleString("en-IN")}
                  </div>
                </div>

                <div style={{ marginTop: "1rem", borderTop: "1px solid var(--color-border)", paddingTop: "0.75rem", display: "flex", gap: "0.5rem" }}>
                  <select
                    className="form-select"
                    style={{ fontSize: "0.8rem", padding: "0.3rem" }}
                    value={p.availabilityType}
                    onChange={async (e) => {
                      await updateDoc(doc(db, "products", p.id), {
                        availabilityType: e.target.value,
                        updatedAt: new Date().toISOString(),
                      });
                    }}
                  >
                    <option value="IN_STOCK">IN_STOCK</option>
                    <option value="SOURCE_ON_REQUEST">SOURCE_ON_REQUEST</option>
                    <option value="OUT_OF_STOCK">OUT_OF_STOCK</option>
                  </select>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Tab 5: Commercial Settings */}
      {activeTab === "settings" && (
        <form onSubmit={handleSaveSettings} className="card" style={{ maxWidth: "600px", padding: "2rem" }}>
          <h3 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "1.5rem" }}>
            Commercial Revenue & Commission Settings
          </h3>

          <div className="notice-box" style={{ marginBottom: "1.5rem", fontSize: "0.85rem" }}>
            Changes here configure defaults. Existing completed historical jobs preserve their snapshot commission rate.
          </div>

          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1rem" }}>
            <div className="form-group">
              <label className="form-label">Sharma Video Care Retention (%) *</label>
              <input
                type="number"
                className="form-input"
                value={svcSplit}
                onChange={(e) => {
                  setSvcSplit(Number(e.target.value));
                  setTechSplit(100 - Number(e.target.value));
                }}
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">External Technician Split (%) *</label>
              <input
                type="number"
                className="form-input"
                value={techSplit}
                onChange={(e) => {
                  setTechSplit(Number(e.target.value));
                  setSvcSplit(100 - Number(e.target.value));
                }}
                required
              />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Default Nationwide Courier Fee (NPR) *</label>
            <input
              type="number"
              className="form-input"
              value={deliveryFee}
              onChange={(e) => setDeliveryFee(Number(e.target.value))}
              required
            />
          </div>

          <div className="form-group">
            <label className="form-label">Initial Service Area</label>
            <input
              type="text"
              className="form-input"
              value="Janakpur (Sub-Metropolitan)"
              disabled
              style={{ background: "#F5FAF7" }}
            />
          </div>

          <button
            type="submit"
            className="btn btn-primary"
            disabled={savingSettings}
            style={{ width: "100%", padding: "0.8rem", marginTop: "1rem" }}
          >
            {savingSettings ? "Updating Settings..." : "Save Commercial Configuration"}
          </button>
        </form>
      )}

      {/* Modal: Technician Assignment */}
      {showAssignModal && selectedRequest && (
        <div className="modal-overlay">
          <div className="modal-content">
            <h3 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "0.5rem" }}>
              Assign Technician to Job
            </h3>
            <p style={{ color: "var(--color-muted)", fontSize: "0.88rem", marginBottom: "1.5rem" }}>
              Selected Service: <strong>{selectedRequest.title}</strong> in {selectedRequest.address?.city}
            </p>

            <div className="form-group">
              <label className="form-label">Select Technician</label>
              <select
                className="form-select"
                value={selectedTechId}
                onChange={(e) => setSelectedTechId(e.target.value)}
              >
                {DEMO_PERSONAS.filter((p) => p.role === "technician").map((t) => (
                  <option key={t.id} value={t.id}>
                    {t.name} ({t.technicianType === "INTERNAL" ? "Internal Staff" : "External Partner"})
                  </option>
                ))}
              </select>
            </div>

            <div style={{ display: "flex", gap: "1rem", marginTop: "1.5rem" }}>
              <button onClick={() => setShowAssignModal(false)} className="btn btn-secondary" style={{ flex: 1 }}>
                Cancel
              </button>
              <button onClick={handleAssignTechnician} className="btn btn-primary" style={{ flex: 1 }}>
                Confirm Assignment
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal: Formulate & Send Diagnostic Quote */}
      {showQuoteModal && selectedRequest && (
        <div className="modal-overlay">
          <div className="modal-content">
            <h3 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "0.5rem" }}>
              Formulate Official Diagnostic Quotation
            </h3>
            <p style={{ color: "var(--color-muted)", fontSize: "0.85rem", marginBottom: "1.25rem" }}>
              Job: <strong>{selectedRequest.title}</strong>
            </p>

            {/* Display diagnosis recorded by technician */}
            {selectedInspection && (
              <div style={{ background: "var(--color-canvas)", padding: "1rem", borderRadius: "var(--radius-sm)", marginBottom: "1.25rem", fontSize: "0.85rem" }}>
                <div><strong>Technician Findings:</strong> {selectedInspection.findings}</div>
                <div style={{ marginTop: "0.25rem" }}><strong>Diagnosis:</strong> {selectedInspection.diagnosis}</div>
                <div style={{ marginTop: "0.25rem" }}><strong>Required Parts:</strong> {selectedInspection.partsRequired?.map((p) => p.name).join(", ") || "None"}</div>
              </div>
            )}

            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1rem" }}>
              <div className="form-group">
                <label className="form-label">Labour Fee (NPR) *</label>
                <input
                  type="number"
                  className="form-input"
                  value={labourAmount}
                  onChange={(e) => setLabourAmount(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Parts & Hardware (NPR) *</label>
                <input
                  type="number"
                  className="form-input"
                  value={partsAmount}
                  onChange={(e) => setPartsAmount(e.target.value)}
                  required
                />
              </div>
            </div>

            <div style={{ display: "flex", justifyContent: "space-between", padding: "0.75rem", background: "#FAF7F2", borderRadius: "var(--radius-sm)", marginBottom: "1rem" }}>
              <span>Total Quotation to Customer:</span>
              <strong style={{ fontSize: "1.1rem" }}>
                Rs. {(Number(labourAmount || 0) + Number(partsAmount || 0)).toLocaleString("en-IN")}
              </strong>
            </div>

            <div className="form-group">
              <label className="form-label">Service Warranty Terms *</label>
              <input
                type="text"
                className="form-input"
                value={quoteWarranty}
                onChange={(e) => setQuoteWarranty(e.target.value)}
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">Technical Notes to Customer</label>
              <textarea
                className="form-textarea"
                rows={2}
                value={quoteNotes}
                onChange={(e) => setQuoteNotes(e.target.value)}
              />
            </div>

            <div style={{ display: "flex", gap: "1rem", marginTop: "1.5rem" }}>
              <button onClick={() => setShowQuoteModal(false)} className="btn btn-secondary" style={{ flex: 1 }}>
                Cancel
              </button>
              <button onClick={handleSendQuotation} className="btn btn-primary" style={{ flex: 1 }}>
                Dispatch Quote to Customer
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal: Dispatch Courier */}
      {showDispatchModal && selectedOrder && (
        <div className="modal-overlay">
          <div className="modal-content">
            <h3 style={{ fontSize: "1.25rem", fontWeight: 700, marginBottom: "0.5rem" }}>
              Dispatch Order via Courier
            </h3>
            <p style={{ color: "var(--color-muted)", fontSize: "0.85rem", marginBottom: "1.25rem" }}>
              Order #{selectedOrder.id.slice(0, 8)} to {selectedOrder.shippingAddress?.city}
            </p>

            <div className="form-group">
              <label className="form-label">Courier Partner *</label>
              <select
                className="form-select"
                value={courierPartner}
                onChange={(e) => setCourierPartner(e.target.value)}
              >
                <option value="Nepal Can Move">Nepal Can Move</option>
                <option value="Sundar Express">Sundar Express</option>
                <option value="Pathfinder Logistics">Pathfinder Logistics</option>
                <option value="Aramex Nepal">Aramex Nepal</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Courier Tracking ID / Waybill Number</label>
              <input
                type="text"
                className="form-input"
                placeholder="e.g. NCM-9281734"
                value={trackingNumber}
                onChange={(e) => setTrackingNumber(e.target.value)}
              />
            </div>

            <div style={{ display: "flex", gap: "1rem", marginTop: "1.5rem" }}>
              <button onClick={() => setShowDispatchModal(false)} className="btn btn-secondary" style={{ flex: 1 }}>
                Cancel
              </button>
              <button onClick={handleDispatchOrder} className="btn btn-primary" style={{ flex: 1 }}>
                Confirm Dispatch
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
