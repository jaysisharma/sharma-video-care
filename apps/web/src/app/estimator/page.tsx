import { Metadata } from "next";
import { RepairEstimator } from "@/components/estimator/RepairEstimator";

export const metadata: Metadata = {
  title: "Repair Cost Estimator & Problem Checker | Sharma Video Care Janakpur",
  description:
    "Instant repair cost calculator and problem diagnostic tool for AC, DSLR Cameras, LED TVs, Washing Machines, Drones, and Laptops in Janakpurdham, Nepal. Free physical inspection.",
  keywords: [
    "AC repair cost Janakpur",
    "Camera repair price Nepal",
    "TV backlight repair cost",
    "Washing machine repair Janakpurdham",
    "Drone repair estimate",
    "Sharma Video Care estimator",
  ],
};

export default function EstimatorPage() {
  return (
    <main
      style={{
        minHeight: "85vh",
        background: "#FBF9F5",
        padding: "32px 20px 80px 20px",
      }}
    >
      <RepairEstimator />
    </main>
  );
}
