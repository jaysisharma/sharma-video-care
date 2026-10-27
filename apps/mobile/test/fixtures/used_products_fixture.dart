import 'package:sharma_video_care_mobile/models/models.dart';

/// Sample pre-owned listings for widget tests. Not shipped in the app:
/// customers only ever see real listings from Firestore.
final List<UsedProductModel> kSampleUsedProducts = [
  UsedProductModel(
    id: 'used-1',
    name: 'Sony Alpha A7 III Full-Frame Body',
    brand: 'Sony',
    model: 'ILCE-7M3',
    categoryName: 'Cameras',
    conditionGrade: 'EXCELLENT',
    price: 165000,
    conditionDescription:
        'Sensor is pristine with zero hot pixels. 14,200 shutter actuations out of 200,000 rated lifecycle. Screen protected with 9H tempered glass.',
    knownDefects: ['Minor tripod mounting friction mark on baseplate'],
    testNotes:
        'Bench-tested in Janakpur lab: All 693 AF points lock accurately. Dual SD burst write verified.',
    includedAccessories: [
      'Sony NP-FZ100 Battery',
      'Wall Charger',
      'Neck Strap',
      'Body Cap'
    ],
    warrantyDetails: '90-Day QuickySewa Lab Warranty',
    imageUrl:
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=600&q=80',
  ),
  UsedProductModel(
    id: 'used-2',
    name: 'Canon EOS 5D Mark IV DSLR Body',
    brand: 'Canon',
    model: 'EOS 5D Mark IV',
    categoryName: 'Cameras',
    conditionGrade: 'EXCELLENT',
    price: 175000,
    conditionDescription:
        'Studio-maintained full-frame DSLR. 30.4MP CMOS sensor with dual pixel RAW. Shutter count verified at 28,500 actuations.',
    knownDefects: [
      'Faint hairline scuff on magnesium alloy edge near strap eyelet'
    ],
    testNotes:
        'Shutter actuation and mirror dampening within factory specifications. Optical viewfinder clean.',
    includedAccessories: [
      'Canon LP-E6N Battery',
      'LC-E6 Charger',
      'Neck Strap',
      'Eyecup Eg'
    ],
    warrantyDetails: '90-Day QuickySewa Lab Warranty',
    imageUrl: 'assets/images/products/canon_eos.jpg',
  ),
  UsedProductModel(
    id: 'used-3',
    name: 'DJI Air 2S Fly More Combo (3 Batteries)',
    brand: 'DJI',
    model: 'Air 2S (Mavic Air 2S)',
    categoryName: 'Drones',
    conditionGrade: 'LIKE_NEW',
    price: 115000,
    conditionDescription:
        'Collector-condition camera drone. Total flight log: 9.4 flight hours across 22 flights. Zero crashes, zero propeller strikes.',
    knownDefects: ['Original packaging box shows light shelf storage marks'],
    testNotes:
        'Gimbal calibration pass, battery health 98% across all 3 packs, O3 video link tested at 4km.',
    includedAccessories: [
      'RC-N1 Controller',
      '3x Flight Batteries',
      'Charging Hub',
      'ND Filter Set',
      'Shoulder Bag'
    ],
    warrantyDetails: '90-Day QuickySewa Lab Warranty',
    imageUrl: 'assets/images/products/dji_drone.jpg',
  ),
  UsedProductModel(
    id: 'used-4',
    name: 'Sony FE 24-70mm f/2.8 GM Zoom Lens',
    brand: 'Sony',
    model: 'SEL2470GM',
    categoryName: 'Lenses',
    conditionGrade: 'EXCELLENT',
    price: 145000,
    conditionDescription:
        'G Master constant aperture standard zoom. Optics clean with zero fungus, haze, or scratches. Direct Drive SSM autofocus smooth.',
    knownDefects: ['Slight cosmetic rubbing on plastic petal hood edge'],
    testNotes:
        'Collimator optical bench verified: Centered sharpness at 24mm and 70mm wide open.',
    includedAccessories: [
      'Front & Rear Lens Caps',
      'Lens Hood',
      'Padded Case'
    ],
    warrantyDetails: '90-Day QuickySewa Lab Warranty',
    imageUrl: 'assets/images/products/sony_lens.jpg',
  ),
  UsedProductModel(
    id: 'used-5',
    name: 'Apple MacBook Pro 14" (M1 Pro, 16GB)',
    brand: 'Apple',
    model: 'MacBook Pro 14 (2021)',
    categoryName: 'Laptops',
    conditionGrade: 'LIKE_NEW',
    price: 155000,
    conditionDescription:
        'Mint condition workstation. 120Hz Liquid Retina XDR screen flawless. Battery health 93% with only 64 charge cycles logged.',
    knownDefects: ['Zero scratches, zero keyboard shine'],
    testNotes:
        'Full hardware diagnostics pass: MagSafe, all 3 TB4 ports, HDMI and SD reader 100% operational.',
    includedAccessories: [
      'Original 67W USB-C Adapter',
      'MagSafe 3 Cable',
      'Original Box'
    ],
    warrantyDetails: '90-Day QuickySewa Lab Warranty',
    imageUrl: 'assets/images/products/macbook_pro.jpg',
  ),
  UsedProductModel(
    id: 'used-6',
    name: 'Fujifilm X-T4 Mirrorless Body',
    brand: 'Fujifilm',
    model: 'X-T4 Body',
    categoryName: 'Cameras',
    conditionGrade: 'LIKE_NEW',
    price: 135000,
    conditionDescription:
        '26.1MP X-Trans CMOS 4 with In-Body Image Stabilization. Shutter count under 6,800 actuations.',
    knownDefects: ['None, virtually indistinguishable from new'],
    testNotes:
        'IBIS 5-axis calibration verified. Sensor clean under 10x magnification bench.',
    includedAccessories: [
      'NP-W235 Battery',
      'AC Adapter',
      'Body Cap',
      'Original Strap'
    ],
    warrantyDetails: '90-Day QuickySewa Lab Warranty',
    imageUrl: null,
  ),
  UsedProductModel(
    id: 'used-7',
    name: 'DJI RS 3 Pro 3-Axis Gimbal Combo',
    brand: 'DJI',
    model: 'RS 3 Pro Combo',
    categoryName: 'Gimbals',
    conditionGrade: 'EXCELLENT',
    price: 88000,
    conditionDescription:
        'Carbon fiber axis arms. Automated axis locks verified smooth. Motor balance within normal torque curves.',
    knownDefects: ['Light scuff on bottom battery grip rubber base'],
    testNotes:
        'Full stabilization stress-test with 4.5kg rig completed successfully.',
    includedAccessories: [
      'BG30 Battery Grip',
      'Briefcase Handle',
      'Tripod',
      'Carrying Case'
    ],
    warrantyDetails: '90-Day QuickySewa Lab Warranty',
    imageUrl: null,
  ),
  UsedProductModel(
    id: 'used-8',
    name: 'Sigma 24-70mm f/2.8 DG DN Art (Sony E)',
    brand: 'Sigma',
    model: 'Art DG DN',
    categoryName: 'Lenses',
    conditionGrade: 'EXCELLENT',
    price: 110000,
    conditionDescription:
        'Flagship Art line standard zoom. Optics clean with zero haze, zero scratch. Zoom ring smooth.',
    knownDefects: ['Minor paint rub on lens hood release button'],
    testNotes:
        'Autofocus stepping motor verified with Sony A7R continuous AF tracking.',
    includedAccessories: [
      'Lens Hood',
      'Front & Rear Caps',
      'Padded Case'
    ],
    warrantyDetails: '90-Day QuickySewa Lab Warranty',
    imageUrl:
        'https://images.unsplash.com/photo-1512790182412-b19e6d62bc39?auto=format&fit=crop&w=600&q=80',
  ),
];
