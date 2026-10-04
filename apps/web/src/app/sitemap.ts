import { MetadataRoute } from "next";
import { SHOP_PRODUCTS } from "@/data/shopProducts";
import { CERTIFIED_USED_PRODUCTS } from "@/data/usedProducts";

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = "https://sharma-video-care.vercel.app";

  const staticRoutes: MetadataRoute.Sitemap = [
    {
      url: `${baseUrl}`,
      lastModified: new Date(),
      changeFrequency: "daily",
      priority: 1.0,
    },
    {
      url: `${baseUrl}/shop`,
      lastModified: new Date(),
      changeFrequency: "daily",
      priority: 0.9,
    },
    {
      url: `${baseUrl}/used`,
      lastModified: new Date(),
      changeFrequency: "daily",
      priority: 0.9,
    },
    {
      url: `${baseUrl}/services`,
      lastModified: new Date(),
      changeFrequency: "weekly",
      priority: 0.85,
    },
    {
      url: `${baseUrl}/services/request`,
      lastModified: new Date(),
      changeFrequency: "monthly",
      priority: 0.8,
    },
    {
      url: `${baseUrl}/policies`,
      lastModified: new Date(),
      changeFrequency: "monthly",
      priority: 0.5,
    },
    {
      url: `${baseUrl}/terms`,
      lastModified: new Date(),
      changeFrequency: "monthly",
      priority: 0.5,
    },
    {
      url: `${baseUrl}/privacy`,
      lastModified: new Date(),
      changeFrequency: "monthly",
      priority: 0.5,
    },
  ];

  const productRoutes: MetadataRoute.Sitemap = SHOP_PRODUCTS.map((prod) => ({
    url: `${baseUrl}/shop/${prod.id}`,
    lastModified: new Date(),
    changeFrequency: "weekly",
    priority: 0.8,
  }));

  const usedRoutes: MetadataRoute.Sitemap = CERTIFIED_USED_PRODUCTS.map((item) => ({
    url: `${baseUrl}/used/${item.id}`,
    lastModified: new Date(),
    changeFrequency: "weekly",
    priority: 0.75,
  }));

  return [...staticRoutes, ...productRoutes, ...usedRoutes];
}
