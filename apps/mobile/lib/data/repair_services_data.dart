import 'package:flutter/material.dart';

class RepairDepartment {
  final String id;
  final String name;
  final String shortDesc;
  final IconData icon;
  final String turnaround;
  final int startingPrice;
  final List<String> commonFixes;
  final String benchTooling;
  final Color accentColor;

  const RepairDepartment({
    required this.id,
    required this.name,
    required this.shortDesc,
    required this.icon,
    required this.turnaround,
    required this.startingPrice,
    required this.commonFixes,
    required this.benchTooling,
    required this.accentColor,
  });
}

class RepairSymptomQuickFix {
  final String id;
  final String title;
  final String category;
  final String commonCause;
  final String labSolution;
  final int priceMin;
  final int priceMax;
  final String turnaround;
  final int warrantyDays;
  final IconData icon;

  const RepairSymptomQuickFix({
    required this.id,
    required this.title,
    required this.category,
    required this.commonCause,
    required this.labSolution,
    required this.priceMin,
    required this.priceMax,
    required this.turnaround,
    required this.warrantyDays,
    required this.icon,
  });
}

class LabStandard {
  final String title;
  final String description;
  final IconData icon;

  const LabStandard({
    required this.title,
    required this.description,
    required this.icon,
  });
}

final List<RepairDepartment> kRepairDepartments = [
  const RepairDepartment(
    id: 'camera',
    name: 'Cameras',
    shortDesc: 'Cleanroom sensor cleaning, mechanical shutter replacement & AF calibration.',
    icon: Icons.camera_alt_rounded,
    turnaround: '2 - 24 Hours',
    startingPrice: 1500,
    commonFixes: [
      'Sensor dust spot micro-cleaning (ISO 100 Class Cleanroom)',
      'Curtain blade jam & Shutter unit replacement (Err 20 / Err 30)',
      'Mainboard fuse & HDMI port micro-soldering',
    ],
    benchTooling: 'Olympus SZ61 Stereo Microscope, ESD Grounded Clean Bench',
    accentColor: Color(0xFFE86F1C),
  ),
  const RepairDepartment(
    id: 'lens',
    name: 'Lenses',
    shortDesc: 'Fungus de-hazing, autofocus motor replacement & zoom ring recalibration.',
    icon: Icons.filter_center_focus_rounded,
    turnaround: '24 - 48 Hours',
    startingPrice: 1800,
    commonFixes: [
      'Optical element de-fungus chemical wash & UV sterilization',
      'USM / Stepper autofocus motor gear replacement',
      'Aperture ribbon cable replacement for Err 01 communication faults',
    ],
    benchTooling: 'Optical Collimator, UV Optical Sterilizer Box',
    accentColor: Color(0xFF2563EB),
  ),
  const RepairDepartment(
    id: 'drone',
    name: 'Drones & gimbals',
    shortDesc: 'DJI gimbal axis stabilization, motor arm replacement & ESC board repair.',
    icon: Icons.flight_takeoff_rounded,
    turnaround: '24 - 48 Hours',
    startingPrice: 2000,
    commonFixes: [
      'Gimbal ribbon flex cable & pitch/roll motor recalibration',
      'Crash arm, propeller motor & landing gear swaps',
      'O3 / O4 transmission module diagnostic & firmware restore',
    ],
    benchTooling: 'DJI Gimbal Calibration Jig, RF Spectrum Analyzer',
    accentColor: Color(0xFF059669),
  ),
  const RepairDepartment(
    id: 'laptop',
    name: 'Laptops',
    shortDesc: 'Chip-level motherboard repair, liquid damage ultrasonic cleaning & screen replacement.',
    icon: Icons.laptop_mac_rounded,
    turnaround: 'Same Day - 24h',
    startingPrice: 2500,
    commonFixes: [
      '19V power rail short circuit diagnosis & MOSFET replacement',
      'Liquid spill ultrasonic PCB decontamination & drying',
      'FHD / 2K IPS screen & genuine OEM battery replacements',
    ],
    benchTooling: 'Hakko FX-951 Soldering Station, Thermal Imaging Camera',
    accentColor: Color(0xFF7C3AED),
  ),
  const RepairDepartment(
    id: 'ac',
    name: 'AC',
    shortDesc: 'Doorstep chemical jet wash, inverter PCB diagnostics & nitrogen leak test.',
    icon: Icons.ac_unit_rounded,
    turnaround: '2 - 4 Hours',
    startingPrice: 1200,
    commonFixes: [
      'Indoor & outdoor high-pressure chemical pump servicing',
      'R32 / R410A refrigerant leak detection & pure gas recharge',
      'Inverter power module PCB capacitor & relay replacement',
    ],
    benchTooling: 'Mastercool Digital Manifold Gauge, Nitrogen Leak Rig',
    accentColor: Color(0xFF0284C7),
  ),
  const RepairDepartment(
    id: 'tv',
    name: 'TVs',
    shortDesc: 'Copper backlight strip replacement, T-Con board repairs & display panel bonding.',
    icon: Icons.tv_rounded,
    turnaround: '4 - 8 Hours',
    startingPrice: 2200,
    commonFixes: [
      'Sound working but black screen: full copper backlight strip replacement',
      'Boot loop, Android logo freeze & power supply board fix',
      'Panel COF tab bonding for screen line artifacts',
    ],
    benchTooling: 'Digital Backlight Tester, Oscilloscope Bench',
    accentColor: Color(0xFFD97706),
  ),
  const RepairDepartment(
    id: 'cctv',
    name: 'CCTV',
    shortDesc: 'Surge recovery, 4K camera re-focusing, power-over-ethernet & hard drive retrieval.',
    icon: Icons.videocam_rounded,
    turnaround: 'Same Day',
    startingPrice: 950,
    commonFixes: [
      'Lightning surge power supply repair on NVR/DVR units',
      '4K / IP camera lens recalibration & infrared night LED swap',
      'Surveillance hard disk diagnostic & video playback restore',
    ],
    benchTooling: 'Hikvision & Dahua Diagnostic Rig, POE Loop Tester',
    accentColor: Color(0xFF475569),
  ),
];

