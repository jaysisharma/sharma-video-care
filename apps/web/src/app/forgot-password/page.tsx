"use client";

import React, { useState } from "react";
import Link from "next/link";
import { CheckCircle2 } from "lucide-react";
import { useAuth } from "../../context/AuthContext";
import { useLanguage } from "../../context/LanguageContext";
import { useSnackbar } from "../../context/SnackbarContext";
import { AuthLayout } from "../../components/auth/AuthLayout";

export default function ForgotPasswordPage() {
  const { resetPassword } = useAuth();
  const { t } = useLanguage();
  const snackbar = useSnackbar();

  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);

  const showSent = () => {
    setSent(true);
    snackbar.success(t("auth.forgot.sentToast"));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) {
      snackbar.warning(t("auth.err.invalidEmail"));
      return;
    }

    setLoading(true);
    try {
      await resetPassword(email);
      showSent();
    } catch (err: any) {
      console.error("Password reset error:", err);
      // Never reveal whether an account exists for this email.
      if (err?.code === "auth/user-not-found") showSent();
      else if (err?.code === "auth/invalid-email") snackbar.warning(t("auth.err.invalidEmail"));
      else if (err?.code === "auth/too-many-requests") snackbar.error(t("auth.err.tooMany"));
      else if (err?.code === "auth/network-request-failed") snackbar.error(t("auth.err.network"));
      else snackbar.error(t("auth.err.generic"));
    } finally {
      setLoading(false);
    }
  };

  return (
    <AuthLayout
      title={t("auth.forgot.title")}
      subtitle={sent ? undefined : t("auth.forgot.subtitle")}
      footer={
        sent ? undefined : (
          <>
            {t("auth.forgot.remember")}
            <Link href="/login" className="auth-switch-link">
              {t("auth.register.signIn")}
            </Link>
          </>
        )
      }
    >
      {sent ? (
        <div className="auth-success" role="status">
          <div className="auth-success-icon">
            <CheckCircle2 size={26} />
          </div>
          <h2>{t("auth.forgot.sentTitle")}</h2>
          <p>{t("auth.forgot.sentBody", { email: email.trim() })}</p>
          <Link href="/login" className="auth-btn-primary">
            {t("auth.forgot.backToLogin")}
          </Link>
        </div>
      ) : (
        <form onSubmit={handleSubmit} noValidate>
          <div className="auth-field">
            <div className="auth-label-row">
              <label className="auth-label" htmlFor="reset-email">
                {t("auth.email")}
              </label>
            </div>
            <input
              id="reset-email"
              type="email"
              inputMode="email"
              className="auth-input"
              placeholder="name@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              autoComplete="email"
              required
            />
          </div>

          <button type="submit" className="auth-btn-primary" disabled={loading} style={{ marginTop: "1.4rem" }}>
            {loading && <span className="auth-spinner" aria-hidden="true" />}
            {loading ? t("auth.forgot.submitting") : t("auth.forgot.submit")}
          </button>
        </form>
      )}
    </AuthLayout>
  );
}
