export interface ProductItem {
  id: string;
  title: string;
  subtitle: string;
  trustNote: string;
  category: string;
  brand: string;
  price: number;
  originalPrice?: number;
  rating: number;
  reviewsCount: number;
  image: string;
}

export const PRODUCT_CATEGORIES = [
  "All",
  "Cameras",
  "Mobile",
  "Laptops",
  "CCTV",
  "Accessories",
  "Home Appliances",
] as const;

export const HOME_PRODUCTS: ProductItem[] = [
  {
    id: "prod-1",
    title: "Canon EOS R5 Mirrorless Camera Body",
    subtitle: "45MP Full-Frame • 8K RAW • In-Body IS",
    trustNote: "Official 1-Yr Warranty • Free Janakpur Delivery",
    category: "Cameras",
    brand: "Canon",
    price: 485000,
    originalPrice: 520000,
    rating: 4.9,
    reviewsCount: 34,
    image: "/images/products/canon_eos.jpg",
  },
  {
    id: "prod-2",
    title: "Apple MacBook Pro 16\" Liquid Retina XDR",
    subtitle: "Apple M3 Pro Chip • 18GB RAM • 512GB SSD",
    trustNote: "Apple Authorized Warranty • Sealed Pack",
    category: "Laptops",
    brand: "Apple",
    price: 345000,
    originalPrice: 365000,
    rating: 5.0,
    reviewsCount: 42,
    image: "/images/products/macbook_pro.jpg",
  },
  {
    id: "prod-3",
    title: "Apple iPhone 15 Pro Max 256GB Titanium",
    subtitle: "Grade 5 Titanium • A17 Pro Chip • 48MP Pro",
    trustNote: "MDMS Registered • 1-Yr Official Warranty",
    category: "Mobile",
    brand: "Apple",
    price: 195000,
    originalPrice: 209000,
    rating: 4.9,
    reviewsCount: 68,
    image: "/images/products/iphone_15_pro.jpg",
  },
  {
    id: "prod-4",
    title: "Sony WH-1000XM5 Wireless Headphones",
    subtitle: "Industry-Leading ANC • Auto NC Optimizer",
    trustNote: "100% Genuine Sony Nepal • 1-Yr Warranty",
    category: "Accessories",
    brand: "Sony",
    price: 46500,
    originalPrice: 52000,
    rating: 4.8,
    reviewsCount: 51,
    image: "/images/products/sony_headphones.jpg",
  },
  {
    id: "prod-5",
    title: "Hikvision 4K Ultra HD Outdoor Bullet CCTV",
    subtitle: "8MP Ultra HD • Smart IR 30m • IP67 Metal",
    trustNote: "Original Hikvision • Free Janakpur Delivery",
    category: "CCTV",
    brand: "Hikvision",
    price: 24500,
    originalPrice: 28000,
    rating: 4.9,
    reviewsCount: 29,
    image: "/images/products/hikvision_cctv.jpg",
  },
  {
    id: "prod-6",
    title: "Nikon D850 DSLR Camera + 24-120mm Kit",
    subtitle: "45.7MP FX Sensor • 4K UHD • Certified Used",
    trustNote: "Lab Tested • 90-Day Sharma Care Warranty",
    category: "Cameras",
    brand: "Nikon",
    price: 215000,
    originalPrice: 285000,
    rating: 4.8,
    reviewsCount: 19,
    image: "/images/products/nikon_d850.jpg",
  },
  {
    id: "prod-7",
    title: "Daikin 1.5 Ton 5-Star Inverter Split AC",
    subtitle: "Triple Display • PM 2.5 Filter • Copper",
    trustNote: "Official Daikin Warranty • Installation Ready",
    category: "Home Appliances",
    brand: "Daikin",
    price: 88500,
    originalPrice: 96000,
    rating: 4.9,
    reviewsCount: 37,
    image: "/images/products/ac_unit.jpg",
  },
  {
    id: "prod-8",
    title: "LG 8kg AI DirectDrive Front-Load Washer",
    subtitle: "AI DD™ • Steam™ Allergy Care • 1400 RPM",
    trustNote: "10-Yr Motor Warranty • Free Delivery",
    category: "Home Appliances",
    brand: "LG",
    price: 74000,
    originalPrice: 82500,
    rating: 4.8,
    reviewsCount: 26,
    image: "/images/products/washing_machine.jpg",
  },
];