final List<RepairSymptomQuickFix> kQuickSymptomFixes = [
  const RepairSymptomQuickFix(
    id: 'sym-1',
    title: 'Sensor Dust Spots on Photos',
    category: 'Camera',
    commonCause: 'Lens swaps in dusty environments or mirror box shutter vibration shedding debris.',
    labSolution: 'ISO 100 cleanroom bench inspection, dry ionization air dusting, and wet optical swab wipe.',
    priceMin: 1500,
    priceMax: 2500,
    turnaround: '2 - 4 Hours',
    warrantyDays: 90,
    icon: Icons.grain_rounded,
  ),
  const RepairSymptomQuickFix(
    id: 'sym-2',
    title: 'Shutter Error / Curtain Stuck (Err 20 / 30)',
    category: 'Camera',
    commonCause: 'Shutter curtain blades fatigued after 100k+ actuations or motor gear teeth stripped.',
    labSolution: 'Complete precision disassembly and installation of a brand-new factory OEM shutter assembly.',
    priceMin: 6500,
    priceMax: 14500,
    turnaround: '24 - 48 Hours',
    warrantyDays: 90,
    icon: Icons.shutter_speed_rounded,
  ),
  const RepairSymptomQuickFix(
    id: 'sym-3',
    title: 'AC Blowing Warm Air (Refrigerant Leak)',
    category: 'AC',
    commonCause: 'Vibration cracks in copper flare joints or condenser coil oxidation leaking refrigerant.',
    labSolution: 'Pressurize system with dry nitrogen, braze leaking joints, vacuum to 500 microns, and refill R32/R410A.',
    priceMin: 2000,
    priceMax: 3800,
    turnaround: '2 - 3 Hours',
    warrantyDays: 90,
    icon: Icons.air_rounded,
  ),
  const RepairSymptomQuickFix(
    id: 'sym-4',
    title: 'Dead Laptop After Liquid / Tea Spill',
    category: 'Laptop',
    commonCause: 'Corrosive conductive liquid bridging 19V motherboard rails and blowing charging controller IC.',
    labSolution: 'Immediate ultrasonic circuit wash with pure isopropanol, microscopic trace rework, and MOSFET swap.',
    priceMin: 2500,
    priceMax: 6500,
    turnaround: '24 Hours',
    warrantyDays: 90,
    icon: Icons.water_drop_outlined,
  ),
  const RepairSymptomQuickFix(
    id: 'sym-5',
    title: 'TV Has Sound But Display Is Completely Dark',
    category: 'TV & Display',
    commonCause: 'Constant current thermal failure in LED backlight diodes causing internal open-circuit protect mode.',
    labSolution: 'Carefully de-frame LCD matrix and replace all backlight strips with upgraded copper-backed heatsink LEDs.',
    priceMin: 2200,
    priceMax: 5000,
    turnaround: 'Same Day (4h)',
    warrantyDays: 90,
    icon: Icons.lightbulb_outline_rounded,
  ),
  const RepairSymptomQuickFix(
    id: 'sym-6',
    title: 'Drone Gimbal Overload / Shaking In Flight',
    category: 'Drone',
    commonCause: 'Fine sand or collision damage binding yaw/roll brushless motor bearings or ripped gimbal ribbon.',
    labSolution: 'Replace damaged multi-layer flex ribbon, ultrasonic clean motor shafts, and recalibrate sensor offsets.',
    priceMin: 2200,
    priceMax: 4800,
    turnaround: '24 Hours',
    warrantyDays: 90,
    icon: Icons.videocam_outlined,
  ),
];

