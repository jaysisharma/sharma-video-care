"use client";

import React, { useState, useMemo } from "react";
import Link from "next/link";
import { useLanguage } from "@/context/LanguageContext";
import { ESTIMATOR_DEVICES, EstimatorDevice, SymptomOption } from "@/data/estimatorData";
import {
  Wind,
  Camera,
  Tv,
  Activity,
  Plane,
  Laptop,
  Shield,
  Wrench,
  Hammer,
  Search,
  CheckCircle2,
  Clock,
  ShieldCheck,
  MapPin,
  ArrowRight,
  PhoneCall,
  MessageCircle,
  HelpCircle,
  Sparkles,
  RefreshCw,
  SlidersHorizontal,
  Home,
  Check,
} from "lucide-react";

// Icon mapping helper
const renderDeviceIcon = (iconName: string, size = 22, color = "currentColor") => {
  switch (iconName) {
    case "Wind":
      return <Wind size={size} color={color} />;
    case "Camera":
      return <Camera size={size} color={color} />;
    case "Tv":
      return <Tv size={size} color={color} />;
    case "Activity":
      return <Activity size={size} color={color} />;
    case "Plane":
      return <Plane size={size} color={color} />;
    case "Laptop":
      return <Laptop size={size} color={color} />;
    case "Shield":
      return <Shield size={size} color={color} />;
    case "Wrench":
      return <Wrench size={size} color={color} />;
    case "Hammer":
      return <Hammer size={size} color={color} />;
    default:
      return <Wrench size={size} color={color} />;
  }
};

