"use client";

import React, { useEffect, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import {
  collection,
  query,
  where,
  doc,
  updateDoc,
  onSnapshot,
} from "firebase/firestore";
import { db } from "../../lib/firebase";
import { useAuth } from "../../context/AuthContext";
import {
  ServiceRequest,
  OrderRecord,
  SourceRequest,
  ServiceQuote,
} from "@sharmavideocare/shared";
import {
  ProfileHeader,
  AccountTabs,
  RepairsTab,
  OrdersTab,
  SourcingTab,
} from "@/components/account";

function AccountContent() {
  const searchParams = useSearchParams();
  const initialTab = searchParams.get("tab") || "repairs";
  const highlightedId = searchParams.get("id") || "";

  const { user, role, firebaseUser, signOut } = useAuth();
  const [activeTab, setActiveTab] = useState(initialTab);

  const [repairs, setRepairs] = useState<ServiceRequest[]>([]);
  const [orders, setOrders] = useState<OrderRecord[]>([]);
  const [sourcing, setSourcing] = useState<SourceRequest[]>([]);
  const [quotes, setQuotes] = useState<Record<string, ServiceQuote>>({});
  const [, setLoading] = useState(true);

  const customerId = user ? user.id : "cust-janakpur-01";

  useEffect(() => {
    // Realtime listeners for customer data
    const qRepairs = query(
      collection(db, "serviceRequests"),
      where("customerId", "==", customerId)
    );
    const unsubRepairs = onSnapshot(qRepairs, (snap) => {
      const list: ServiceRequest[] = [];
      snap.forEach((d) =>
        list.push({ id: d.id, ...d.data() } as ServiceRequest)
      );
      setRepairs(
        list.sort(
          (a, b) =>
            new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
        )
      );
    });

    const qOrders = query(
      collection(db, "orders"),
      where("customerId", "==", customerId)
    );
    const unsubOrders = onSnapshot(qOrders, (snap) => {
      const list: OrderRecord[] = [];
      snap.forEach((d) => list.push({ id: d.id, ...d.data() } as OrderRecord));
      setOrders(
        list.sort(
          (a, b) =>
            new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
        )
      );
    });

    const qSource = query(
      collection(db, "sourceRequests"),
      where("customerId", "==", customerId)
    );
    const unsubSource = onSnapshot(qSource, (snap) => {
      const list: SourceRequest[] = [];
      snap.forEach((d) =>
        list.push({ id: d.id, ...d.data() } as SourceRequest)
      );
      setSourcing(
        list.sort(
          (a, b) =>
            new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
        )
      );
    });

    // Fetch quotes for customer
    const qQuotes = query(
      collection(db, "quotes"),
      where("customerId", "==", customerId)
    );
    const unsubQuotes = onSnapshot(qQuotes, (snap) => {
      const map: Record<string, ServiceQuote> = {};
      snap.forEach((d) => {
        const quote = { id: d.id, ...d.data() } as ServiceQuote;
        map[quote.serviceRequestId] = quote;
      });
      setQuotes(map);
      setLoading(false);
    });

    return () => {
      unsubRepairs();
      unsubOrders();
      unsubSource();
      unsubQuotes();
    };
  }, [customerId]);

  const handleQuoteResponse = async (
    serviceReqId: string,
    quoteId: string,
    accept: boolean
  ) => {
    try {
      const newStatus = accept ? "ACCEPTED" : "REJECTED";
      await updateDoc(doc(db, "quotes", quoteId), {
        status: newStatus,
        [accept ? "acceptedAt" : "rejectedAt"]: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      });

      await updateDoc(doc(db, "serviceRequests", serviceReqId), {
        status: accept ? "CUSTOMER_APPROVED" : "CANCELLED",
        updatedAt: new Date().toISOString(),
      });
    } catch (err) {
      console.error("Quote action failed:", err);
    }
  };

  return (
    <div className="container" style={{ padding: "3rem 1.25rem" }}>
      {/* Profile Header */}
      <ProfileHeader
        user={user}
        role={role}
        firebaseUser={firebaseUser}
        signOut={signOut}
      />

      {/* Navigation Tabs */}
      <AccountTabs
        activeTab={activeTab}
        onTabChange={setActiveTab}
        repairsCount={repairs.length}
        ordersCount={orders.length}
        sourcingCount={sourcing.length}
      />

      {/* Tab 1: Repairs & Services */}
      {activeTab === "repairs" && (
        <RepairsTab
          repairs={repairs}
          quotes={quotes}
          highlightedId={highlightedId}
          onQuoteResponse={handleQuoteResponse}
        />
      )}

      {/* Tab 2: Orders & Delivery */}
      {activeTab === "orders" && <OrdersTab orders={orders} />}

      {/* Tab 3: Sourcing Requests */}
      {activeTab === "sourcing" && <SourcingTab sourcing={sourcing} />}
    </div>
  );
}

export default function AccountPage() {
  return (
    <Suspense
      fallback={
        <div
          className="container"
          style={{ padding: "4rem 0", textAlign: "center" }}
        >
          Loading account...
        </div>
      }
    >
      <AccountContent />
    </Suspense>
  );
}
