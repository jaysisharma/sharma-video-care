"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuth } from "../../context/AuthContext";
import {
  User,
  Mail,
  Phone,
  Lock,
  AlertCircle,
  ArrowLeft,
  Eye,
  EyeOff,
  X,
} from "lucide-react";
import { Logo } from "../../components/Logo";

export default function RegisterPage() {
  const router = useRouter();
  const { signUp } = useAuth();

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("+977 ");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [agreeTerms, setAgreeTerms] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!name.trim()) {
      setError("Please enter your full name.");
      return;
    }
    if (!email.trim()) {
      setError("Please enter a valid email address.");
      return;
    }
    if (!phone.trim() || phone.trim() === "+977") {
      setError("Please enter a valid Nepal mobile contact number.");
      return;
    }
    if (password.length < 6) {
      setError("Password must be at least 6 characters long.");
      return;
    }
    if (password !== confirmPassword) {
      setError("Passwords do not match. Please verify your password confirmation.");
      return;
    }
    if (!agreeTerms) {
      setError("You must agree to the Terms of Service to create an account.");
      return;
    }

    setLoading(true);
    try {
      await signUp(name, email, phone, password);
      router.push("/account");
    } catch (err: any) {
      console.error("Registration error:", err);
      if (err?.code === "auth/email-already-in-use") {
        setError("An account with this email address already exists. Please sign in instead.");
      } else if (err?.code === "auth/weak-password") {
        setError("Password is too weak. Please use letters and numbers.");
      } else {
        setError(err?.message || "Failed to create account. Please try again.");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-page">
      <div className="auth-card" style={{ maxWidth: "480px" }}>
        {/* Header */}
        <div className="auth-header">
          <div className="auth-brand-logo">
            <Logo variant="stacked" size={44} showSubtitle={false} />
          </div>
          <h1 className="auth-title">Create your account</h1>
          <p className="auth-subtitle">
            Sign up to track repairs, approve quotations, and shop electronics.
          </p>
        </div>

        {/* Error notification */}
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

        <form onSubmit={handleSubmit} noValidate>
          <div className="auth-field">
            <div className="auth-label-row">
              <label className="auth-label" htmlFor="reg-name">
                Full Name
              </label>
            </div>
            <div className="auth-input-wrapper">
              <input
                id="reg-name"
                type="text"
                className="auth-input"
                placeholder="e.g. Ramesh Sah"
                value={name}
                onChange={(e) => setName(e.target.value)}
                autoComplete="name"
                required
              />
              <User size={16} className="auth-input-icon" />
            </div>
          </div>

          <div className="auth-field">
            <div className="auth-label-row">
              <label className="auth-label" htmlFor="reg-email">
                Email Address
              </label>
            </div>
            <div className="auth-input-wrapper">
              <input
                id="reg-email"
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

          <div className="auth-field">
            <div className="auth-label-row">
              <label className="auth-label" htmlFor="reg-phone">
                Mobile Number (Nepal)
              </label>
            </div>
            <div className="auth-input-wrapper">
              <input
                id="reg-phone"
                type="tel"
                className="auth-input"
                placeholder="+977-9801234567"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                autoComplete="tel"
                required
              />
              <Phone size={16} className="auth-input-icon" />
            </div>
            <span style={{ fontSize: "0.75rem", color: "#64748b", marginTop: "3px", display: "block" }}>
              Used for repair telemetry SMS updates and technician arrival in Janakpur.
            </span>
          </div>

          <div className="auth-field">
            <div className="auth-label-row">
              <label className="auth-label" htmlFor="reg-password">
                Password
              </label>
            </div>
            <div className="auth-input-wrapper">
              <input
                id="reg-password"
                type={showPassword ? "text" : "password"}
                className="auth-input"
                placeholder="At least 6 characters"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="new-password"
                required
              />
              <Lock size={16} className="auth-input-icon" />
              <button
                type="button"
                className="auth-eye-btn"
                onClick={() => setShowPassword(!showPassword)}
                aria-label={showPassword ? "Hide password" : "Show password"}
              >
                {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>
          </div>

          <div className="auth-field">
            <div className="auth-label-row">
              <label className="auth-label" htmlFor="reg-confirm">
                Confirm Password
              </label>
            </div>
            <div className="auth-input-wrapper">
              <input
                id="reg-confirm"
                type={showPassword ? "text" : "password"}
                className="auth-input"
                placeholder="Repeat your password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                autoComplete="new-password"
                required
              />
              <Lock size={16} className="auth-input-icon" />
            </div>
          </div>

          <div className="auth-checkbox-row" style={{ alignItems: "flex-start", marginTop: "1rem" }}>
            <label className="auth-checkbox-label" style={{ alignItems: "flex-start" }}>
              <input
                type="checkbox"
                checked={agreeTerms}
                onChange={(e) => setAgreeTerms(e.target.checked)}
                style={{ marginTop: "3px" }}
              />
              <span style={{ fontSize: "0.82rem", lineHeight: 1.45 }}>
                I agree to Sharma Video Care&apos;s{" "}
                <Link href="/terms" target="_blank" style={{ color: "var(--color-primary)", textDecoration: "underline" }}>
                  Terms of Service
                </Link>{" "}
                and{" "}
                <Link href="/privacy" target="_blank" style={{ color: "var(--color-primary)", textDecoration: "underline" }}>
                  Privacy Policy
                </Link>
                .
              </span>
            </label>
          </div>

          <button
            type="submit"
            className="auth-btn-primary"
            style={{ marginTop: "1.25rem" }}
            disabled={loading}
          >
            {loading ? "Creating account..." : "Create Account"}
          </button>
        </form>

        <div className="auth-switch-prompt">
          Already have an account?
          <Link href="/login" className="auth-switch-link">
            Sign in
          </Link>
        </div>
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