export const RepairEstimator: React.FC = () => {
  const { language } = useLanguage();
  const isNe = language === "ne";

  // State
  const [selectedDeviceId, setSelectedDeviceId] = useState<string>("device-ac");
  const [selectedBrand, setSelectedBrand] = useState<string>("All Brands");
  const [selectedSymptomId, setSelectedSymptomId] = useState<string>("ac-no-cooling");
  const [searchQuery, setSearchQuery] = useState<string>("");

  // Current selected device
  const currentDevice = useMemo(
    () => ESTIMATOR_DEVICES.find((d) => d.id === selectedDeviceId) || ESTIMATOR_DEVICES[0],
    [selectedDeviceId]
  );

  // Symptoms matching device & search query
  const filteredSymptoms = useMemo(() => {
    let symptoms = currentDevice.symptoms;

    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase().trim();
      symptoms = symptoms.filter(
        (s) =>
          s.title.toLowerCase().includes(q) ||
          s.titleNe.toLowerCase().includes(q) ||
          s.desc.toLowerCase().includes(q) ||
          s.descNe.toLowerCase().includes(q)
      );
    }
    return symptoms;
  }, [currentDevice, searchQuery]);

  // Selected symptom object
  const currentSymptom = useMemo(() => {
    const found = currentDevice.symptoms.find((s) => s.id === selectedSymptomId);
    return found || currentDevice.symptoms[0];
  }, [currentDevice, selectedSymptomId]);

  // When device changes, reset to its first symptom
  const handleSelectDevice = (device: EstimatorDevice) => {
    setSelectedDeviceId(device.id);
    setSelectedBrand("All Brands");
    setSelectedSymptomId(device.symptoms[0]?.id || "");
    setSearchQuery("");
  };

  // WhatsApp prefilled message
  const whatsappHref = useMemo(() => {
    const devName = isNe ? currentDevice.nameNe : currentDevice.name;
    const sympName = isNe ? currentSymptom.titleNe : currentSymptom.title;
    const brandText = selectedBrand !== "All Brands" ? ` (${selectedBrand})` : "";
    const minP = currentSymptom.minPrice.toLocaleString("en-IN");
    const maxP = currentSymptom.maxPrice.toLocaleString("en-IN");

    const text = isNe
      ? `नमस्ते Sharma Video Care! मैले वेबसाइटबाट खर्च अनुमान हेरेँ: उपकरण: ${devName}${brandText}, समस्या: ${sympName}, अनुमानित खर्च: रु. ${minP} - ${maxP}। के प्राविधिक उपलब्ध हुनुहुन्छ?`
      : `Hello Sharma Video Care! I used your online estimator for ${devName}${brandText}. Issue: ${sympName}. Estimated Cost: Rs. ${minP} - ${maxP}. Can you confirm repair booking availability?`;

    return `https://wa.me/9779854022200?text=${encodeURIComponent(text)}`;
  }, [currentDevice, currentSymptom, selectedBrand, isNe]);

  // Booking Page URL with query parameters
  const bookingHref = useMemo(() => {
    const params = new URLSearchParams({
      category: currentDevice.slug,
      title: currentDevice.categoryTitle,
      model: selectedBrand !== "All Brands" ? selectedBrand : currentDevice.name,
      symptom: isNe ? currentSymptom.titleNe : currentSymptom.title,
      estimate: `Rs. ${currentSymptom.minPrice.toLocaleString("en-IN")} - ${currentSymptom.maxPrice.toLocaleString("en-IN")}`,
    });
    return `/services/request?${params.toString()}`;
  }, [currentDevice, currentSymptom, selectedBrand, isNe]);

  return (
    <div style={{ width: "100%", maxWidth: "1280px", margin: "0 auto" }}>
      {/* Hero Header */}
      <div
        style={{
          background: "linear-gradient(135deg, #181512 0%, #292019 100%)",
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
              background: "rgba(232, 111, 28, 0.2)",
              border: "1px solid rgba(232, 111, 28, 0.4)",
              color: "#FF8C38",
              fontSize: "12px",
              fontWeight: 750,
              textTransform: "uppercase",
              letterSpacing: "0.06em",
              marginBottom: "14px",
            }}
          >
            <Sparkles size={14} />
            <span>{isNe ? "निःशुल्क डिजिटल आत्म-परीक्षण टुल" : "Free Instant Self-Diagnosis Tool"}</span>
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
              ? "इलेक्ट्रोनिक्स तथा उपकरण मर्मत खर्च अनुमान"
              : "Interactive Repair Cost Estimator & Problem Checker"}
          </h1>

          <p
            style={{
              fontSize: "15px",
              color: "#C7BEB5",
              margin: 0,
              lineHeight: 1.6,
              maxWidth: "680px",
            }}
          >
            {isNe
              ? "तपाईंको उपकरण र देखिने समस्या छान्नुहोस् — तत्काल पारदर्शी मूल्य दायरा, लाग्ने समय र आधिकारिक वारेन्टी विवरण जान्नुहोस्। जनकपुरधाम वर्कशपमा प्रत्यक्ष चेकअप पूर्ण रूपमा निःशुल्क छ।"
              : "Select your appliance or gadget symptoms to calculate accurate repair cost ranges, turnaround time, and warranty terms before booking a visit. Physical bench diagnosis in Janakpur is 100% free."}
          </p>
        </div>

        {/* Decorative Badge Right */}
        <div
          style={{
            position: "absolute",
            right: "24px",
            bottom: "24px",
            display: "none",
            background: "rgba(255, 255, 255, 0.05)",
            backdropFilter: "blur(10px)",
            border: "1px solid rgba(255, 255, 255, 0.1)",
            padding: "12px 18px",
            borderRadius: "12px",
          }}
          className="estimator-hero-badge"
        >
          <div style={{ fontSize: "11px", color: "#A89F95", textTransform: "uppercase", fontWeight: 700 }}>
            {isNe ? "जनकपुर ग्यारेन्टी" : "Janakpur Guarantee"}
          </div>
          <div style={{ fontSize: "14px", fontWeight: 800, color: "#FF8C38", marginTop: "2px" }}>
            {isNe ? "९०-दिने आधिकारिक वारेन्टी" : "90-Day Official Warranty"}
          </div>
        </div>
      </div>

      {/* Main 2-Column Interface: Left Wizard + Right Live Calculation Card */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "minmax(0, 1.35fr) minmax(320px, 0.95fr)",
          gap: "28px",
          alignItems: "start",
        }}
        className="estimator-grid"
      >
        {/* Left Column: Device Selector & Symptom Cards */}
        <div>
          {/* Step 1: Device Selector Pills / Cards */}
          <div style={{ marginBottom: "24px" }}>
            <div
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                marginBottom: "12px",
              }}
            >
              <h2
                style={{
                  fontSize: "15px",
                  fontWeight: 750,
                  color: "#181512",
                  margin: 0,
                  textTransform: "uppercase",
                  letterSpacing: "0.04em",
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                }}
              >
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
                {isNe ? "उपकरण छान्नुहोस्" : "Select Device Type"}
              </h2>

              <span style={{ fontSize: "12px", color: "#78716C", fontWeight: 600 }}>
                {ESTIMATOR_DEVICES.length} {isNe ? "उपलब्ध कोटिहरू" : "Categories"}
              </span>
            </div>

            {/* Grid of Devices */}
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fill, minmax(130px, 1fr))",
                gap: "10px",
              }}
            >
              {ESTIMATOR_DEVICES.map((device) => {
                const isSelected = device.id === selectedDeviceId;
                return (
                  <button
                    key={device.id}
                    type="button"
                    onClick={() => handleSelectDevice(device)}
                    style={{
                      display: "flex",
                      flexDirection: "column",
                      alignItems: "center",
                      justifyContent: "center",
                      padding: "14px 10px",
                      borderRadius: "12px",
                      border: isSelected ? "2px solid #E86F1C" : "1px solid #E7E2DB",
                      background: isSelected ? "#FFF7F2" : "#FFFFFF",
                      color: isSelected ? "#E86F1C" : "#44403C",
                      cursor: "pointer",
                      transition: "all 0.15s ease",
                      boxShadow: isSelected
                        ? "0 4px 12px rgba(232, 111, 28, 0.12)"
                        : "0 1px 3px rgba(0, 0, 0, 0.02)",
                    }}
                  >
                    <div
                      style={{
                        width: "40px",
                        height: "40px",
                        borderRadius: "10px",
                        background: isSelected ? "#E86F1C" : "#F5F2EB",
                        color: isSelected ? "#FFFFFF" : "#57534E",
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "center",
                        marginBottom: "8px",
                      }}
                    >
                      {renderDeviceIcon(device.iconName, 20, isSelected ? "#FFFFFF" : "#57534E")}
                    </div>
                    <span
                      style={{
                        fontSize: "12.5px",
                        fontWeight: isSelected ? 750 : 600,
                        textAlign: "center",
                        lineHeight: 1.25,
                      }}
                    >
                      {isNe ? device.nameNe : device.name}
                    </span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Step 2: Brand Filter Chips (Optional helper) */}
          <div
            style={{
              background: "#FFFFFF",
              borderRadius: "14px",
              border: "1px solid #ECE7E0",
              padding: "16px 18px",
              marginBottom: "24px",
            }}
          >
            <div
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                marginBottom: "10px",
                flexWrap: "wrap",
                gap: "8px",
              }}
            >
              <h3
                style={{
                  fontSize: "14px",
                  fontWeight: 750,
                  color: "#181512",
                  margin: 0,
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                }}
              >
                <span
                  style={{
                    width: "22px",
                    height: "22px",
                    borderRadius: "50%",
                    background: "#0F172A",
                    color: "#FFFFFF",
                    display: "inline-flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: "11px",
                    fontWeight: 800,
                  }}
                >
                  2
                </span>
                {isNe ? "ब्रान्ड / मोडल (ऐच्छिक)" : "Brand / Make (Optional)"}
              </h3>

              {selectedBrand !== "All Brands" && (
                <button
                  type="button"
                  onClick={() => setSelectedBrand("All Brands")}
                  style={{
                    background: "none",
                    border: "none",
                    color: "#E86F1C",
                    fontSize: "12px",
                    fontWeight: 650,
                    cursor: "pointer",
                    padding: 0,
                  }}
                >
                  {isNe ? "रिसेट" : "Reset Brand"}
                </button>
              )}
            </div>

            <div style={{ display: "flex", flexWrap: "wrap", gap: "6px" }}>
              <button
                type="button"
                onClick={() => setSelectedBrand("All Brands")}
                style={{
                  padding: "5px 12px",
                  borderRadius: "999px",
                  fontSize: "12px",
                  fontWeight: selectedBrand === "All Brands" ? 750 : 550,
                  background: selectedBrand === "All Brands" ? "#0F172A" : "#F4F0E8",
                  color: selectedBrand === "All Brands" ? "#FFFFFF" : "#57534E",
                  border: "none",
                  cursor: "pointer",
                }}
              >
                {isNe ? "सबै ब्रान्डहरू" : "All Brands"}
              </button>
              {currentDevice.popularBrands.map((brand) => {
                const isSelected = selectedBrand === brand;
                return (
                  <button
                    key={brand}
                    type="button"
                    onClick={() => setSelectedBrand(brand)}
                    style={{
                      padding: "5px 12px",
                      borderRadius: "999px",
                      fontSize: "12px",
                      fontWeight: isSelected ? 750 : 550,
                      background: isSelected ? "#E86F1C" : "#F4F0E8",
                      color: isSelected ? "#FFFFFF" : "#57534E",
                      border: "none",
                      cursor: "pointer",
                      transition: "all 0.15s ease",
                    }}
                  >
                    {brand}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Step 3: Choose Symptom / Issue */}
          <div>
            <div
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                marginBottom: "12px",
                flexWrap: "wrap",
                gap: "10px",
              }}
            >
              <h2
                style={{
                  fontSize: "15px",
                  fontWeight: 750,
                  color: "#181512",
                  margin: 0,
                  textTransform: "uppercase",
                  letterSpacing: "0.04em",
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                }}
              >
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
                  3
                </span>
                {isNe ? "देखिने लक्षण / समस्या छान्नुहोस्" : "Select Symptom or Defect"}
              </h2>

              {/* Symptom Quick Filter Input */}
              <div
                style={{
                  position: "relative",
                  width: "220px",
                  display: "flex",
                  alignItems: "center",
                }}
              >
                <Search
                  size={14}
                  style={{
                    position: "absolute",
                    left: "10px",
                    color: "#9C9286",
                    pointerEvents: "none",
                  }}
                />
                <input
                  type="text"
                  placeholder={isNe ? "समस्या खोज्नुहोस्..." : "Filter symptoms..."}
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  style={{
                    width: "100%",
                    padding: "6px 28px 6px 30px",
                    fontSize: "12px",
                    borderRadius: "8px",
                    border: "1px solid #DED8CE",
                    background: "#FFFFFF",
                    outline: "none",
                    color: "#181512",
                  }}
                />
                {searchQuery && (
                  <button
                    type="button"
                    onClick={() => setSearchQuery("")}
                    style={{
                      position: "absolute",
                      right: "8px",
                      background: "none",
                      border: "none",
                      fontSize: "12px",
                      color: "#8C827A",
                      cursor: "pointer",
                      padding: 0,
                    }}
                  >
                    ✕
                  </button>
                )}
              </div>
            </div>

            {/* Symptom Cards List */}
            {filteredSymptoms.length === 0 ? (
              <div
                style={{
                  background: "#FFFFFF",
                  border: "1px dashed #D6CEC2",
                  borderRadius: "14px",
                  padding: "32px 20px",
                  textAlign: "center",
                }}
              >
                <p style={{ margin: "0 0 10px 0", fontSize: "14px", color: "#78716C" }}>
                  {isNe
                    ? "कुनै मिल्दो समस्या फेला परेन। कृपया फरक शब्द खोज्नुहोस्।"
                    : "No specific symptom matched your search filter."}
                </p>
                <button
                  type="button"
                  onClick={() => setSearchQuery("")}
                  style={{
                    padding: "6px 14px",
                    borderRadius: "6px",
                    background: "#E86F1C",
                    color: "#FFFFFF",
                    border: "none",
                    fontSize: "12px",
                    fontWeight: 700,
                    cursor: "pointer",
                  }}
                >
                  {isNe ? "सबै लक्षण हेर्नुहोस्" : "Show All Symptoms"}
                </button>
              </div>
            ) : (
              <div style={{ display: "flex", flexDirection: "column", gap: "10px" }}>
                {filteredSymptoms.map((symptom) => {
                  const isSelected = symptom.id === selectedSymptomId;
                  return (
                    <div
                      key={symptom.id}
                      onClick={() => setSelectedSymptomId(symptom.id)}
                      style={{
                        background: isSelected ? "#FFFFFF" : "#FAF9F7",
                        borderRadius: "14px",
                        border: isSelected ? "2px solid #E86F1C" : "1px solid #E8E3DB",
                        padding: "16px 18px",
                        cursor: "pointer",
                        transition: "all 0.15s ease",
                        boxShadow: isSelected
                          ? "0 4px 16px rgba(232, 111, 28, 0.08)"
                          : "none",
                        position: "relative",
                      }}
                    >
                      <div
                        style={{
                          display: "flex",
                          alignItems: "flex-start",
                          justifyContent: "space-between",
                          gap: "12px",
                        }}
                      >
                        <div style={{ flex: 1 }}>
                          <div
                            style={{
                              display: "flex",
                              alignItems: "center",
                              gap: "8px",
                              marginBottom: "4px",
                              flexWrap: "wrap",
                            }}
                          >
                            <span
                              style={{
                                fontSize: "14.5px",
                                fontWeight: 750,
                                color: isSelected ? "#E86F1C" : "#181512",
                                lineHeight: 1.35,
                              }}
                            >
                              {isNe ? symptom.titleNe : symptom.title}
                            </span>

                            {/* Severity Badge */}
                            <span
                              style={{
                                fontSize: "10.5px",
                                fontWeight: 700,
                                padding: "2px 7px",
                                borderRadius: "4px",
                                background:
                                  symptom.severity === "high"
                                    ? "#FEE2E2"
                                    : symptom.severity === "medium"
                                    ? "#FEF3C7"
                                    : "#E0F2FE",
                                color:
                                  symptom.severity === "high"
                                    ? "#B91C1C"
                                    : symptom.severity === "medium"
                                    ? "#B45309"
                                    : "#0369A1",
                                textTransform: "uppercase",
                              }}
                            >
                              {symptom.severity === "high"
                                ? isNe
                                  ? "जटिल"
                                  : "Critical"
                                : symptom.severity === "medium"
                                ? isNe
                                  ? "मध्यम"
                                  : "Moderate"
                                : isNe
                                ? "सामान्य"
                                : "Minor"}
                            </span>
                          </div>

                          <p
                            style={{
                              fontSize: "12.5px",
                              color: "#6B655D",
                              margin: "0 0 10px 0",
                              lineHeight: 1.5,
                            }}
                          >
                            {isNe ? symptom.descNe : symptom.desc}
                          </p>

                          {/* Quick Specs Footnote */}
                          <div
                            style={{
                              display: "flex",
                              alignItems: "center",
                              gap: "14px",
                              fontSize: "11.5px",
                              color: "#8C827A",
                              flexWrap: "wrap",
                            }}
                          >
                            <span style={{ display: "inline-flex", alignItems: "center", gap: "4px" }}>
                              <Clock size={12} color="#E86F1C" />
                              {isNe ? symptom.turnaroundNe : symptom.turnaround}
                            </span>
                            <span>•</span>
                            <span style={{ display: "inline-flex", alignItems: "center", gap: "4px" }}>
                              <ShieldCheck size={12} color="#16A34A" />
                              {symptom.warrantyDays} {isNe ? "दिन वारेन्टी" : "Days Warranty"}
                            </span>
                            <span>•</span>
                            <span>
                              {symptom.homeVisitAvailable
                                ? isNe
                                  ? "घरमै मर्मत सम्भव"
                                  : "Home Visit Available"
                                : isNe
                                ? "जनकपुर ल्याब बेन्च"
                                : "Lab Bench Diagnostics"}
                            </span>
                          </div>
                        </div>

                        {/* Estimated Price Tag Right */}
                        <div
                          style={{
                            textAlign: "right",
                            display: "flex",
                            flexDirection: "column",
                            alignItems: "flex-end",
                            flexShrink: 0,
                          }}
                        >
                          <div style={{ fontSize: "11px", color: "#8C827A", fontWeight: 600 }}>
                            {isNe ? "अनुमानित खर्च" : "Est. Range"}
                          </div>
                          <div
                            style={{
                              fontSize: "15px",
                              fontWeight: 800,
                              color: isSelected ? "#E86F1C" : "#181512",
                              fontVariantNumeric: "tabular-nums",
                              marginTop: "2px",
                            }}
                          >
                            Rs. {symptom.minPrice.toLocaleString("en-IN")} – {symptom.maxPrice.toLocaleString("en-IN")}
                          </div>

                          {/* Selection Checkmark */}
                          <div
                            style={{
                              marginTop: "8px",
                              width: "20px",
                              height: "20px",
                              borderRadius: "50%",
                              background: isSelected ? "#E86F1C" : "#E5E0D8",
                              color: "#FFFFFF",
                              display: "flex",
                              alignItems: "center",
                              justifyContent: "center",
                            }}
                          >
                            {isSelected && <Check size={12} strokeWidth={3} />}
                          </div>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>

        {/* Right Column: Live Quotation Summary Card */}
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
            {/* Card Header */}
            <div
              style={{
                background: "linear-gradient(135deg, #FAF7F2 0%, #F5EFE6 100%)",
                borderBottom: "1px solid #ECE4D8",
                padding: "20px 22px",
              }}
            >
              <div
                style={{
                  fontSize: "11.5px",
                  fontWeight: 750,
                  color: "#E86F1C",
                  textTransform: "uppercase",
                  letterSpacing: "0.06em",
                  marginBottom: "4px",
                }}
              >
                {isNe ? "विस्तृत खर्च विवरण" : "Instant Estimate Breakdown"}
              </div>
              <h3
                style={{
                  fontSize: "18px",
                  fontWeight: 800,
                  color: "#181512",
                  margin: 0,
                  letterSpacing: "-0.01em",
                }}
              >
                {isNe ? currentDevice.nameNe : currentDevice.name}
                {selectedBrand !== "All Brands" ? ` • ${selectedBrand}` : ""}
              </h3>
            </div>

            {/* Card Body */}
            <div style={{ padding: "22px" }}>
              {/* Grand Price Range Display */}
              <div
                style={{
                  background: "#FFF8F2",
                  border: "1px solid #FED7AA",
                  borderRadius: "12px",
                  padding: "16px 18px",
                  marginBottom: "20px",
                  textAlign: "center",
                }}
              >
                <div style={{ fontSize: "12px", color: "#78716C", fontWeight: 650, marginBottom: "4px" }}>
                  {isNe ? "कुल अनुमानित खर्च दायरा" : "Total Estimated Repair Cost"}
                </div>
                <div
                  style={{
                    fontSize: "26px",
                    fontWeight: 850,
                    color: "#E86F1C",
                    fontVariantNumeric: "tabular-nums",
                    letterSpacing: "-0.02em",
                  }}
                >
                  Rs. {currentSymptom.minPrice.toLocaleString("en-IN")} –{" "}
                  {currentSymptom.maxPrice.toLocaleString("en-IN")}
                </div>
                <div style={{ fontSize: "11.5px", color: "#16A34A", fontWeight: 700, marginTop: "4px" }}>
                  ✓ {isNe ? "जनकपुरधाम वर्कशपमा प्रत्यक्ष चेकअप निःशुल्क" : "Free Physical Diagnosis in Janakpur"}
                </div>
              </div>

              {/* Itemized Breakdown Rows */}
              <div
                style={{
                  display: "flex",
                  flexDirection: "column",
                  gap: "12px",
                  fontSize: "13px",
                  paddingBottom: "18px",
                  borderBottom: "1px solid #F0ECE4",
                  marginBottom: "18px",
                }}
              >
                {/* Issue Selected */}
                <div style={{ display: "flex", justifyContent: "space-between", gap: "10px" }}>
                  <span style={{ color: "#78716C" }}>{isNe ? "समस्या:" : "Diagnosed Issue:"}</span>
                  <span style={{ fontWeight: 700, color: "#181512", textAlign: "right" }}>
                    {isNe ? currentSymptom.titleNe : currentSymptom.title}
                  </span>
                </div>

                {/* Service Labor */}
                <div style={{ display: "flex", justifyContent: "space-between", gap: "10px" }}>
                  <span style={{ color: "#78716C" }}>{isNe ? "प्राविधिक सेवा शुल्क:" : "Diagnostic & Labor:"}</span>
                  <span style={{ fontWeight: 700, color: "#181512" }}>
                    Rs. {currentSymptom.laborFee.toLocaleString("en-IN")}
                  </span>
                </div>

                {/* Spare Parts Estimation */}
                <div style={{ display: "flex", justifyContent: "space-between", gap: "10px" }}>
                  <span style={{ color: "#78716C" }}>{isNe ? "स्पेयर पार्ट्स अनुमान:" : "Original Parts Est:"}</span>
                  <span style={{ fontWeight: 600, color: "#57534E", textAlign: "right", fontSize: "12px" }}>
                    {isNe ? currentSymptom.partsEstimateNe : currentSymptom.partsEstimate}
                  </span>
                </div>

                {/* Turnaround Time */}
                <div style={{ display: "flex", justifyContent: "space-between", gap: "10px" }}>
                  <span style={{ color: "#78716C" }}>{isNe ? "लाग्ने समय:" : "Turnaround Time:"}</span>
                  <span
                    style={{
                      fontWeight: 700,
                      color: "#E86F1C",
                      display: "inline-flex",
                      alignItems: "center",
                      gap: "4px",
                    }}
                  >
                    <Clock size={13} />
                    {isNe ? currentSymptom.turnaroundNe : currentSymptom.turnaround}
                  </span>
                </div>

                {/* Warranty Coverage */}
                <div style={{ display: "flex", justifyContent: "space-between", gap: "10px" }}>
                  <span style={{ color: "#78716C" }}>{isNe ? "वारेन्टी संरक्षण:" : "Warranty Guarantee:"}</span>
                  <span
                    style={{
                      fontWeight: 700,
                      color: "#16A34A",
                      display: "inline-flex",
                      alignItems: "center",
                      gap: "4px",
                    }}
                  >
                    <ShieldCheck size={14} />
                    {currentSymptom.warrantyDays} {isNe ? "दिन शर्मा भिडियो केयर वारेन्टी" : "Days Official Warranty"}
                  </span>
                </div>

                {/* Service Mode */}
                <div style={{ display: "flex", justifyContent: "space-between", gap: "10px" }}>
                  <span style={{ color: "#78716C" }}>{isNe ? "सेवा माध्यम:" : "Service Location:"}</span>
                  <span style={{ fontWeight: 650, color: "#181512" }}>
                    {currentSymptom.homeVisitAvailable
                      ? isNe
                        ? "घरमै सेवा (Doorstep Service)"
                        : "Doorstep Home Visit"
                      : isNe
                      ? "जनकपुर सेन्टर (Station Road)"
                      : "Station Road Workshop"}
                  </span>
                </div>
              </div>

              {/* Technician Guidance / Pro-Tip Box */}
              <div
                style={{
                  background: "#F8FAFC",
                  border: "1px solid #E2E8F0",
                  borderRadius: "10px",
                  padding: "12px 14px",
                  fontSize: "12px",
                  color: "#334155",
                  lineHeight: 1.5,
                  marginBottom: "20px",
                  display: "flex",
                  alignItems: "flex-start",
                  gap: "8px",
                }}
              >
                <HelpCircle size={15} color="#E86F1C" style={{ flexShrink: 0, marginTop: "2px" }} />
                <div>
                  <strong>{isNe ? "प्राविधिक सल्लाह:" : "Technician Advice:"} </strong>
                  {isNe ? currentSymptom.recommendedActionNe : currentSymptom.recommendedAction}
                </div>
              </div>

              {/* Action Buttons */}
              <div style={{ display: "flex", flexDirection: "column", gap: "10px" }}>
                {/* Primary CTA: Book With Estimate */}
                <Link
                  href={bookingHref}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    gap: "8px",
                    background: "#E86F1C",
                    color: "#FFFFFF",
                    padding: "12px 18px",
                    borderRadius: "10px",
                    fontWeight: 750,
                    fontSize: "14px",
                    textDecoration: "none",
                    boxShadow: "0 4px 12px rgba(232, 111, 28, 0.28)",
                    transition: "background 0.15s ease",
                  }}
                  onMouseEnter={(e) => (e.currentTarget.style.background = "#D35F12")}
                  onMouseLeave={(e) => (e.currentTarget.style.background = "#E86F1C")}
                >
                  <span>{isNe ? "यही अनुमानमा मर्मत बुक गर्नुहोस्" : "Book Repair With This Estimate"}</span>
                  <ArrowRight size={16} />
                </Link>

                {/* Secondary CTA: WhatsApp Chat */}
                <a
                  href={whatsappHref}
                  target="_blank"
                  rel="noopener noreferrer"
                  style={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    gap: "8px",
                    background: "rgba(37, 211, 102, 0.1)",
                    border: "1px solid rgba(37, 211, 102, 0.3)",
                    color: "#15803D",
                    padding: "11px 16px",
                    borderRadius: "10px",
                    fontWeight: 700,
                    fontSize: "13px",
                    textDecoration: "none",
                    transition: "background 0.15s ease",
                  }}
                  onMouseEnter={(e) => (e.currentTarget.style.background = "rgba(37, 211, 102, 0.18)")}
                  onMouseLeave={(e) => (e.currentTarget.style.background = "rgba(37, 211, 102, 0.1)")}
                >
                  <MessageCircle size={16} color="#25D366" />
                  <span>{isNe ? "ह्वाट्सएपमा सोधपुछ गर्नुहोस्" : "Confirm Estimate on WhatsApp"}</span>
                </a>

                {/* Direct Hotline */}
                <a
                  href="tel:+9779854022200"
                  style={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    gap: "6px",
                    color: "#78716C",
                    fontSize: "12px",
                    fontWeight: 650,
                    textDecoration: "none",
                    marginTop: "4px",
                  }}
                >
                  <PhoneCall size={13} color="#E86F1C" />
                  <span>{isNe ? "हटलाइन: ९८५४०२२२००" : "Call Hotline: +977 985-4022200"}</span>
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RepairEstimator;
