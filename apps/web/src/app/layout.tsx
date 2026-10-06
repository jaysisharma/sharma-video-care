import type { Metadata } from "next";
import { Inter, Noto_Sans_Devanagari, JetBrains_Mono } from "next/font/google";
import "./globals.css";
import { AuthProvider } from "../context/AuthContext";
import { CartProvider } from "../context/CartContext";
import { LanguageProvider } from "../context/LanguageContext";
import { AppShell } from "../components/AppShell";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
  weight: ["400", "500", "600", "700", "800"],
});

const notoSansDevanagari = Noto_Sans_Devanagari({
  subsets: ["devanagari"],
  variable: "--font-devanagari",
  display: "swap",
  weight: ["400", "500", "600", "700", "800"],
});

const jetbrainsMono = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-mono",
  display: "swap",
  weight: ["500", "600"],
});

export const metadata: Metadata = {
  metadataBase: new URL("https://sharma-video-care.vercel.app"),
  title: {
    default: "Sharma Video Care | Electronics Repair & Genuine Tech Equipment",
    template: "%s | Sharma Video Care",
  },
  description:
    "Sharma Video Care — Professional electronics repair, certified camera diagnostics, genuine tech gear, and pre-owned equipment with physical inspection in Janakpur and nationwide delivery across Nepal.",
  keywords: [
    "camera repair Janakpur",
    "electronics repair Nepal",
    "buy cameras Nepal",
    "Sony Alpha Nepal",
    "Canon repair Nepal",
    "DJI drone repair Janakpur",
    "certified second hand camera Nepal",
    "Sharma Video Care",
  ],
  authors: [{ name: "Sharma Video Care" }],
  openGraph: {
    type: "website",
    locale: "en_NP",
    url: "https://sharma-video-care.vercel.app",
    siteName: "Sharma Video Care",
    title: "Sharma Video Care | Electronics Repair & Genuine Tech Store Nepal",
    description:
      "Expert electronics & camera diagnosis, genuine gear, and certified pre-owned tech in Janakpur & all across Nepal.",
    images: [
      {
        url: "/images/hero-camera.png",
        width: 1200,
        height: 630,
        alt: "Sharma Video Care Nepal",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Sharma Video Care | Electronics Repair & Tech Store",
    description:
      "Precision electronics repair, certified pre-owned cameras, and nationwide delivery across Nepal.",
    images: ["/images/hero-camera.png"],
  },
};

const localBusinessSchema = {
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  name: "Sharma Video Care",
  image: "https://sharma-video-care.vercel.app/images/hero-camera.png",
  url: "https://sharma-video-care.vercel.app",
  telephone: "+9779854022200",
  priceRange: "NPR 500 - NPR 500000",
  address: {
    "@type": "PostalAddress",
    streetAddress: "Station Road, Near Ramanand Chowk",
    addressLocality: "Janakpurdham",
    addressRegion: "Madhesh Province",
    postalCode: "45600",
    addressCountry: "NP",
  },
  geo: {
    "@type": "GeoCoordinates",
    latitude: 26.7271,
    longitude: 85.9407,
  },
  openingHoursSpecification: [
    {
      "@type": "OpeningHoursSpecification",
      dayOfWeek: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
      opens: "09:00",
      closes: "19:30",
    },
  ],
  sameAs: ["https://wa.me/9779854022200"],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="en"
      className={`${inter.variable} ${notoSansDevanagari.variable} ${jetbrainsMono.variable}`}
    >
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(localBusinessSchema) }}
        />
      </head>
      <body>
        <AuthProvider>
          <CartProvider>
            <LanguageProvider>
              <AppShell>{children}</AppShell>
            </LanguageProvider>
          </CartProvider>
        </AuthProvider>
      </body>
    </html>
  );
}
