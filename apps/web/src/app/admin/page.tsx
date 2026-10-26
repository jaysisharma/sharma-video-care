import { uploadToCloudinary } from "../../lib/cloudinary";
"use client";

import React, { useEffect, useState, useMemo } from "react";
import Link from "next/link";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import "./admin.css";
import {
  collection,
  query,
  getDocs,
  doc,
  updateDoc,
  addDoc,
  deleteDoc,
  onSnapshot,
  setDoc,
  getDoc,
  where,
} from "firebase/firestore";
import { db } from "../../lib/firebase";
import { useAuth } from "../../context/AuthContext";
import { useSnackbar } from "../../context/SnackbarContext";
import { RequireRole } from "../../components/RequireRole";
import { CERTIFIED_USED_PRODUCTS, CertifiedUsedItem } from "../../data/usedProducts";
import { UsedConditionGrade } from "@sharmavideocare/shared";
import {
  ServiceRequest,
  OrderRecord,
  PaymentProof,
  InspectionRecord,
  ProductItem,
  CommercialSettings,
  DEFAULT_TECH_COMMISSION_PCT,
  DEFAULT_SVC_COMMISSION_PCT,
  UserProfile,
} from "@sharmavideocare/shared";
import { AdminNotificationsTab } from "../../components/admin/AdminNotificationsTab";
import {
  Bell,
  LayoutDashboard,
  Wrench,
  Package,
  CreditCard,
  Image as ImageIcon,
  FolderTree,
  Box,
  Settings,
  CheckCircle,
  XCircle,
  Truck,
  Plus,
  Send,
  UserCheck,
  Search,
  ExternalLink,
  LogOut,
  Menu,
  X,
  Trash2,
  Edit2,
  Eye,
  ArrowRight,
  UploadCloud,
  ShieldCheck,
  Sparkles,
  Camera,
  RotateCcw,
  AlertTriangle,
  Check,
  Shield,
} from "lucide-react";

export interface HeroSlide {
  id: string;
  title: string;
  subtitle: string;
  kicker: string;
  ctaText: string;
  ctaLink: string;
  imageUrl: string;
  active: boolean;
  order: number;
}

export interface CategoryData {
  id: string;
  name: string;
  slug: string;
  description: string;
  itemCount: number;
}

const DEFAULT_SLIDES: HeroSlide[] = [
  {
    id: "slide-1",
    title: "Precision Camera & Optics Diagnostics in Janakpur",
    subtitle: "Certified sensor cleaning, shutter replacement, and genuine optical parts with 90-day warranty.",
    kicker: "SERVICE BENCH",
    ctaText: "Book Diagnosis",
    ctaLink: "/services",
    imageUrl: "/images/hero-camera.png",
    active: true,
    order: 1,
  },
  {
    id: "slide-2",
    title: "Certified Pre-Owned Sony, Canon & DJI Gear",
    subtitle: "Every camera body and drone passes a rigorous 48-point physical inspection before dispatch.",
    kicker: "CERTIFIED GEAR",
    ctaText: "Browse Certified Gear",
    ctaLink: "/used",
    imageUrl: "/images/products/canon_eos.jpg",
    active: true,
    order: 2,
  },
  {
    id: "slide-3",
    title: "Safe Nationwide Delivery Across All 7 Provinces",
    subtitle: "Insured courier shipping via Nepal Can Move & Aramex with tamper-evident packaging.",
    kicker: "SAFE FULFILLMENT",
    ctaText: "Shop Equipment",
    ctaLink: "/shop",
    imageUrl: "/images/products/macbook_pro.jpg",
    active: true,
    order: 3,
  },
];

const DEFAULT_CATEGORIES: CategoryData[] = [
  { id: "cat-cameras", name: "Cameras & Optical Bodies", slug: "cameras", description: "Mirrorless bodies, cinema rigs, and full-frame DSLRs", itemCount: 14 },
  { id: "cat-lenses", name: "Lenses & Cine Glass", slug: "lenses", description: "Prime optics, telephoto zooms, and cinema lenses", itemCount: 9 },
  { id: "cat-drones", name: "Drones & Aerial Systems", slug: "drones", description: "DJI Mavic, Inspire, and aerial gimbal stabilizers", itemCount: 6 },
  { id: "cat-audio", name: "Studio & Wireless Audio", slug: "audio", description: "Wireless microphones, boom mics, and recorders", itemCount: 11 },
  { id: "cat-used", name: "Certified Pre-Owned Gear", slug: "used", description: "Lab-inspected equipment with guaranteed shutter health", itemCount: 8 },
  { id: "cat-cctv", name: "CCTV Surveillance", slug: "cctv", description: "4K IP security cameras, NVRs, and perimeter gear", itemCount: 15 },
];

type AdminTab =
  | "overview"
  | "repairs"
  | "orders"
  | "payments"
  | "carousel"
  | "categories"
  | "products"
  | "used"
  | "notifications"
  | "settings";

const VALID_TABS: AdminTab[] = [
  "overview",
  "repairs",
  "orders",
  "payments",
  "carousel",
  "categories",
  "products",
  "used",
  "notifications",
  "settings",
];

export default function AdminConsolePage() {
  return (
    <RequireRole roles={["admin"]}>
      <React.Suspense
        fallback={
          <div className="admin-layout" style={{ padding: "40px", color: "var(--admin-text-muted)" }}>
            Loading Admin Console...
          </div>
        }
      >
        <AdminConsole />
      </React.Suspense>
    </RequireRole>
  );
}

