"use client";

import React from "react";
import {
  HeroSection,
  CategoryCards,
  PopularServices,
  PromoBanners,
  FeaturedProducts,
  StoreCatalogue,
} from "@/components/home";

export default function HomePage() {
  return (
    <div style={{ minHeight: "100vh", background: "#F8F6F2" }}>
      {/* Section 1: Hero Section */}
      <HeroSection />

      {/* Section 2: 4 Quick-Access Category Cards */}
      <CategoryCards />

      {/* Section 3: Popular Services Grid */}
      <PopularServices />

      {/* Section 4: 3 Promo Banners */}
      <PromoBanners />

      {/* Section 5: Featured Products Grid */}
      <FeaturedProducts />

      {/* Section 6: Full Store & Equipment Catalogue */}
      <StoreCatalogue />
    </div>
  );
}
