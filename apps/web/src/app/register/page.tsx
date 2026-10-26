"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { useAuth, safeRedirectPath } from "../../context/AuthContext";
import { useLanguage } from "../../context/LanguageContext";
import { useSnackbar } from "../../context/SnackbarContext";
import { AuthLayout, PasswordField } from "../../components/auth/AuthLayout";

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const NEPAL_MOBILE_PATTERN = /^(\+?977)?9[678]\d{8}$/;

const SIGN_UP_ERRORS: Record<string, string> = {
  "auth/email-already-in-use": "auth.err.emailInUse",
  "auth/weak-password": "auth.err.weakPassword",
  "auth/password-does-not-meet-requirements": "auth.err.weakPassword",
  "auth/invalid-email": "auth.err.invalidEmail",
  "auth/network-request-failed": "auth.err.network",
  "auth/too-many-requests": "auth.err.tooMany",
};

function RegisterForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const redirectParam = safeRedirectPath(searchParams.get("redirect"));

  const { signUp } = useAuth();
  const { t } = useLanguage();
  const snackbar = useSnackbar();

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [agreeTerms, setAgreeTerms] = useState(false);
  const [loading, setLoading] = useState(false);

  const validationError = (): string | null => {
    if (!name.trim()) return "auth.err.name";
    if (!EMAIL_PATTERN.test(email.trim())) return "auth.err.invalidEmail";
    if (!NEPAL_MOBILE_PATTERN.test(phone.replace(/[\s-]/g, ""))) return "auth.err.phone";
    if (password.length < 8 || !/[A-Za-z]/.test(password) || !/\d/.test(password)) return "auth.err.weakPassword";
    if (password !== confirmPassword) return "auth.err.mismatch";
    if (!agreeTerms) return "auth.err.terms";
    return null;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const invalid = validationError();
    if (invalid) {
      snackbar.warning(t(invalid));
      return;
    }

    setLoading(true);
    try {
      await signUp(name, email, phone, password);
      snackbar.success(t("auth.register.success", { email: email.trim() }));
      router.replace(redirectParam || "/account");
    } catch (err: any) {
      console.error("Registration error:", err);
      snackbar.error(t(SIGN_UP_ERRORS[err?.code] || "auth.err.generic"));
    } finally {
      setLoading(false);
    }
  };

  return (
    <AuthLayout
      title={t("auth.register.title")}
      subtitle={t("auth.register.subtitle")}
      footer={
        <>
          {t("auth.register.haveAccount")}
          <Link
            href={redirectParam ? `/login?redirect=${encodeURIComponent(redirectParam)}` : "/login"}
            className="auth-switch-link"
          >
            {t("auth.register.signIn")}
          </Link>
        </>
      }
    >
      <form onSubmit={handleSubmit} noValidate>
        <div className="auth-field">
          <div className="auth-label-row">
            <label className="auth-label" htmlFor="reg-name">
              {t("auth.register.name")}
            </label>
          </div>
          <input
            id="reg-name"
            type="text"
            className="auth-input"
            placeholder={t("auth.register.namePlaceholder")}
            value={name}
            onChange={(e) => setName(e.target.value)}
            autoComplete="name"
            required
          />
        </div>

        <div className="auth-field">
          <div className="auth-label-row">
            <label className="auth-label" htmlFor="reg-phone">
              {t("auth.register.phone")}
            </label>
          </div>
          <input
            id="reg-phone"
            type="tel"
            inputMode="tel"
            className="auth-input"
            placeholder="98XXXXXXXX"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            autoComplete="tel"
            aria-describedby="reg-phone-hint"
            required
          />
          <p id="reg-phone-hint" className="auth-hint">
            {t("auth.register.phoneHint")}
          </p>
        </div>

        <div className="auth-field">
          <div className="auth-label-row">
            <label className="auth-label" htmlFor="reg-email">
              {t("auth.email")}
            </label>
          </div>
          <input
            id="reg-email"
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
          id="reg-password"
          label={t("auth.password")}
          value={password}
          onChange={setPassword}
          autoComplete="new-password"
          placeholder={t("auth.register.passwordPlaceholder")}
        />

        <PasswordField
          id="reg-confirm"
          label={t("auth.register.confirm")}
          value={confirmPassword}
          onChange={setConfirmPassword}
          autoComplete="new-password"
          placeholder={t("auth.register.confirmPlaceholder")}
        />

        <div className="auth-checkbox-row">
          <label className="auth-checkbox-label">
            <input type="checkbox" checked={agreeTerms} onChange={(e) => setAgreeTerms(e.target.checked)} />
            <span>
              {t("auth.register.agreePrefix")}{" "}
              <Link href="/terms" target="_blank" className="auth-inline-link">
                {t("auth.register.terms")}
              </Link>{" "}
              {t("auth.register.and")}{" "}
              <Link href="/privacy" target="_blank" className="auth-inline-link">
                {t("auth.register.privacy")}
              </Link>
              {t("auth.register.agreeSuffix")}
            </span>
          </label>
        </div>

        <button type="submit" className="auth-btn-primary" disabled={loading}>
          {loading && <span className="auth-spinner" aria-hidden="true" />}
          {loading ? t("auth.register.submitting") : t("auth.register.submit")}
        </button>
      </form>
    </AuthLayout>
  );
}

export default function RegisterPage() {
  return (
    <React.Suspense fallback={<div className="auth-page" />}>
      <RegisterForm />
    </React.Suspense>
  );
}
