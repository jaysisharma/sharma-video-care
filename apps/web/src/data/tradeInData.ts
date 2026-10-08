export interface TradeInModel {
  id: string;
  category: "camera" | "lens" | "laptop" | "drone" | "mobile";
  categoryName: string;
  categoryNameNe: string;
  brand: string;
  model: string;
  baseValuation: number; // Maximum benchmark buyout in NPR
  shutterApplicable: boolean;
  image: string;
}

export const TRADE_IN_MODELS: TradeInModel[] = [
  // Cameras
  {
    id: "cam-sony-a7iv",
    category: "camera",
    categoryName: "DSLR & Mirrorless",
    categoryNameNe: "क्यामेरा",
    brand: "Sony",
    model: "Sony Alpha A7 IV Body",
    baseValuation: 235000,
    shutterApplicable: true,
    image: "/images/products/canon_eos.jpg",
  },
  {
    id: "cam-sony-a7iii",
    category: "camera",
    categoryName: "DSLR & Mirrorless",
    categoryNameNe: "क्यामेरा",
    brand: "Sony",
    model: "Sony Alpha A7 III Body",
    baseValuation: 145000,
    shutterApplicable: true,
    image: "/images/products/canon_eos.jpg",
  },
  {
    id: "cam-canon-r5",
    category: "camera",
    categoryName: "DSLR & Mirrorless",
    categoryNameNe: "क्यामेरा",
    brand: "Canon",
    model: "Canon EOS R5 Mirrorless Body",
    baseValuation: 330000,
    shutterApplicable: true,
    image: "/images/products/canon_eos.jpg",
  },
  {
    id: "cam-canon-r6ii",
    category: "camera",
    categoryName: "DSLR & Mirrorless",
    categoryNameNe: "क्यामेरा",
    brand: "Canon",
    model: "Canon EOS R6 Mark II Body",
    baseValuation: 215000,
    shutterApplicable: true,
    image: "/images/products/canon_eos.jpg",
  },
  {
    id: "cam-canon-5div",
    category: "camera",
    categoryName: "DSLR & Mirrorless",
    categoryNameNe: "क्यामेरा",
    brand: "Canon",
    model: "Canon EOS 5D Mark IV Body",
    baseValuation: 135000,
    shutterApplicable: true,
    image: "/images/products/canon_eos.jpg",
  },
  {
    id: "cam-nikon-z8",
    category: "camera",
    categoryName: "DSLR & Mirrorless",
    categoryNameNe: "क्यामेरा",
    brand: "Nikon",
    model: "Nikon Z8 Mirrorless Body",
    baseValuation: 345000,
    shutterApplicable: true,
    image: "/images/products/nikon_d850.jpg",
  },
  {
    id: "cam-nikon-d850",
    category: "camera",
    categoryName: "DSLR & Mirrorless",
    categoryNameNe: "क्यामेरा",
    brand: "Nikon",
    model: "Nikon D850 DSLR Body",
    baseValuation: 160000,
    shutterApplicable: true,
    image: "/images/products/nikon_d850.jpg",
  },
  {
    id: "cam-fuji-xt5",
    category: "camera",
    categoryName: "DSLR & Mirrorless",
    categoryNameNe: "क्यामेरा",
    brand: "Fujifilm",
    model: "Fujifilm X-T5 Body",
    baseValuation: 150000,
    shutterApplicable: true,
    image: "/images/products/canon_eos.jpg",
  },

  // Lenses
  {
    id: "lens-sony-2470gm2",
    category: "lens",
    categoryName: "Optical Lenses",
    categoryNameNe: "क्यामेरा लेन्स",
    brand: "Sony",
    model: "Sony FE 24-70mm f/2.8 GM II",
    baseValuation: 195000,
    shutterApplicable: false,
    image: "/images/products/sony_lens.jpg",
  },
  {
    id: "lens-sony-70200gm2",
    category: "lens",
    categoryName: "Optical Lenses",
    categoryNameNe: "क्यामेरा लेन्स",
    brand: "Sony",
    model: "Sony FE 70-200mm f/2.8 GM OSS II",
    baseValuation: 225000,
    shutterApplicable: false,
    image: "/images/products/sony_lens.jpg",
  },
  {
    id: "lens-canon-rf2470",
    category: "lens",
    categoryName: "Optical Lenses",
    categoryNameNe: "क्यामेरा लेन्स",
    brand: "Canon",
    model: "Canon RF 24-70mm f/2.8 L IS USM",
    baseValuation: 205000,
    shutterApplicable: false,
    image: "/images/products/sony_lens.jpg",
  },
  {
    id: "lens-sigma-2470art",
    category: "lens",
    categoryName: "Optical Lenses",
    categoryNameNe: "क्यामेरा लेन्स",
    brand: "Sigma",
    model: "Sigma 24-70mm f/2.8 DG DN Art",
    baseValuation: 98000,
    shutterApplicable: false,
    image: "/images/products/sony_lens.jpg",
  },

  // Laptops
  {
    id: "lap-mac-pro16m3",
    category: "laptop",
    categoryName: "Laptops & MacBook",
    categoryNameNe: "ल्यापटप / म्याकबुक",
    brand: "Apple",
    model: "Apple MacBook Pro 16\" (M3 Pro, 18GB, 512GB)",
    baseValuation: 250000,
    shutterApplicable: false,
    image: "/images/products/macbook_pro.jpg",
  },
  {
    id: "lap-mac-air13m2",
    category: "laptop",
    categoryName: "Laptops & MacBook",
    categoryNameNe: "ल्यापटप / म्याकबुक",
    brand: "Apple",
    model: "Apple MacBook Air 13\" (M2 Chip, 8GB, 256GB)",
    baseValuation: 110000,
    shutterApplicable: false,
    image: "/images/products/macbook_pro.jpg",
  },
  {
    id: "lap-dell-xps15",
    category: "laptop",
    categoryName: "Laptops & MacBook",
    categoryNameNe: "ल्यापटप / म्याकबुक",
    brand: "Dell",
    model: "Dell XPS 15 (i7 13th Gen, 16GB, RTX 4050)",
    baseValuation: 135000,
    shutterApplicable: false,
    image: "/images/products/macbook_pro.jpg",
  },

  // Drones
  {
    id: "drone-dji-mini4pro",
    category: "drone",
    categoryName: "Drones & Aerial",
    categoryNameNe: "ड्रोन",
    brand: "DJI",
    model: "DJI Mini 4 Pro (with RC 2 Controller)",
    baseValuation: 115000,
    shutterApplicable: false,
    image: "/images/products/dji_drone.jpg",
  },
  {
    id: "drone-dji-air3",
    category: "drone",
    categoryName: "Drones & Aerial",
    categoryNameNe: "ड्रोन",
    brand: "DJI",
    model: "DJI Air 3 Fly More Combo",
    baseValuation: 140000,
    shutterApplicable: false,
    image: "/images/products/dji_drone.jpg",
  },

  // Smartphones
  {
    id: "mob-iphone15promax",
    category: "mobile",
    categoryName: "Smartphones",
    categoryNameNe: "स्मार्टफोन",
    brand: "Apple",
    model: "iPhone 15 Pro Max 256GB Titanium",
    baseValuation: 140000,
    shutterApplicable: false,
    image: "/images/products/iphone_15_pro.jpg",
  },
  {
    id: "mob-s24ultra",
    category: "mobile",
    categoryName: "Smartphones",
    categoryNameNe: "स्मार्टफोन",
    brand: "Samsung",
    model: "Samsung Galaxy S24 Ultra 256GB",
    baseValuation: 125000,
    shutterApplicable: false,
    image: "/images/products/iphone_15_pro.jpg",
  },
];