final List<LabStandard> kLabStandards = [
  const LabStandard(
    title: 'ISO-Compliant Cleanroom Bench',
    description: 'Optical sensors and delicate camera lenses are serviced in dedicated HEPA-filtered laminar airflow stations to prevent micro-dust contamination.',
    icon: Icons.cleaning_services_rounded,
  ),
  const LabStandard(
    title: 'Genuine OEM Replacement Parts',
    description: 'We source directly from Sony, Canon, DJI, Apple, and Daikin distributor partners. Every component is serialized and backed by our guarantee.',
    icon: Icons.verified_user_rounded,
  ),
  const LabStandard(
    title: 'Zero Obligation Free Diagnosis',
    description: 'Initial 45-point physical bench check in Janakpur is 100% free. If you decide not to proceed with the quoted repair, you pay Rs. 0.',
    icon: Icons.currency_exchange_rounded,
  ),
  const LabStandard(
    title: '90-Day QuickySewa Lab Warranty',
    description: 'Every completed repair carries a full 90-day parts and labor warranty card with priority re-inspection guarantee.',
    icon: Icons.shield_rounded,
  ),
];

class MarketplaceRepairService {
  final String id;
  final String title;
  final String category;
  final String shortDescription;
  final int price;
  final int originalPrice;
  final double rating;
  final int reviewCount;
  final String turnaround;
  final String badge;
  final List<String> features;
  final IconData icon;
  final Color accentColor;
  final bool isPopular;

  const MarketplaceRepairService({
    required this.id,
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.turnaround,
    required this.badge,
    required this.features,
    required this.icon,
    required this.accentColor,
    this.isPopular = false,
  });

  int get discountPercent => (((originalPrice - price) / originalPrice) * 100).round();
}

class LabTechnician {
  final String id;
  final String name;
  final String role;
  final String experience;
  final double rating;
  final int jobsCompleted;
  final String speciality;
  final IconData icon;

  const LabTechnician({
    required this.id,
    required this.name,
    required this.role,
    required this.experience,
    required this.rating,
    required this.jobsCompleted,
    required this.speciality,
    required this.icon,
  });
}

class CustomerReview {
  final String author;
  final String location;
  final String date;
  final String comment;
  final double rating;
  final String serviceName;

  const CustomerReview({
    required this.author,
    required this.location,
    required this.date,
    required this.comment,
    required this.rating,
    required this.serviceName,
  });
}

