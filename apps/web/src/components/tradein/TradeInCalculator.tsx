"use client";

import React, { useState, useMemo } from "react";
import Link from "next/link";
import { collection, addDoc } from "firebase/firestore";
import { db } from "../../lib/firebase";
import { useLanguage } from "@/context/LanguageContext";
import {
  TRADE_IN_MODELS,
  COSMETIC_CONDITIONS,
  FUNCTIONAL_CONDITIONS,
  SHUTTER_TIERS,
  ACCESSORY_BONUSES,
  TradeInModel,
} from "@/data/tradeInData";
import {
  Camera,
  Laptop,
  Plane,
  Smartphone,
  CheckCircle2,
  HelpCircle,
  Sparkles,
  ArrowRight,
  ShieldCheck,
  Building2,
  Truck,
  MessageCircle,
  PhoneCall,
  Check,
  RefreshCcw,
  Banknote,
  Gift,
  AlertCircle,
} from "lucide-react";

export const TradeInCalculator: React.FC = () => {
  const { language } = useLanguage();
  const isNe = language === "ne";

  // Category filter
  const [selectedCategory, setSelectedCategory] = useState<string>("camera");
  const [selectedModelId, setSelectedModelId] = useState<string>("cam-sony-a7iv");
  const [customModelName, setCustomModelName] = useState<string>("");
  const [isCustomModel, setIsCustomModel] = useState<boolean>(false);

  // Condition states
  const [cosmeticId, setCosmeticId] = useState<string>("mint");
  const [functionalId, setFunctionalId] = useState<string>("flawless");
  const [shutterId, setShutterId] = useState<string>("low");
  const [selectedAccessories, setSelectedAccessories] = useState<string[]>(["box", "charger"]);

  // Lead / Submission states
  const [customerName, setCustomerName] = useState<string>("");
  const [customerPhone, setCustomerPhone] = useState<string>("");
  const [customerCity, setCustomerCity] = useState<string>("Janakpur");
  const [fulfillmentType, setFulfillmentType] = useState<"COUNTER_DROP" | "COURIER_PICKUP">("COUNTER_DROP");
  const [notes, setNotes] = useState<string>("");

  const [submitting, setSubmitting] = useState<boolean>(false);
  const [submittedTicket, setSubmittedTicket] = useState<{ id: string; cashVal: string; creditVal: string } | null>(
    null
  );
  const [error, setError] = useState<string>("");

  // Filtered models for current category
  const categoryModels = useMemo(
    () => TRADE_IN_MODELS.filter((m) => m.category === selectedCategory),
    [selectedCategory]
  );

  // Current selected model
  const currentModel = useMemo(
    () => TRADE_IN_MODELS.find((m) => m.id === selectedModelId) || TRADE_IN_MODELS[0],
    [selectedModelId]
  );

  // Valuation calculation logic
  const valuation = useMemo(() => {
    const base = isCustomModel ? 100000 : currentModel.baseValuation;

    const cos = COSMETIC_CONDITIONS.find((c) => c.id === cosmeticId)?.multiplier || 1.0;
    const func = FUNCTIONAL_CONDITIONS.find((f) => f.id === functionalId)?.multiplier || 1.0;
    const shut = currentModel.shutterApplicable
      ? SHUTTER_TIERS.find((s) => s.id === shutterId)?.multiplier || 1.0
      : 1.0;

    // Total condition ratio
    const conditionRatio = cos * func * shut;

    // Accessories bonus
    const accessoriesBonus = selectedAccessories.reduce((acc, currId) => {
      const match = ACCESSORY_BONUSES.find((b) => b.id === currId);
      return acc + (match ? match.bonusAmount : 0);
    }, 0);

    const calculatedBase = Math.round(base * conditionRatio) + accessoriesBonus;

    // Price range (+/- 6%)
    const minCash = Math.round((calculatedBase * 0.94) / 500) * 500;
    const maxCash = Math.round((calculatedBase * 1.04) / 500) * 500;

    // Store credit gets +10% bonus
    const minCredit = Math.round(minCash * 1.1);
    const maxCredit = Math.round(maxCash * 1.1);

    return {
      minCash,
      maxCash,
      minCredit,
      maxCredit,
      conditionRatio,
      accessoriesBonus,
    };
  }, [currentModel, isCustomModel, cosmeticId, functionalId, shutterId, selectedAccessories]);

  const toggleAccessory = (id: string) => {
    setSelectedAccessories((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!customerName.trim() || !customerPhone.trim()) {
      setError(isNe ? "कृपया आफ्नो पूरा नाम र फोन नम्बर प्रविष्ट गर्नुहोस्।" : "Please enter your name and phone number.");
      return;
    }

    setSubmitting(true);
    setError("");

    try {
      const modelTitle = isCustomModel ? customModelName || "Custom Equipment" : currentModel.model;
      const cashStr = `Rs. ${valuation.minCash.toLocaleString("en-IN")} - ${valuation.maxCash.toLocaleString("en-IN")}`;
      const creditStr = `Rs. ${valuation.minCredit.toLocaleString("en-IN")} - ${valuation.maxCredit.toLocaleString("en-IN")}`;

      const docRef = await addDoc(collection(db, "tradeInRequests"), {
        customerName,
        customerPhone,
        customerCity,
        modelTitle,
        category: selectedCategory,
        cosmeticCondition: cosmeticId,
        functionalCondition: functionalId,
        shutterTier: shutterId,
        accessories: selectedAccessories,
        fulfillmentType,
        estimatedCashValuation: cashStr,
        estimatedCreditValuation: creditStr,
        customerNotes: notes,
        status: "PENDING_BENCH_TEST",
        createdAt: new Date().toISOString(),
      });

      setSubmittedTicket({
        id: docRef.id.slice(0, 8).toUpperCase(),
        cashVal: cashStr,
        creditVal: creditStr,
      });
    } catch (err: any) {
      console.error(err);
      setError(err?.message || "Failed to submit request. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  const whatsappShareUrl = useMemo(() => {
    if (!submittedTicket) return "";
    const modelTitle = isCustomModel ? customModelName || "Equipment" : currentModel.model;
    const text = isNe
      ? `नमस्ते Sharma Video Care! मैले ट्रेड-इन अनुरोध दर्ता गरेँ (Ticket: TRD-${submittedTicket.id}):\nउपकरण: ${modelTitle}\nअनुमानित नगद: ${submittedTicket.cashVal}\nट्रेड-इन भउचर: ${submittedTicket.creditVal}\nसम्पर्क: ${customerPhone} (${customerName})`
      : `Hello Sharma Video Care! I submitted a Trade-In request (Ticket: TRD-${submittedTicket.id}):\nDevice: ${modelTitle}\nEstimated Cash: ${submittedTicket.cashVal}\nStore Credit: ${submittedTicket.creditVal}\nContact: ${customerPhone} (${customerName})`;

    return `https://wa.me/9779854022200?text=${encodeURIComponent(text)}`;
  }, [submittedTicket, isCustomModel, customModelName, currentModel, customerName, customerPhone, isNe]);

  return (
    <div style={{ width: "100%", maxWidth: "1280px", margin: "0 auto" }}>
      {/* Header Banner */}
      <div
        style={{
          background: "linear-gradient(135deg, #0F172A 0%, #1E293B 100%)",
          borderRadius: "20px",
          padding: "36px 28px",
          color: "#FFFFFF",
          marginBottom: "28px",
          position: "relative",
          overflow: "hidden",
          border: "1px solid rgba(255, 255, 255, 0.08)",
          boxShadow: "0 10px 30px rgba(0, 0, 0, 0.15)",
        }}
      >
        <div style={{ position: "relative", zIndex: 2, maxWidth: "800px" }}>
          <div
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "8px",
              padding: "5px 12px",
              borderRadius: "999px",
              background: "rgba(16, 185, 129, 0.18)",
              border: "1px solid rgba(16, 185, 129, 0.4)",
              color: "#34D399",
              fontSize: "12px",
              fontWeight: 750,
              textTransform: "uppercase",
              letterSpacing: "0.06em",
              marginBottom: "14px",
            }}
          >
            <Banknote size={14} />
            <span>{isNe ? "तत्काल नगद भुक्तानी वा +१०% अपग्रेड बोनस" : "Instant Cash Payout or +10% Upgrade Bonus"}</span>
          </div>

          <h1
            style={{
              fontSize: "clamp(24px, 4vw, 36px)",
              fontWeight: 850,
              margin: "0 0 10px 0",
              letterSpacing: "-0.02em",
              lineHeight: 1.25,
            }}
          >
            {isNe
              ? "पुराना क्यामेरा र ग्याजेट बेच्नुहोस् वा अपग्रेड गर्नुहोस्"
              : "Sell Old Gear & Trade-In Valuation Calculator"}
          </h1>

          <p
            style={{
              fontSize: "15px",
              color: "#94A3B8",
              margin: 0,
              lineHeight: 1.6,
              maxWidth: "680px",
            }}
          >
            {isNe
              ? "आफ्नो प्रयोग गरिएको क्यामेरा, लेन्स, ल्यापटप वा ड्रोनको अवस्था छान्नुहोस् र तुरुन्तै पारदर्शी बजार मूल्य जान्नुहोस्। जनकपुरधाम काउन्टरमा तत्काल नगद पाउनुहोस् वा नयाँ गियरमा +१०% थप बोनससहित एक्सचेन्ज गर्नुहोस्।"
              : "Calculate the exact market value of your used cameras, lenses, laptops, or drones in seconds. Get instant cash payout at our Janakpur bench or get +10% bonus credit toward upgrading your gear."}
          </p>
        </div>
      </div>

      {submittedTicket ? (
        /* Success / Ticket Confirmation Screen */
        <div
          style={{
            background: "#FFFFFF",
            borderRadius: "18px",
            border: "1px solid #E2E8F0",
            padding: "40px 24px",
            textAlign: "center",
            maxWidth: "680px",
            margin: "0 auto",
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.05)",
          }}
        >
          <div
            style={{
              width: "60px",
              height: "60px",
              borderRadius: "50%",
              background: "#ECFDF5",
              color: "#059669",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              margin: "0 auto 16px auto",
            }}
          >
            <CheckCircle2 size={34} />
          </div>

          <h2 style={{ fontSize: "22px", fontWeight: 800, color: "#0F172A", margin: "0 0 6px 0" }}>
            {isNe ? "ट्रेड-इन अनुरोध सफलतापूर्वक दर्ता भयो!" : "Trade-In Valuation Submitted!"}
          </h2>

          <div
            style={{
              display: "inline-block",
              background: "#F1F5F9",
              padding: "4px 12px",
              borderRadius: "6px",
              fontSize: "13px",
              fontWeight: 700,
              color: "#334155",
              marginBottom: "20px",
            }}
          >
            Ticket ID: <strong>TRD-{submittedTicket.id}</strong>
          </div>

          {/* Valuations Box */}
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "1fr 1fr",
              gap: "14px",
              background: "#F8FAFC",
              border: "1px solid #E2E8F0",
              borderRadius: "12px",
              padding: "18px",
              marginBottom: "24px",
              textAlign: "left",
            }}
          >
            <div>
              <div style={{ fontSize: "11.5px", color: "#64748B", fontWeight: 700, textTransform: "uppercase" }}>
                {isNe ? "नगद भुक्तानी अनुमान" : "Cash Payout"}
              </div>
              <div style={{ fontSize: "18px", fontWeight: 850, color: "#0F172A", marginTop: "2px" }}>
                {submittedTicket.cashVal}
              </div>
              <div style={{ fontSize: "11px", color: "#16A34A", marginTop: "2px" }}>
                {isNe ? "तत्काल बैंक / eSewa ट्रान्सफर" : "Direct Bank / eSewa"}
              </div>
            </div>

            <div style={{ borderLeft: "1px solid #E2E8F0", paddingLeft: "14px" }}>
              <div style={{ fontSize: "11.5px", color: "#E86F1C", fontWeight: 700, textTransform: "uppercase" }}>
                {isNe ? "स्टोर क्रेडिट (+१०% बोनस)" : "Store Credit (+10% Bonus)"}
              </div>
              <div style={{ fontSize: "18px", fontWeight: 850, color: "#E86F1C", marginTop: "2px" }}>
                {submittedTicket.creditVal}
              </div>
              <div style={{ fontSize: "11px", color: "#64748B", marginTop: "2px" }}>
                {isNe ? "नयाँ वा प्रमाणित गियरमा प्रयोग" : "Upgrade to Any Store Item"}
              </div>
            </div>
          </div>

          <p style={{ fontSize: "13.5px", color: "#64748B", lineHeight: 1.6, marginBottom: "24px" }}>
            {isNe
              ? "हाम्रो प्राविधिक टोलीले तपाईंको अनुरोध समीक्षा गर्नेछ। कृपया तलको ह्वाट्सएप बटन थिचेर उपकरणको फोटो पठाउनुहोस् वा जनकपुरधाम स्टेसन रोड काउन्टरमा ल्याउनुहोस्।"
              : "Our hardware technician will review your specifications. Click WhatsApp below to share photos of your gear or bring it to our Station Road center for 15-minute bench testing & payment."}
          </p>

          <div style={{ display: "flex", gap: "10px", justifyContent: "center", flexWrap: "wrap" }}>
            <a
              href={whatsappShareUrl}
              target="_blank"
              rel="noopener noreferrer"
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "8px",
                background: "#25D366",
                color: "#FFFFFF",
                padding: "10px 20px",
                borderRadius: "8px",
                fontSize: "13px",
                fontWeight: 750,
                textDecoration: "none",
              }}
            >
              <MessageCircle size={16} />
              <span>{isNe ? "ह्वाट्सएपमा फोटो पठाउनुहोस्" : "Send Photos on WhatsApp"}</span>
            </a>

            <button
              type="button"
              onClick={() => setSubmittedTicket(null)}
              style={{
                background: "#F1F5F9",
                color: "#334155",
                border: "none",
                padding: "10px 18px",
                borderRadius: "8px",
                fontSize: "13px",
                fontWeight: 700,
                cursor: "pointer",
              }}
            >
              {isNe ? "अर्को उपकरण जाँच्नुहोस्" : "Calculate Another Device"}
            </button>
          </div>
        </div>
      ) : (
        /* Main Calculator Interface */
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "minmax(0, 1.35fr) minmax(320px, 0.95fr)",
            gap: "28px",
            alignItems: "start",
          }}
          className="estimator-grid"
        >
          {/* Left Column: Form & Conditions */}
          <div>
            {/* Step 1: Category & Device Picker */}
            <div style={{ marginBottom: "24px" }}>
              <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "12px" }}>
                <span
                  style={{
                    width: "24px",
                    height: "24px",
                    borderRadius: "50%",
                    background: "#E86F1C",
                    color: "#FFFFFF",
                    display: "inline-flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: "12px",
                    fontWeight: 800,
                  }}
                >
                  1
                </span>
                <h2 style={{ fontSize: "15px", fontWeight: 750, color: "#181512", margin: 0, textTransform: "uppercase" }}>
                  {isNe ? "उपकरणको कोटि र मोडल छान्नुहोस्" : "Select Equipment Category & Model"}
                </h2>
              </div>

              {/* Category Pills */}
              <div style={{ display: "flex", gap: "8px", flexWrap: "wrap", marginBottom: "14px" }}>
                {[
                  { id: "camera", label: "Cameras", labelNe: "क्यामेरा", icon: Camera },
                  { id: "lens", label: "Lenses", labelNe: "लेन्स", icon: Camera },
                  { id: "laptop", label: "Laptops", labelNe: "ल्यापटप", icon: Laptop },
                  { id: "drone", label: "Drones", labelNe: "ड्रोन", icon: Plane },
                  { id: "mobile", label: "Mobiles", labelNe: "मोबाइल", icon: Smartphone },
                ].map((c) => {
                  const isSelected = selectedCategory === c.id;
                  const Icon = c.icon;
                  return (
                    <button
                      key={c.id}
                      type="button"
                      onClick={() => {
                        setSelectedCategory(c.id);
                        setIsCustomModel(false);
                        const firstInCat = TRADE_IN_MODELS.find((m) => m.category === c.id);
                        if (firstInCat) setSelectedModelId(firstInCat.id);
                      }}
                      style={{
                        display: "inline-flex",
                        alignItems: "center",
                        gap: "6px",
                        padding: "8px 14px",
                        borderRadius: "10px",
                        border: isSelected ? "2px solid #E86F1C" : "1px solid #CBD5E1",
                        background: isSelected ? "#FFF7F2" : "#FFFFFF",
                        color: isSelected ? "#E86F1C" : "#475569",
                        fontWeight: isSelected ? 750 : 600,
                        fontSize: "13px",
                        cursor: "pointer",
                      }}
                    >
                      <Icon size={15} />
                      <span>{isNe ? c.labelNe : c.label}</span>
                    </button>
                  );
                })}
              </div>

              {/* Model Dropdown or Selection */}
              <div
                style={{
                  background: "#FFFFFF",
                  border: "1px solid #ECE7E0",
                  borderRadius: "12px",
                  padding: "16px",
                }}
              >
                {!isCustomModel ? (
                  <div>
                    <label style={{ display: "block", fontSize: "12px", fontWeight: 700, color: "#64748B", marginBottom: "6px" }}>
                      {isNe ? "प्रचलित मोडलहरू:" : "Select Model from Catalog:"}
                    </label>
                    <select
                      value={selectedModelId}
                      onChange={(e) => setSelectedModelId(e.target.value)}
                      style={{
                        width: "100%",
                        padding: "10px 12px",
                        borderRadius: "8px",
                        border: "1px solid #CBD5E1",
                        fontSize: "13.5px",
                        fontWeight: 600,
                        color: "#0F172A",
                        background: "#F8FAFC",
                        outline: "none",
                        marginBottom: "10px",
                      }}
                    >
                      {categoryModels.map((m) => (
                        <option key={m.id} value={m.id}>
                          {m.brand} • {m.model}
                        </option>
                      ))}
                    </select>

                    <button
                      type="button"
                      onClick={() => setIsCustomModel(true)}
                      style={{
                        background: "none",
                        border: "none",
                        color: "#E86F1C",
                        fontSize: "12px",
                        fontWeight: 700,
                        cursor: "pointer",
                        padding: 0,
                      }}
                    >
                      + {isNe ? "तपाईंको मोडल सूचीमा छैन? यहाँ लेख्नुहोस्" : "Device not listed? Enter custom model"}
                    </button>
                  </div>
                ) : (
                  <div>
                    <label style={{ display: "block", fontSize: "12px", fontWeight: 700, color: "#64748B", marginBottom: "6px" }}>
                      {isNe ? "उपकरणको नाम र ब्रान्ड टाइप गर्नुहोस्:" : "Enter Brand and Model Name:"}
                    </label>
                    <input
                      type="text"
                      placeholder="e.g. Sony FX3, Nikon Z6 III, MacBook Pro M1 Max..."
                      value={customModelName}
                      onChange={(e) => setCustomModelName(e.target.value)}
                      style={{
                        width: "100%",
                        padding: "9px 12px",
                        borderRadius: "8px",
                        border: "1px solid #CBD5E1",
                        fontSize: "13.5px",
                        color: "#0F172A",
                        outline: "none",
                        marginBottom: "8px",
                      }}
                    />
                    <button
                      type="button"
                      onClick={() => setIsCustomModel(false)}
                      style={{
                        background: "none",
                        border: "none",
                        color: "#64748B",
                        fontSize: "12px",
                        cursor: "pointer",
                        padding: 0,
                      }}
                    >
                      ← {isNe ? "सूचीबाट छान्नुहोस्" : "Back to catalog list"}
                    </button>
                  </div>
                )}
              </div>
            </div>

            {/* Step 2: Condition Assessment */}
            <div style={{ marginBottom: "24px" }}>
              <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "12px" }}>
                <span
                  style={{
                    width: "24px",
                    height: "24px",
                    borderRadius: "50%",
                    background: "#0F172A",
                    color: "#FFFFFF",
                    display: "inline-flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: "12px",
                    fontWeight: 800,
                  }}
                >
                  2
                </span>
                <h2 style={{ fontSize: "15px", fontWeight: 750, color: "#181512", margin: 0, textTransform: "uppercase" }}>
                  {isNe ? "शारीरिक तथा प्राविधिक अवस्था" : "Physical & Functional Condition"}
                </h2>
              </div>

              {/* A. Cosmetic Condition */}
              <div style={{ marginBottom: "16px" }}>
                <div style={{ fontSize: "12.5px", fontWeight: 700, color: "#475569", marginBottom: "8px" }}>
                  {isNe ? "१. बाहिरी स्क्र्याच / शारीरिक अवस्था:" : "A. Cosmetic Condition (Scratches & Body Wear):"}
                </div>
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "8px" }}>
                  {COSMETIC_CONDITIONS.map((c) => {
                    const isSelected = cosmeticId === c.id;
                    return (
                      <div
                        key={c.id}
                        onClick={() => setCosmeticId(c.id)}
                        style={{
                          padding: "10px 12px",
                          borderRadius: "10px",
                          border: isSelected ? "2px solid #E86F1C" : "1px solid #E2E8F0",
                          background: isSelected ? "#FFF7F2" : "#FFFFFF",
                          cursor: "pointer",
                        }}
                      >
                        <div style={{ fontSize: "12.5px", fontWeight: 750, color: isSelected ? "#E86F1C" : "#0F172A" }}>
                          {isNe ? c.labelNe : c.label}
                        </div>
                        <div style={{ fontSize: "11px", color: "#64748B", marginTop: "2px" }}>
                          {isNe ? c.descNe : c.desc}
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* B. Functionality */}
              <div style={{ marginBottom: "16px" }}>
                <div style={{ fontSize: "12.5px", fontWeight: 700, color: "#475569", marginBottom: "8px" }}>
                  {isNe ? "२. प्राविधिक तथा कार्यक्षमता अवस्था:" : "B. Functional & Working Status:"}
                </div>
                <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))", gap: "8px" }}>
                  {FUNCTIONAL_CONDITIONS.map((f) => {
                    const isSelected = functionalId === f.id;
                    return (
                      <div
                        key={f.id}
                        onClick={() => setFunctionalId(f.id)}
                        style={{
                          padding: "10px 12px",
                          borderRadius: "10px",
                          border: isSelected ? "2px solid #E86F1C" : "1px solid #E2E8F0",
                          background: isSelected ? "#FFF7F2" : "#FFFFFF",
                          cursor: "pointer",
                        }}
                      >
                        <div style={{ fontSize: "12.5px", fontWeight: 750, color: isSelected ? "#E86F1C" : "#0F172A" }}>
                          {isNe ? f.labelNe : f.label}
                        </div>
                        <div style={{ fontSize: "11px", color: "#64748B", marginTop: "2px" }}>
                          {isNe ? f.descNe : f.desc}
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* C. Shutter Count (if Camera) */}
              {currentModel.shutterApplicable && (
                <div style={{ marginBottom: "16px" }}>
                  <div style={{ fontSize: "12.5px", fontWeight: 700, color: "#475569", marginBottom: "8px" }}>
                    {isNe ? "३. क्यामेरा सटर काउन्ट (Shutter Count):" : "C. Shutter Count Range:"}
                  </div>
                  <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "8px" }}>
                    {SHUTTER_TIERS.map((s) => {
                      const isSelected = shutterId === s.id;
                      return (
                        <div
                          key={s.id}
                          onClick={() => setShutterId(s.id)}
                          style={{
                            padding: "8px 12px",
                            borderRadius: "10px",
                            border: isSelected ? "2px solid #E86F1C" : "1px solid #E2E8F0",
                            background: isSelected ? "#FFF7F2" : "#FFFFFF",
                            cursor: "pointer",
                          }}
                        >
                          <div style={{ fontSize: "12px", fontWeight: 750, color: isSelected ? "#E86F1C" : "#0F172A" }}>
                            {isNe ? s.labelNe : s.label}
                          </div>
                        </div>
                      );
                    })}
                  </div>
                </div>
              )}

              {/* D. Included Accessories Checklist */}
              <div>
                <div style={{ fontSize: "12.5px", fontWeight: 700, color: "#475569", marginBottom: "8px" }}>
                  {isNe ? "४. समावेश भएका सामानहरू (+बोनस मूल्य थपिन्छ):" : "D. Included Accessories (+Bonus Cash):"}
                </div>
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "8px" }}>
                  {ACCESSORY_BONUSES.map((b) => {
                    const isChecked = selectedAccessories.includes(b.id);
                    return (
                      <label
                        key={b.id}
                        style={{
                          display: "flex",
                          alignItems: "center",
                          gap: "8px",
                          padding: "8px 12px",
                          borderRadius: "8px",
                          background: isChecked ? "#ECFDF5" : "#F8FAFC",
                          border: isChecked ? "1px solid #A7F3D0" : "1px solid #E2E8F0",
                          cursor: "pointer",
                          fontSize: "12px",
                          fontWeight: 650,
                          color: isChecked ? "#065F46" : "#475569",
                        }}
                      >
                        <input
                          type="checkbox"
                          checked={isChecked}
                          onChange={() => toggleAccessory(b.id)}
                        />
                        <span>{isNe ? b.nameNe : b.name} (+रु. {b.bonusAmount.toLocaleString("en-IN")})</span>
                      </label>
                    );
                  })}
                </div>
              </div>
            </div>

            {/* Step 3: Fulfillment & Customer Details */}
            <div
              style={{
                background: "#FFFFFF",
                borderRadius: "14px",
                border: "1px solid #E2E8F0",
                padding: "20px",
                marginBottom: "24px",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "16px" }}>
                <span
                  style={{
                    width: "24px",
                    height: "24px",
                    borderRadius: "50%",
                    background: "#0F172A",
                    color: "#FFFFFF",
                    display: "inline-flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: "12px",
                    fontWeight: 800,
                  }}
                >
                  3
                </span>
                <h2 style={{ fontSize: "15px", fontWeight: 750, color: "#181512", margin: 0, textTransform: "uppercase" }}>
                  {isNe ? "डेलिभरी माध्यम र सम्पर्क विवरण" : "Drop-Off Method & Contact"}
                </h2>
              </div>

              {/* Fulfillment Option Radio Cards */}
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "10px", marginBottom: "16px" }}>
                <div
                  onClick={() => setFulfillmentType("COUNTER_DROP")}
                  style={{
                    padding: "12px",
                    borderRadius: "10px",
                    border: fulfillmentType === "COUNTER_DROP" ? "2px solid #E86F1C" : "1px solid #E2E8F0",
                    background: fulfillmentType === "COUNTER_DROP" ? "#FFF7F2" : "#F8FAFC",
                    cursor: "pointer",
                  }}
                >
                  <div style={{ display: "flex", alignItems: "center", gap: "6px", fontWeight: 750, fontSize: "13px", color: "#0F172A" }}>
                    <Building2 size={16} color="#E86F1C" />
                    <span>{isNe ? "जनकपुरधाम काउन्टर" : "Janakpur Counter Drop"}</span>
                  </div>
                  <div style={{ fontSize: "11px", color: "#64748B", marginTop: "4px" }}>
                    {isNe ? "स्टेसन रोड वर्कशपमा १५ मिनेटमै चेकअप र भुक्तानी।" : "Instant 15-min bench testing & same-day payout."}
                  </div>
                </div>

                <div
                  onClick={() => setFulfillmentType("COURIER_PICKUP")}
                  style={{
                    padding: "12px",
                    borderRadius: "10px",
                    border: fulfillmentType === "COURIER_PICKUP" ? "2px solid #E86F1C" : "1px solid #E2E8F0",
                    background: fulfillmentType === "COURIER_PICKUP" ? "#FFF7F2" : "#F8FAFC",
                    cursor: "pointer",
                  }}
                >
                  <div style={{ display: "flex", alignItems: "center", gap: "6px", fontWeight: 750, fontSize: "13px", color: "#0F172A" }}>
                    <Truck size={16} color="#16A34A" />
                    <span>{isNe ? "नेपालभर सुरक्षित कुरियर पिकअप" : "Nationwide Courier Pickup"}</span>
                  </div>
                  <div style={{ fontSize: "11px", color: "#64748B", marginTop: "4px" }}>
                    {isNe ? "काठमाडौँ, पोखरा, विराटनगर आदिबाट घरमै कुरियर।" : "Insured transit pickup across all districts."}
                  </div>
                </div>
              </div>

              {/* Form Input Fields */}
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "10px", marginBottom: "12px" }}>
                <div>
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 700, color: "#64748B", marginBottom: "4px" }}>
                    {isNe ? "तपाईंको पूरा नाम *" : "Your Full Name *"}
                  </label>
                  <input
                    type="text"
                    required
                    value={customerName}
                    onChange={(e) => setCustomerName(e.target.value)}
                    placeholder="e.g. Ramesh Sharma"
                    style={{
                      width: "100%",
                      padding: "8px 12px",
                      borderRadius: "6px",
                      border: "1px solid #CBD5E1",
                      fontSize: "13px",
                      outline: "none",
                    }}
                  />
                </div>

                <div>
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 700, color: "#64748B", marginBottom: "4px" }}>
                    {isNe ? "सम्पर्क फोन / ह्वाट्सएप *" : "Contact Phone Number *"}
                  </label>
                  <input
                    type="tel"
                    required
                    value={customerPhone}
                    onChange={(e) => setCustomerPhone(e.target.value)}
                    placeholder="e.g. 9854022200"
                    style={{
                      width: "100%",
                      padding: "8px 12px",
                      borderRadius: "6px",
                      border: "1px solid #CBD5E1",
                      fontSize: "13px",
                      outline: "none",
                    }}
                  />
                </div>
              </div>

              <div style={{ marginBottom: "12px" }}>
                <label style={{ display: "block", fontSize: "12px", fontWeight: 700, color: "#64748B", marginBottom: "4px" }}>
                  {isNe ? "सहर / जिल्ला" : "Your City / District"}
                </label>
                <input
                  type="text"
                  value={customerCity}
                  onChange={(e) => setCustomerCity(e.target.value)}
                  placeholder="e.g. Janakpurdham, Kathmandu, Biratnagar"
                  style={{
                    width: "100%",
                    padding: "8px 12px",
                    borderRadius: "6px",
                    border: "1px solid #CBD5E1",
                    fontSize: "13px",
                    outline: "none",
                  }}
                />
              </div>

              {error && (
                <div style={{ padding: "8px 12px", background: "#FEF2F2", border: "1px solid #FCA5A5", color: "#DC2626", borderRadius: "6px", fontSize: "12px", marginBottom: "12px" }}>
                  <AlertCircle size={14} style={{ display: "inline", marginRight: "4px" }} />
                  {error}
                </div>
              )}

              <button
                type="button"
                onClick={handleSubmit}
                disabled={submitting}
                style={{
                  width: "100%",
                  padding: "12px",
                  borderRadius: "8px",
                  background: "#E86F1C",
                  color: "#FFFFFF",
                  border: "none",
                  fontSize: "14px",
                  fontWeight: 750,
                  cursor: "pointer",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  gap: "8px",
                  boxShadow: "0 4px 12px rgba(232, 111, 28, 0.25)",
                }}
              >
                <span>{submitting ? (isNe ? "अनुरोध पठाइँदैछ..." : "Submitting...") : (isNe ? "यो मूल्यमा ट्रेड-इन अनुरोध दर्ता गर्नुहोस्" : "Lock In Valuation & Request Payout")}</span>
                <ArrowRight size={16} />
              </button>
            </div>
          </div>

          {/* Right Column: Live Dual Valuation Card */}
          <div style={{ position: "sticky", top: "90px" }}>
            <div
              style={{
                background: "#FFFFFF",
                borderRadius: "18px",
                border: "1px solid #E5DFD5",
                boxShadow: "0 10px 30px rgba(0, 0, 0, 0.05)",
                overflow: "hidden",
              }}
            >
              {/* Header */}
              <div
                style={{
                  background: "linear-gradient(135deg, #FAF7F2 0%, #F5EFE6 100%)",
                  borderBottom: "1px solid #ECE4D8",
                  padding: "20px",
                }}
              >
                <div style={{ fontSize: "11px", fontWeight: 750, color: "#E86F1C", textTransform: "uppercase" }}>
                  {isNe ? "तत्काल मूल्यांकन सारांश" : "Instant Valuation Summary"}
                </div>
                <h3 style={{ fontSize: "17px", fontWeight: 800, color: "#0F172A", margin: "4px 0 0 0" }}>
                  {isCustomModel ? customModelName || "Custom Device" : currentModel.model}
                </h3>
              </div>

              {/* Body */}
              <div style={{ padding: "20px" }}>
                {/* 1. Cash Buyout Option */}
                <div
                  style={{
                    background: "#F8FAFC",
                    border: "1px solid #E2E8F0",
                    borderRadius: "12px",
                    padding: "16px",
                    marginBottom: "14px",
                  }}
                >
                  <div style={{ display: "flex", alignItems: "center", gap: "6px", color: "#0F172A", fontWeight: 750, fontSize: "13px" }}>
                    <Banknote size={16} color="#16A34A" />
                    <span>{isNe ? "विकल्प १: सिधै नगद भुक्तानी" : "Option 1: Direct Cash Buyout"}</span>
                  </div>
                  <div style={{ fontSize: "24px", fontWeight: 850, color: "#0F172A", fontVariantNumeric: "tabular-nums", margin: "6px 0 2px 0" }}>
                    Rs. {valuation.minCash.toLocaleString("en-IN")} – {valuation.maxCash.toLocaleString("en-IN")}
                  </div>
                  <div style={{ fontSize: "11.5px", color: "#64748B" }}>
                    {isNe ? "काउन्टर परीक्षणपछि तुरुन्तै बैंक / eSewa / नगद भुक्तानी।" : "Same-day cash into your account after inspection."}
                  </div>
                </div>

                {/* 2. Trade-In Store Credit (+10% Bonus) */}
                <div
                  style={{
                    background: "#FFF8F2",
                    border: "2px solid #FED7AA",
                    borderRadius: "12px",
                    padding: "16px",
                    marginBottom: "20px",
                    position: "relative",
                  }}
                >
                  <div
                    style={{
                      position: "absolute",
                      top: "-10px",
                      right: "12px",
                      background: "#E86F1C",
                      color: "#FFFFFF",
                      fontSize: "10px",
                      fontWeight: 800,
                      padding: "2px 8px",
                      borderRadius: "999px",
                    }}
                  >
                    +10% EXTRA VALUE
                  </div>

                  <div style={{ display: "flex", alignItems: "center", gap: "6px", color: "#E86F1C", fontWeight: 750, fontSize: "13px" }}>
                    <Gift size={16} color="#E86F1C" />
                    <span>{isNe ? "विकल्प २: स्टोर अपग्रेड भउचर (+१०% बोनस)" : "Option 2: Store Upgrade Voucher"}</span>
                  </div>
                  <div style={{ fontSize: "24px", fontWeight: 850, color: "#E86F1C", fontVariantNumeric: "tabular-nums", margin: "6px 0 2px 0" }}>
                    Rs. {valuation.minCredit.toLocaleString("en-IN")} – {valuation.maxCredit.toLocaleString("en-IN")}
                  </div>
                  <div style={{ fontSize: "11.5px", color: "#78716C" }}>
                    {isNe ? "स्टोरका नयाँ क्यामेरा, ल्यापटप वा सेकेन्ड-ह्यान्ड किन्न प्रयोग गर्नुहोस्।" : "Use toward any new gear in Store or Certified Pre-Owned."}
                  </div>
                </div>

                {/* Trust Points */}
                <div style={{ display: "flex", flexDirection: "column", gap: "8px", fontSize: "12px", color: "#475569" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                    <ShieldCheck size={14} color="#16A34A" />
                    <span>{isNe ? "१००% पारदर्शी ल्याब डायग्नोस्टिक" : "100% Transparent Bench Inspection"}</span>
                  </div>
                  <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                    <Building2 size={14} color="#E86F1C" />
                    <span>{isNe ? "स्टेसन रोड, जनकपुरधाममा प्रत्यक्ष काउन्टर" : "Walk-in Counter at Station Road, Janakpur"}</span>
                  </div>
                  <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                    <Truck size={14} color="#2563EB" />
                    <span>{isNe ? "नेपालभर सुरक्षित पिकअप सेवा" : "Doorstep Courier Pickup Across Nepal"}</span>
                  </div>
                </div>

                {/* Direct WhatsApp Callout */}
                <div style={{ marginTop: "20px", borderTop: "1px solid #F1F5F9", paddingTop: "14px" }}>
                  <a
                    href="https://wa.me/9779854022200?text=Hello%20Sharma%20Video%20Care,%20I%20want%20to%20sell/trade-in%20my%20camera%20gear."
                    target="_blank"
                    rel="noopener noreferrer"
                    style={{
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      gap: "6px",
                      color: "#16A34A",
                      fontSize: "12.5px",
                      fontWeight: 700,
                      textDecoration: "none",
                    }}
                  >
                    <MessageCircle size={15} />
                    <span>{isNe ? "ह्वाट्सएप हटलाइन: ९८५४०२२२००" : "Inquire Directly on WhatsApp"}</span>
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default TradeInCalculator;