export interface ConditionFactor {
  id: string;
  label: string;
  labelNe: string;
  multiplier: number;
  desc: string;
  descNe: string;
}

export const COSMETIC_CONDITIONS: ConditionFactor[] = [
  {
    id: "mint",
    label: "Grade A+ (Like New / Mint)",
    labelNe: "ग्रेड A+ (जस्तै नयाँ / शून्य स्क्र्याच)",
    multiplier: 1.0,
    desc: "Flawless cosmetic condition, zero scratches or dents.",
    descNe: "कुनै कोरिएको छैन, नयाँ जस्तै चम्किलो।",
  },
  {
    id: "excellent",
    label: "Grade A (Excellent)",
    labelNe: "ग्रेड A (उत्कृष्ट / हल्का प्रयोग)",
    multiplier: 0.9,
    desc: "Minor micro-scratches on base, screen/optics 100% clean.",
    descNe: "हल्का मात्र प्रयोगको संकेत, स्क्रिन र सेन्सर सफा।",
  },
  {
    id: "good",
    label: "Grade B (Good / Normal Wear)",
    labelNe: "ग्रेड B (राम्रो / सामान्य प्रयोग)",
    multiplier: 0.78,
    desc: "Visible scratches or scuffs, but zero cracks.",
    descNe: "स्पष्ट स्क्र्याच तर कुनै भाँचिएको वा फुटेको छैन।",
  },
  {
    id: "fair",
    label: "Grade C (Heavy Wear)",
    labelNe: "ग्रेड C (धेरै प्रयोग भएको)",
    multiplier: 0.65,
    desc: "Heavy cosmetic scuffs, rubber peeling, paint worn.",
    descNe: "धेरै प्रयोग भएको, रबर उप्किएको वा रंग उडेको।",
  },
];

