"use client";

import React, { useEffect } from "react";
import { usePathname, useRouter } from "next/navigation";
import { UserRole } from "@sharmavideocare/shared";
import { useAuth } from "../context/AuthContext";

/**
 * Client-side route guard. This only controls what UI renders; the real
 * enforcement is firestore.rules, which every read/write still goes through.
 */
export function RequireRole({ roles, children }: { roles?: UserRole[]; children: React.ReactNode }) {
  const { user, role, isLoading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (!isLoading && !user) {
      router.replace(`/login?redirect=${encodeURIComponent(pathname || "/")}`);
    }
  }, [isLoading, user, pathname, router]);

  if (isLoading || !user) {
    return <div style={{ padding: "4rem 1.25rem", textAlign: "center", color: "#64748b" }}>Checking access...</div>;
  }

  if (roles && !roles.includes(role)) {
    return (
      <div style={{ padding: "5rem 1.25rem", maxWidth: 520, margin: "0 auto", textAlign: "center" }}>
        <h2 style={{ fontSize: "1.4rem", fontWeight: 800, marginBottom: "0.5rem" }}>Access restricted</h2>
        <p style={{ color: "#64748b", fontSize: "0.92rem", lineHeight: 1.5, marginBottom: "1.5rem" }}>
          Your account ({user.email}) does not have permission to view this page.
        </p>
        <a href="/" className="btn btn-primary btn-sm">Back to store</a>
      </div>
    );
  }

  return <>{children}</>;
}
