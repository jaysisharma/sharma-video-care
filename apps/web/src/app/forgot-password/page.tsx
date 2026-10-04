"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useAuth } from "../../context/AuthContext";
import { Mail, ArrowLeft, CheckCircle2, AlertCircle, X } from "lucide-react";
import { Logo } from "../../components/Logo";

export default function ForgotPasswordPage() {
  const { resetPassword } = useAuth();

  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    if (!email.trim()) {
      setError("Please enter your account email address.");
      return;
    }

    setLoading(true);
    try {
      await resetPassword(email);
      setSuccess(true);
    } catch (err: any) {
      console.error("Password reset error:", err);
      if (err?.code === "auth/user-not-found") {
        setError("No account found with this email address.");
      } else {
        setError(err?.message || "Failed to send reset link. Please try again.");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-page">
      <div className="auth-card">
        {/* Header */}
        <div className="auth-header">
          <div className="auth-brand-logo">
            <Logo variant="stacked" size={44} showSubtitle={false} />
          </div>
          <h1 className="auth-title">Reset your password</h1>
          <p className="auth-subtitle">
            Enter your account email to receive secure recovery instructions.
          </p>
        </div>

        {error && (
          <div className="auth-alert-error">
            <AlertCircle size={18} style={{ flexShrink: 0, marginTop: "1px" }} />
            <div style={{ flex: 1 }}>{error}</div>
            <button
              type="button"
              onClick={() => setError(null)}
              style={{ background: "none", border: "none", color: "inherit", cursor: "pointer", padding: "2px" }}
              aria-label="Dismiss error"
            >
              <X size={15} />
            </button>
          </div>
        )}

        {success ? (
          <div style={{ textAlign: "center", padding: "0.5rem 0" }}>
            <div
              style={{
                width: "48px",
                height: "48px",
                borderRadius: "50%",
                backgroundColor: "#dcfce7",
                color: "#16a34a",
                display: "inline-flex",
                alignItems: "center",
                justifyContent: "center",
                marginBottom: "1rem",
              }}
            >
              <CheckCircle2 size={24} />
            </div>
            <h2 style={{ fontSize: "1.15rem", fontWeight: 700, color: "#0f172a", marginBottom: "0.35rem" }}>
              Check your inbox
            </h2>
            <p style={{ color: "#64748b", fontSize: "0.88rem", lineHeight: 1.5, marginBottom: "1.5rem" }}>
              We have dispatched password recovery instructions to <strong>{email}</strong>.
            </p>
            <Link href="/login" className="auth-btn-primary" style={{ textDecoration: "none" }}>
              Return to Sign In
            </Link>
          </div>
        ) : (
          <form onSubmit={handleSubmit} noValidate>
            <div className="auth-field">
              <div className="auth-label-row">
                <label className="auth-label" htmlFor="reset-email">
                  Email Address
                </label>
              </div>
              <div className="auth-input-wrapper">
                <input
                  id="reset-email"
                  type="email"
                  className="auth-input"
                  placeholder="name@example.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  autoComplete="email"
                  required
                />
                <Mail size={16} className="auth-input-icon" />
              </div>
            </div>

            <button
              type="submit"
              className="auth-btn-primary"
              style={{ marginTop: "1rem" }}
              disabled={loading}
            >
              {loading ? "Sending link..." : "Send Reset Link"}
            </button>

            <div className="auth-switch-prompt">
              Remember your password?
              <Link href="/login" className="auth-switch-link">
                Sign in
              </Link>
            </div>
          </form>
        )}
      </div>

      <div className="auth-bottom-nav">
        <Link href="/" className="auth-back-link">
          <ArrowLeft size={15} />
          <span>Back to Sharma Video Care Store</span>
        </Link>
      </div>
    </div>
  );
}
