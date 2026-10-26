"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "../../context/AuthContext";
import { useSnackbar } from "../../context/SnackbarContext";

export function AccountSecurity() {
  const router = useRouter();
  const { firebaseUser, resendVerificationEmail, deleteAccount } = useAuth();
  const [verifySent, setVerifySent] = useState(false);
  const [showDelete, setShowDelete] = useState(false);
  const [password, setPassword] = useState("");
  const [deleting, setDeleting] = useState(false);
  const snackbar = useSnackbar();

  if (!firebaseUser) return null;

  const handleResend = async () => {
    try {
      await resendVerificationEmail();
      setVerifySent(true);
      snackbar.success(`Verification email sent to ${firebaseUser.email}.`);
    } catch {
      snackbar.error("Could not send the verification email. Please try again later.");
    }
  };

  const handleDelete = async (e: React.FormEvent) => {
    e.preventDefault();
    setDeleting(true);
    try {
      await deleteAccount(password);
      snackbar.success("Your account has been deleted.");
      router.replace("/");
    } catch (err: any) {
      snackbar.error(
        err?.code === "auth/invalid-credential" || err?.code === "auth/wrong-password"
          ? "Incorrect password."
          : "Could not delete your account. Please try again."
      );
    } finally {
      setDeleting(false);
    }
  };

  return (
    <div style={{ marginBottom: "1.5rem" }}>
      {!firebaseUser.emailVerified && (
        <div
          className="card"
          style={{ padding: "0.9rem 1.1rem", marginBottom: "1rem", background: "#FFF7E6", borderColor: "#F5C26B" }}
        >
          <strong>Please verify your email.</strong>{" "}
          {verifySent ? (
            <span>Verification email sent to {firebaseUser.email}.</span>
          ) : (
            <button type="button" className="btn btn-secondary btn-sm" onClick={handleResend} style={{ marginLeft: "0.5rem" }}>
              Resend verification email
            </button>
          )}
        </div>
      )}


      {!showDelete ? (
        <button
          type="button"
          onClick={() => setShowDelete(true)}
          style={{ background: "none", border: "none", color: "#b91c1c", cursor: "pointer", padding: 0, fontSize: "0.85rem" }}
        >
          Delete my account
        </button>
      ) : (
        <form onSubmit={handleDelete} className="card" style={{ padding: "1rem 1.1rem", maxWidth: 440 }}>
          <p style={{ fontSize: "0.88rem", marginBottom: "0.75rem" }}>
            This permanently deletes your login and profile. Order and repair records are kept for warranty and
            accounting. Enter your password to confirm.
          </p>
          <input
            type="password"
            className="auth-input"
            placeholder="Current password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            autoComplete="current-password"
            required
            style={{ marginBottom: "0.75rem", width: "100%" }}
          />
          <div style={{ display: "flex", gap: "0.5rem" }}>
            <button type="submit" className="btn btn-sm" disabled={deleting || !password} style={{ background: "#b91c1c", color: "#fff" }}>
              {deleting ? "Deleting..." : "Permanently delete"}
            </button>
            <button type="button" className="btn btn-secondary btn-sm" onClick={() => setShowDelete(false)}>
              Cancel
            </button>
          </div>
        </form>
      )}
    </div>
  );
}