export const FUNCTIONAL_CONDITIONS: ConditionFactor[] = [
  {
    id: "flawless",
    label: "100% Fully Working & Tested",
    labelNe: "१००% पूर्ण रूपमा चालू",
    multiplier: 1.0,
    desc: "All buttons, autofocus, sensors, ports, screen work perfectly.",
    descNe: "सबै बटन, अटोफोकस, सेन्सर र स्क्रिन दुरुस्त छन्।",
  },
  {
    id: "minor-flaw",
    label: "Minor Quirk / Weak Battery",
    labelNe: "सानो समस्या / कमजोर ब्याट्री",
    multiplier: 0.86,
    desc: "e.g. Battery health below 80% or rubber port cap loose.",
    descNe: "ब्याट्री कमजोर भएको वा सामान्य रबर कभर फुत्केको।",
  },
  {
    id: "defective",
    label: "Defective / Needs Repair",
    labelNe: "समस्याग्रस्त / मर्मत आवश्यक",
    multiplier: 0.65,
    desc: "Error code present, zoom stuck, or port non-functional.",
    descNe: "इरर आउने, जुम अड्किएको वा मर्मत गर्नुपर्ने।",
  },
];

export const SHUTTER_TIERS: ConditionFactor[] = [
  {
    id: "low",
    label: "< 15,000 Clicks (Barely Used)",
    labelNe: "१५,००० भन्दा कम क्लिक",
    multiplier: 1.0,
    desc: "Like new shutter curtain life remaining.",
    descNe: "सटर लाइफ पूर्ण सुरक्षित।",
  },
  {
    id: "mid",
    label: "15,000 – 50,000 Clicks",
    labelNe: "१५,००० – ५०,००० क्लिक",
    multiplier: 0.93,
    desc: "Normal hobbyist or studio usage.",
    descNe: "सामान्य फोटोग्राफी प्रयोग।",
  },
  {
    id: "high",
    label: "50,000 – 100,000 Clicks",
    labelNe: "५०,००० – १,००,००० क्लिक",
    multiplier: 0.85,
    desc: "Moderate professional usage.",
    descNe: "व्यावसायिक रूपमा मध्यम प्रयोग।",
  },
  {
    id: "very-high",
    label: "> 100,000 Clicks (Heavy Use)",
    labelNe: "१,००,००० भन्दा बढी क्लिक",
    multiplier: 0.75,
    desc: "High shutter cycles logged.",
    descNe: "उच्च क्लिक लग भएको।",
  },
];

export interface AccessoryBonus {
  id: string;
  name: string;
  nameNe: string;
  bonusAmount: number;
}

export const ACCESSORY_BONUSES: AccessoryBonus[] = [
  { id: "box", name: "Original Packaging Box & Manuals", nameNe: "सक्कली बक्स र म्यानुअल", bonusAmount: 2500 },
  { id: "charger", name: "Original OEM Charger & Cable", nameNe: "सक्कली चार्जर र केबल", bonusAmount: 2000 },
  { id: "battery", name: "Extra Genuine Battery", nameNe: "अतिरिक्त सक्कली ब्याट्री", bonusAmount: 3000 },
  { id: "bill", name: "Original Purchase VAT Bill / Receipt", nameNe: "सक्कली खरिद बिल / भ्याट बिल", bonusAmount: 2000 },
];