function AdminConsole() {
  const { user, role, signOut, firebaseUser } = useAuth();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const router = useRouter();

  // Resolve active tab from URL path (/admin/categories), query param (?tab=categories), or default to overview
  const resolvedTab = useMemo<AdminTab>(() => {
    if (pathname) {
      const segments = pathname.split("/").filter(Boolean);
      if (segments.length >= 2 && segments[0] === "admin") {
        const sub = segments[1].toLowerCase() as AdminTab;
        if (VALID_TABS.includes(sub)) {
          return sub;
        }
      }
    }
    const qTab = searchParams?.get("tab")?.toLowerCase() as AdminTab;
    if (qTab && VALID_TABS.includes(qTab)) {
      return qTab;
    }
    return "overview";
  }, [pathname, searchParams]);

  const [activeTab, setActiveTab] = useState<AdminTab>(resolvedTab);

  useEffect(() => {
    setActiveTab(resolvedTab);
  }, [resolvedTab]);

  const navigateToTab = (tab: AdminTab) => {
    setActiveTab(tab);
    setSidebarOpen(false);
    const target = tab === "overview" ? "/admin" : `/admin/${tab}`;
    if (pathname !== target) {
      router.push(target);
    }
  };

  const [sidebarOpen, setSidebarOpen] = useState(false);
  const snackbar = useSnackbar();

  // Filters & Search
  const [searchQuery, setSearchQuery] = useState("");
  const [repairFilter, setRepairFilter] = useState("ALL");
  const [orderFilter, setOrderFilter] = useState("ALL");
  const [paymentFilter, setPaymentFilter] = useState("ALL");

  // Datasets
  const [serviceRequests, setServiceRequests] = useState<ServiceRequest[]>([]);
  const [orders, setOrders] = useState<OrderRecord[]>([]);
  const [payments, setPayments] = useState<PaymentProof[]>([]);
  const [products, setProducts] = useState<ProductItem[]>([]);
  const [slides, setSlides] = useState<HeroSlide[]>(DEFAULT_SLIDES);
  const [categories, setCategories] = useState<CategoryData[]>(DEFAULT_CATEGORIES);

  // Settings
  const [techSplit, setTechSplit] = useState(DEFAULT_TECH_COMMISSION_PCT);
  const [svcSplit, setSvcSplit] = useState(DEFAULT_SVC_COMMISSION_PCT);
  const [deliveryFee, setDeliveryFee] = useState(150);
  const [savingSettings, setSavingSettings] = useState(false);

  // Modals state
  const [selectedRequest, setSelectedRequest] = useState<ServiceRequest | null>(null);
  const [showAssignModal, setShowAssignModal] = useState(false);
  const [technicians, setTechnicians] = useState<UserProfile[]>([]);
  const [selectedTechId, setSelectedTechId] = useState("");

  const [showQuoteModal, setShowQuoteModal] = useState(false);
  const [labourAmount, setLabourAmount] = useState("2500");
  const [partsAmount, setPartsAmount] = useState("4500");
  const [quoteWarranty, setQuoteWarranty] = useState("90 Days Service Warranty");
  const [quoteNotes, setQuoteNotes] = useState("Includes sensor cleaning and mechanical calibration.");

  const [selectedOrder, setSelectedOrder] = useState<OrderRecord | null>(null);
  const [courierPartner, setCourierPartner] = useState("Nepal Can Move");
  const [trackingNumber, setTrackingNumber] = useState("");
  const [showDispatchModal, setShowDispatchModal] = useState(false);

  const [viewingPaymentProof, setViewingPaymentProof] = useState<PaymentProof | null>(null);

  // Hero Slide Form
  const [slideTitle, setSlideTitle] = useState("");
  const [slideKicker, setSlideKicker] = useState("");
  const [slideSubtitle, setSlideSubtitle] = useState("");
  const [slideCtaText, setSlideCtaText] = useState("Learn More");
  const [slideCtaLink, setSlideCtaLink] = useState("/shop");
  const [slideImageUrl, setSlideImageUrl] = useState("/images/hero-camera.png");
  const [slideActive, setSlideActive] = useState(true);
  const [editingSlideId, setEditingSlideId] = useState<string | null>(null);

  // Category Form
  const [catName, setCatName] = useState("");
  const [catSlug, setCatSlug] = useState("");
  const [catDesc, setCatDesc] = useState("");

  // Certified Pre-Owned / Used Gear Form & State
  const [usedProducts, setUsedProducts] = useState<CertifiedUsedItem[]>(CERTIFIED_USED_PRODUCTS);
  const [usedSearch, setUsedSearch] = useState("");
  const [usedGradeFilter, setUsedGradeFilter] = useState("ALL");
  const [usedStatusFilter, setUsedStatusFilter] = useState("ALL");
  const [usedCategoryFilter, setUsedCategoryFilter] = useState("ALL");
  const [editingUsedId, setEditingUsedId] = useState<string | null>(null);
  const [viewingUsedItem, setViewingUsedItem] = useState<CertifiedUsedItem | null>(null);

  const [usedName, setUsedName] = useState("");
  const [usedBrand, setUsedBrand] = useState("Sony");
  const [usedModel, setUsedModel] = useState("");
  const [usedCategory, setUsedCategory] = useState("Cameras");
  const [usedGrade, setUsedGrade] = useState<UsedConditionGrade>("EXCELLENT");
  const [usedPrice, setUsedPrice] = useState("165000");
  const [usedOriginalPrice, setUsedOriginalPrice] = useState("245000");
  const [usedUsageMetric, setUsedUsageMetric] = useState("14,200 Shutter Actuations");
  const [usedMetricType, setUsedMetricType] = useState<"SHUTTER" | "FLIGHT" | "OPTICS">("SHUTTER");
  const [usedConditionDesc, setUsedConditionDesc] = useState("");
  const [usedDefects, setUsedDefects] = useState("");
  const [usedFunctionalStatus, setUsedFunctionalStatus] = useState<"TESTED_FULLY_FUNCTIONAL" | "TESTED_WITH_LIMITATIONS">("TESTED_FULLY_FUNCTIONAL");
  const [usedTestNotes, setUsedTestNotes] = useState("");
  const [usedAccessories, setUsedAccessories] = useState("");
  const [usedWarranty, setUsedWarranty] = useState("90-Day Comprehensive QuickySewa Lab Warranty");
  const [usedSerial, setUsedSerial] = useState("");
  const [usedImage, setUsedImage] = useState("/images/products/canon_eos.jpg");
  const [usedActive, setUsedActive] = useState(true);

  // Product Form
  const [prodName, setProdName] = useState("");
  const [prodBrand, setProdBrand] = useState("Canon");
  const [prodCategory, setProdCategory] = useState("Cameras");
  const [prodPrice, setProdPrice] = useState("120000");
  const [prodImageUrl, setProdImageUrl] = useState("/images/products/canon_eos.jpg");
  const [prodStock, setProdStock] = useState("5");

  // Load Firestore data
  useEffect(() => {
    const unsubReqs = onSnapshot(collection(db, "serviceRequests"), (snap) => {
      const list: ServiceRequest[] = [];
      snap.forEach((d) => list.push({ id: d.id, ...d.data() } as ServiceRequest));
      setServiceRequests(list.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()));
    });

    const unsubTechs = onSnapshot(
      query(collection(db, "users"), where("role", "==", "technician")),
      (snap) => {
        const list: UserProfile[] = [];
        snap.forEach((d) => list.push({ ...(d.data() as UserProfile), id: d.id }));
        setTechnicians(list.filter((t) => t.status === "ACTIVE").sort((a, b) => a.name.localeCompare(b.name)));
      }
    );

    const unsubOrders = onSnapshot(collection(db, "orders"), (snap) => {
      const list: OrderRecord[] = [];
      snap.forEach((d) => list.push({ id: d.id, ...d.data() } as OrderRecord));
      setOrders(list.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()));
    });

    const unsubPayments = onSnapshot(collection(db, "payments"), (snap) => {
      const list: PaymentProof[] = [];
      snap.forEach((d) => list.push({ id: d.id, ...d.data() } as PaymentProof));
      setPayments(list.sort((a, b) => new Date(b.submittedAt).getTime() - new Date(a.submittedAt).getTime()));
    });

    const unsubProducts = onSnapshot(collection(db, "products"), (snap) => {
      const list: ProductItem[] = [];
      snap.forEach((d) => list.push({ id: d.id, ...d.data() } as ProductItem));
      setProducts(list);
    });

    const unsubSlides = onSnapshot(collection(db, "heroSlides"), (snap) => {
      if (!snap.empty) {
        const list: HeroSlide[] = [];
        snap.forEach((d) => list.push({ id: d.id, ...d.data() } as HeroSlide));
        setSlides(list.sort((a, b) => (a.order || 0) - (b.order || 0)));
      }
    });

    const unsubCategories = onSnapshot(collection(db, "categories"), (snap) => {
      if (!snap.empty) {
        const list: CategoryData[] = [];
        snap.forEach((d) => list.push({ id: d.id, ...d.data() } as CategoryData));
        setCategories(list);
      }
    });

    const unsubUsed = onSnapshot(collection(db, "usedProducts"), (snap) => {
      if (!snap.empty) {
        const liveList: CertifiedUsedItem[] = [];
        snap.forEach((d) => {
          const data = d.data();
          liveList.push({
            id: d.id,
            ...data,
            usageMetric: data.usageMetric || "Tested & Certified",
            metricType: data.metricType || "SHUTTER",
          } as CertifiedUsedItem);
        });
        const liveIds = new Set(liveList.map((i) => i.id));
        const combined = [
          ...liveList,
          ...CERTIFIED_USED_PRODUCTS.filter((i) => !liveIds.has(i.id)),
        ];
        setUsedProducts(combined);
      } else {
        setUsedProducts(CERTIFIED_USED_PRODUCTS);
      }
    });

    getDoc(doc(db, "settings", "commercial")).then((snap) => {
      if (snap.exists()) {
        const data = snap.data() as CommercialSettings;
        if (data.externalTechnicianCommissionPct) setTechSplit(data.externalTechnicianCommissionPct);
        if (data.sharmaVideoCareCommissionPct) setSvcSplit(data.sharmaVideoCareCommissionPct);
        if (data.deliveryNationwideFeeDefault) setDeliveryFee(data.deliveryNationwideFeeDefault);
      }
    });

    return () => {
      unsubTechs();
      unsubReqs();
      unsubOrders();
      unsubPayments();
      unsubProducts();
      unsubSlides();
      unsubCategories();
      unsubUsed();
    };
  }, []);

  // Action Handlers
  const handleAssignTechnician = async () => {
    if (!selectedRequest) return;
    const tech = technicians.find((t) => t.id === selectedTechId);
    if (!tech) {
      snackbar.warning("Select a technician first.");
      return;
    }
    try {
      await updateDoc(doc(db, "serviceRequests", selectedRequest.id), {
        assignedTechnicianId: selectedTechId,
        assignedTechnicianName: tech.name,
        status: "INSPECTION_SCHEDULED",
        updatedAt: new Date().toISOString(),
      });
      setShowAssignModal(false);
      setSelectedRequest(null);
      snackbar.success("Technician assigned.");
    } catch (e) {
      console.error(e);
      snackbar.error("Failed to assign technician.");
    }
  };

  const handleSendQuotation = async () => {
    if (!selectedRequest) return;
    try {
      const labour = Number(labourAmount) || 0;
      const parts = Number(partsAmount) || 0;
      const total = labour + parts;

      const quoteData = {
        serviceRequestId: selectedRequest.id,
        customerId: selectedRequest.customerId,
        items: [
          { id: "item-1", description: "Technical Labour", type: "LABOUR", amount: labour },
          { id: "item-2", description: "Components & Parts", type: "PART", amount: parts },
        ],
        labourTotal: labour,
        partsTotal: parts,
        total,
        currency: "NPR",
        notes: quoteNotes,
        warrantyTerms: quoteWarranty,
        status: "SENT",
        createdAt: new Date().toISOString(),
      };

      const quoteRef = await addDoc(collection(db, "quotes"), quoteData);
      await updateDoc(doc(db, "serviceRequests", selectedRequest.id), {
        quoteId: quoteRef.id,
        status: "QUOTE_SENT",
        updatedAt: new Date().toISOString(),
      });

      setShowQuoteModal(false);
      setSelectedRequest(null);
      snackbar.success("Diagnostic quote dispatched to customer.");
    } catch (e) {
      console.error(e);
      snackbar.error("Failed to dispatch quotation.");
    }
  };

  const handleVerifyPayment = async (payment: PaymentProof) => {
    try {
      await updateDoc(doc(db, "payments", payment.id), {
        status: "VERIFIED",
        verifiedBy: user?.name || "Admin",
        verifiedAt: new Date().toISOString(),
      });
      await updateDoc(doc(db, "orders", payment.orderId), {
        paymentStatus: "VERIFIED",
        orderStatus: "CONFIRMED",
        updatedAt: new Date().toISOString(),
      });
      if (viewingPaymentProof?.id === payment.id) setViewingPaymentProof(null);
      snackbar.success("Payment verified. Order confirmed.");
    } catch (e) {
      console.error(e);
      snackbar.error("Failed to verify payment.");
    }
  };

  const handleRejectPayment = async (payment: PaymentProof) => {
    try {
      await updateDoc(doc(db, "payments", payment.id), {
        status: "REJECTED",
        rejectionReason: "Voucher reference not matched in bank statement.",
        verifiedBy: user?.name || "Admin",
        verifiedAt: new Date().toISOString(),
      });
      await updateDoc(doc(db, "orders", payment.orderId), {
        paymentStatus: "REJECTED",
        updatedAt: new Date().toISOString(),
      });
      if (viewingPaymentProof?.id === payment.id) setViewingPaymentProof(null);
      snackbar.success("Payment rejected.");
    } catch (e) {
      console.error(e);
      snackbar.error("Failed to reject payment.");
    }
  };

  const handleDispatchOrder = async () => {
    if (!selectedOrder) return;
    try {
      await updateDoc(doc(db, "orders", selectedOrder.id), {
        orderStatus: "DISPATCHED",
        courierDetails: {
          partnerName: courierPartner,
          trackingNumber: trackingNumber || ("TRK-" + Math.floor(100000 + Math.random() * 900000)),
          dispatchedAt: new Date().toISOString(),
        },
        updatedAt: new Date().toISOString(),
      });
      setShowDispatchModal(false);
      setSelectedOrder(null);
      setTrackingNumber("");
      snackbar.success("Order dispatched via " + courierPartner);
    } catch (e) {
      console.error(e);
      snackbar.error("Failed to dispatch order.");
    }
  };

  const handleMarkDelivered = async (orderId: string) => {
    try {
      await updateDoc(doc(db, "orders", orderId), {
        orderStatus: "DELIVERED",
        paymentStatus: "VERIFIED",
        updatedAt: new Date().toISOString(),
      });
      snackbar.success("Order marked as delivered.");
    } catch (e) {
      console.error(e);
      snackbar.error("Failed to mark order as delivered.");
    }
  };

  // Slide Management
  const handleSaveSlide = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!slideTitle.trim()) {
      snackbar.warning("Slide title is required.");
      return;
    }
    const data = {
      title: slideTitle,
      subtitle: slideSubtitle,
      kicker: slideKicker || "QUICKYSEWA PROMOTION",
      ctaText: slideCtaText || "Explore",
      ctaLink: slideCtaLink || "/shop",
      imageUrl: slideImageUrl || "/images/hero-camera.png",
      active: slideActive,
      order: editingSlideId ? (slides.find(s => s.id === editingSlideId)?.order || slides.length + 1) : slides.length + 1,
    };

    try {
      if (editingSlideId) {
        await setDoc(doc(db, "heroSlides", editingSlideId), data, { merge: true });
        snackbar.success("Banner updated.");
      } else {
        await addDoc(collection(db, "heroSlides"), data);
        snackbar.success("Banner added.");
      }
      // Reset form
      setEditingSlideId(null);
      setSlideTitle("");
      setSlideSubtitle("");
      setSlideKicker("");
      setSlideCtaText("Learn More");
      setSlideCtaLink("/shop");
      setSlideImageUrl("/images/hero-camera.png");
      setSlideActive(true);
    } catch (err) {
      console.error(err);
      snackbar.error("Error saving banner.");
    }
  };

  const handleEditSlide = (slide: HeroSlide) => {
    setEditingSlideId(slide.id);
    setSlideTitle(slide.title);
    setSlideSubtitle(slide.subtitle);
    setSlideKicker(slide.kicker);
    setSlideCtaText(slide.ctaText);
    setSlideCtaLink(slide.ctaLink);
    setSlideImageUrl(slide.imageUrl);
    setSlideActive(slide.active);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleDeleteSlide = async (id: string) => {
    if (!confirm("Are you sure you want to delete this promotional banner?")) return;
    try {
      await deleteDoc(doc(db, "heroSlides", id));
      snackbar.success("Banner deleted.");
    } catch (err) {
      console.error(err);
      snackbar.error("Failed to delete banner.");
    }
  };

  const handleToggleSlideActive = async (slide: HeroSlide) => {
    try {
      await updateDoc(doc(db, "heroSlides", slide.id), { active: !slide.active });
      snackbar.success("Banner status updated.");
    } catch (err) {
      console.error(err);
      snackbar.error("Failed to update banner status.");
    }
  };

  const [uploadingBanner, setUploadingBanner] = useState(false);
  const [uploadingProductImg, setUploadingProductImg] = useState(false);
  const [uploadingUsedImg, setUploadingUsedImg] = useState(false);

  // Cloudinary image file handlers
  const handleImageFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploadingBanner(true);
    try {
      const secureUrl = await uploadToCloudinary(file, "video_care/banners");
      setSlideImageUrl(secureUrl);
      snackbar.success("Banner uploaded to Cloudinary successfully!");
    } catch (err: any) {
      console.error("Banner upload error:", err);
      snackbar.error(err.message || "Failed to upload banner to Cloudinary.");
    } finally {
      setUploadingBanner(false);
    }
  };

  const handleProductImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploadingProductImg(true);
    try {
      const secureUrl = await uploadToCloudinary(file, "video_care/products");
      setProdImageUrl(secureUrl);
      snackbar.success("Product image uploaded to Cloudinary!");
    } catch (err: any) {
      console.error("Product upload error:", err);
      snackbar.error(err.message || "Failed to upload product image.");
    } finally {
      setUploadingProductImg(false);
    }
  };

  const handleUsedImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploadingUsedImg(true);
    try {
      const secureUrl = await uploadToCloudinary(file, "video_care/preowned");
      setUsedImage(secureUrl);
      snackbar.success("Pre-owned gear photo uploaded to Cloudinary!");
    } catch (err: any) {
      console.error("Pre-owned upload error:", err);
      snackbar.error(err.message || "Failed to upload gear photo.");
    } finally {
      setUploadingUsedImg(false);
    }
  };

  // Category Management
  const handleSaveCategory = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!catName.trim()) {
      snackbar.warning("Category name is required.");
      return;
    }
    const slug = catSlug.trim() || catName.toLowerCase().replace(/[^a-z0-9]+/g, "-");
    const data = {
      name: catName,
      slug,
      description: catDesc,
      itemCount: 0,
    };
    try {
      await addDoc(collection(db, "categories"), data);
      snackbar.success("Category created.");
      setCatName("");
      setCatSlug("");
      setCatDesc("");
    } catch (err) {
      console.error(err);
      snackbar.error("Error saving category.");
    }
  };

  const handleDeleteCategory = async (id: string) => {
    if (!confirm("Delete this category?")) return;
    try {
      await deleteDoc(doc(db, "categories", id));
      snackbar.success("Category removed.");
    } catch (err) {
      console.error(err);
      snackbar.error("Failed to remove category.");
    }
  };

  // Product Management
  const handleSaveProduct = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!prodName.trim()) return;
    const stock = Number(prodStock) || 0;
    const data = {
      name: prodName,
      title: prodName,
      brand: prodBrand,
      categoryId: prodCategory.toLowerCase(),
      categoryName: prodCategory,
      category: prodCategory,
      price: Number(prodPrice) || 0,
      priceNpr: Number(prodPrice) || 0,
      stockQuantity: stock,
      images: [prodImageUrl],
      imageUrl: prodImageUrl,
      active: stock > 0,
      inStock: stock > 0,
      availabilityType: stock > 0 ? "IN_STOCK" : "OUT_OF_STOCK",
      condition: "Brand New",
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    try {
      await addDoc(collection(db, "products"), data);
      snackbar.success("Product added to catalog.");
      setProdName("");
      setProdPrice("120000");
      setProdStock("5");
    } catch (err) {
      console.error(err);
      snackbar.error("Failed to add product.");
    }
  };

  const handleToggleProductStock = async (product: ProductItem) => {
    try {
      const currentActive = product.active !== false;
      const nextActive = !currentActive;
      await updateDoc(doc(db, "products", product.id), {
        active: nextActive,
        stockQuantity: nextActive ? 5 : 0,
        inStock: nextActive,
        updatedAt: new Date().toISOString(),
      });
      snackbar.success("Stock updated.");
    } catch (err) {
      console.error(err);
      snackbar.error("Failed to update stock.");
    }
  };

  // Used Gear Handlers
  const handleSaveUsedProduct = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!usedName.trim()) {
      snackbar.warning("Equipment name is required.");
      return;
    }

    const defectsArray = usedDefects
      .split("\n")
      .map((s) => s.trim())
      .filter((s) => s.length > 0);

    const accessoriesArray = usedAccessories
      .split("\n")
      .map((s) => s.trim())
      .filter((s) => s.length > 0);

    const now = new Date().toISOString();
    const itemData = {
      name: usedName.trim(),
      brand: usedBrand.trim(),
      model: usedModel.trim(),
      categoryName: usedCategory,
      conditionGrade: usedGrade,
      price: Number(usedPrice) || 0,
      originalNewPrice: Number(usedOriginalPrice) || undefined,
      usageMetric: usedUsageMetric.trim(),
      metricType: usedMetricType,
      conditionDescription: usedConditionDesc.trim(),
      knownDefects: defectsArray,
      functionalTestStatus: usedFunctionalStatus,
      testNotes: usedTestNotes.trim(),
      includedAccessories: accessoriesArray,
      warrantyDetails: usedWarranty.trim(),
      returnEligibility: true,
      returnWindowDays: 7,
      images: [usedImage.trim()],
      serialNumberMasked: usedSerial.trim(),
      stockQuantity: usedActive ? 1 : 0,
      active: usedActive,
      updatedAt: now,
    };

    try {
      if (editingUsedId) {
        await setDoc(doc(db, "usedProducts", editingUsedId), itemData, { merge: true });
        snackbar.success("Pre-owned equipment updated.");
      } else {
        await addDoc(collection(db, "usedProducts"), {
          ...itemData,
          createdAt: now,
        });
        snackbar.success("New pre-owned gear listed in catalog.");
      }
      handleCancelUsedEdit();
    } catch (err) {
      console.error(err);
      snackbar.error("Failed to save used equipment listing.");
    }
  };

  const handleEditUsedProduct = (item: CertifiedUsedItem) => {
    setEditingUsedId(item.id);
    setUsedName(item.name || "");
    setUsedBrand(item.brand || "Sony");
    setUsedModel(item.model || "");
    setUsedCategory(item.categoryName || "Cameras");
    setUsedGrade(item.conditionGrade || "EXCELLENT");
    setUsedPrice(String(item.price || "0"));
    setUsedOriginalPrice(String(item.originalNewPrice || "0"));
    setUsedUsageMetric(item.usageMetric || "");
    setUsedMetricType(item.metricType || "SHUTTER");
    setUsedConditionDesc(item.conditionDescription || "");
    setUsedDefects((item.knownDefects || []).join("\n"));
    setUsedFunctionalStatus(item.functionalTestStatus || "TESTED_FULLY_FUNCTIONAL");
    setUsedTestNotes(item.testNotes || "");
    setUsedAccessories((item.includedAccessories || []).join("\n"));
    setUsedWarranty(item.warrantyDetails || "90-Day Comprehensive QuickySewa Lab Warranty");
    setUsedSerial(item.serialNumberMasked || "");
    setUsedImage(item.images?.[0] || "/images/products/canon_eos.jpg");
    setUsedActive(item.active !== false && item.stockQuantity > 0);
    window.scrollTo({ top: 300, behavior: "smooth" });
  };

  const handleCancelUsedEdit = () => {
    setEditingUsedId(null);
    setUsedName("");
    setUsedBrand("Sony");
    setUsedModel("");
    setUsedCategory("Cameras");
    setUsedGrade("EXCELLENT");
    setUsedPrice("165000");
    setUsedOriginalPrice("245000");
    setUsedUsageMetric("14,200 Shutter Actuations");
    setUsedMetricType("SHUTTER");
    setUsedConditionDesc("");
    setUsedDefects("");
    setUsedFunctionalStatus("TESTED_FULLY_FUNCTIONAL");
    setUsedTestNotes("");
    setUsedAccessories("");
    setUsedWarranty("90-Day Comprehensive QuickySewa Lab Warranty");
    setUsedSerial("");
    setUsedImage("/images/products/canon_eos.jpg");
    setUsedActive(true);
  };

  const handleDeleteUsedProduct = async (item: CertifiedUsedItem) => {
    if (!confirm(`Are you sure you want to delete '${item.name}' from certified inventory?`)) return;
    try {
      await deleteDoc(doc(db, "usedProducts", item.id));
      snackbar.success("Pre-owned item removed.");
    } catch (err) {
      console.error(err);
      snackbar.error("Failed to delete item.");
    }
  };

  const handleToggleUsedStock = async (item: CertifiedUsedItem) => {
    try {
      const isCurrentlyActive = item.active !== false && item.stockQuantity > 0;
      const nextActive = !isCurrentlyActive;
      await setDoc(
        doc(db, "usedProducts", item.id),
        {
          active: nextActive,
          stockQuantity: nextActive ? 1 : 0,
          updatedAt: new Date().toISOString(),
        },
        { merge: true }
      );
      snackbar.success(nextActive ? "Item marked as Available (In Stock)." : "Item marked as SOLD.");
    } catch (err) {
      console.error(err);
      snackbar.error("Failed to update status.");
    }
  };

  // Filter used products
  const filteredUsedProducts = useMemo(() => {
    const q = usedSearch.toLowerCase().trim();
    return usedProducts.filter((item) => {
      const matchesSearch =
        !q ||
        item.name.toLowerCase().includes(q) ||
        item.brand.toLowerCase().includes(q) ||
        item.model.toLowerCase().includes(q) ||
        (item.serialNumberMasked && item.serialNumberMasked.toLowerCase().includes(q)) ||
        (item.usageMetric && item.usageMetric.toLowerCase().includes(q));

      const matchesGrade = usedGradeFilter === "ALL" || item.conditionGrade === usedGradeFilter;
      const matchesCategory = usedCategoryFilter === "ALL" || item.categoryName === usedCategoryFilter;

      const inStock = item.active !== false && item.stockQuantity > 0;
      const matchesStatus =
        usedStatusFilter === "ALL" ||
        (usedStatusFilter === "IN_STOCK" && inStock) ||
        (usedStatusFilter === "SOLD" && !inStock);

      return matchesSearch && matchesGrade && matchesCategory && matchesStatus;
    });
  }, [usedProducts, usedSearch, usedGradeFilter, usedCategoryFilter, usedStatusFilter]);

  // Settings
  const handleSaveSettings = async (e: React.FormEvent) => {
    e.preventDefault();
    setSavingSettings(true);
    try {
      await setDoc(
        doc(db, "settings", "commercial"),
        {
          externalTechnicianCommissionPct: Number(techSplit),
          sharmaVideoCareCommissionPct: Number(svcSplit),
          deliveryNationwideFeeDefault: Number(deliveryFee),
          updatedAt: new Date().toISOString(),
        },
        { merge: true }
      );
      snackbar.success("Settings saved.");
    } catch (err) {
      console.error(err);
      snackbar.error("Failed to save settings.");
    } finally {
      setSavingSettings(false);
    }
  };

  const getDeviceName = (r: ServiceRequest) => {
    const raw = r as any;
    if (raw.deviceBrand) return `${raw.deviceBrand} ${raw.deviceModel || ""}`.trim();
    return r.title || r.categoryName || "Optical Equipment";
  };

  const getIssueText = (r: ServiceRequest) => {
    const raw = r as any;
    return r.description || raw.issueDescription || "Diagnosis required";
  };

  const getOrderTotal = (o: OrderRecord) => {
    return o.total ?? (o as any).totalNpr ?? 0;
  };

  const getOrderCity = (o: OrderRecord) => {
    const addr = o.shippingAddress || (o as any).deliveryAddress;
    return addr ? `${addr.city || ""}, ${addr.province || ""}` : "Janakpur";
  };

  const getPaymentAmount = (p: PaymentProof) => {
    return p.amount ?? (p as any).amountNpr ?? 0;
  };

  const getPaymentMethod = (p: PaymentProof) => {
    return p.method || (p as any).paymentMethod || "Bank Transfer";
  };

  // Filtered lists
  const filteredRepairs = useMemo(() => {
    return serviceRequests.filter((r) => {
      const devName = getDeviceName(r).toLowerCase();
      const issue = getIssueText(r).toLowerCase();
      const q = searchQuery.toLowerCase();
      const matchesSearch =
        searchQuery === "" ||
        devName.includes(q) ||
        issue.includes(q) ||
        r.id.toLowerCase().includes(q);

      if (!matchesSearch) return false;
      if (repairFilter === "ALL") return true;
      if (repairFilter === "PENDING") return r.status === "REQUESTED" || r.status === "UNDER_REVIEW" || r.status === "INSPECTION_SCHEDULED";
      if (repairFilter === "QUOTE_SENT") return r.status === "QUOTE_SENT";
      if (repairFilter === "COMPLETED") return r.status === "COMPLETED" || r.status === "CLOSED";
      return r.status === repairFilter;
    });
  }, [serviceRequests, searchQuery, repairFilter]);

  const filteredOrders = useMemo(() => {
    return orders.filter((o) => {
      const q = searchQuery.toLowerCase();
      const matchesSearch =
        searchQuery === "" ||
        o.id.toLowerCase().includes(q) ||
        o.customerName?.toLowerCase().includes(q) ||
        getOrderCity(o).toLowerCase().includes(q);

      if (!matchesSearch) return false;
      if (orderFilter === "ALL") return true;
      return o.orderStatus === orderFilter;
    });
  }, [orders, searchQuery, orderFilter]);

  const filteredPayments = useMemo(() => {
    return payments.filter((p) => {
      if (paymentFilter === "ALL") return true;
      return p.status === paymentFilter;
    });
  }, [payments, paymentFilter]);

  // Pending counts
  const pendingRepairsCount = serviceRequests.filter((r) => r.status === "REQUESTED" || r.status === "UNDER_REVIEW" || r.status === "INSPECTION_SCHEDULED").length;
  const pendingOrdersCount = orders.filter((o) => o.orderStatus === "PENDING_PAYMENT" || o.orderStatus === "PAYMENT_SUBMITTED" || o.orderStatus === "CONFIRMED").length;
  const pendingPaymentsCount = payments.filter((p) => p.status === "PENDING_VERIFICATION" || p.status === "PENDING" || (p.status as any) === "SUBMITTED").length;

  return (
    <div className="admin-layout">
      {/* Toast */}
      {/* Sidebar */}
      <aside className={"admin-sidebar" + (sidebarOpen ? " open" : "")}>
        <div className="admin-sidebar-header">
          <Link href="/admin" className="admin-brand">
            <div className="admin-brand-icon">QS</div>
            <div>
              <div className="admin-brand-title">QuickySewa</div>
              <div className="admin-brand-sub">Admin Console</div>
            </div>
          </Link>
          <button
            type="button"
            className="admin-footer-btn"
            style={{ display: sidebarOpen ? "flex" : "none" }}
            onClick={() => setSidebarOpen(false)}
          >
            <X size={16} />
          </button>
        </div>

        <nav className="admin-nav">
          <Link
            href="/admin"
            className={"admin-nav-item" + (activeTab === "overview" ? " active" : "")}
            onClick={() => { setActiveTab("overview"); setSidebarOpen(false); }}
          >
            <span className="admin-nav-label">
              <LayoutDashboard size={18} />
              <span>Overview</span>
            </span>
          </Link>

          <Link
            href="/admin/repairs"
            className={"admin-nav-item" + (activeTab === "repairs" ? " active" : "")}
            onClick={() => { setActiveTab("repairs"); setSidebarOpen(false); }}
          >
            <span className="admin-nav-label">
              <Wrench size={18} />
              <span>Repairs</span>
            </span>
            {pendingRepairsCount > 0 && <span className="admin-nav-badge">{pendingRepairsCount}</span>}
          </Link>

          <Link
            href="/admin/orders"
            className={"admin-nav-item" + (activeTab === "orders" ? " active" : "")}
            onClick={() => { setActiveTab("orders"); setSidebarOpen(false); }}
          >
            <span className="admin-nav-label">
              <Package size={18} />
              <span>Orders</span>
            </span>
            {pendingOrdersCount > 0 && <span className="admin-nav-badge">{pendingOrdersCount}</span>}
          </Link>

          <Link
            href="/admin/payments"
            className={"admin-nav-item" + (activeTab === "payments" ? " active" : "")}
            onClick={() => { setActiveTab("payments"); setSidebarOpen(false); }}
          >
            <span className="admin-nav-label">
              <CreditCard size={18} />
              <span>Payments</span>
            </span>
            {pendingPaymentsCount > 0 && <span className="admin-nav-badge">{pendingPaymentsCount}</span>}
          </Link>

          <Link
            href="/admin/carousel"
            className={"admin-nav-item" + (activeTab === "carousel" ? " active" : "")}
            onClick={() => { setActiveTab("carousel"); setSidebarOpen(false); }}
          >
            <span className="admin-nav-label">
              <ImageIcon size={18} />
              <span>Hero Banners</span>
            </span>
            <span className="admin-nav-badge">{slides.length}</span>
          </Link>

          <Link
            href="/admin/categories"
            className={"admin-nav-item" + (activeTab === "categories" ? " active" : "")}
            onClick={() => { setActiveTab("categories"); setSidebarOpen(false); }}
          >
            <span className="admin-nav-label">
              <FolderTree size={18} />
              <span>Categories</span>
            </span>
            <span className="admin-nav-badge">{categories.length}</span>
          </Link>

          <Link
            href="/admin/products"
            className={"admin-nav-item" + (activeTab === "products" ? " active" : "")}
            onClick={() => { setActiveTab("products"); setSidebarOpen(false); }}
          >
            <span className="admin-nav-label">
              <Box size={18} />
              <span>Products</span>
            </span>
            <span className="admin-nav-badge">{products.length}</span>
          </Link>

          <Link
            href="/admin/used"
            className={"admin-nav-item" + (activeTab === "used" ? " active" : "")}
            onClick={() => { setActiveTab("used"); setSidebarOpen(false); }}
          >
            <span className="admin-nav-label">
              <Sparkles size={18} />
              <span>Pre-Owned Gear</span>
            </span>
            <span className="admin-nav-badge">{usedProducts.length}</span>
          </Link>

          <Link
            href="/admin/notifications"
            className={"admin-nav-item" + (activeTab === "notifications" ? " active" : "")}
            onClick={() => { setActiveTab("notifications"); setSidebarOpen(false); }}
          >
            <span className="admin-nav-label">
              <Bell size={18} />
              <span>Notifications</span>
            </span>
          </Link>

          <Link
            href="/admin/settings"
            className={"admin-nav-item" + (activeTab === "settings" ? " active" : "")}
            onClick={() => { setActiveTab("settings"); setSidebarOpen(false); }}
          >
            <span className="admin-nav-label">
              <Settings size={18} />
              <span>Settings</span>
            </span>
          </Link>
        </nav>

        <div className="admin-sidebar-footer">
          <div className="admin-user-info">
            <div className="admin-user-avatar">
              {user?.name?.[0]?.toUpperCase() || "A"}
            </div>
            <div className="admin-user-details">
              <div className="admin-user-name">{user?.name || "Administrator"}</div>
              <div className="admin-user-role">{firebaseUser?.email || "admin@sharmavideocare.com"}</div>
            </div>
          </div>

          <Link href="/" className="admin-footer-btn">
            <ExternalLink size={14} />
            <span>Storefront</span>
          </Link>

          <button
            type="button"
            className="admin-footer-btn"
            onClick={() => signOut().then(() => snackbar.success("You have been signed out."))}
          >
            <LogOut size={14} />
            <span>Sign Out</span>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="admin-main">
        {/* Top Header */}
        <header className="admin-header">
          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
            <button
              type="button"
              className="admin-btn admin-btn-secondary admin-btn-sm"
              style={{ display: "none" }}
              onClick={() => setSidebarOpen(!sidebarOpen)}
            >
              <Menu size={16} />
            </button>
            <div className="admin-header-title">
              {activeTab === "overview" && "Dashboard Overview"}
              {activeTab === "repairs" && "Service & Repair Tickets"}
              {activeTab === "orders" && "Store Orders & Fulfillment"}
              {activeTab === "payments" && "Bank Payment Slips"}
              {activeTab === "carousel" && "Homepage Hero Banners"}
              {activeTab === "categories" && "Store Categories"}
              {activeTab === "products" && "Equipment & Parts Catalog"}
              {activeTab === "used" && "Certified Pre-Owned & Second-Hand Gear"}
              {activeTab === "notifications" && "Notifications Broadcast & Alerts"}
              {activeTab === "settings" && "Commercial & Commission Settings"}
            </div>
          </div>

          <div className="admin-header-actions">
            {activeTab === "carousel" && (
              <button
                type="button"
                className="admin-btn admin-btn-primary admin-btn-sm"
                onClick={() => {
                  setEditingSlideId(null);
                  setSlideTitle("");
                  setSlideSubtitle("");
                  setSlideKicker("");
                  window.scrollTo({ top: 0, behavior: "smooth" });
                }}
              >
                <Plus size={14} />
                <span>New Banner</span>
              </button>
            )}

            {activeTab === "categories" && (
              <button
                type="button"
                className="admin-btn admin-btn-primary admin-btn-sm"
                onClick={() => {
                  window.scrollTo({ top: 0, behavior: "smooth" });
                }}
              >
                <Plus size={14} />
                <span>New Category</span>
              </button>
            )}

            <div className="admin-badge badge-neutral">
              {role === "admin" ? "Admin Mode" : role}
            </div>
          </div>
        </header>

        {/* View Content */}
        <main className="admin-content">
          {/* TAB: OVERVIEW */}
          {activeTab === "overview" && (
            <div>
              {/* KPI Cards */}
              <div className="admin-stats-grid">
                <div className="admin-stat-card">
                  <div>
                    <div className="admin-stat-label">Total Repairs</div>
                    <div className="admin-stat-value">{serviceRequests.length}</div>
                  </div>
                  <div className="admin-stat-icon">
                    <Wrench size={20} />
                  </div>
                </div>

                <div className="admin-stat-card">
                  <div>
                    <div className="admin-stat-label">Pending Repairs</div>
                    <div className="admin-stat-value">{pendingRepairsCount}</div>
                  </div>
                  <div className="admin-stat-icon" style={{ color: "#d97706" }}>
                    <ShieldCheck size={20} />
                  </div>
                </div>

                <div className="admin-stat-card">
                  <div>
                    <div className="admin-stat-label">Active Orders</div>
                    <div className="admin-stat-value">{pendingOrdersCount}</div>
                  </div>
                  <div className="admin-stat-icon" style={{ color: "#2563eb" }}>
                    <Package size={20} />
                  </div>
                </div>

                <div className="admin-stat-card">
                  <div>
                    <div className="admin-stat-label">Pending Payments</div>
                    <div className="admin-stat-value">{pendingPaymentsCount}</div>
                  </div>
                  <div className="admin-stat-icon" style={{ color: "#dc2626" }}>
                    <CreditCard size={20} />
                  </div>
                </div>

                <div className="admin-stat-card">
                  <div>
                    <div className="admin-stat-label">Pre-Owned Inventory</div>
                    <div className="admin-stat-value">
                      {usedProducts.filter(u => u.active !== false && u.stockQuantity > 0).length}
                      <span style={{ fontSize: "14px", fontWeight: 500, color: "var(--admin-text-muted)", marginLeft: "4px" }}>
                        / {usedProducts.length}
                      </span>
                    </div>
                  </div>
                  <div className="admin-stat-icon" style={{ color: "#16a34a" }}>
                    <Sparkles size={20} />
                  </div>
                </div>
              </div>

              {/* Two Clean Recent Tables */}
              <div style={{ display: "grid", gridTemplateColumns: "1fr", gap: "24px" }}>
                {/* Recent Repairs */}
                <div className="admin-card">
                  <div className="admin-card-header">
                    <div className="admin-card-title">Recent Repair Tickets</div>
                    <button
                      type="button"
                      className="admin-btn admin-btn-secondary admin-btn-sm"
                      onClick={() => navigateToTab("repairs")}
                    >
                      <span>View All ({serviceRequests.length})</span>
                      <ArrowRight size={14} />
                    </button>
                  </div>
                  <div className="admin-table-container">
                    <table className="admin-table">
                      <thead>
                        <tr>
                          <th>Ticket ID</th>
                          <th>Device</th>
                          <th>Issue</th>
                          <th>Status</th>
                          <th>Technician</th>
                          <th>Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        {serviceRequests.slice(0, 5).map((req) => (
                          <tr key={req.id}>
                            <td style={{ fontWeight: 600 }}>{req.id.slice(0, 8)}...</td>
                            <td>{getDeviceName(req)}</td>
                            <td style={{ maxWidth: "240px", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                              {getIssueText(req)}
                            </td>
                            <td>
                              <span className={"admin-badge " + (
                                req.status === "COMPLETED" ? "badge-success" :
                                (req.status === "REQUESTED" || req.status === "UNDER_REVIEW") ? "badge-warning" : "badge-info"
                              )}>
                                {req.status}
                              </span>
                            </td>
                            <td>{req.assignedTechnicianName || "Unassigned"}</td>
                            <td>
                              <button
                                type="button"
                                className="admin-btn admin-btn-secondary admin-btn-sm"
                                onClick={() => {
                                  setSelectedRequest(req);
                                  setShowAssignModal(true);
                                }}
                              >
                                Assign
                              </button>
                            </td>
                          </tr>
                        ))}
                        {serviceRequests.length === 0 && (
                          <tr>
                            <td colSpan={6} style={{ textAlign: "center", padding: "24px", color: "var(--admin-text-muted)" }}>
                              No repair tickets found.
                            </td>
                          </tr>
                        )}
                      </tbody>
                    </table>
                  </div>
                </div>

                {/* Recent Orders */}
                <div className="admin-card">
                  <div className="admin-card-header">
                    <div className="admin-card-title">Recent Store Orders</div>
                    <button
                      type="button"
                      className="admin-btn admin-btn-secondary admin-btn-sm"
                      onClick={() => navigateToTab("orders")}
                    >
                      <span>View All ({orders.length})</span>
                      <ArrowRight size={14} />
                    </button>
                  </div>
                  <div className="admin-table-container">
                    <table className="admin-table">
                      <thead>
                        <tr>
                          <th>Order ID</th>
                          <th>Customer</th>
                          <th>Total</th>
                          <th>Payment</th>
                          <th>Fulfillment</th>
                          <th>Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        {orders.slice(0, 5).map((order) => (
                          <tr key={order.id}>
                            <td style={{ fontWeight: 600 }}>{order.id.slice(0, 8)}...</td>
                            <td>{order.customerName || "Customer"}</td>
                            <td style={{ fontWeight: 600 }}>
                          NPR {getOrderTotal(order).toLocaleString()}
                          {order.priceVerified === false && (
                            <div style={{ color: "#b45309", fontSize: "0.72rem", fontWeight: 700 }}>Verify prices</div>
                          )}
                        </td>
                            <td>
                              <span className={"admin-badge " + (order.paymentStatus === "VERIFIED" ? "badge-success" : "badge-warning")}>
                                {order.paymentStatus}
                              </span>
                            </td>
                            <td>
                              <span className={"admin-badge " + (
                                order.orderStatus === "DELIVERED" ? "badge-success" :
                                order.orderStatus === "DISPATCHED" ? "badge-info" : "badge-neutral"
                              )}>
                                {order.orderStatus}
                              </span>
                            </td>
                            <td>
                              <button
                                type="button"
                                className="admin-btn admin-btn-secondary admin-btn-sm"
                                onClick={() => {
                                  setSelectedOrder(order);
                                  setShowDispatchModal(true);
                                }}
                              >
                                Dispatch
                              </button>
                            </td>
                          </tr>
                        ))}
                        {orders.length === 0 && (
                          <tr>
                            <td colSpan={6} style={{ textAlign: "center", padding: "24px", color: "var(--admin-text-muted)" }}>
                              No orders found.
                            </td>
                          </tr>
                        )}
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* TAB: REPAIRS */}
          {activeTab === "repairs" && (
            <div>
              <div className="admin-filter-bar">
                <button
                  type="button"
                  className={"admin-filter-btn" + (repairFilter === "ALL" ? " active" : "")}
                  onClick={() => setRepairFilter("ALL")}
                >
                  All ({serviceRequests.length})
                </button>
                <button
                  type="button"
                  className={"admin-filter-btn" + (repairFilter === "PENDING" ? " active" : "")}
                  onClick={() => setRepairFilter("PENDING")}
                >
                  Pending ({pendingRepairsCount})
                </button>
                <button
                  type="button"
                  className={"admin-filter-btn" + (repairFilter === "QUOTE_SENT" ? " active" : "")}
                  onClick={() => setRepairFilter("QUOTE_SENT")}
                >
                  Quote Sent
                </button>
                <button
                  type="button"
                  className={"admin-filter-btn" + (repairFilter === "COMPLETED" ? " active" : "")}
                  onClick={() => setRepairFilter("COMPLETED")}
                >
                  Completed
                </button>
              </div>

              <div className="admin-table-container">
                <table className="admin-table">
                  <thead>
                    <tr>
                      <th>Ticket ID</th>
                      <th>Customer</th>
                      <th>Device &amp; Model</th>
                      <th>Reported Issue</th>
                      <th>Status</th>
                      <th>Technician</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredRepairs.map((req) => (
                      <tr key={req.id}>
                        <td style={{ fontWeight: 600 }}>{req.id.slice(0, 8)}...</td>
                        <td>
                          <div>{req.customerName || "Customer"}</div>
                          <div style={{ fontSize: "11px", color: "var(--admin-text-muted)" }}>{req.customerPhone}</div>
                        </td>
                        <td>{getDeviceName(req)}</td>
                        <td style={{ maxWidth: "260px" }}>{getIssueText(req)}</td>
                        <td>
                          <span className={"admin-badge " + (
                            req.status === "COMPLETED" ? "badge-success" :
                            (req.status === "REQUESTED" || req.status === "UNDER_REVIEW") ? "badge-warning" : "badge-info"
                          )}>
                            {req.status}
                          </span>
                        </td>
                        <td>{req.assignedTechnicianName || "Unassigned"}</td>
                        <td>
                          <div style={{ display: "flex", gap: "6px" }}>
                            <button
                              type="button"
                              className="admin-btn admin-btn-secondary admin-btn-sm"
                              onClick={() => {
                                setSelectedRequest(req);
                                setShowAssignModal(true);
                              }}
                            >
                              Assign
                            </button>
                            <button
                              type="button"
                              className="admin-btn admin-btn-primary admin-btn-sm"
                              onClick={() => {
                                setSelectedRequest(req);
                                setShowQuoteModal(true);
                              }}
                            >
                              Quote
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                    {filteredRepairs.length === 0 && (
                      <tr>
                        <td colSpan={7} style={{ textAlign: "center", padding: "32px", color: "var(--admin-text-muted)" }}>
                          No tickets matching filter.
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* TAB: ORDERS */}
          {activeTab === "orders" && (
            <div>
              <div className="admin-filter-bar">
                <button
                  type="button"
                  className={"admin-filter-btn" + (orderFilter === "ALL" ? " active" : "")}
                  onClick={() => setOrderFilter("ALL")}
                >
                  All ({orders.length})
                </button>
                <button
                  type="button"
                  className={"admin-filter-btn" + (orderFilter === "PENDING_PAYMENT" ? " active" : "")}
                  onClick={() => setOrderFilter("PENDING_PAYMENT")}
                >
                  Pending Payment
                </button>
                <button
                  type="button"
                  className={"admin-filter-btn" + (orderFilter === "CONFIRMED" ? " active" : "")}
                  onClick={() => setOrderFilter("CONFIRMED")}
                >
                  Confirmed
                </button>
                <button
                  type="button"
                  className={"admin-filter-btn" + (orderFilter === "DISPATCHED" ? " active" : "")}
                  onClick={() => setOrderFilter("DISPATCHED")}
                >
                  Dispatched
                </button>
                <button
                  type="button"
                  className={"admin-filter-btn" + (orderFilter === "DELIVERED" ? " active" : "")}
                  onClick={() => setOrderFilter("DELIVERED")}
                >
                  Delivered
                </button>
              </div>

              <div className="admin-table-container">
                <table className="admin-table">
                  <thead>
                    <tr>
                      <th>Order ID</th>
                      <th>Customer &amp; Address</th>
                      <th>Total</th>
                      <th>Payment</th>
                      <th>Status</th>
                      <th>Courier Tracking</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredOrders.map((order) => (
                      <tr key={order.id}>
                        <td style={{ fontWeight: 600 }}>{order.id.slice(0, 8)}...</td>
                        <td>
                          <div>{order.customerName || "Customer"}</div>
                          <div style={{ fontSize: "11px", color: "var(--admin-text-muted)" }}>
                            {getOrderCity(order)}
                          </div>
                        </td>
                        <td style={{ fontWeight: 600 }}>
                          NPR {getOrderTotal(order).toLocaleString()}
                          {order.priceVerified === false && (
                            <div style={{ color: "#b45309", fontSize: "0.72rem", fontWeight: 700 }}>Verify prices</div>
                          )}
                        </td>
                        <td>
                          <span className={"admin-badge " + (order.paymentStatus === "VERIFIED" ? "badge-success" : "badge-warning")}>
                            {order.paymentStatus}
                          </span>
                        </td>
                        <td>
                          <span className={"admin-badge " + (
                            order.orderStatus === "DELIVERED" ? "badge-success" :
                            order.orderStatus === "DISPATCHED" ? "badge-info" : "badge-neutral"
                          )}>
                            {order.orderStatus}
                          </span>
                        </td>
                        <td>
                          {order.courierDetails ? (
                            <div style={{ fontSize: "12px" }}>
                              <div><strong>{order.courierDetails.partnerName}</strong></div>
                              <div style={{ color: "var(--admin-text-muted)" }}>{order.courierDetails.trackingNumber}</div>
                            </div>
                          ) : (
                            <span style={{ color: "var(--admin-text-muted)", fontSize: "12px" }}>Not dispatched</span>
                          )}
                        </td>
                        <td>
                          <div style={{ display: "flex", gap: "6px" }}>
                            <button
                              type="button"
                              className="admin-btn admin-btn-secondary admin-btn-sm"
                              onClick={() => {
                                setSelectedOrder(order);
                                setShowDispatchModal(true);
                              }}
                            >
                              Dispatch
                            </button>
                            {order.orderStatus !== "DELIVERED" && (
                              <button
                                type="button"
                                className="admin-btn admin-btn-primary admin-btn-sm"
                                onClick={() => handleMarkDelivered(order.id)}
                              >
                                Delivered
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))}
                    {filteredOrders.length === 0 && (
                      <tr>
                        <td colSpan={7} style={{ textAlign: "center", padding: "32px", color: "var(--admin-text-muted)" }}>
                          No orders matching filter.
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* TAB: PAYMENTS */}
          {activeTab === "payments" && (
            <div>
              <div className="admin-filter-bar">
                <button
                  type="button"
                  className={"admin-filter-btn" + (paymentFilter === "ALL" ? " active" : "")}
                  onClick={() => setPaymentFilter("ALL")}
                >
                  All ({payments.length})
                </button>
                <button
                  type="button"
                  className={"admin-filter-btn" + (paymentFilter === "PENDING_VERIFICATION" ? " active" : "")}
                  onClick={() => setPaymentFilter("PENDING_VERIFICATION")}
                >
                  Pending ({pendingPaymentsCount})
                </button>
                <button
                  type="button"
                  className={"admin-filter-btn" + (paymentFilter === "VERIFIED" ? " active" : "")}
                  onClick={() => setPaymentFilter("VERIFIED")}
                >
                  Verified
                </button>
                <button
                  type="button"
                  className={"admin-filter-btn" + (paymentFilter === "REJECTED" ? " active" : "")}
                  onClick={() => setPaymentFilter("REJECTED")}
                >
                  Rejected
                </button>
              </div>

              <div className="admin-table-container">
                <table className="admin-table">
                  <thead>
                    <tr>
                      <th>Ref Number</th>
                      <th>Order ID</th>
                      <th>Method</th>
                      <th>Amount</th>
                      <th>Slip Image</th>
                      <th>Status</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredPayments.map((p) => (
                      <tr key={p.id}>
                        <td style={{ fontWeight: 600 }}>{p.referenceNumber || p.id.slice(0, 8)}</td>
                        <td>{p.orderId?.slice(0, 8)}...</td>
                        <td>{getPaymentMethod(p)}</td>
                        <td style={{ fontWeight: 600 }}>NPR {getPaymentAmount(p).toLocaleString()}</td>
                        <td>
                          {p.proofImageUrl ? (
                            <button
                              type="button"
                              className="admin-btn admin-btn-secondary admin-btn-sm"
                              onClick={() => setViewingPaymentProof(p)}
                            >
                              <Eye size={13} />
                              <span>View Slip</span>
                            </button>
                          ) : (
                            <span style={{ color: "var(--admin-text-muted)", fontSize: "12px" }}>No slip attached</span>
                          )}
                        </td>
                        <td>
                          <span className={"admin-badge " + (
                            p.status === "VERIFIED" ? "badge-success" :
                            p.status === "REJECTED" ? "badge-danger" : "badge-warning"
                          )}>
                            {p.status}
                          </span>
                        </td>
                        <td>
                          {(p.status === "PENDING_VERIFICATION" || p.status === "PENDING" || (p.status as any) === "SUBMITTED") && (
                            <div style={{ display: "flex", gap: "6px" }}>
                              <button
                                type="button"
                                className="admin-btn admin-btn-primary admin-btn-sm"
                                onClick={() => handleVerifyPayment(p)}
                              >
                                Approve
                              </button>
                              <button
                                type="button"
                                className="admin-btn admin-btn-danger admin-btn-sm"
                                onClick={() => handleRejectPayment(p)}
                              >
                                Reject
                              </button>
                            </div>
                          )}
                        </td>
                      </tr>
                    ))}
                    {filteredPayments.length === 0 && (
                      <tr>
                        <td colSpan={7} style={{ textAlign: "center", padding: "32px", color: "var(--admin-text-muted)" }}>
                          No payment slips matching filter.
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* TAB: CAROUSEL / HERO BANNERS */}
          {activeTab === "carousel" && (
            <div>
              {/* Add / Edit Banner Form */}
              <div className="admin-card">
                <div className="admin-card-header">
                  <div className="admin-card-title">
                    {editingSlideId ? "Edit Hero Banner" : "Add New Promotional Banner"}
                  </div>
                  {editingSlideId && (
                    <button
                      type="button"
                      className="admin-btn admin-btn-secondary admin-btn-sm"
                      onClick={() => {
                        setEditingSlideId(null);
                        setSlideTitle("");
                        setSlideSubtitle("");
                        setSlideKicker("");
                      }}
                    >
                      Cancel Edit
                    </button>
                  )}
                </div>

                <form onSubmit={handleSaveSlide}>
                  <div className="admin-grid-2">
                    <div className="admin-form-group">
                      <label className="admin-label">Kicker / Badge Text</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. SERVICE BENCH, SPECIAL OFFER"
                        value={slideKicker}
                        onChange={(e) => setSlideKicker(e.target.value)}
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Headline / Title *</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. Precision Camera Diagnostics in Janakpur"
                        value={slideTitle}
                        onChange={(e) => setSlideTitle(e.target.value)}
                        required
                      />
                    </div>
                  </div>

                  <div className="admin-form-group">
                    <label className="admin-label">Subtitle / Description</label>
                    <textarea
                      className="admin-textarea"
                      rows={2}
                      placeholder="e.g. Certified sensor cleaning, shutter replacement with 90-day warranty."
                      value={slideSubtitle}
                      onChange={(e) => setSlideSubtitle(e.target.value)}
                    />
                  </div>

                  <div className="admin-grid-2">
                    <div className="admin-form-group">
                      <label className="admin-label">Call-to-Action Button Label</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. Book Diagnosis"
                        value={slideCtaText}
                        onChange={(e) => setSlideCtaText(e.target.value)}
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Target Link (URL or Path)</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. /services, /shop, /used"
                        value={slideCtaLink}
                        onChange={(e) => setSlideCtaLink(e.target.value)}
                      />
                    </div>
                  </div>

                  <div className="admin-grid-2">
                    <div className="admin-form-group">
                      <label className="admin-label">Image Source URL</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. /images/hero-camera.png or https://..."
                        value={slideImageUrl}
                        onChange={(e) => setSlideImageUrl(e.target.value)}
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Upload Banner to Cloudinary {uploadingBanner && "(Uploading...)"}</label>
                      <input
                        type="file"
                        className="admin-input"
                        accept="image/*"
                        disabled={uploadingBanner}
                        onChange={handleImageFileUpload}
                      />
                    </div>
                  </div>

                  <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginTop: "12px" }}>
                    <label style={{ display: "flex", alignItems: "center", gap: "8px", fontSize: "13px", cursor: "pointer" }}>
                      <input
                        type="checkbox"
                        checked={slideActive}
                        onChange={(e) => setSlideActive(e.target.checked)}
                      />
                      <span>Active on Homepage</span>
                    </label>

                    <button type="submit" className="admin-btn admin-btn-primary">
                      {editingSlideId ? "Update Banner" : "Save Promotional Banner"}
                    </button>
                  </div>
                </form>
              </div>

              {/* Existing Banners List */}
              <div className="admin-card">
                <div className="admin-card-header">
                  <div className="admin-card-title">Configured Hero Banners ({slides.length})</div>
                </div>

                <div className="admin-table-container">
                  <table className="admin-table">
                    <thead>
                      <tr>
                        <th>Preview</th>
                        <th>Kicker &amp; Title</th>
                        <th>Target Link</th>
                        <th>Status</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {slides.map((s) => (
                        <tr key={s.id}>
                          <td style={{ width: "90px" }}>
                            <div style={{ width: "80px", height: "48px", borderRadius: "6px", overflow: "hidden", background: "#f1f5f9", border: "1px solid var(--admin-border)", position: "relative" }}>
                              <img
                                src={s.imageUrl || "/images/hero-camera.png"}
                                alt={s.title}
                                style={{ width: "100%", height: "100%", objectFit: "cover" }}
                              />
                            </div>
                          </td>
                          <td>
                            <div style={{ fontSize: "11px", fontWeight: 700, color: "var(--admin-brand)", textTransform: "uppercase" }}>
                              {s.kicker}
                            </div>
                            <div style={{ fontWeight: 600, color: "var(--admin-text-main)" }}>{s.title}</div>
                            <div style={{ fontSize: "11.5px", color: "var(--admin-text-muted)" }}>{s.subtitle}</div>
                          </td>
                          <td>
                            <span style={{ fontSize: "12px", fontFamily: "var(--font-mono, monospace)" }}>
                              {s.ctaLink}
                            </span>
                          </td>
                          <td>
                            <button
                              type="button"
                              className={"admin-badge " + (s.active ? "badge-success" : "badge-neutral")}
                              style={{ cursor: "pointer", border: "none" }}
                              onClick={() => handleToggleSlideActive(s)}
                            >
                              {s.active ? "Active" : "Disabled"}
                            </button>
                          </td>
                          <td>
                            <div style={{ display: "flex", gap: "6px" }}>
                              <button
                                type="button"
                                className="admin-btn admin-btn-secondary admin-btn-sm"
                                onClick={() => handleEditSlide(s)}
                              >
                                <Edit2 size={13} />
                                <span>Edit</span>
                              </button>
                              <button
                                type="button"
                                className="admin-btn admin-btn-danger admin-btn-sm"
                                onClick={() => handleDeleteSlide(s.id)}
                              >
                                <Trash2 size={13} />
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* TAB: CATEGORIES */}
          {activeTab === "categories" && (
            <div>
              {/* Add Category Form */}
              <div className="admin-card">
                <div className="admin-card-header">
                  <div className="admin-card-title">Add Store Category</div>
                </div>

                <form onSubmit={handleSaveCategory}>
                  <div className="admin-grid-2">
                    <div className="admin-form-group">
                      <label className="admin-label">Category Name *</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. Mirrorless Lenses"
                        value={catName}
                        onChange={(e) => {
                          setCatName(e.target.value);
                          if (!catSlug) setCatSlug(e.target.value.toLowerCase().replace(/[^a-z0-9]+/g, "-"));
                        }}
                        required
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">URL Slug</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. lenses"
                        value={catSlug}
                        onChange={(e) => setCatSlug(e.target.value)}
                      />
                    </div>
                  </div>

                  <div className="admin-form-group">
                    <label className="admin-label">Description</label>
                    <input
                      type="text"
                      className="admin-input"
                      placeholder="Brief category summary for customer navigation"
                      value={catDesc}
                      onChange={(e) => setCatDesc(e.target.value)}
                    />
                  </div>

                  <button type="submit" className="admin-btn admin-btn-primary">
                    <Plus size={14} />
                    <span>Create Category</span>
                  </button>
                </form>
              </div>

              {/* Categories Table */}
              <div className="admin-card">
                <div className="admin-card-header">
                  <div className="admin-card-title">Active Categories ({categories.length})</div>
                </div>

                <div className="admin-table-container">
                  <table className="admin-table">
                    <thead>
                      <tr>
                        <th>Category Name</th>
                        <th>Slug</th>
                        <th>Description</th>
                        <th>Items Count</th>
                        <th>Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {categories.map((cat) => (
                        <tr key={cat.id}>
                          <td style={{ fontWeight: 600 }}>{cat.name}</td>
                          <td>
                            <span style={{ fontSize: "12px", fontFamily: "var(--font-mono, monospace)" }}>
                              /{cat.slug}
                            </span>
                          </td>
                          <td style={{ color: "var(--admin-text-muted)" }}>{cat.description || "—"}</td>
                          <td>{cat.itemCount || 0} items</td>
                          <td>
                            <button
                              type="button"
                              className="admin-btn admin-btn-danger admin-btn-sm"
                              onClick={() => handleDeleteCategory(cat.id)}
                            >
                              <Trash2 size={13} />
                              <span>Delete</span>
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* TAB: PRODUCTS */}
          {activeTab === "products" && (
            <div>
              {/* Quick Add Product */}
              <div className="admin-card">
                <div className="admin-card-header">
                  <div className="admin-card-title">Add Equipment / Product</div>
                </div>

                <form onSubmit={handleSaveProduct}>
                  <div className="admin-grid-2">
                    <div className="admin-form-group">
                      <label className="admin-label">Product Name *</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. Sony Alpha 7 IV"
                        value={prodName}
                        onChange={(e) => setProdName(e.target.value)}
                        required
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Brand</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. Sony, Canon, DJI, Nikon"
                        value={prodBrand}
                        onChange={(e) => setProdBrand(e.target.value)}
                      />
                    </div>
                  </div>

                  <div className="admin-grid-2">
                    <div className="admin-form-group">
                      <label className="admin-label">Category</label>
                      <select
                        className="admin-select"
                        value={prodCategory}
                        onChange={(e) => setProdCategory(e.target.value)}
                      >
                        <option value="Cameras">Cameras</option>
                        <option value="Lenses">Lenses</option>
                        <option value="Drones">Drones</option>
                        <option value="Audio">Audio</option>
                        <option value="Accessories">Accessories</option>
                      </select>
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Price (NPR) *</label>
                      <input
                        type="number"
                        className="admin-input"
                        value={prodPrice}
                        onChange={(e) => setProdPrice(e.target.value)}
                        required
                      />
                    </div>
                  </div>

                  <div className="admin-grid-2">
                    <div className="admin-form-group">
                      <label className="admin-label">Stock Quantity</label>
                      <input
                        type="number"
                        className="admin-input"
                        value={prodStock}
                        onChange={(e) => setProdStock(e.target.value)}
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Product Image (URL or Cloudinary Upload)</label>
                      <div style={{ display: "flex", gap: "8px" }}>
                        <input
                          type="text"
                          className="admin-input"
                          style={{ flex: 1 }}
                          value={prodImageUrl}
                          placeholder="e.g. /images/products/canon_eos.jpg or Cloudinary URL"
                          onChange={(e) => setProdImageUrl(e.target.value)}
                        />
                        <label className="admin-btn admin-btn-secondary" style={{ cursor: "pointer", margin: 0, whiteSpace: "nowrap" }}>
                          <UploadCloud size={14} />
                          <span>{uploadingProductImg ? "Uploading..." : "Upload to Cloudinary"}</span>
                          <input
                            type="file"
                            accept="image/*"
                            style={{ display: "none" }}
                            disabled={uploadingProductImg}
                            onChange={handleProductImageUpload}
                          />
                        </label>
                      </div>
                    </div>
                  </div>

                  <button type="submit" className="admin-btn admin-btn-primary">
                    <Plus size={14} />
                    <span>Add to Inventory</span>
                  </button>
                </form>
              </div>

              {/* Products Table */}
              <div className="admin-card">
                <div className="admin-card-header">
                  <div className="admin-card-title">Inventory Catalog ({products.length})</div>
                </div>

                <div className="admin-table-container">
                  <table className="admin-table">
                    <thead>
                      <tr>
                        <th>Product</th>
                        <th>Brand</th>
                        <th>Category</th>
                        <th>Price (NPR)</th>
                        <th>Stock</th>
                        <th>Status</th>
                        <th>Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {products.map((item) => {
                        const itemTitle = item.name || (item as any).title || "Product";
                        const itemPrice = item.price ?? (item as any).priceNpr ?? 0;
                        const itemImage = item.images?.[0] || (item as any).imageUrl || "/images/products/canon_eos.jpg";
                        const inStock = item.active !== false && (item.stockQuantity > 0 || (item as any).inStock);
                        return (
                          <tr key={item.id}>
                            <td style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                              <div style={{ width: "40px", height: "40px", borderRadius: "6px", background: "#f1f5f9", overflow: "hidden", flexShrink: 0 }}>
                                <img
                                  src={itemImage}
                                  alt={itemTitle}
                                  style={{ width: "100%", height: "100%", objectFit: "cover" }}
                                />
                              </div>
                              <span style={{ fontWeight: 600 }}>{itemTitle}</span>
                            </td>
                            <td>{item.brand}</td>
                            <td>{item.categoryName || (item as any).category || "Equipment"}</td>
                            <td style={{ fontWeight: 600 }}>NPR {itemPrice.toLocaleString()}</td>
                            <td>{item.stockQuantity ?? 1} in stock</td>
                            <td>
                              <span className={"admin-badge " + (inStock ? "badge-success" : "badge-danger")}>
                                {inStock ? "In Stock" : "Out of Stock"}
                              </span>
                            </td>
                            <td>
                              <button
                                type="button"
                                className="admin-btn admin-btn-secondary admin-btn-sm"
                                onClick={() => handleToggleProductStock(item)}
                              >
                                Toggle Stock
                              </button>
                            </td>
                          </tr>
                        );
                      })}
                      {products.length === 0 && (
                        <tr>
                          <td colSpan={7} style={{ textAlign: "center", padding: "28px", color: "var(--admin-text-muted)" }}>
                            No products found in inventory.
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* TAB: PRE-OWNED / USED GEAR */}
          {activeTab === "used" && (
            <div>
              {/* Form: Add or Edit Pre-Owned Item */}
              <div className="admin-card" id="used-gear-form">
                <div className="admin-card-header">
                  <div>
                    <div className="admin-card-title">
                      {editingUsedId ? `Edit Pre-Owned Equipment (${usedName || "Item"})` : "Add Certified Pre-Owned Equipment"}
                    </div>
                    <div style={{ fontSize: "12px", color: "var(--admin-text-muted)", marginTop: "2px" }}>
                      Every listed piece of second-hand gear undergoes physical bench testing &amp; 48-point optical diagnostics before publishing.
                    </div>
                  </div>
                  {editingUsedId && (
                    <button
                      type="button"
                      className="admin-btn admin-btn-secondary admin-btn-sm"
                      onClick={handleCancelUsedEdit}
                    >
                      <RotateCcw size={13} />
                      <span>Cancel Editing</span>
                    </button>
                  )}
                </div>

                <form onSubmit={handleSaveUsedProduct}>
                  {/* Row 1: Basic Identifiers */}
                  <div className="admin-grid-3">
                    <div className="admin-form-group">
                      <label className="admin-label">Equipment Name / Title *</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. Sony Alpha A7 III Full-Frame Body"
                        value={usedName}
                        onChange={(e) => setUsedName(e.target.value)}
                        required
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Brand *</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. Sony, Canon, Nikon, DJI, Fujifilm"
                        value={usedBrand}
                        onChange={(e) => setUsedBrand(e.target.value)}
                        required
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Model Code</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. ILCE-7M3 or EOS R6"
                        value={usedModel}
                        onChange={(e) => setUsedModel(e.target.value)}
                      />
                    </div>
                  </div>

                  {/* Row 2: Category, Condition Grade & Metric Type */}
                  <div className="admin-grid-3">
                    <div className="admin-form-group">
                      <label className="admin-label">Category</label>
                      <select
                        className="admin-select"
                        value={usedCategory}
                        onChange={(e) => setUsedCategory(e.target.value)}
                      >
                        <option value="Cameras">Cameras</option>
                        <option value="Lenses">Lenses</option>
                        <option value="Drones">Drones</option>
                        <option value="Audio">Audio</option>
                        <option value="Gimbals">Gimbals &amp; Stabilizers</option>
                        <option value="Lighting">Lighting</option>
                        <option value="Accessories">Accessories</option>
                      </select>
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Condition Grade *</label>
                      <select
                        className="admin-select"
                        value={usedGrade}
                        onChange={(e) => setUsedGrade(e.target.value as UsedConditionGrade)}
                      >
                        <option value="LIKE_NEW">LIKE NEW (Mint, 99% aesthetic condition)</option>
                        <option value="EXCELLENT">EXCELLENT (Light cosmetic signs, 90%+)</option>
                        <option value="GOOD">GOOD (Moderate signs of field use, 80%+)</option>
                        <option value="FAIR">FAIR (Heavy cosmetic wear, 100% working)</option>
                      </select>
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Primary Metric Type</label>
                      <select
                        className="admin-select"
                        value={usedMetricType}
                        onChange={(e) => setUsedMetricType(e.target.value as "SHUTTER" | "FLIGHT" | "OPTICS")}
                      >
                        <option value="SHUTTER">Shutter Count (Cameras)</option>
                        <option value="FLIGHT">Flight Hours (Drones)</option>
                        <option value="OPTICS">Optics / Glass Clarity (Lenses)</option>
                      </select>
                    </div>
                  </div>

                  {/* Row 3: Pricing & Usage Metric */}
                  <div className="admin-grid-3">
                    <div className="admin-form-group">
                      <label className="admin-label">Selling Price (NPR) *</label>
                      <input
                        type="number"
                        className="admin-input"
                        placeholder="e.g. 165000"
                        value={usedPrice}
                        onChange={(e) => setUsedPrice(e.target.value)}
                        required
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Original New Price (NPR)</label>
                      <input
                        type="number"
                        className="admin-input"
                        placeholder="e.g. 245000 (for savings badge)"
                        value={usedOriginalPrice}
                        onChange={(e) => setUsedOriginalPrice(e.target.value)}
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Usage Metric Text *</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. 14,200 Shutter Actuations or 8.5 Flight Hours"
                        value={usedUsageMetric}
                        onChange={(e) => setUsedUsageMetric(e.target.value)}
                        required
                      />
                    </div>
                  </div>

                  {/* Row 4: Inspection Status, Serial & Stock */}
                  <div className="admin-grid-3">
                    <div className="admin-form-group">
                      <label className="admin-label">Functional Lab Status</label>
                      <select
                        className="admin-select"
                        value={usedFunctionalStatus}
                        onChange={(e) => setUsedFunctionalStatus(e.target.value as any)}
                      >
                        <option value="TESTED_FULLY_FUNCTIONAL">TESTED FULLY FUNCTIONAL (100% Pass)</option>
                        <option value="TESTED_WITH_LIMITATIONS">TESTED WITH LIMITATIONS (Minor quirk noted)</option>
                      </select>
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Masked Serial Number</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. 482****-NPL"
                        value={usedSerial}
                        onChange={(e) => setUsedSerial(e.target.value)}
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Inventory Status</label>
                      <select
                        className="admin-select"
                        value={usedActive ? "IN_STOCK" : "SOLD"}
                        onChange={(e) => setUsedActive(e.target.value === "IN_STOCK")}
                      >
                        <option value="IN_STOCK">Available (In Stock - 1 Unit)</option>
                        <option value="SOLD">SOLD OUT (Archive / Inactive)</option>
                      </select>
                    </div>
                  </div>

                  {/* Row 5: Descriptions */}
                  <div className="admin-grid-2">
                    <div className="admin-form-group">
                      <label className="admin-label">Cosmetic &amp; Physical Condition Description</label>
                      <textarea
                        className="admin-textarea"
                        rows={3}
                        placeholder="Describe external chassis condition, sensor glass clarity, rubber grip state, display condition..."
                        value={usedConditionDesc}
                        onChange={(e) => setUsedConditionDesc(e.target.value)}
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Bench Inspection &amp; Diagnostic Notes</label>
                      <textarea
                        className="admin-textarea"
                        rows={3}
                        placeholder="Lab bench findings: sensor cleaning performed, shutter mechanism tested, card slot speeds verified, AF accuracy..."
                        value={usedTestNotes}
                        onChange={(e) => setUsedTestNotes(e.target.value)}
                      />
                    </div>
                  </div>

                  {/* Row 6: Defects and Accessories */}
                  <div className="admin-grid-2">
                    <div className="admin-form-group">
                      <label className="admin-label">
                        Known Defects &amp; Blemishes
                        <span style={{ fontWeight: 400, color: "var(--admin-text-muted)", marginLeft: "4px" }}>
                          (One per line)
                        </span>
                      </label>
                      <textarea
                        className="admin-textarea"
                        rows={3}
                        placeholder="e.g.&#10;Minor tripod mounting friction mark on baseplate&#10;Slight handling gloss on thumb rubber"
                        value={usedDefects}
                        onChange={(e) => setUsedDefects(e.target.value)}
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">
                        Included Accessories
                        <span style={{ fontWeight: 400, color: "var(--admin-text-muted)", marginLeft: "4px" }}>
                          (One per line)
                        </span>
                      </label>
                      <textarea
                        className="admin-textarea"
                        rows={3}
                        placeholder="e.g.&#10;Original Sony NP-FZ100 Rechargeable Battery&#10;Sony AC Wall Charger &amp; Cable&#10;Original Neck Strap&#10;Front Body Cap"
                        value={usedAccessories}
                        onChange={(e) => setUsedAccessories(e.target.value)}
                      />
                    </div>
                  </div>

                  {/* Row 7: Warranty and Image */}
                  <div className="admin-grid-2">
                    <div className="admin-form-group">
                      <label className="admin-label">Warranty Guarantee</label>
                      <input
                        type="text"
                        className="admin-input"
                        placeholder="e.g. 90-Day Comprehensive QuickySewa Lab Warranty"
                        value={usedWarranty}
                        onChange={(e) => setUsedWarranty(e.target.value)}
                      />
                    </div>

                    <div className="admin-form-group">
                      <label className="admin-label">Primary Image (URL or Cloudinary Upload)</label>
                      <div style={{ display: "flex", gap: "8px" }}>
                        <input
                          type="text"
                          className="admin-input"
                          style={{ flex: 1 }}
                          placeholder="e.g. /images/products/canon_eos.jpg or Cloudinary URL"
                          value={usedImage}
                          onChange={(e) => setUsedImage(e.target.value)}
                        />
                        <label className="admin-btn admin-btn-secondary" style={{ cursor: "pointer", margin: 0, whiteSpace: "nowrap" }}>
                          <UploadCloud size={14} />
                          <span>{uploadingUsedImg ? "Uploading..." : "Upload to Cloudinary"}</span>
                          <input
                            type="file"
                            accept="image/*"
                            style={{ display: "none" }}
                            disabled={uploadingUsedImg}
                            onChange={handleUsedImageUpload}
                          />
                        </label>
                      </div>
                    </div>
                  </div>

                  <div style={{ display: "flex", alignItems: "center", gap: "10px", marginTop: "6px" }}>
                    <button type="submit" className="admin-btn admin-btn-primary">
                      {editingUsedId ? <Check size={14} /> : <Plus size={14} />}
                      <span>{editingUsedId ? "Save Listing Changes" : "Publish Pre-Owned Listing"}</span>
                    </button>

                    {editingUsedId && (
                      <button
                        type="button"
                        className="admin-btn admin-btn-secondary"
                        onClick={handleCancelUsedEdit}
                      >
                        Cancel
                      </button>
                    )}
                  </div>
                </form>
              </div>

              {/* Inventory Catalog List */}
              <div className="admin-card">
                <div className="admin-card-header">
                  <div>
                    <div className="admin-card-title">
                      Certified Pre-Owned Inventory ({filteredUsedProducts.length} items)
                    </div>
                    <div style={{ fontSize: "12px", color: "var(--admin-text-muted)", marginTop: "2px" }}>
                      Real-time inventory synchronized across customer marketplace, search indices, and order checkout.
                    </div>
                  </div>
                </div>

                {/* Filter and Search Bar */}
                <div className="admin-filter-bar" style={{ marginBottom: "16px" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: "8px", flex: 1, minWidth: "220px" }}>
                    <Search size={15} style={{ color: "var(--admin-text-muted)" }} />
                    <input
                      type="text"
                      className="admin-input"
                      placeholder="Search by title, brand, model, serial or metric..."
                      value={usedSearch}
                      onChange={(e) => setUsedSearch(e.target.value)}
                      style={{ padding: "6px 10px", fontSize: "12.5px" }}
                    />
                  </div>

                  <select
                    className="admin-select"
                    value={usedGradeFilter}
                    onChange={(e) => setUsedGradeFilter(e.target.value)}
                    style={{ width: "auto", padding: "6px 10px", fontSize: "12.5px" }}
                  >
                    <option value="ALL">All Condition Grades</option>
                    <option value="LIKE_NEW">Grade: Like New</option>
                    <option value="EXCELLENT">Grade: Excellent</option>
                    <option value="GOOD">Grade: Good</option>
                    <option value="FAIR">Grade: Fair</option>
                  </select>

                  <select
                    className="admin-select"
                    value={usedCategoryFilter}
                    onChange={(e) => setUsedCategoryFilter(e.target.value)}
                    style={{ width: "auto", padding: "6px 10px", fontSize: "12.5px" }}
                  >
                    <option value="ALL">All Categories</option>
                    <option value="Cameras">Cameras</option>
                    <option value="Lenses">Lenses</option>
                    <option value="Drones">Drones</option>
                    <option value="Audio">Audio</option>
                    <option value="Gimbals">Gimbals</option>
                    <option value="Lighting">Lighting</option>
                    <option value="Accessories">Accessories</option>
                  </select>

                  <select
                    className="admin-select"
                    value={usedStatusFilter}
                    onChange={(e) => setUsedStatusFilter(e.target.value)}
                    style={{ width: "auto", padding: "6px 10px", fontSize: "12.5px" }}
                  >
                    <option value="ALL">All Statuses</option>
                    <option value="IN_STOCK">Available (In Stock)</option>
                    <option value="SOLD">Sold Out</option>
                  </select>
                </div>

                {/* Table of Used Products */}
                <div className="admin-table-container">
                  <table className="admin-table">
                    <thead>
                      <tr>
                        <th>Equipment</th>
                        <th>Grade &amp; Metrics</th>
                        <th>Pricing</th>
                        <th>Inspection &amp; Defects</th>
                        <th>Status</th>
                        <th style={{ textAlign: "right" }}>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredUsedProducts.map((item) => {
                        const inStock = item.active !== false && item.stockQuantity > 0;
                        const savingsPct =
                          item.originalNewPrice && item.originalNewPrice > item.price
                            ? Math.round(((item.originalNewPrice - item.price) / item.originalNewPrice) * 100)
                            : null;
                        const itemImg = item.images?.[0] || "/images/products/canon_eos.jpg";

                        return (
                          <tr key={item.id}>
                            {/* Equipment Identifiers */}
                            <td>
                              <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                                <div
                                  style={{
                                    width: "48px",
                                    height: "48px",
                                    borderRadius: "8px",
                                    background: "#f1f5f9",
                                    overflow: "hidden",
                                    flexShrink: 0,
                                    border: "1px solid var(--admin-border)",
                                  }}
                                >
                                  <img
                                    src={itemImg}
                                    alt={item.name}
                                    style={{ width: "100%", height: "100%", objectFit: "cover" }}
                                  />
                                </div>
                                <div>
                                  <div style={{ fontWeight: 700, fontSize: "13.5px", color: "var(--admin-text-main)" }}>
                                    {item.name}
                                  </div>
                                  <div style={{ fontSize: "11.5px", color: "var(--admin-text-muted)", marginTop: "2px" }}>
                                    <span>{item.brand}</span>
                                    {item.model && <span> &bull; {item.model}</span>}
                                    {item.serialNumberMasked && (
                                      <span style={{ fontFamily: "var(--font-mono)", marginLeft: "4px" }}>
                                        (S/N: {item.serialNumberMasked})
                                      </span>
                                    )}
                                  </div>
                                </div>
                              </div>
                            </td>

                            {/* Grade & Metrics */}
                            <td>
                              <div>
                                <span className={`grade-badge grade-badge-${item.conditionGrade}`}>
                                  {item.conditionGrade.replace("_", " ")}
                                </span>
                              </div>
                              {item.usageMetric && (
                                <div className="metric-pill">
                                  <span>{item.usageMetric}</span>
                                </div>
                              )}
                            </td>

                            {/* Pricing */}
                            <td>
                              <div style={{ fontWeight: 800, fontSize: "14px", color: "var(--admin-text-main)" }}>
                                NPR {item.price.toLocaleString()}
                              </div>
                              {item.originalNewPrice && item.originalNewPrice > item.price && (
                                <div style={{ fontSize: "11px", color: "var(--admin-text-muted)", marginTop: "2px" }}>
                                  <span style={{ textDecoration: "line-through", marginRight: "4px" }}>
                                    NPR {item.originalNewPrice.toLocaleString()}
                                  </span>
                                  {savingsPct && (
                                    <span style={{ color: "#16a34a", fontWeight: 700 }}>
                                      (-{savingsPct}%)
                                    </span>
                                  )}
                                </div>
                              )}
                            </td>

                            {/* Inspection & Defects */}
                            <td>
                              <div style={{ fontSize: "12px" }}>
                                <span style={{ fontWeight: 600, color: item.functionalTestStatus === "TESTED_FULLY_FUNCTIONAL" ? "#15803d" : "#b45309" }}>
                                  {item.functionalTestStatus === "TESTED_FULLY_FUNCTIONAL" ? "100% Tested" : "Tested (Quirks)"}
                                </span>
                              </div>
                              <div style={{ fontSize: "11px", color: "var(--admin-text-muted)", marginTop: "2px" }}>
                                {item.knownDefects?.length
                                  ? `${item.knownDefects.length} defect(s) noted`
                                  : "Clean cosmetic condition"}
                              </div>
                            </td>

                            {/* Availability Status */}
                            <td>
                              <span className={"admin-badge " + (inStock ? "badge-success" : "badge-danger")}>
                                {inStock ? "Available" : "SOLD"}
                              </span>
                            </td>

                            {/* Actions */}
                            <td style={{ textAlign: "right" }}>
                              <div style={{ display: "inline-flex", alignItems: "center", gap: "6px" }}>
                                <button
                                  type="button"
                                  className="admin-btn admin-btn-secondary admin-btn-sm"
                                  title="View Inspection Certificate"
                                  onClick={() => setViewingUsedItem(item)}
                                >
                                  <Eye size={13} />
                                  <span>Inspect</span>
                                </button>

                                <button
                                  type="button"
                                  className="admin-btn admin-btn-secondary admin-btn-sm"
                                  title="Edit Listing"
                                  onClick={() => handleEditUsedProduct(item)}
                                >
                                  <Edit2 size={13} />
                                  <span>Edit</span>
                                </button>

                                <button
                                  type="button"
                                  className={`admin-btn ${inStock ? "admin-btn-secondary" : "admin-btn-primary"} admin-btn-sm`}
                                  title={inStock ? "Mark as Sold" : "Re-activate in Stock"}
                                  onClick={() => handleToggleUsedStock(item)}
                                >
                                  {inStock ? "Mark Sold" : "Re-list"}
                                </button>

                                <button
                                  type="button"
                                  className="admin-btn admin-btn-danger admin-btn-sm"
                                  title="Delete item"
                                  onClick={() => handleDeleteUsedProduct(item)}
                                >
                                  <Trash2 size={13} />
                                </button>
                              </div>
                            </td>
                          </tr>
                        );
                      })}

                      {filteredUsedProducts.length === 0 && (
                        <tr>
                          <td colSpan={6} style={{ textAlign: "center", padding: "32px", color: "var(--admin-text-muted)" }}>
                            No certified pre-owned equipment matched your search or filters.
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* Inspection Details Preview Modal */}
          {viewingUsedItem && (
            <div className="admin-modal-overlay" onClick={() => setViewingUsedItem(null)}>
              <div
                className="admin-modal-box"
                style={{ maxWidth: "680px" }}
                onClick={(e) => e.stopPropagation()}
              >
                <div className="admin-card-header" style={{ marginBottom: "16px", paddingBottom: "12px", borderBottom: "1px solid var(--admin-border)" }}>
                  <div>
                    <div className="admin-card-title" style={{ fontSize: "16px" }}>
                      Lab Inspection Certificate &bull; {viewingUsedItem.name}
                    </div>
                    <div style={{ fontSize: "12px", color: "var(--admin-text-muted)", marginTop: "2px" }}>
                      Verified in Janakpur Lab Bench &bull; Serial: {viewingUsedItem.serialNumberMasked || "Verified"}
                    </div>
                  </div>
                  <button
                    type="button"
                    className="admin-btn admin-btn-secondary admin-btn-sm"
                    onClick={() => setViewingUsedItem(null)}
                  >
                    <X size={14} />
                  </button>
                </div>

                <div className="inspection-modal-grid">
                  <div>
                    <div style={{ width: "100%", height: "160px", borderRadius: "8px", overflow: "hidden", background: "#f1f5f9", border: "1px solid var(--admin-border)" }}>
                      <img
                        src={viewingUsedItem.images?.[0] || "/images/products/canon_eos.jpg"}
                        alt={viewingUsedItem.name}
                        style={{ width: "100%", height: "100%", objectFit: "cover" }}
                      />
                    </div>

                    <div style={{ marginTop: "12px" }}>
                      <div style={{ fontSize: "11px", color: "var(--admin-text-muted)", textTransform: "uppercase", fontWeight: 700 }}>
                        Selling Price
                      </div>
                      <div style={{ fontSize: "18px", fontWeight: 800, color: "var(--admin-text-main)", marginTop: "2px" }}>
                        NPR {viewingUsedItem.price.toLocaleString()}
                      </div>
                      {viewingUsedItem.originalNewPrice && (
                        <div style={{ fontSize: "12px", color: "var(--admin-text-muted)", textDecoration: "line-through" }}>
                          NPR {viewingUsedItem.originalNewPrice.toLocaleString()} (New)
                        </div>
                      )}
                    </div>
                  </div>

                  <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
                    <div>
                      <div style={{ fontSize: "11px", color: "var(--admin-text-muted)", textTransform: "uppercase", fontWeight: 700 }}>
                        Condition &amp; Health Metrics
                      </div>
                      <div style={{ display: "flex", alignItems: "center", gap: "8px", marginTop: "4px" }}>
                        <span className={`grade-badge grade-badge-${viewingUsedItem.conditionGrade}`}>
                          {viewingUsedItem.conditionGrade.replace("_", " ")}
                        </span>
                        {viewingUsedItem.usageMetric && (
                          <span className="metric-pill" style={{ marginTop: 0 }}>
                            {viewingUsedItem.usageMetric}
                          </span>
                        )}
                      </div>
                      <div style={{ fontSize: "12.5px", color: "#334155", marginTop: "6px", lineHeight: "1.45" }}>
                        {viewingUsedItem.conditionDescription || "No cosmetic flaws noted."}
                      </div>
                    </div>

                    <div>
                      <div style={{ fontSize: "11px", color: "var(--admin-text-muted)", textTransform: "uppercase", fontWeight: 700 }}>
                        Bench Diagnostic Findings
                      </div>
                      <div style={{ fontSize: "12px", color: "#334155", marginTop: "4px", background: "#f8fafc", padding: "8px 10px", borderRadius: "6px", border: "1px solid #e2e8f0" }}>
                        {viewingUsedItem.testNotes || "All optical and mechanical mechanisms passed full 48-point diagnostic benchmarks."}
                      </div>
                    </div>

                    <div>
                      <div style={{ fontSize: "11px", color: "var(--admin-text-muted)", textTransform: "uppercase", fontWeight: 700 }}>
                        Known Cosmetic Blemishes
                      </div>
                      {viewingUsedItem.knownDefects?.length ? (
                        <ul style={{ margin: "4px 0 0 16px", padding: 0, fontSize: "12px", color: "#64748b" }}>
                          {viewingUsedItem.knownDefects.map((d, idx) => (
                            <li key={idx} style={{ marginBottom: "2px" }}>{d}</li>
                          ))}
                        </ul>
                      ) : (
                        <div style={{ fontSize: "12px", color: "#16a34a", marginTop: "2px" }}>
                          &bull; Zero significant defects or blemishes detected.
                        </div>
                      )}
                    </div>

                    <div>
                      <div style={{ fontSize: "11px", color: "var(--admin-text-muted)", textTransform: "uppercase", fontWeight: 700 }}>
                        Included Accessories
                      </div>
                      {viewingUsedItem.includedAccessories?.length ? (
                        <ul style={{ margin: "4px 0 0 16px", padding: 0, fontSize: "12px", color: "#64748b" }}>
                          {viewingUsedItem.includedAccessories.map((a, idx) => (
                            <li key={idx} style={{ marginBottom: "2px" }}>{a}</li>
                          ))}
                        </ul>
                      ) : (
                        <div style={{ fontSize: "12px", color: "var(--admin-text-muted)", marginTop: "2px" }}>
                          Standard body cap and battery.
                        </div>
                      )}
                    </div>

                    <div style={{ fontSize: "12px", color: "#15803d", fontWeight: 600, background: "#f0fdf4", padding: "6px 10px", borderRadius: "6px" }}>
                      &#10003; {viewingUsedItem.warrantyDetails || "90-Day Comprehensive Warranty included."}
                    </div>
                  </div>
                </div>

                <div style={{ display: "flex", justifyContent: "flex-end", gap: "10px", marginTop: "20px", paddingTop: "12px", borderTop: "1px solid var(--admin-border)" }}>
                  <button
                    type="button"
                    className="admin-btn admin-btn-secondary"
                    onClick={() => setViewingUsedItem(null)}
                  >
                    Close
                  </button>
                  <button
                    type="button"
                    className="admin-btn admin-btn-primary"
                    onClick={() => {
                      const item = viewingUsedItem;
                      setViewingUsedItem(null);
                      handleEditUsedProduct(item);
                    }}
                  >
                    <Edit2 size={13} />
                    <span>Edit Listing</span>
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* TAB: NOTIFICATIONS */}
          {activeTab === "notifications" && <AdminNotificationsTab />}

          {/* TAB: SETTINGS */}
          {activeTab === "settings" && (
            <div className="admin-card" style={{ maxWidth: "600px" }}>
              <div className="admin-card-header">
                <div className="admin-card-title">Commercial &amp; Commission Settings</div>
              </div>

              <form onSubmit={handleSaveSettings}>
                <div className="admin-form-group">
                  <label className="admin-label">External Technician Commission (%)</label>
                  <input
                    type="number"
                    className="admin-input"
                    value={techSplit}
                    onChange={(e) => setTechSplit(Number(e.target.value))}
                    min={0}
                    max={100}
                    required
                  />
                  <span style={{ fontSize: "11.5px", color: "var(--admin-text-muted)" }}>
                    Percentage paid to third-party certified repair specialists.
                  </span>
                </div>

                <div className="admin-form-group">
                  <label className="admin-label">QuickySewa Platform Split (%)</label>
                  <input
                    type="number"
                    className="admin-input"
                    value={svcSplit}
                    onChange={(e) => setSvcSplit(Number(e.target.value))}
                    min={0}
                    max={100}
                    required
                  />
                </div>

                <div className="admin-form-group">
                  <label className="admin-label">Default Nationwide Courier Fee (NPR)</label>
                  <input
                    type="number"
                    className="admin-input"
                    value={deliveryFee}
                    onChange={(e) => setDeliveryFee(Number(e.target.value))}
                    min={0}
                    required
                  />
                </div>

                <button
                  type="submit"
                  className="admin-btn admin-btn-primary"
                  disabled={savingSettings}
                >
                  {savingSettings ? "Saving..." : "Save Settings"}
                </button>
              </form>
            </div>
          )}
        </main>
      </div>

      {/* MODAL: ASSIGN TECHNICIAN */}
      {showAssignModal && selectedRequest && (
        <div className="admin-modal-overlay">
          <div className="admin-modal">
            <div className="admin-modal-header">
              <div className="admin-modal-title">Assign Repair Technician</div>
              <button
                type="button"
                className="admin-btn admin-btn-secondary admin-btn-sm"
                onClick={() => { setShowAssignModal(false); setSelectedRequest(null); }}
              >
                <X size={15} />
              </button>
            </div>

            <div className="admin-modal-body">
              <div style={{ marginBottom: "16px", padding: "12px", background: "#f8fafc", borderRadius: "8px", border: "1px solid var(--admin-border)" }}>
                <div><strong>Ticket:</strong> {selectedRequest.id.slice(0, 10)}</div>
                <div><strong>Device:</strong> {getDeviceName(selectedRequest)}</div>
                <div><strong>Issue:</strong> {getIssueText(selectedRequest)}</div>
              </div>

              <div className="admin-form-group">
                <label className="admin-label">Select Certified Specialist</label>
                <select
                  className="admin-select"
                  value={selectedTechId}
                  onChange={(e) => setSelectedTechId(e.target.value)}
                >
                  <option value="" disabled>
                    {technicians.length ? "Choose a technician" : "No active technicians — set role in users collection"}
                  </option>
                  {technicians.map((tech) => (
                    <option key={tech.id} value={tech.id}>
                      {tech.name} — {tech.technicianType === "EXTERNAL" ? "External" : "Internal"} ({tech.phone || tech.email})
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div className="admin-modal-footer">
              <button
                type="button"
                className="admin-btn admin-btn-secondary"
                onClick={() => { setShowAssignModal(false); setSelectedRequest(null); }}
              >
                Cancel
              </button>
              <button
                type="button"
                className="admin-btn admin-btn-primary"
                onClick={handleAssignTechnician}
              >
                Assign Specialist
              </button>
            </div>
          </div>
        </div>
      )}

      {/* MODAL: SEND QUOTATION */}
      {showQuoteModal && selectedRequest && (
        <div className="admin-modal-overlay">
          <div className="admin-modal">
            <div className="admin-modal-header">
              <div className="admin-modal-title">Dispatch Diagnostic Quotation</div>
              <button
                type="button"
                className="admin-btn admin-btn-secondary admin-btn-sm"
                onClick={() => { setShowQuoteModal(false); setSelectedRequest(null); }}
              >
                <X size={15} />
              </button>
            </div>

            <div className="admin-modal-body">
              <div style={{ marginBottom: "14px", padding: "12px", background: "#f8fafc", borderRadius: "8px", border: "1px solid var(--admin-border)" }}>
                <div><strong>Device:</strong> {getDeviceName(selectedRequest)}</div>
                <div><strong>Customer:</strong> {selectedRequest.customerName || "Customer"}</div>
              </div>

              <div className="admin-grid-2">
                <div className="admin-form-group">
                  <label className="admin-label">Labour Cost (NPR)</label>
                  <input
                    type="number"
                    className="admin-input"
                    value={labourAmount}
                    onChange={(e) => setLabourAmount(e.target.value)}
                  />
                </div>

                <div className="admin-form-group">
                  <label className="admin-label">Parts &amp; Components (NPR)</label>
                  <input
                    type="number"
                    className="admin-input"
                    value={partsAmount}
                    onChange={(e) => setPartsAmount(e.target.value)}
                  />
                </div>
              </div>

              <div className="admin-form-group">
                <label className="admin-label">Warranty Terms</label>
                <input
                  type="text"
                  className="admin-input"
                  value={quoteWarranty}
                  onChange={(e) => setQuoteWarranty(e.target.value)}
                />
              </div>

              <div className="admin-form-group">
                <label className="admin-label">Technical Notes</label>
                <textarea
                  className="admin-textarea"
                  rows={2}
                  value={quoteNotes}
                  onChange={(e) => setQuoteNotes(e.target.value)}
                />
              </div>

              <div style={{ padding: "10px", background: "var(--admin-brand-soft)", borderRadius: "6px", display: "flex", justifyContent: "space-between", fontWeight: 700 }}>
                <span>Total Quotation:</span>
                <span style={{ color: "var(--admin-brand)" }}>
                  NPR {((Number(labourAmount) || 0) + (Number(partsAmount) || 0)).toLocaleString()}
                </span>
              </div>
            </div>

            <div className="admin-modal-footer">
              <button
                type="button"
                className="admin-btn admin-btn-secondary"
                onClick={() => { setShowQuoteModal(false); setSelectedRequest(null); }}
              >
                Cancel
              </button>
              <button
                type="button"
                className="admin-btn admin-btn-primary"
                onClick={handleSendQuotation}
              >
                <Send size={14} />
                <span>Dispatch Quote</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* MODAL: DISPATCH ORDER */}
      {showDispatchModal && selectedOrder && (
        <div className="admin-modal-overlay">
          <div className="admin-modal">
            <div className="admin-modal-header">
              <div className="admin-modal-title">Dispatch Order via Courier</div>
              <button
                type="button"
                className="admin-btn admin-btn-secondary admin-btn-sm"
                onClick={() => { setShowDispatchModal(false); setSelectedOrder(null); }}
              >
                <X size={15} />
              </button>
            </div>

            <div className="admin-modal-body">
              <div style={{ marginBottom: "14px", padding: "12px", background: "#f8fafc", borderRadius: "8px", border: "1px solid var(--admin-border)" }}>
                <div><strong>Order:</strong> {selectedOrder.id}</div>
                <div><strong>Recipient:</strong> {selectedOrder.customerName} ({getOrderCity(selectedOrder)})</div>
                <div><strong>Total Value:</strong> NPR {getOrderTotal(selectedOrder).toLocaleString()}</div>
                {selectedOrder.priceVerified === false && (
                  <div style={{ color: "#b45309", marginTop: "0.5rem" }}>
                    <strong>Price check failed — confirm with customer before dispatch:</strong>
                    <ul style={{ margin: "0.25rem 0 0 1rem" }}>
                      {(selectedOrder.priceIssues || []).map((issue) => <li key={issue}>{issue}</li>)}
                      {(selectedOrder.unverifiedItems || []).map((item) => (
                        <li key={item}>{item}: not in live catalog, price not verified</li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>

              <div className="admin-form-group">
                <label className="admin-label">Logistics Partner</label>
                <select
                  className="admin-select"
                  value={courierPartner}
                  onChange={(e) => setCourierPartner(e.target.value)}
                >
                  <option value="Nepal Can Move">Nepal Can Move (NCM)</option>
                  <option value="Aramex Nepal">Aramex Nepal</option>
                  <option value="Sundarban Express">Sundarban Express</option>
                  <option value="Janakpur Local Counter">Janakpur Local Counter Pickup</option>
                </select>
              </div>

              <div className="admin-form-group">
                <label className="admin-label">Courier Consignment / Tracking Number</label>
                <input
                  type="text"
                  className="admin-input"
                  placeholder="e.g. NCM-884920"
                  value={trackingNumber}
                  onChange={(e) => setTrackingNumber(e.target.value)}
                />
              </div>
            </div>

            <div className="admin-modal-footer">
              <button
                type="button"
                className="admin-btn admin-btn-secondary"
                onClick={() => { setShowDispatchModal(false); setSelectedOrder(null); }}
              >
                Cancel
              </button>
              <button
                type="button"
                className="admin-btn admin-btn-primary"
                onClick={handleDispatchOrder}
              >
                <Truck size={14} />
                <span>Confirm Dispatch</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* MODAL: VIEW PAYMENT SLIP */}
      {viewingPaymentProof && (
        <div className="admin-modal-overlay">
          <div className="admin-modal" style={{ maxWidth: "480px" }}>
            <div className="admin-modal-header">
              <div className="admin-modal-title">Bank Deposit Slip</div>
              <button
                type="button"
                className="admin-btn admin-btn-secondary admin-btn-sm"
                onClick={() => setViewingPaymentProof(null)}
              >
                <X size={15} />
              </button>
            </div>

            <div className="admin-modal-body">
              <div style={{ marginBottom: "12px" }}>
                <div><strong>Reference:</strong> {viewingPaymentProof.referenceNumber}</div>
                <div><strong>Method:</strong> {getPaymentMethod(viewingPaymentProof)}</div>
                <div><strong>Amount:</strong> NPR {getPaymentAmount(viewingPaymentProof).toLocaleString()}</div>
              </div>

              <div style={{ borderRadius: "8px", overflow: "hidden", border: "1px solid var(--admin-border)", maxHeight: "350px", display: "flex", alignItems: "center", justifyContent: "center", background: "#f8fafc" }}>
                <img
                  src={viewingPaymentProof.proofImageUrl}
                  alt="Payment Voucher"
                  style={{ width: "100%", maxHeight: "350px", objectFit: "contain" }}
                />
              </div>
            </div>

            <div className="admin-modal-footer">
              <button
                type="button"
                className="admin-btn admin-btn-secondary"
                onClick={() => setViewingPaymentProof(null)}
              >
                Close
              </button>
              {(viewingPaymentProof.status === "PENDING_VERIFICATION" || viewingPaymentProof.status === "PENDING" || (viewingPaymentProof.status as any) === "SUBMITTED") && (
                <>
                  <button
                    type="button"
                    className="admin-btn admin-btn-danger"
                    onClick={() => handleRejectPayment(viewingPaymentProof)}
                  >
                    Reject
                  </button>
                  <button
                    type="button"
                    className="admin-btn admin-btn-primary"
                    onClick={() => handleVerifyPayment(viewingPaymentProof)}
                  >
                    Approve Payment
                  </button>
                </>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
