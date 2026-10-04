"use client";

import React from "react";

interface AccountTabsProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
  repairsCount: number;
  ordersCount: number;
  sourcingCount: number;
}

export const AccountTabs: React.FC<AccountTabsProps> = ({
  activeTab,
  onTabChange,
  repairsCount,
  ordersCount,
  sourcingCount,
}) => {
  return (
    <div
      style={{
        display: "flex",
        gap: "0.5rem",
        borderBottom: "1px solid var(--color-border)",
        marginBottom: "2rem",
      }}
    >
      <button
        type="button"
        onClick={() => onTabChange("repairs")}
        style={{
          padding: "0.75rem 1.25rem",
          background: "none",
          border: "none",
          borderBottom:
            activeTab === "repairs"
              ? "3px solid var(--color-primary)"
              : "3px solid transparent",
          fontWeight: activeTab === "repairs" ? 700 : 500,
          color:
            activeTab === "repairs"
              ? "var(--color-primary)"
              : "var(--color-muted)",
          fontSize: "0.95rem",
          cursor: "pointer",
        }}
      >
        My Repairs &amp; Services ({repairsCount})
      </button>

      <button
        type="button"
        onClick={() => onTabChange("orders")}
        style={{
          padding: "0.75rem 1.25rem",
          background: "none",
          border: "none",
          borderBottom:
            activeTab === "orders"
              ? "3px solid var(--color-primary)"
              : "3px solid transparent",
          fontWeight: activeTab === "orders" ? 700 : 500,
          color:
            activeTab === "orders"
              ? "var(--color-primary)"
              : "var(--color-muted)",
          fontSize: "0.95rem",
          cursor: "pointer",
        }}
      >
        My Orders &amp; Delivery ({ordersCount})
      </button>

      {sourcingCount > 0 && (
        <button
          type="button"
          onClick={() => onTabChange("sourcing")}
          style={{
            padding: "0.75rem 1.25rem",
            background: "none",
            border: "none",
            borderBottom:
              activeTab === "sourcing"
                ? "3px solid var(--color-primary)"
                : "3px solid transparent",
            fontWeight: activeTab === "sourcing" ? 700 : 500,
            color:
              activeTab === "sourcing"
                ? "var(--color-primary)"
                : "var(--color-muted)",
            fontSize: "0.95rem",
            cursor: "pointer",
          }}
        >
          Special Inquiries ({sourcingCount})
        </button>
      )}
    </div>
  );
};
