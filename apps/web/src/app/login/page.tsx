"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { useAuth, DEMO_PERSONAS, DemoPersona } from "../../context/AuthContext";
import {
  Lock,
  Mail,
  AlertCircle,
  ArrowRight,
  ArrowLeft,
  Eye,
  EyeOff,
  ChevronDown,
  ChevronUp,
  X,
} from "lucide-react";
import { Logo } from "../../components/Logo";

function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const redirectParam = searchParams.get("redirect");

  const { signIn } = useAuth();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [capsLockActive, setCapsLockActive] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showDevShortcuts, setShowDevShortcuts] = useState(false);

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.getModifierState) {
      setCapsLockActive(e.getModifierState("CapsLock"));
    }
  };

  const handleKeyUp = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.getModifierState) {
      setCapsLockActive(e.getModifierState("CapsLock"));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    const cleanEmail = email.trim();
    if (!cleanEmail || !password) {
      setError("Please enter your email and password.");
      return;
    }

    setLoading(true);
    try {
      await signIn(cleanEmail, password);

      // Intelligent Auto-Routing based on role
      if (redirectParam) {
        router.push(redirectParam);
      } else {
        const matchedPersona = DEMO_PERSONAS.find(
          (p) => p.email.toLowerCase() === cleanEmail.toLowerCase()
        );
        if (matchedPersona?.role === "admin") {
          router.push("/admin");
        } else if (matchedPersona?.role === "technician") {
          router.push("/technician");
        } else {
          router.push("/account");
        }
      }
    } catch (err: any) {
      console.error("Sign in error:", err);
      if (
        err?.code === "auth/invalid-credential" ||
        err?.code === "auth/wrong-password" ||
        err?.code === "auth/user-not-found"
      ) {
        setError("Invalid email address or password. Please verify your credentials.");
      } else if (err?.code === "auth/too-many-requests") {
        setError("Account temporarily locked due to multiple failed attempts. Please reset your password or try again later.");
      } else {
        setError(err?.message || "Failed to sign in. Please verify your connection.");
      }
    } finally {
      setLoading(false);
    }
  };

  const handleAutofillPersona = (persona: DemoPersona) => {
    setError(null);
    setEmail(persona.email);
    setPassword(persona.defaultPassword || "Customer123!");
  };

  return (
    <div className="auth-page">
      <div className="auth-card">
        {/* Header */}
        <div className="auth-header">
          <div className="auth-brand-logo">
            <Logo variant="stacked" size={44} showSubtitle={false} />
          </div>
          <h1 className="auth-title">Sign in to your account</h1>
          <p className="auth-subtitle">
            Manage your repair tickets, quotations, and equipment orders.
          </p>
        </div>

        {/* Google One-Click Button */}
        <button
          type="button"
          className="auth-google-btn"
          onClick={() => {
            setError("Google sign-in is disabled in this environment. Please enter your credentials below.");
          }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24">
            <path
              fill="#4285F4"
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
            />
            <path
              fill="#34A853"
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
            />
            <path
              fill="#FBBC05"
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
            />
            <path
              fill="#EA4335"
              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
            />
          </svg>
          <span>Continue with Google</span>
        </button>

        {/* Divider */}
        <div className="auth-divider">
          <span>or sign in with credentials</span>
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

        {/* Login Form */}
        <form onSubmit={handleSubmit} noValidate>
          <div className="auth-field">
            <div className="auth-label-row">
              <label className="auth-label" htmlFor="auth-email">
                Email Address
              </label>
            </div>
            <div className="auth-input-wrapper">
              <input
                id="auth-email"
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
              <label className="auth-label" htmlFor="auth-password">
                Password
              </label>
              <Link href="/forgot-password" className="auth-forgot-link">
                Forgot password?
              </Link>
            </div>
            <div className="auth-input-wrapper">
              <input
                id="auth-password"
                type={showPassword ? "text" : "password"}
                className="auth-input"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                onKeyDown={handleKeyDown}
                onKeyUp={handleKeyUp}
                autoComplete="current-password"
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

            {capsLockActive && (
              <div className="auth-caps-warning">
                <AlertCircle size={13} />
                <span>Caps Lock is ON</span>
              </div>
            )}
          </div>

          {/* Remember me */}
          <div className="auth-checkbox-row">
            <label className="auth-checkbox-label">
              <input
                type="checkbox"
                checked={rememberMe}
                onChange={(e) => setRememberMe(e.target.checked)}
              />
              <span>Remember this device</span>
            </label>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            className="auth-btn-primary"
            disabled={loading}
          >
            {loading ? "Signing in..." : "Sign In"}
          </button>
        </form>

        {/* Create Account link */}
        <div className="auth-switch-prompt">
          Don&apos;t have an account yet?
          <Link href="/register" className="auth-switch-link">
            Create an account
          </Link>
        </div>
      </div>

      {/* Back to store navigation */}
      <div className="auth-bottom-nav">
        <Link href="/" className="auth-back-link">
          <ArrowLeft size={15} />
          <span>Back to Sharma Video Care Store</span>
        </Link>
      </div>

      {/* Discreet Developer Helper (Hidden by default, zero clutter) */}
      <div className="auth-dev-section">
        <button
          type="button"
          className="auth-dev-toggle-btn"
          onClick={() => setShowDevShortcuts(!showDevShortcuts)}
        >
          {showDevShortcuts ? "Hide test credentials" : "Quick test accounts"}
        </button>

        {showDevShortcuts && (
          <div className="auth-dev-panel">
            <div className="auth-dev-header">Click to fill account:</div>
            <div className="auth-dev-chips">
              {DEMO_PERSONAS.map((p) => (
                <button
                  key={p.id}
                  type="button"
                  className="auth-dev-chip"
                  onClick={() => handleAutofillPersona(p)}
                >
                  {p.name.split(" ")[0]} ({p.role === "technician" ? `${p.technicianType?.toLowerCase()} tech` : p.role})
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default function LoginPage() {
  return (
    <React.Suspense
      fallback={
        <div className="auth-page">
          <div style={{ color: "#64748b", fontSize: "0.9rem" }}>Loading sign in...</div>
        </div>
      }
    >
      <LoginForm />
    </React.Suspense>
  );
}
