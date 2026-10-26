"use client";

import React, { useState, useRef } from "react";
import { UploadCloud, X, CheckCircle, Loader2 } from "lucide-react";
import { uploadToCloudinary, getOptimizedCloudinaryUrl } from "@/lib/cloudinary";

export interface CloudinaryUploadProps {
  value?: string;
  onChange?: (url: string) => void;
  onRemove?: () => void;
  folder?: string;
  label?: string;
  helperText?: string;
  accept?: string;
  disabled?: boolean;
}

export function CloudinaryUpload({
  value,
  onChange,
  onRemove,
  folder = "video_care",
  label = "Upload Image",
  helperText = "PNG, JPG, WEBP up to 10MB",
  accept = "image/*",
  disabled = false,
}: CloudinaryUploadProps) {
  const [isUploading, setIsUploading] = useState(false);
  const [dragOver, setDragOver] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFile = async (file: File) => {
    if (!file) return;

    if (!file.type.startsWith("image/")) {
      setErrorMessage("Please select an image file (PNG, JPG, WEBP).");
      return;
    }

    if (file.size > 10 * 1024 * 1024) {
      setErrorMessage("Image exceeds 10MB limit.");
      return;
    }

    setErrorMessage(null);
    setIsUploading(true);

    try {
      const secureUrl = await uploadToCloudinary(file, folder);
      onChange?.(secureUrl);
    } catch (err: any) {
      console.error("Cloudinary upload failed:", err);
      setErrorMessage(err.message || "Upload failed. Please try again.");
    } finally {
      setIsUploading(false);
      if (fileInputRef.current) {
        fileInputRef.current.value = "";
      }
    }
  };

  const handleDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setDragOver(false);
    if (disabled || isUploading) return;

    const file = e.dataTransfer.files?.[0];
    if (file) {
      handleFile(file);
    }
  };

  const handleDragOver = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    if (!disabled && !isUploading) {
      setDragOver(true);
    }
  };

  const handleDragLeave = () => {
    setDragOver(false);
  };

  return (
    <div style={{ width: "100%", display: "flex", flexDirection: "column", gap: "8px" }}>
      {label && (
        <label
          style={{
            fontSize: "0.875rem",
            fontWeight: 650,
            color: "var(--color-ink, #0F172A)",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
          }}
        >
          <span>{label}</span>
          {value && (
            <span
              style={{
                fontSize: "0.75rem",
                color: "#059669",
                display: "inline-flex",
                alignItems: "center",
                gap: "4px",
                fontWeight: 600,
              }}
            >
              <CheckCircle size={13} /> Cloudinary Hosted
            </span>
          )}
        </label>
      )}

      {/* Hidden native input */}
      <input
        ref={fileInputRef}
        type="file"
        accept={accept}
        style={{ display: "none" }}
        disabled={disabled || isUploading}
        onChange={(e) => {
          const file = e.target.files?.[0];
          if (file) handleFile(file);
        }}
      />

      {value ? (
        /* Preview Card */
        <div
          style={{
            position: "relative",
            display: "flex",
            alignItems: "center",
            gap: "12px",
            padding: "10px 14px",
            background: "#FFFFFF",
            border: "1.5px solid #10B981",
            borderRadius: "10px",
            boxShadow: "0 1px 3px rgba(0,0,0,0.05)",
          }}
        >
          <img
            src={getOptimizedCloudinaryUrl(value, { width: 120, height: 120 })}
            alt="Uploaded Preview"
            style={{
              width: "56px",
              height: "56px",
              objectFit: "cover",
              borderRadius: "8px",
              border: "1px solid #E2E8F0",
              flexShrink: 0,
            }}
          />

          <div style={{ flex: 1, minWidth: 0 }}>
            <div
              style={{
                fontSize: "0.85rem",
                fontWeight: 650,
                color: "#065F46",
                textOverflow: "ellipsis",
                overflow: "hidden",
                whiteSpace: "nowrap",
              }}
            >
              Image uploaded successfully
            </div>
            <div
              style={{
                fontSize: "0.75rem",
                color: "#64748B",
                textOverflow: "ellipsis",
                overflow: "hidden",
                whiteSpace: "nowrap",
                marginTop: "2px",
              }}
            >
              {value}
            </div>
            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              disabled={disabled || isUploading}
              style={{
                background: "none",
                border: "none",
                padding: 0,
                marginTop: "4px",
                fontSize: "0.75rem",
                fontWeight: 650,
                color: "var(--color-primary, #E86F1C)",
                cursor: "pointer",
                textDecoration: "underline",
              }}
            >
              Replace image
            </button>
          </div>

          <button
            type="button"
            onClick={() => onRemove?.()}
            disabled={disabled || isUploading}
            title="Remove image"
            style={{
              background: "#FEE2E2",
              border: "none",
              borderRadius: "50%",
              width: "28px",
              height: "28px",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              cursor: "pointer",
              color: "#DC2626",
              flexShrink: 0,
              transition: "background 0.15s ease",
            }}
          >
            <X size={15} />
          </button>
        </div>
      ) : (
        /* Upload Dropzone */
        <div
          onClick={() => !disabled && !isUploading && fileInputRef.current?.click()}
          onDrop={handleDrop}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          style={{
            cursor: disabled || isUploading ? "not-allowed" : "pointer",
            border: `2px dashed ${dragOver ? "var(--color-primary, #E86F1C)" : "#CBD5E1"}`,
            background: dragOver
              ? "#FFF7ED"
              : isUploading
              ? "#F8FAFC"
              : "#FAFAFA",
            borderRadius: "12px",
            padding: "20px 16px",
            textAlign: "center",
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            gap: "8px",
            transition: "all 0.2s ease",
          }}
        >
          {isUploading ? (
            <>
              <Loader2
                size={26}
                color="var(--color-primary, #E86F1C)"
                style={{ animation: "spin 1s linear infinite" }}
              />
              <span
                style={{
                  fontSize: "0.85rem",
                  fontWeight: 650,
                  color: "var(--color-primary, #E86F1C)",
                }}
              >
                Uploading to Cloudinary CDN...
              </span>
            </>
          ) : (
            <>
              <div
                style={{
                  width: "42px",
                  height: "42px",
                  borderRadius: "10px",
                  background: "#FFFFFF",
                  border: "1px solid #E2E8F0",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  color: "var(--color-primary, #E86F1C)",
                }}
              >
                <UploadCloud size={22} />
              </div>
              <div>
                <span
                  style={{
                    fontSize: "0.875rem",
                    fontWeight: 650,
                    color: "var(--color-ink, #0F172A)",
                  }}
                >
                  Click to choose
                </span>{" "}
                <span style={{ fontSize: "0.875rem", color: "#64748B" }}>
                  or drag & drop
                </span>
              </div>
              {helperText && (
                <span style={{ fontSize: "0.75rem", color: "#94A3B8" }}>
                  {helperText}
                </span>
              )}
            </>
          )}
        </div>
      )}

      {errorMessage && (
        <div
          style={{
            fontSize: "0.78rem",
            color: "#DC2626",
            background: "#FEF2F2",
            border: "1px solid #FCA5A5",
            borderRadius: "6px",
            padding: "6px 10px",
          }}
        >
          {errorMessage}
        </div>
      )}
    </div>
  );
}
