"use client";

import React, { useState } from "react";
import Link from "next/link";
import { useCart } from "@/context/CartContext";
import { PRODUCT_CATEGORIES, HOME_PRODUCTS, ProductItem } from "./data";
import { ProductCard, ProductCardData } from "@/components/ProductCard";

export const FeaturedProducts: React.FC = () => {
  const { addToCart } = useCart();
  const [selectedCategory, setSelectedCategory] = useState("All");
  const [wishlist, setWishlist] = useState<string[]>([]);
  const [addedId, setAddedId] = useState<string | null>(null);

  const filteredProducts =
    selectedCategory === "All"
      ? HOME_PRODUCTS
      : HOME_PRODUCTS.filter((p) => p.category === selectedCategory);

  const handleAddToCart = (product: ProductItem | ProductCardData, e?: React.MouseEvent) => {
    if (e) {
      e.preventDefault();
      e.stopPropagation();
    }
    addToCart({
      productId: product.id,
      productType: "NEW",
      name: product.title,
      image: product.image,
      unitPrice: product.price,
      quantity: 1,
      totalPrice: product.price,
      warrantySummary: product.trustNote,
    });
    setAddedId(product.id);
    setTimeout(() => setAddedId(null), 1800);
  };

  const toggleWishlist = (id: string, e?: React.MouseEvent) => {
    if (e) {
      e.preventDefault();
      e.stopPropagation();
    }
    setWishlist((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  return (
    <section
      style={{
        width: "100%",
        padding: "0 24px 60px 24px",
      }}
    >
      <div
        style={{
          maxWidth: "1280px",
          margin: "0 auto",
        }}
      >
        {/* Section Header with Category Filter Chips */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            flexWrap: "wrap",
            gap: "16px",
            marginBottom: "22px",
          }}
        >
          {/* Title & Filter Chips Group */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              flexWrap: "wrap",
              gap: "14px",
            }}
          >
            <h2
              style={{
                fontSize: "20px",
                fontWeight: 800,
                color: "#181512",
                letterSpacing: "-0.015em",
                margin: 0,
                whiteSpace: "nowrap",
              }}
            >
              Featured Products
            </h2>

            {/* Filter Chips */}
            <div
              style={{
                display: "flex",
                alignItems: "center",
                flexWrap: "wrap",
                gap: "6px",
              }}
            >
              {PRODUCT_CATEGORIES.map((cat) => {
                const isActive = selectedCategory === cat;
                return (
                  <button
                    key={cat}
                    type="button"
                    onClick={() => setSelectedCategory(cat)}
                    style={{
                      padding: "5px 14px",
                      borderRadius: "9999px",
                      fontSize: "12.5px",
                      fontWeight: isActive ? 700 : 500,
                      border: "none",
                      cursor: "pointer",
                      background: isActive ? "#E86F1C" : "#EBE7DF",
                      color: isActive ? "#FFFFFF" : "#4B443B",
                      transition: "all 0.15s ease",
                    }}
                    onMouseEnter={(e) => {
                      if (!isActive) e.currentTarget.style.background = "#E0DBD2";
                    }}
                    onMouseLeave={(e) => {
                      if (!isActive) e.currentTarget.style.background = "#EBE7DF";
                    }}
                  >
                    {cat}
                  </button>
                );
              })}
            </div>
          </div>

          {/* View All Products Link */}
          <Link
            href="/shop"
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
              fontSize: "13px",
              fontWeight: 650,
              color: "#4B443B",
              textDecoration: "none",
              transition: "color 0.15s ease",
              whiteSpace: "nowrap",
            }}
            onMouseEnter={(e) => (e.currentTarget.style.color = "#E86F1C")}
            onMouseLeave={(e) => (e.currentTarget.style.color = "#4B443B")}
          >
            <span>View All Products</span>
            <svg
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.4"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <line x1="5" y1="12" x2="19" y2="12" />
              <polyline points="12 5 19 12 12 19" />
            </svg>
          </Link>
        </div>

        {/* Product Cards Grid */}
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))",
            gap: "20px",
          }}
        >
          {filteredProducts.map((product) => (
            <ProductCard
              key={product.id}
              product={product}
              isWishlisted={wishlist.includes(product.id)}
              onToggleWishlist={toggleWishlist}
              onAddToCart={handleAddToCart}
              isAdded={addedId === product.id}
            />
          ))}
        </div>
      </div>
    </section>
  );
};