final List<MarketplaceRepairService> kMarketplaceServices = [
  const MarketplaceRepairService(
    id: 'svc-cam-1',
    title: 'Full-Frame CMOS Sensor Micro-Clean & Polish',
    category: 'Camera',
    shortDescription: 'Wet swab microscopic cleaning inside ISO Class 100 cleanroom + test chart calibration.',
    price: 1500,
    originalPrice: 2000,
    rating: 4.9,
    reviewCount: 142,
    turnaround: '45 Mins • Lab Express',
    badge: '🔥 BESTSELLER',
    isPopular: true,
    features: [
      'ISO-100 cleanroom laminar flow wet cleaning',
      'Electronic shutter test & f/22 test chart verification',
      'Anti-static dust repellent coating applied',
      '90-Day clean guarantee',
    ],
    icon: Icons.camera_alt_rounded,
    accentColor: Color(0xFFE86F1C),
  ),
  const MarketplaceRepairService(
    id: 'svc-cam-2',
    title: 'Mechanical Shutter Unit Overhaul (Err 20 / 30)',
    category: 'Camera',
    shortDescription: 'OEM shutter curtain blades replacement, magnet solenoid calibration & count reset.',
    price: 5200,
    originalPrice: 6500,
    rating: 4.8,
    reviewCount: 78,
    turnaround: '24 Hours',
    badge: 'OEM PARTS',
    features: [
      'Genuine factory shutter blade replacement',
      'Curtain speed synchronization check',
      'Internal gearbox lubrication & mirror box clean',
      '150,000 actuations rated',
    ],
    icon: Icons.burst_mode_rounded,
    accentColor: Color(0xFFE86F1C),
  ),
  const MarketplaceRepairService(
    id: 'svc-lens-1',
    title: 'Optical Lens Glass De-Fungus & UV Sterilization',
    category: 'Lens',
    shortDescription: 'Complete optical element deconstruction, chemical de-hazing wash & UV ozone bath.',
    price: 1800,
    originalPrice: 2500,
    rating: 4.9,
    reviewCount: 196,
    turnaround: '24 Hours',
    badge: 'OPTICAL CLEAR',
    isPopular: true,
    features: [
      'Multi-stage non-abrasive optical bath',
      'UV ozone chamber sterilization (kills 99.9% spores)',
      'Laser collimator alignment & sharpness verify',
      'Clean barrel dust seals',
    ],
    icon: Icons.filter_center_focus_rounded,
    accentColor: Color(0xFF2563EB),
  ),
  const MarketplaceRepairService(
    id: 'svc-lens-2',
    title: 'Aperture Ribbon Cable Fix (Err 01 / Err 99)',
    category: 'Lens',
    shortDescription: 'Fixes electronic aperture lockup, ERR 01 communication faults & iris blade stickiness.',
    price: 2400,
    originalPrice: 3200,
    rating: 4.8,
    reviewCount: 94,
    turnaround: '24 - 48 Hours',
    badge: 'POPULAR FIX',
    features: [
      'High-flex Japanese ribbon cable replacement',
      'Stepping motor contact micro-soldering',
      'Full focal range zoom ring torque check',
      '90-Day aperture warranty',
    ],
    icon: Icons.camera_rounded,
    accentColor: Color(0xFF2563EB),
  ),
  const MarketplaceRepairService(
    id: 'svc-drone-1',
    title: 'DJI Gimbal Axis Flex Ribbon & Motor Overhaul',
    category: 'Drone',
    shortDescription: 'Fixes "Gimbal Overload", shaky video, tilt motor jitter & stuck yaw axis.',
    price: 2200,
    originalPrice: 3000,
    rating: 4.9,
    reviewCount: 115,
    turnaround: '24 Hours',
    badge: 'DJI SPECIALIST',
    isPopular: true,
    features: [
      'Original multi-layer flex ribbon installation',
      'Roll/Yaw/Pitch brushless motor bearing clean',
      'IMU & gimbal software recalibration',
      'Flight test stabilization record',
    ],
    icon: Icons.flight_takeoff_rounded,
    accentColor: Color(0xFF059669),
  ),
  const MarketplaceRepairService(
    id: 'svc-drone-2',
    title: 'Crash Damage Arm, Motor & ESC Board Swap',
    category: 'Drone',
    shortDescription: 'OEM structural arm replacement, motor rewiring & ESC power distribution repair.',
    price: 3600,
    originalPrice: 4800,
    rating: 4.8,
    reviewCount: 68,
    turnaround: '24 - 48 Hours',
    badge: 'CRASH RESCUE',
    features: [
      'Original DJI body arm & motor assembly',
      'ESC electronic speed controller test',
      'Obstacle avoidance sensor check',
      'Free propeller balance set',
    ],
    icon: Icons.handyman_rounded,
    accentColor: Color(0xFF059669),
  ),
  const MarketplaceRepairService(
    id: 'svc-lap-1',
    title: 'Chip-Level Motherboard Repair (No Power / 19V Short)',
    category: 'Laptop',
    shortDescription: 'Thermal camera short detection, blown MOSFET & ceramic capacitor micro-soldering.',
    price: 2800,
    originalPrice: 4000,
    rating: 4.9,
    reviewCount: 230,
    turnaround: 'Same Day - 24h',
    badge: 'CHIP-LEVEL EXPERT',
    isPopular: true,
    features: [
      'FLIR thermal imaging fault isolation',
      'Hakko precision SMD component replacement',
      'Power delivery rails & charging IC restore',
      'Full 4-hour burn-in stress test',
    ],
    icon: Icons.laptop_mac_rounded,
    accentColor: Color(0xFF7C3AED),
  ),
  const MarketplaceRepairService(
    id: 'svc-lap-2',
    title: 'Thermal Overhaul & Liquid Metal / Kryonaut Service',
    category: 'Laptop',
    shortDescription: 'Ultrasonic copper fin cleaning, dried paste removal & ultra-high conductivity paste.',
    price: 1100,
    originalPrice: 1500,
    rating: 4.9,
    reviewCount: 310,
    turnaround: '1 - 2 Hours',
    badge: 'QUICK TUNEUP',
    features: [
      'Thermal Grizzly Kryonaut application',
      'Fan bearing lubrication & de-dusting',
      'Average 12°C - 18°C temperature drop',
      'Keyboard and chassis deep polish',
    ],
    icon: Icons.air_rounded,
    accentColor: Color(0xFF7C3AED),
  ),
  const MarketplaceRepairService(
    id: 'svc-ac-1',
    title: 'Hydro-Jet Chemical Deep Foam Cleaning (Indoor + Outdoor)',
    category: 'AC',
    shortDescription: 'High pressure pressure pump cleaning of coil fins, blower wheel & anti-microbial treatment.',
    price: 1200,
    originalPrice: 1600,
    rating: 4.9,
    reviewCount: 420,
    turnaround: '1.5 Hours • Doorstep',
    badge: '🔥 POPULAR HOME',
    isPopular: true,
    features: [
      'Coil cleaning with non-corrosive chemical foam',
      'Outdoor condenser jet wash (removes caked dust)',
      'Drain line flush & tray sterilization',
      'Immediate 30% airflow & cooling boost',
    ],
    icon: Icons.ac_unit_rounded,
    accentColor: Color(0xFF0284C7),
  ),
  const MarketplaceRepairService(
    id: 'svc-ac-2',
    title: 'Refrigerant Nitrogen Leak Test & R32/R410A Gas Topup',
    category: 'AC',
    shortDescription: 'Digital manifold leak detection, vacuum evacuation & certified virgin gas charging.',
    price: 2800,
    originalPrice: 3500,
    rating: 4.8,
    reviewCount: 185,
    turnaround: '2 - 3 Hours • Doorstep',
    badge: 'LEAK PROOF',
    features: [
      'High pressure nitrogen bubble test',
      'Dual-stage vacuum pump deep moisture extraction',
      'Exact gram-weight electronic scale gas fill',
      'Ampere draw & delta-T temperature verify',
    ],
    icon: Icons.water_drop_rounded,
    accentColor: Color(0xFF0284C7),
  ),
  const MarketplaceRepairService(
    id: 'svc-ac-3',
    title: 'Inverter Dual-PCB Motherboard Micro-Repair',
    category: 'AC',
    shortDescription: 'Fixes error codes (E1, E6, F3, CH), IPM module short-circuits & communication faults.',
    price: 3200,
    originalPrice: 4500,
    rating: 4.7,
    reviewCount: 92,
    turnaround: '24 Hours',
    badge: 'SAVES REPLACEMENT',
    features: [
      'Saves buying expensive new Rs. 15k+ inverter PCB',
      'IGBT module & filtering capacitors replaced',
      'Conformal anti-moisture coating applied',
      '60-Day electrical warranty',
    ],
    icon: Icons.electrical_services_rounded,
    accentColor: Color(0xFF0284C7),
  ),
  const MarketplaceRepairService(
    id: 'svc-tv-1',
    title: 'Copper Heatsink Backlight Array Replacement (Sound OK, Black Screen)',
    category: 'TV & Display',
    shortDescription: 'Full panel de-framing & replacement of all diode strips with heavy copper backed LEDs.',
    price: 2500,
    originalPrice: 3500,
    rating: 4.9,
    reviewCount: 195,
    turnaround: '4 Hours • Same Day',
    badge: 'LONG LIFE FIX',
    isPopular: true,
    features: [
      'Fixes "Sound works but picture is black/dark"',
      'Upgraded copper heatsink strips (runs 20°C cooler)',
      'Uniform brightness with no hot spots',
      '90-Day display backlight warranty',
    ],
    icon: Icons.tv_rounded,
    accentColor: Color(0xFFE11D48),
  ),
  const MarketplaceRepairService(
    id: 'svc-cctv-1',
    title: '4K IP & DVR Surveillance Maintenance & Video Recovery',
    category: 'CCTV',
    shortDescription: 'PoE voltage test, lens focus realign, infrared night vision tune & hard drive check.',
    price: 1200,
    originalPrice: 1800,
    rating: 4.8,
    reviewCount: 154,
    turnaround: '2 - 4 Hours',
    badge: 'SECURITY CARE',
    features: [
      'Infrared LED illumination distance restore',
      'NVR/DVR HDD sector health diagnostic',
      'Waterproof gland seal re-application',
      'Mobile live-view app reconnect & setup',
    ],
    icon: Icons.videocam_rounded,
    accentColor: Color(0xFF475569),
  ),
];

