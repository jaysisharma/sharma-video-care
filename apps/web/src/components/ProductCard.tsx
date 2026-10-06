"use client";

import React, { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { useLanguage } from "@/context/LanguageContext";

export interface ProductCardData {
  id: string;
  title: string;
  subtitle?: string;
  trustNote?: string;
  category?: string;
  brand?: string;
  price: number;
  originalPrice?: number;
  rating?: number;
  reviewsCount?: number;
  image?: string;
  images?: string[];
  availabilityType?: "IN_STOCK" | "SOURCE_ON_REQUEST" | "SPECIAL_ORDER" | "OUT_OF_STOCK";
  warrantyInfo?: string;
  description?: string;
  tag?: string;
}

export interface ProductCardProps {
  product: ProductCardData;
  isWishlisted?: boolean;
  onToggleWishlist?: (id: string, e: React.MouseEvent) => void;
  onAddToCart?: (product: ProductCardData, e: React.MouseEvent) => void;
  isAdded?: boolean;
  href?: string;
}

export const ProductCard: React.FC<ProductCardProps> = ({
  product,
  isWishlisted = false,
  onToggleWishlist,
  onAddToCart,
  isAdded = false,
  href,
}) => {
  const { language } = useLanguage();
  const [localWishlisted, setLocalWishlisted] = useState(isWishlisted);
  const [isCardHovered, setIsCardHovered] = useState(false);

  const productHref = href || `/shop/${product.id}`;

  const imageSrc =
    product.image ||
    (product.images && product.images.length > 0 ? product.images[0] : null) ||
    "/images/products/canon_eos.jpg";

  const isRemoteImage = imageSrc.startsWith("http://") || imageSrc.startsWith("https://");

  const hasDiscount = !!(product.originalPrice && product.originalPrice > product.price);
  const savingsAmount = hasDiscount ? product.originalPrice! - product.price : 0;

  const ratingValue = product.rating ?? 4.8;
  const reviewsValue = product.reviewsCount ?? 18;

  const handleWishlistClick = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setLocalWishlisted((prev) => !prev);
    if (onToggleWishlist) {
      onToggleWishlist(product.id, e);
    }
  };

  const handleAddToCartClick = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (onAddToCart) {
      onAddToCart(product, e);
    }
  };

  return (
    <div
      style={{
        background: "#FFFFFF",
        borderRadius: "14px",
        border: isCardHovered ? "1px solid #E86F1C" : "1px solid #EBE6DE",
        display: "flex",
        flexDirection: "column",
        height: "100%",
        overflow: "hidden",
        boxShadow: isCardHovered
          ? "0 10px 24px -4px rgba(232, 111, 28, 0.12), 0 3px 8px rgba(0, 0, 0, 0.04)"
          : "0 2px 6px rgba(0, 0, 0, 0.02)",
        transform: isCardHovered ? "translateY(-3px)" : "translateY(0)",
        transition: "border-color 0.2s ease, box-shadow 0.22s ease, transform 0.22s ease",
        position: "relative",
      }}
      onMouseEnter={() => setIsCardHovered(true)}
      onMouseLeave={() => setIsCardHovered(false)}
    >
      {/* Studio Photo Canvas with Solid Neutral Background */}
      <Link
        href={productHref}
        style={{
          display: "block",
          position: "relative",
          height: "205px",
          background: "#F8F6F0",
          padding: "18px",
          textDecoration: "none",
          borderBottom: "1px solid #EFE8DE",
          overflow: "hidden",
          flexShrink: 0,
        }}
      >
        {/* Deal / Sale Chip */}
        {hasDiscount && (
          <span
            style={{
              position: "absolute",
              top: "12px",
              left: "12px",
              zIndex: 2,
              padding: "3px 8px",
              borderRadius: "6px",
              background: "#E86F1C",
              color: "#FFFFFF",
              fontSize: "10.5px",
              fontWeight: 750,
              letterSpacing: "0.04em",
              textTransform: "uppercase",
              boxShadow: "0 2px 6px rgba(232, 111, 28, 0.25)",
            }}
          >
            {language === "ne" ? "छुट" : "SALE"}
          </span>
        )}

        {/* High-Ticket Trust Tag (e.g. MDMS Cleared, Authorized Stock, Lab Certified) */}
        {product.tag && (
          <span
            style={{
              position: "absolute",
              bottom: "10px",
              left: "12px",
              zIndex: 2,
              padding: "2px 7px",
              borderRadius: "4px",
              background: "#0F172A",
              color: "#FFFFFF",
              fontSize: "10px",
              fontWeight: 650,
              letterSpacing: "0.02em",
            }}
          >
            {product.tag}
          </span>
        )}

        {/* Wishlist Heart Button */}
        <button
          type="button"
          onClick={handleWishlistClick}
          aria-label={localWishlisted ? "Remove from wishlist" : "Add to wishlist"}
          style={{
            position: "absolute",
            top: "12px",
            right: "12px",
            zIndex: 2,
            width: "32px",
            height: "32px",
            borderRadius: "50%",
            background: "rgba(255, 255, 255, 0.94)",
            border: "1px solid #E8E1D5",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            cursor: "pointer",
            padding: 0,
            boxShadow: "0 2px 6px rgba(0, 0, 0, 0.04)",
            transition: "transform 0.18s ease, background 0.15s ease",
            transform: localWishlisted ? "scale(1.05)" : "scale(1)",
          }}
          onMouseEnter={(e) => (e.currentTarget.style.transform = "scale(1.12)")}
          onMouseLeave={(e) =>
            (e.currentTarget.style.transform = localWishlisted ? "scale(1.05)" : "scale(1)")
          }
        >
          <svg
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill={localWishlisted ? "#EF4444" : "none"}
            stroke={localWishlisted ? "#EF4444" : "#9C9286"}
            strokeWidth="1.8"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
          </svg>
        </button>

        {/* Product Image with Hover Scale */}
        <div
          style={{
            position: "relative",
            width: "100%",
            height: "100%",
            transform: isCardHovered ? "scale(1.03)" : "scale(1)",
            transition: "transform 0.3s cubic-bezier(0.16, 1, 0.3, 1)",
          }}
        >
          {isRemoteImage ? (
            <img
              src={imageSrc}
              alt={product.title}
              style={{
                width: "100%",
                height: "100%",
                objectFit: "contain",
                objectPosition: "center",
              }}
              loading="lazy"
            />
          ) : (
            <Image
              src={imageSrc}
              alt={product.title}
              fill
              sizes="(max-width: 600px) 90vw, (max-width: 1024px) 45vw, 25vw"
              style={{
                objectFit: "contain",
                objectPosition: "center",
              }}
            />
          )}
        </div>
      </Link>

      {/* Card Info - Uniform spacing and strict heights across all cards */}
      <div
        style={{
          padding: "16px",
          display: "flex",
          flexDirection: "column",
          flex: 1,
          justifyContent: "space-between",
        }}
      >
        <div>
          {/* Product Title - Clamped to 2 lines with strict 40px container */}
          <h3 style={{ margin: "0 0 6px 0", height: "40px", overflow: "hidden" }}>
            <Link
              href={productHref}
              title={product.title}
              style={{
                fontSize: "14px",
                fontWeight: 650,
                color: isCardHovered ? "#E86F1C" : "#181512",
                lineHeight: "20px",
                textDecoration: "none",
                display: "-webkit-box",
                WebkitLineClamp: 2,
                WebkitBoxOrient: "vertical",
                overflow: "hidden",
                transition: "color 0.18s ease",
              }}
            >
              {product.title}
            </Link>
          </h3>

          {/* Rating - Fixed 18px row across all cards */}
          <div
            style={{
              height: "18px",
              display: "flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <svg
              width="12"
              height="12"
              viewBox="0 0 24 24"
              fill="#F59E0B"
              stroke="#F59E0B"
              strokeWidth="1"
            >
              <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
            </svg>
            <span
              style={{
                fontSize: "12px",
                fontWeight: 700,
                color: "#181512",
                lineHeight: 1,
              }}
            >
              {ratingValue.toFixed(1)}
            </span>
            <span
              style={{
                fontSize: "11px",
                color: "#9A9084",
                lineHeight: 1,
              }}
            >
              ({reviewsValue})
            </span>
          </div>
        </div>

        {/* Price & Action Row - Strict baseline alignment */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            paddingTop: "12px",
            marginTop: "12px",
            borderTop: "1px solid #F3EFEA",
          }}
        >
          {/* Price Block - Exact 38px height container */}
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              justifyContent: "center",
              minHeight: "38px",
            }}
          >
            <div
              style={{
                fontSize: "16px",
                fontWeight: 800,
                color: "#181512",
                letterSpacing: "-0.015em",
                fontVariantNumeric: "tabular-nums",
                lineHeight: 1.2,
              }}
            >
              Rs. {product.price.toLocaleString("en-IN")}
            </div>

            {/* Consistent Sub-price / Guarantee Line (Exact 16px height) */}
            <div
              style={{
                height: "16px",
                display: "flex",
                alignItems: "center",
                gap: "5px",
                marginTop: "3px",
              }}
            >
              {hasDiscount ? (
                <>
                  <span
                    style={{
                      fontSize: "11px",
                      color: "#A19B91",
                      textDecoration: "line-through",
                    }}
                  >
                    Rs. {product.originalPrice!.toLocaleString("en-IN")}
                  </span>
                  {savingsAmount > 0 && (
                    <span
                      style={{
                        fontSize: "10px",
                        fontWeight: 700,
                        color: "#15803D",
                        background: "#EAF6EE",
                        padding: "1px 5px",
                        borderRadius: "4px",
                      }}
                    >
                      {language === "ne"
                        ? `बचत रु. ${savingsAmount.toLocaleString("en-IN")}`
                        : `Save Rs. ${savingsAmount.toLocaleString("en-IN")}`}
                    </span>
                  )}
                </>
              ) : (
                <span
                  style={{
                    fontSize: "11px",
                    color: "#9CA3AF",
                    fontWeight: 500,
                  }}
                >
                  {language === "ne" ? "आधिकारिक वारेन्टी" : "Official Warranty"}
                </span>
              )}
            </div>
          </div>

          {/* Action CTA Button */}
          <button
            type="button"
            onClick={handleAddToCartClick}
            aria-label={isAdded ? "Added to cart" : `Add ${product.title} to cart`}
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "6px",
              height: "34px",
              padding: "0 13px",
              borderRadius: "8px",
              background: isAdded ? "#16A34A" : "#E86F1C",
              color: "#FFFFFF",
              border: "none",
              fontSize: "12px",
              fontWeight: 700,
              cursor: "pointer",
              transition: "all 0.18s ease",
              boxShadow: isAdded
                ? "0 2px 6px rgba(22, 163, 74, 0.2)"
                : "0 2px 6px rgba(232, 111, 28, 0.25)",
              flexShrink: 0,
            }}
            onMouseEnter={(e) => {
              if (!isAdded) e.currentTarget.style.background = "#D35F12";
            }}
            onMouseLeave={(e) => {
              if (!isAdded) e.currentTarget.style.background = "#E86F1C";
            }}
          >
            {isAdded ? (
              <>
                <svg
                  width="13"
                  height="13"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="3"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <polyline points="20 6 9 17 4 12" />
                </svg>
                <span>{language === "ne" ? "थपियो" : "Added"}</span>
              </>
            ) : (
              <>
                <svg
                  width="13"
                  height="13"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2.4"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <circle cx="9" cy="21" r="1" />
                  <circle cx="20" cy="21" r="1" />
                  <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6" />
                </svg>
                <span>{language === "ne" ? "कार्टमा थप्नुहोस्" : "Add to Cart"}</span>
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
};

export default ProductCard;
