"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { useAuth, safeRedirectPath, homePathForRole } from "../../context/AuthContext";
import { useLanguage } from "../../context/LanguageContext";
import { useSnackbar } from "../../context/SnackbarContext";
import { AuthLayout, PasswordField } from "../../components/auth/AuthLayout";

const SIGN_IN_ERRORS: Record<string, string> = {
  "auth/invalid-credential": "auth.err.invalidCredentials",
  "auth/invalid-login-credentials": "auth.err.invalidCredentials",
  "auth/wrong-password": "auth.err.invalidCredentials",
  "auth/user-not-found": "auth.err.invalidCredentials",
  "auth/invalid-email": "auth.err.invalidEmail",
  "auth/user-disabled": "auth.err.disabled",
  "auth/too-many-requests": "auth.err.tooMany",
  "auth/network-request-failed": "auth.err.network",
};

function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const redirectParam = safeRedirectPath(searchParams.get("redirect"));

  const { signIn } = useAuth();
  const { t } = useLanguage();
  const snackbar = useSnackbar();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [rememberMe, setRememberMe] = useState(true);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const cleanEmail = email.trim();
    if (!cleanEmail || !password) {
      snackbar.warning(t("auth.err.required"));
      return;
    }

    setLoading(true);
    try {
      const profile = await signIn(cleanEmail, password, rememberMe);
      const firstName = profile?.name?.split(" ")[0];
      snackbar.success(firstName ? t("auth.login.success", { name: firstName }) : t("auth.login.title"));
      router.replace(redirectParam || homePathForRole(profile?.role));
    } catch (err: any) {
      console.error("Sign in error:", err);
      snackbar.error(t(SIGN_IN_ERRORS[err?.code] || "auth.err.generic"));
    } finally {
      setLoading(false);
    }
  };

  return (
    <AuthLayout
      title={t("auth.login.title")}
      subtitle={t("auth.login.subtitle")}
      footer={
        <>
          {t("auth.login.noAccount")}
          <Link
            href={redirectParam ? `/register?redirect=${encodeURIComponent(redirectParam)}` : "/register"}
            className="auth-switch-link"
          >
            {t("auth.login.createAccount")}
          </Link>
        </>
      }
    >
      <form onSubmit={handleSubmit} noValidate>
        <div className="auth-field">
          <div className="auth-label-row">
            <label className="auth-label" htmlFor="auth-email">
              {t("auth.email")}
            </label>
          </div>
          <input
            id="auth-email"
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

        <PasswordField
          id="auth-password"
          label={t("auth.password")}
          value={password}
          onChange={setPassword}
          autoComplete="current-password"
          labelAside={
            <Link href="/forgot-password" className="auth-forgot-link">
              {t("auth.login.forgot")}
            </Link>
          }
        />

        <div className="auth-checkbox-row">
          <label className="auth-checkbox-label">
            <input type="checkbox" checked={rememberMe} onChange={(e) => setRememberMe(e.target.checked)} />
            <span>{t("auth.login.remember")}</span>
          </label>
        </div>

        <button type="submit" className="auth-btn-primary" disabled={loading}>
          {loading && <span className="auth-spinner" aria-hidden="true" />}
          {loading ? t("auth.login.submitting") : t("auth.login.submit")}
        </button>
      </form>

      <p className="auth-guest-note">
        {t("auth.guestNote")}{" "}
        <Link href={redirectParam || "/"} className="auth-inline-link">
          {t("auth.continueGuest")} →
        </Link>
      </p>
    </AuthLayout>
  );
}

export default function LoginPage() {
  return (
    <React.Suspense fallback={<div className="auth-page" />}>
      <LoginForm />
    </React.Suspense>
  );
}