final List<LabTechnician> kLabTechnicians = [
  const LabTechnician(
    id: 'tech-1',
    name: 'Bikash Sharma',
    role: 'Chief Electronics & Optics Engineer',
    experience: '26 Years Lab Exp.',
    rating: 4.98,
    jobsCompleted: 1420,
    speciality: 'CMOS Sensors, Optics, DJI Drones & Studio Gear',
    icon: Icons.precision_manufacturing_rounded,
  ),
  const LabTechnician(
    id: 'tech-2',
    name: 'Sunil Mandal',
    role: 'Senior Micro-Soldering & Chip Specialist',
    experience: '14 Years Lab Exp.',
    rating: 4.94,
    jobsCompleted: 980,
    speciality: 'Motherboard BGA, 19V Short-Circuits & Inverter PCBs',
    icon: Icons.memory_rounded,
  ),
  const LabTechnician(
    id: 'tech-3',
    name: 'Ramesh Jha',
    role: 'Master HVAC & Dual-Inverter Specialist',
    experience: '11 Years Field Exp.',
    rating: 4.91,
    jobsCompleted: 850,
    speciality: 'Inverter Diagnostics, Hydro-Jet Cleaning & Leakages',
    icon: Icons.ac_unit_rounded,
  ),
];

final List<CustomerReview> kCustomerReviews = [
  const CustomerReview(
    author: 'Sunil Raut',
    location: 'Bhanu Chowk, Janakpur',
    date: '3 days ago',
    comment: 'Bikash dai cleaned my Sony A7 IV sensor in 40 mins inside the cleanroom bench. Completely zero dust spots even at f/22 aperture! Unmatched in Janakpur.',
    rating: 5.0,
    serviceName: 'Full-Frame Sensor Micro-Clean',
  ),
  const CustomerReview(
    author: 'Pradip Yadav',
    location: 'Ramanand Chowk, Janakpur',
    date: '1 week ago',
    comment: 'Saved my Daikin 1.5T inverter AC! Showroom asked Rs. 16,000 for new motherboard, QuickySewa repaired the damaged PCB for just Rs. 3,200. Cooling perfectly.',
    rating: 5.0,
    serviceName: 'Inverter Dual-PCB Motherboard Repair',
  ),
  const CustomerReview(
    author: 'Deepak Karn',
    location: 'Station Road, Janakpur',
    date: '2 weeks ago',
    comment: 'DJI Mini 3 Pro had a broken gimbal arm after a tree hit. Repaired with original ribbon cable and calibrated within 24 hours. Very transparent WhatsApp quote!',
    rating: 5.0,
    serviceName: 'DJI Gimbal Axis Flex Ribbon Fix',
  ),
];

