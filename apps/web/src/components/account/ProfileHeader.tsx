"use client";

import React from "react";
import Link from "next/link";
import { Wrench, MessageSquare } from "lucide-react";

interface ProfileHeaderProps {
  user: {
    id: string;
    name: string;
    email: string;
    phone?: string;
  } | null;
  role: string;
  firebaseUser: any;
  signOut: () => void | Promise<void>;
}

export const ProfileHeader: React.FC<ProfileHeaderProps> = ({
  user,
  role,
  firebaseUser,
  signOut,
}) => {
  return (
    <div
      className="card"
      style={{
        padding: "1.75rem",
        marginBottom: "2rem",
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        flexWrap: "wrap",
        gap: "1rem",
      }}
    >
      <div style={{ display: "flex", alignItems: "center", gap: "1rem" }}>
        <div
          style={{
            width: "56px",
            height: "56px",
            borderRadius: "50%",
            background: "var(--color-primary)",
            color: "#fff",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: "1.4rem",
            fontWeight: 700,
          }}
        >
          {user ? user.name[0] : "C"}
        </div>
        <div>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: "0.5rem",
              marginBottom: "0.2rem",
            }}
          >
            <h2
              style={{
                fontSize: "1.4rem",
                fontWeight: 800,
                color: "var(--color-ink)",
                margin: 0,
              }}
            >
              {user ? user.name : "Customer Account"}
            </h2>
            <span
              className="badge badge-muted"
              style={{
                textTransform: "uppercase",
                fontSize: "0.7rem",
                padding: "0.2rem 0.4rem",
              }}
            >
              {role}
            </span>
          </div>
          <div style={{ fontSize: "0.88rem", color: "var(--color-muted)" }}>
            {user?.email} • {user?.phone || "+977-9801234567"} • Janakpur, Nepal
          </div>
        </div>
      </div>

      <div style={{ display: "flex", gap: "0.75rem", alignItems: "center" }}>
        <Link href="/chat" className="btn btn-secondary btn-sm">
          <MessageSquare size={16} /> Support Chat
        </Link>
        <Link href="/services" className="btn btn-primary btn-sm">
          <Wrench size={16} /> New Service
        </Link>
        {firebaseUser && (
          <button
            type="button"
            onClick={() => signOut()}
            className="btn btn-secondary btn-sm"
            title="Sign Out"
          >
            Sign Out
          </button>
        )}
      </div>
    </div>
  );
};
