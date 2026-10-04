"use client";

import React, { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { doc, getDoc } from "firebase/firestore";
import { db } from "../../../lib/firebase";
import { useCart } from "../../../context/CartContext";
import { SHOP_PRODUCTS, ShopProduct } from "@/data/shopProducts";
import {
  ShoppingCart,
  Check,
  ArrowLeft,
  ShieldCheck,
  RotateCcw,
  Truck,
  PhoneCall,
  CheckCircle2,
  PackageCheck,
} from "lucide-react";

export default function ProductDetailPage() {
  const params = useParams();
  const id = params?.id as string;
  const router = useRouter();

  const [product, setProduct] = useState<ShopProduct | null>(null);
  const [selectedImage, setSelectedImage] = useState<string>("");
  const [loading, setLoading] = useState(true);
  const [quantity, setQuantity] = useState(1);
  const [added, setAdded] = useState(false);

  const { addToCart } = useCart();

  useEffect(() => {
    async function loadProduct() {
      try {
        const snap = await getDoc(doc(db, "products", id));
        if (snap.exists()) {
          const data = snap.data();
          const p: ShopProduct = {
            id: snap.id,
            title: data.name || data.title || "Product",
            subtitle: data.subtitle || data.description || "",
            brand: data.brand || "Brand",
            model: data.model || "",
            sku: data.sku || snap.id,
            price: data.price || 0,
            originalPrice: data.originalPrice,
            category: data.categoryName || data.category || "Cameras",
            rating: data.rating || 4.8,
            reviewsCount: data.reviewsCount || 12,
            image: data.image || (data.images && data.images[0]) || "/images/products/canon_eos.jpg",
            images: data.images || (data.image ? [data.image] : ["/images/products/canon_eos.jpg"]),
            availabilityType: data.availabilityType || "IN_STOCK",
            stockQuantity: data.stockQuantity || 5,
            warrantyInfo: data.warrantyInfo || "Official Manufacturer Warranty",
            returnPolicyInfo: data.returnPolicyInfo || "7-day replacement guarantee",
            description: data.description || "",
            specifications: data.specifications || {},
          };
          setProduct(p);
          setSelectedImage(p.image || (p.images && p.images[0]) || "");
        } else {
          // Fallback to verified catalog item
          const fallback = SHOP_PRODUCTS.find((p) => p.id === id);
          if (fallback) {
            setProduct(fallback);
            setSelectedImage(fallback.image || (fallback.images && fallback.images[0]) || "");
          }
        }
      } catch (err) {
        console.warn("Firestore error, falling back to static catalog:", err);
        const fallback = SHOP_PRODUCTS.find((p) => p.id === id);
        if (fallback) {
          setProduct(fallback);
          setSelectedImage(fallback.image || (fallback.images && fallback.images[0]) || "");
        }
      } finally {
        setLoading(false);
      }
    }
    if (id) loadProduct();
  }, [id]);

  if (loading) {
    return (
      <div style={{ background: "#F8FAFC", minHeight: "80vh", padding: "4rem 1.25rem" }}>
        <div style={{ maxWidth: "1200px", margin: "0 auto", textAlign: "center", color: "#64748B" }}>
          Loading product specifications...
        </div>
      </div>
    );
  }

  if (!product) {
    return (
      <div style={{ background: "#F8FAFC", minHeight: "80vh", padding: "4rem 1.25rem" }}>
        <div
          style={{
            maxWidth: "600px",
            margin: "0 auto",
            textAlign: "center",
            background: "#FFFFFF",
            padding: "3rem 2rem",
            borderRadius: "14px",
            border: "1px solid #E2E8F0",
          }}
        >
          <h2 style={{ fontSize: "1.5rem", fontWeight: 800, color: "#0F172A", margin: "0 0 0.75rem 0" }}>
            Product Not Found
          </h2>
          <p style={{ color: "#64748B", fontSize: "14px", margin: "0 0 1.5rem 0" }}>
            The requested product model is not available or has been moved to our archive.
          </p>
          <Link
            href="/shop"
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "8px",
              background: "#E86F1C",
              color: "#FFFFFF",
              textDecoration: "none",
              padding: "10px 20px",
              borderRadius: "8px",
              fontSize: "14px",
              fontWeight: 650,
            }}
          >
            <ArrowLeft size={16} /> Back to Store Catalogue
          </Link>
        </div>
      </div>
    );
  }

  const hasDiscount = !!(product.originalPrice && product.originalPrice > product.price);
  const savings = hasDiscount ? product.originalPrice! - product.price : 0;

  const handleAddToCart = () => {
    addToCart({
      productId: product.id,
      productType: "NEW",
      name: product.title,
      image: selectedImage || product.image || (product.images && product.images[0]),
      unitPrice: product.price,
      quantity,
      totalPrice: product.price * quantity,
      warrantySummary: product.warrantyInfo,
    });
    setAdded(true);
    setTimeout(() => setAdded(false), 2000);
  };

  const handleBuyNow = () => {
    handleAddToCart();
    router.push("/cart");
  };

  const isRemoteImage =
    selectedImage.startsWith("http://") || selectedImage.startsWith("https://");

  return (
    <div style={{ background: "#F8FAFC", minHeight: "100vh", padding: "2rem 1.25rem 4rem 1.25rem" }}>
      <div style={{ maxWidth: "1280px", margin: "0 auto" }}>
        {/* Navigation Breadcrumb */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: "8px",
            fontSize: "13px",
            color: "#64748B",
            marginBottom: "1.5rem",
          }}
        >
          <Link href="/shop" style={{ display: "inline-flex", alignItems: "center", gap: "6px", color: "#64748B", textDecoration: "none" }}>
            <ArrowLeft size={15} /> Back to Catalogue
          </Link>
          <span>/</span>
          <span>{product.category || "Electronics"}</span>
          <span>/</span>
          <span style={{ color: "#0F172A", fontWeight: 600 }}>{product.title}</span>
        </div>

        {/* Main Product Layout */}
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(360px, 1fr))",
            gap: "3rem",
            alignItems: "start",
          }}
        >
          {/* Left Column: Image Canvas & Thumbnails */}
          <div>
            <div
              style={{
                width: "100%",
                height: "460px",
                background: "#FFFFFF",
                borderRadius: "14px",
                overflow: "hidden",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                border: "1px solid #E2E8F0",
                position: "relative",
                padding: "24px",
                boxShadow: "0 2px 8px rgba(0, 0, 0, 0.03)",
              }}
            >
              {hasDiscount && (
                <span
                  style={{
                    position: "absolute",
                    top: "16px",
                    left: "16px",
                    background: "#E86F1C",
                    color: "#FFFFFF",
                    fontSize: "11px",
                    fontWeight: 800,
                    letterSpacing: "0.04em",
                    padding: "4px 10px",
                    borderRadius: "6px",
                    textTransform: "uppercase",
                  }}
                >
                  SALE
                </span>
              )}

              {selectedImage ? (
                isRemoteImage ? (
                  <img
                    src={selectedImage}
                    alt={product.title}
                    style={{
                      width: "100%",
                      height: "100%",
                      objectFit: "contain",
                      objectPosition: "center",
                    }}
                  />
                ) : (
                  <div style={{ position: "relative", width: "100%", height: "100%" }}>
                    <Image
                      src={selectedImage}
                      alt={product.title}
                      fill
                      priority
                      style={{ objectFit: "contain", objectPosition: "center" }}
                    />
                  </div>
                )
              ) : (
                <div style={{ color: "#94A3B8" }}>No Image Available</div>
              )}
            </div>

            {/* Gallery Thumbnails */}
            {product.images && product.images.length > 1 && (
              <div style={{ display: "flex", gap: "10px", marginTop: "14px" }}>
                {product.images.map((img, idx) => (
                  <button
                    key={idx}
                    type="button"
                    onClick={() => setSelectedImage(img)}
                    style={{
                      width: "68px",
                      height: "68px",
                      borderRadius: "8px",
                      border: selectedImage === img ? "2px solid #E86F1C" : "1px solid #E2E8F0",
                      background: "#FFFFFF",
                      overflow: "hidden",
                      cursor: "pointer",
                      padding: "4px",
                    }}
                  >
                    <img
                      src={img}
                      alt={`${product.title} view ${idx + 1}`}
                      style={{ width: "100%", height: "100%", objectFit: "contain" }}
                    />
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Right Column: Pricing, Specs, Order Form */}
          <div>
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
                marginBottom: "0.5rem",
              }}
            >
              <span
                style={{
                  fontSize: "12px",
                  fontWeight: 750,
                  color: "#E86F1C",
                  textTransform: "uppercase",
                  letterSpacing: "0.06em",
                }}
              >
                {product.brand} {product.model && `• ${product.model}`}
              </span>

              {product.availabilityType === "OUT_OF_STOCK" || product.stockQuantity === 0 ? (
                <span
                  style={{
                    background: "#FEF2F2",
                    color: "#DC2626",
                    border: "1px solid #FEE2E2",
                    padding: "3px 8px",
                    borderRadius: "6px",
                    fontSize: "11px",
                    fontWeight: 700,
                  }}
                >
                  Out of Stock
                </span>
              ) : (
                <span
                  style={{
                    background: "#ECFDF5",
                    color: "#059669",
                    border: "1px solid #D1FAE5",
                    padding: "3px 8px",
                    borderRadius: "6px",
                    fontSize: "11px",
                    fontWeight: 700,
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "4px",
                  }}
                >
                  <PackageCheck size={13} /> In Stock Ready to Ship
                </span>
              )}
            </div>

            <h1
              style={{
                fontSize: "2rem",
                fontWeight: 800,
                color: "#0F172A",
                margin: "0 0 0.75rem 0",
                lineHeight: 1.25,
                letterSpacing: "-0.02em",
              }}
            >
              {product.title}
            </h1>

            {/* Price Row */}
            <div
              style={{
                display: "flex",
                alignItems: "baseline",
                gap: "12px",
                marginBottom: "1.25rem",
                flexWrap: "wrap",
              }}
            >
              <div
                style={{
                  fontSize: "2rem",
                  fontWeight: 800,
                  color: "#0F172A",
                  letterSpacing: "-0.02em",
                }}
              >
                Rs. {product.price.toLocaleString("en-IN")}
              </div>

              {hasDiscount && (
                <>
                  <div
                    style={{
                      fontSize: "1.1rem",
                      color: "#94A3B8",
                      textDecoration: "line-through",
                    }}
                  >
                    Rs. {product.originalPrice!.toLocaleString("en-IN")}
                  </div>
                  <div
                    style={{
                      fontSize: "12px",
                      fontWeight: 700,
                      color: "#15803D",
                      background: "#EAF6EE",
                      padding: "2px 8px",
                      borderRadius: "4px",
                    }}
                  >
                    Save Rs. {savings.toLocaleString("en-IN")}
                  </div>
                </>
              )}
            </div>

            {/* Subtitle / Overview */}
            <p
              style={{
                fontSize: "14.5px",
                color: "#475569",
                lineHeight: 1.6,
                margin: "0 0 1.5rem 0",
              }}
            >
              {product.description || product.subtitle}
            </p>

            {/* Action Box */}
            <div
              style={{
                background: "#FFFFFF",
                borderRadius: "12px",
                border: "1px solid #E2E8F0",
                padding: "1.5rem",
                marginBottom: "2rem",
                boxShadow: "0 1px 3px rgba(0, 0, 0, 0.02)",
              }}
            >
              {product.availabilityType === "OUT_OF_STOCK" || product.stockQuantity === 0 ? (
                <div>
                  <p style={{ fontSize: "14px", color: "#64748B", margin: "0 0 1rem 0" }}>
                    This item is temporarily out of stock. You can submit a custom sourcing request
                    or browse available items.
                  </p>
                  <Link
                    href="/source-request"
                    style={{
                      display: "inline-block",
                      background: "#0F172A",
                      color: "#FFFFFF",
                      padding: "10px 18px",
                      borderRadius: "8px",
                      fontSize: "13.5px",
                      fontWeight: 650,
                      textDecoration: "none",
                    }}
                  >
                    Request Sourcing for this Model
                  </Link>
                </div>
              ) : (
                <div>
                  <div
                    style={{
                      display: "flex",
                      gap: "1rem",
                      alignItems: "center",
                      marginBottom: "1.25rem",
                    }}
                  >
                    <label style={{ fontSize: "13.5px", fontWeight: 650, color: "#334155" }}>
                      Quantity:
                    </label>
                    <select
                      value={quantity}
                      onChange={(e) => setQuantity(Number(e.target.value))}
                      style={{
                        width: "80px",
                        height: "38px",
                        padding: "0 10px",
                        borderRadius: "6px",
                        border: "1px solid #CBD5E1",
                        fontSize: "14px",
                        fontWeight: 600,
                        background: "#FFFFFF",
                        outline: "none",
                      }}
                    >
                      {[...Array(Math.min(product.stockQuantity || 5, 8))].map((_, i) => (
                        <option key={i + 1} value={i + 1}>
                          {i + 1}
                        </option>
                      ))}
                    </select>
                    <span style={{ fontSize: "12px", color: "#64748B" }}>
                      ({product.stockQuantity || 5} units available in Janakpur warehouse)
                    </span>
                  </div>

                  <div style={{ display: "flex", gap: "12px", flexWrap: "wrap" }}>
                    <button
                      type="button"
                      onClick={handleAddToCart}
                      style={{
                        flex: 1,
                        minWidth: "160px",
                        height: "44px",
                        display: "inline-flex",
                        alignItems: "center",
                        justifyContent: "center",
                        gap: "8px",
                        background: added ? "#16A34A" : "#E86F1C",
                        color: "#FFFFFF",
                        border: "none",
                        borderRadius: "8px",
                        fontSize: "14px",
                        fontWeight: 700,
                        cursor: "pointer",
                        transition: "background 0.15s ease",
                      }}
                    >
                      {added ? (
                        <>
                          <Check size={18} /> Added to Cart!
                        </>
                      ) : (
                        <>
                          <ShoppingCart size={18} /> Add to Cart
                        </>
                      )}
                    </button>

                    <button
                      type="button"
                      onClick={handleBuyNow}
                      style={{
                        height: "44px",
                        padding: "0 24px",
                        background: "#0F172A",
                        color: "#FFFFFF",
                        border: "none",
                        borderRadius: "8px",
                        fontSize: "14px",
                        fontWeight: 700,
                        cursor: "pointer",
                      }}
                    >
                      Buy Now
                    </button>
                  </div>
                </div>
              )}
            </div>

            {/* Technical Specifications Table */}
            {product.specifications && Object.keys(product.specifications).length > 0 && (
              <div
                style={{
                  background: "#FFFFFF",
                  borderRadius: "12px",
                  border: "1px solid #E2E8F0",
                  padding: "1.25rem",
                  marginBottom: "2rem",
                }}
              >
                <h3
                  style={{
                    fontSize: "15px",
                    fontWeight: 750,
                    color: "#0F172A",
                    margin: "0 0 1rem 0",
                    letterSpacing: "-0.01em",
                  }}
                >
                  Technical Specifications
                </h3>
                <div style={{ display: "flex", flexDirection: "column" }}>
                  {Object.entries(product.specifications).map(([key, value], idx) => (
                    <div
                      key={key}
                      style={{
                        display: "grid",
                        gridTemplateColumns: "160px 1fr",
                        padding: "8px 0",
                        borderTop: idx === 0 ? "none" : "1px solid #F1F5F9",
                        fontSize: "13px",
                      }}
                    >
                      <span style={{ color: "#64748B", fontWeight: 550 }}>{key}</span>
                      <span style={{ color: "#0F172A", fontWeight: 600 }}>{value}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Policy & Assurance Details */}
            <div
              style={{
                display: "flex",
                flexDirection: "column",
                gap: "1rem",
                background: "#FFFFFF",
                borderRadius: "12px",
                border: "1px solid #E2E8F0",
                padding: "1.25rem",
              }}
            >
              <div style={{ display: "flex", gap: "10px", alignItems: "flex-start" }}>
                <ShieldCheck size={20} color="#E86F1C" style={{ flexShrink: 0, marginTop: "2px" }} />
                <div>
                  <div style={{ fontSize: "13.5px", fontWeight: 700, color: "#0F172A" }}>
                    Warranty Protection
                  </div>
                  <div style={{ fontSize: "12.5px", color: "#64748B", marginTop: "2px" }}>
                    {product.warrantyInfo || "Official manufacturer warranty applies with VAT invoice."}
                  </div>
                </div>
              </div>

              <div style={{ display: "flex", gap: "10px", alignItems: "flex-start" }}>
                <Truck size={20} color="#E86F1C" style={{ flexShrink: 0, marginTop: "2px" }} />
                <div>
                  <div style={{ fontSize: "13.5px", fontWeight: 700, color: "#0F172A" }}>
                    Nationwide Courier Transit
                  </div>
                  <div style={{ fontSize: "12.5px", color: "#64748B", marginTop: "2px" }}>
                    Dispatched via verified courier partners with parcel tracking across all 77 districts.
                  </div>
                </div>
              </div>

              <div style={{ display: "flex", gap: "10px", alignItems: "flex-start" }}>
                <RotateCcw size={20} color="#E86F1C" style={{ flexShrink: 0, marginTop: "2px" }} />
                <div>
                  <div style={{ fontSize: "13.5px", fontWeight: 700, color: "#0F172A" }}>
                    7-Day Inspection Guarantee
                  </div>
                  <div style={{ fontSize: "12.5px", color: "#64748B", marginTop: "2px" }}>
                    {product.returnPolicyInfo ||
                      "Doorstep inspection and immediate replacement for transit damages or factory faults."}
                  </div>
                </div>
              </div>

              <div style={{ display: "flex", gap: "10px", alignItems: "flex-start" }}>
                <PhoneCall size={20} color="#E86F1C" style={{ flexShrink: 0, marginTop: "2px" }} />
                <div>
                  <div style={{ fontSize: "13.5px", fontWeight: 700, color: "#0F172A" }}>
                    Janakpur Store Hotline
                  </div>
                  <div style={{ fontSize: "12.5px", color: "#64748B", marginTop: "2px" }}>
                    Have questions? Call our technical desk at{" "}
                    <a
                      href="tel:+9779854025000"
                      style={{ color: "#E86F1C", fontWeight: 700, textDecoration: "none" }}
                    >
                      +977-9854025000
                    </a>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
