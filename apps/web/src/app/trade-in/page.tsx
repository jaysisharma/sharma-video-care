import { Metadata } from "next";
import { TradeInCalculator } from "@/components/tradein/TradeInCalculator";

export const metadata: Metadata = {
  title: "Sell Old Gear & Instant Trade-In Valuation Calculator | Sharma Video Care",
  description:
    "Get an instant cash buyout or +10% store credit valuation for your DSLR cameras, mirrorless bodies, optical lenses, laptops, drones, and smartphones. Counter drop-off in Janakpurdham or insured courier pickup across Nepal.",
  keywords: [
    "Sell camera Nepal",
    "Trade in camera Janakpur",
    "Used camera valuation Nepal",
    "Sell DSLR Kathmandu Janakpur",
    "Exchange old camera for new",
    "Sharma Video Care trade-in",
    "Sell DJI drone Nepal",
    "Camera shutter count valuation",
  ],
  openGraph: {
    title: "Sell Old Gear & Trade-In Valuation Calculator | Sharma Video Care",
    description:
      "Instant cash buyout or +10% store credit upgrade for your cameras, lenses, laptops, and drones. Physical bench inspection at Station Road, Janakpur or insured pickup across Nepal.",
    type: "website",
    url: "https://sharma-video-care.vercel.app/trade-in",
  },
};

export default function TradeInPage() {
  return (
    <main
      style={{
        minHeight: "85vh",
        background: "#F8FAFC",
        padding: "32px 20px 80px 20px",
      }}
    >
      <TradeInCalculator />
    </main>
  );
}
