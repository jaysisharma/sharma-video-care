"use client";

import React from "react";
import Link from "next/link";
import { ArrowLeft, Check, Eye, EyeOff } from "lucide-react";
import { Logo } from "../Logo";
import { useLanguage } from "../../context/LanguageContext";

interface AuthLayoutProps {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
  footer?: React.ReactNode;
}

/** Shared shell for login / register / forgot-password: brand panel + form card. */
export function AuthLayout({ title, subtitle, children, footer }: AuthLayoutProps) {
  const { t } = useLanguage();

  return (
    <div className="auth-page">
      <aside className="auth-brand-panel" aria-hidden="true">
        <Logo variant="full" size={40} inverted />
        <div>
          <p className="auth-brand-tagline">{t("auth.brandTagline")}</p>
          <ul className="auth-brand-points">
            {["auth.brandPoint1", "auth.brandPoint2", "auth.brandPoint3"].map((key) => (
              <li key={key}>
                <span className="auth-brand-check">
                  <Check size={14} strokeWidth={3} />
                </span>
                {t(key)}
              </li>
            ))}
          </ul>
        </div>
        <p className="auth-brand-address">Station Road, Janakpurdham · +977-9801234567</p>
      </aside>

      <div className="auth-main">
        <div className="auth-topbar">
          <Link href="/" className="auth-back-link">
            <ArrowLeft size={15} />
            <span>{t("auth.back")}</span>
          </Link>
          <LanguageToggle />
        </div>

        <div className="auth-card">
          <div className="auth-header">
            <div className="auth-mobile-logo">
              <Logo variant="stacked" size={44} showSubtitle={false} />
            </div>
            <h1 className="auth-title">{title}</h1>
            {subtitle && <p className="auth-subtitle">{subtitle}</p>}
          </div>
          {children}
          {footer && <div className="auth-switch-prompt">{footer}</div>}
        </div>
      </div>
    </div>
  );
}

function LanguageToggle() {
  const { language, setLanguage } = useLanguage();
  return (
    <div className="auth-lang-toggle" role="group" aria-label="Language">
      <button type="button" aria-pressed={language === "en"} onClick={() => setLanguage("en")}>
        EN
      </button>
      <button type="button" aria-pressed={language === "ne"} onClick={() => setLanguage("ne")} lang="ne">
        नेपाली
      </button>
    </div>
  );
}

/** Password input with show/hide toggle and caps-lock hint. */
export function PasswordField({
  id,
  label,
  value,
  onChange,
  autoComplete,
  placeholder,
  labelAside,
}: {
  id: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
  autoComplete: "current-password" | "new-password";
  placeholder?: string;
  labelAside?: React.ReactNode;
}) {
  const { t } = useLanguage();
  const [visible, setVisible] = React.useState(false);
  const [capsLock, setCapsLock] = React.useState(false);
  const trackCaps = (e: React.KeyboardEvent<HTMLInputElement>) => setCapsLock(e.getModifierState?.("CapsLock") ?? false);

  return (
    <div className="auth-field">
      <div className="auth-label-row">
        <label className="auth-label" htmlFor={id}>
          {label}
        </label>
        {labelAside}
      </div>
      <div className="auth-input-wrapper">
        <input
          id={id}
          type={visible ? "text" : "password"}
          className="auth-input auth-input-with-action"
          placeholder={placeholder}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          onKeyDown={trackCaps}
          onKeyUp={trackCaps}
          autoComplete={autoComplete}
          required
        />
        <button
          type="button"
          className="auth-eye-btn"
          onClick={() => setVisible((v) => !v)}
          aria-label={visible ? t("auth.hidePassword") : t("auth.showPassword")}
        >
          {visible ? <EyeOff size={17} /> : <Eye size={17} />}
        </button>
      </div>
      {capsLock && <p className="auth-hint auth-hint-warning">{t("auth.capsLock")}</p>}
    </div>
  );
}
