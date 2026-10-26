"use client";

import React, { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from "react";
import { CheckCircle2, AlertCircle, AlertTriangle, Info, X } from "lucide-react";

export type SnackType = "success" | "error" | "warning" | "info";

interface SnackOptions {
  type?: SnackType;
  duration?: number;
  actionLabel?: string;
  onAction?: () => void;
}

interface Snack extends Required<Pick<SnackOptions, "type" | "duration">> {
  id: number;
  message: string;
  actionLabel?: string;
  onAction?: () => void;
}

interface SnackbarContextType {
  showSnackbar: (message: string, options?: SnackOptions | SnackType) => void;
  success: (message: string) => void;
  error: (message: string) => void;
  warning: (message: string) => void;
  info: (message: string) => void;
}

const noop = () => {};
const SnackbarContext = createContext<SnackbarContextType>({
  showSnackbar: noop,
  success: noop,
  error: noop,
  warning: noop,
  info: noop,
});

const MAX_VISIBLE = 3;
const ICONS = { success: CheckCircle2, error: AlertCircle, warning: AlertTriangle, info: Info };

/** The single way the web app shows transient status messages. */
export const SnackbarProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [snacks, setSnacks] = useState<Snack[]>([]);
  const nextId = useRef(1);

  const dismiss = useCallback((id: number) => {
    setSnacks((list) => list.filter((s) => s.id !== id));
  }, []);

  const showSnackbar = useCallback((message: string, options?: SnackOptions | SnackType) => {
    const opts = typeof options === "string" ? { type: options } : options || {};
    const type = opts.type || "info";
    const snack: Snack = {
      id: nextId.current++,
      message,
      type,
      duration: opts.duration ?? (type === "error" ? 6000 : 3500),
      actionLabel: opts.actionLabel,
      onAction: opts.onAction,
    };
    setSnacks((list) => [...list.filter((s) => s.message !== message), snack].slice(-MAX_VISIBLE));
  }, []);

  const value = useMemo<SnackbarContextType>(
    () => ({
      showSnackbar,
      success: (m) => showSnackbar(m, "success"),
      error: (m) => showSnackbar(m, "error"),
      warning: (m) => showSnackbar(m, "warning"),
      info: (m) => showSnackbar(m, "info"),
    }),
    [showSnackbar]
  );

  return (
    <SnackbarContext.Provider value={value}>
      {children}
      <div className="svc-snackbar-region" aria-live="polite">
        {snacks.map((s) => (
          <SnackbarItem key={s.id} snack={s} onDismiss={dismiss} />
        ))}
      </div>
    </SnackbarContext.Provider>
  );
};

function SnackbarItem({ snack, onDismiss }: { snack: Snack; onDismiss: (id: number) => void }) {
  const [paused, setPaused] = useState(false);
  const Icon = ICONS[snack.type];

  useEffect(() => {
    if (paused) return;
    const timer = setTimeout(() => onDismiss(snack.id), snack.duration);
    return () => clearTimeout(timer);
  }, [paused, snack.id, snack.duration, onDismiss]);

  return (
    <div
      className={`svc-snackbar svc-snackbar-${snack.type}`}
      role={snack.type === "error" ? "alert" : "status"}
      onMouseEnter={() => setPaused(true)}
      onMouseLeave={() => setPaused(false)}
      onFocus={() => setPaused(true)}
      onBlur={() => setPaused(false)}
    >
      <Icon size={18} className="svc-snackbar-icon" aria-hidden="true" />
      <div className="svc-snackbar-message">{snack.message}</div>
      {snack.actionLabel && snack.onAction && (
        <button
          type="button"
          className="svc-snackbar-action"
          onClick={() => {
            snack.onAction?.();
            onDismiss(snack.id);
          }}
        >
          {snack.actionLabel}
        </button>
      )}
      <button type="button" className="svc-snackbar-close" onClick={() => onDismiss(snack.id)} aria-label="Dismiss">
        <X size={15} />
      </button>
    </div>
  );
}

export const useSnackbar = () => useContext(SnackbarContext);
