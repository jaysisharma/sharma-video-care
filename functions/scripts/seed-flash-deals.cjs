#!/usr/bin/env node
/**
 * Seeds the flash-deal products shown on the mobile home screen into the
 * `products` collection (same fields the web admin writes, plus
 * `originalPrice`, `isFlashDeal` and `flashDealEndsAt`).
 *
 * Re-running is safe: documents use fixed ids and are merged, so prices and
 * the end time are refreshed without creating duplicates.
 *
 * Auth: uses Application Default Credentials. Either run
 *   gcloud auth application-default login   (with an account on the project)
 * or point GOOGLE_APPLICATION_CREDENTIALS at a service-account key file.
 *
 * Usage (from the repo root):
 *   node functions/scripts/seed-flash-deals.cjs --dry-run
 *   node functions/scripts/seed-flash-deals.cjs --hours=72
 */
const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const PROJECT_ID = 'video-care-456d3';

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const hoursArg = args.find((a) => a.startsWith('--hours='));
const hours = hoursArg ? Number(hoursArg.split('=')[1]) : 72;
if (!Number.isFinite(hours) || hours <= 0) {
  console.error('--hours must be a positive number');
  process.exit(1);
}

const RETURN_POLICY = '7-day return if unused and in original packaging';

// Edit prices, stock and copy here before running; this is the source of truth for the seed.
const DEALS = [
  {
    id: 'flash-sony-a7-iv',
    name: 'Sony Alpha A7 IV Full-Frame Body',
    brand: 'Sony',
    categoryName: 'Cameras',
    price: 320000,
    originalPrice: 385000,
    stockQuantity: 2,
    description: '33MP Exmor R CMOS • 4K 60p 10-Bit • S-Cinetone • Real-Time AF',
    warrantyInfo: '1-Year Official Sony Warranty',
    image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=600&q=80',
  },
  {
    id: 'flash-dji-mini-4-pro',
    name: 'DJI Mini 4 Pro Drone Fly More Combo',
    brand: 'DJI',
    categoryName: 'Drones',
    price: 165000,
    originalPrice: 195000,
    stockQuantity: 3,
    description: '< 249g • Omnidirectional Sensing • 4K/60fps HDR • 20km O4 Range',
    warrantyInfo: 'Official DJI Nepal Warranty',
    image: 'https://images.unsplash.com/photo-1527977966376-1c8408f9f108?auto=format&fit=crop&w=600&q=80',
  },
  {
    id: 'flash-sony-fe-50-f18',
    name: 'Sony FE 50mm f/1.8 Prime Lens',
    brand: 'Sony',
    categoryName: 'Lenses',
    price: 42000,
    originalPrice: 52000,
    stockQuantity: 4,
    description: 'E-Mount Full-Frame • Fast f/1.8 Aperture • 7-Blade Circular Aperture',
    warrantyInfo: '1-Year Warranty',
    image: 'https://images.unsplash.com/photo-1617005082133-548c4dd27f35?auto=format&fit=crop&w=600&q=80',
  },
  {
    id: 'flash-canon-eos-r5',
    name: 'Canon EOS R5 Mirrorless Pro Body',
    brand: 'Canon',
    categoryName: 'Cameras',
    price: 485000,
    originalPrice: 550000,
    stockQuantity: 1,
    description: '45MP Full-Frame • 8K RAW • In-Body IS • Dual CFexpress/SD Slots',
    warrantyInfo: '1-Year Official Canon Nepal Warranty',
    image: 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?auto=format&fit=crop&w=600&q=80',
  },
  {
    id: 'flash-macbook-pro-m3-pro-14',
    name: 'Apple MacBook Pro M3 Pro 14"',
    brand: 'Apple',
    categoryName: 'Laptops',
    price: 295000,
    originalPrice: 335000,
    stockQuantity: 2,
    description: 'Apple M3 Pro 11-Core CPU • 14-Core GPU • Liquid Retina XDR • Space Black',
    warrantyInfo: '1-Year Apple Care Official',
    image: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=600&q=80',
  },
];

function toDoc(deal, nowIso, endsAtIso) {
  const inStock = deal.stockQuantity > 0;
  return {
    name: deal.name,
    title: deal.name,
    brand: deal.brand,
    categoryId: deal.categoryName.toLowerCase(),
    categoryName: deal.categoryName,
    category: deal.categoryName,
    price: deal.price,
    priceNpr: deal.price,
    originalPrice: deal.originalPrice,
    stockQuantity: deal.stockQuantity,
    images: [deal.image],
    imageUrl: deal.image,
    description: deal.description,
    warrantyInfo: deal.warrantyInfo,
    returnPolicyInfo: RETURN_POLICY,
    active: inStock,
    inStock,
    availabilityType: inStock ? 'IN_STOCK' : 'OUT_OF_STOCK',
    condition: 'Brand New',
    isFlashDeal: true,
    flashDealEndsAt: endsAtIso,
    updatedAt: nowIso,
  };
}

async function main() {
  const now = new Date();
  const nowIso = now.toISOString();
  const endsAtIso = new Date(now.getTime() + hours * 3600 * 1000).toISOString();

  for (const deal of DEALS) {
    if (!(deal.originalPrice > deal.price)) {
      throw new Error(`${deal.id}: originalPrice must be above price`);
    }
  }

  console.log(`${dryRun ? '[dry run] ' : ''}Seeding ${DEALS.length} flash deals into ${PROJECT_ID}/products, ending ${endsAtIso}`);
  if (dryRun) {
    for (const deal of DEALS) console.log(` - ${deal.id}: Rs. ${deal.price} (was ${deal.originalPrice}), stock ${deal.stockQuantity}`);
    return;
  }

  initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
  const db = getFirestore();
  const batch = db.batch();
  const refs = DEALS.map((deal) => db.collection('products').doc(deal.id));
  const existing = await db.getAll(...refs);

  DEALS.forEach((deal, i) => {
    const data = toDoc(deal, nowIso, endsAtIso);
    if (!existing[i].exists) data.createdAt = nowIso;
    batch.set(refs[i], data, { merge: true });
    console.log(` - ${existing[i].exists ? 'updated' : 'created'} ${deal.id}`);
  });

  await batch.commit();
  console.log('Done.');
}

main().catch((err) => {
  console.error(err.message || err);
  if (String(err.message || err).includes('credential')) {
    console.error('Run `gcloud auth application-default login` with an account that has access to the project.');
  }
  process.exit(1);
});
