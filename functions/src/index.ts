import { initializeApp } from "firebase-admin/app";
import { getFirestore, DocumentReference, DocumentSnapshot } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { logger } from "firebase-functions";
import { createHash } from "crypto";

initializeApp();
const db = getFirestore();

// Set with: firebase functions:secrets:set CLOUDINARY_API_SECRET
const cloudinaryApiSecret = defineSecret("CLOUDINARY_API_SECRET");
const CLOUDINARY_FOLDER = /^[a-z0-9_-]{1,40}(\/[a-z0-9_-]{1,40}){0,3}$/;

/**
 * Signs a Cloudinary upload so the API secret never ships inside the app.
 * Any signed-in user (anonymous guests included) may upload, only into
 * well-formed folders, and only with the parameters signed here.
 */
export const signCloudinaryUpload = onCall({ secrets: [cloudinaryApiSecret] }, (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in to upload photos.");
  }
  const folder = typeof request.data?.folder === "string" ? request.data.folder : "video_care";
  if (!CLOUDINARY_FOLDER.test(folder)) {
    throw new HttpsError("invalid-argument", "Invalid upload folder.");
  }
  const timestamp = Math.floor(Date.now() / 1000);
  // Cloudinary signs the alphabetically sorted parameters followed by the secret.
  const signature = createHash("sha1")
    .update(`folder=${folder}&timestamp=${timestamp}${cloudinaryApiSecret.value()}`)
    .digest("hex");
  return { folder, timestamp, signature };
});

// Must match the flat delivery fee charged by the web and mobile checkouts.
const DELIVERY_FEE = 150;
const MAX_QTY_PER_ITEM = 100;

interface OrderItemInput {
  productId?: string;
  productType?: string;
  name?: string;
  unitPrice?: number;
  quantity?: number;
}

/**
 * Orders are written by clients (including guests), so nothing in them is trusted.
 * This trigger re-checks every price against the live catalog, applies inventory
 * changes with the Admin SDK (clients cannot write products), and records the result
 * on the order so admins can see which orders need a manual price check.
 */
export const onOrderCreated = onDocumentCreated("orders/{orderId}", async (event) => {
  const snap = event.data;
  if (!snap) return;
  const orderRef = snap.ref as DocumentReference;
  const orderId = event.params.orderId;

  await db.runTransaction(async (tx) => {
    const fresh = await tx.get(orderRef);
    const order = fresh.data();
    if (!order || order.inventoryApplied) return; // retries must not double-decrement

    const items: OrderItemInput[] = Array.isArray(order.items) ? order.items : [];
    const issues: string[] = [];
    const unverifiedItems: string[] = [];

    // Firestore transactions require every read before the first write.
    const lookups = await Promise.all(
      items.map(async (item) => {
        if (!item.productId || item.productType === "SOURCED") return null;
        const collection = item.productType === "USED" ? "usedProducts" : "products";
        const ref = db.collection(collection).doc(item.productId);
        return { ref, doc: (await tx.get(ref)) as DocumentSnapshot };
      })
    );

    let computedSubtotal = 0;
    const writes: Array<() => void> = [];
    const now = new Date().toISOString();

    items.forEach((item, i) => {
      const label = item.name || item.productId || `item ${i + 1}`;
      const qty = item.quantity;
      const unitPrice = item.unitPrice;

      if (!Number.isInteger(qty) || (qty as number) < 1 || (qty as number) > MAX_QTY_PER_ITEM) {
        issues.push(`${label}: invalid quantity ${qty}`);
        return;
      }
      if (typeof unitPrice !== "number" || unitPrice < 0) {
        issues.push(`${label}: invalid unit price`);
        return;
      }
      computedSubtotal += unitPrice * (qty as number);

      const lookup = lookups[i];
      if (!lookup || !lookup.doc.exists) {
        unverifiedItems.push(label);
        return;
      }

      const product = lookup.doc.data()!;
      if (typeof product.price === "number" && product.price !== unitPrice) {
        issues.push(`${label}: charged Rs. ${unitPrice}, catalog price Rs. ${product.price}`);
      }

      if (item.productType === "USED") {
        if (product.status === "SOLD" || product.availability === "SOLD") {
          issues.push(`${label}: already sold`);
          return;
        }
        writes.push(() =>
          tx.update(lookup.ref, { status: "SOLD", availability: "SOLD", soldOrderId: orderId, updatedAt: now })
        );
      } else {
        const stock = typeof product.stockQuantity === "number" ? product.stockQuantity : 0;
        if (stock < (qty as number)) issues.push(`${label}: only ${stock} in stock`);
        const newStock = Math.max(0, stock - (qty as number));
        writes.push(() =>
          tx.update(lookup.ref, {
            stockQuantity: newStock,
            availabilityType: newStock === 0 ? "OUT_OF_STOCK" : product.availabilityType || "IN_STOCK",
            updatedAt: now,
          })
        );
      }
    });

    const discount = typeof order.discount === "number" ? order.discount : 0;
    if (discount !== 0) issues.push(`unexpected discount Rs. ${discount}`);
    if (order.subtotal !== computedSubtotal) {
      issues.push(`subtotal Rs. ${order.subtotal} does not match items (Rs. ${computedSubtotal})`);
    }
    if (order.deliveryFee !== DELIVERY_FEE) issues.push(`delivery fee Rs. ${order.deliveryFee} (expected ${DELIVERY_FEE})`);
    if (order.total !== computedSubtotal + DELIVERY_FEE) {
      issues.push(`total Rs. ${order.total} (expected Rs. ${computedSubtotal + DELIVERY_FEE})`);
    }

    writes.forEach((w) => w());
    tx.update(orderRef, {
      inventoryApplied: true,
      priceVerified: issues.length === 0 && unverifiedItems.length === 0,
      priceIssues: issues,
      unverifiedItems,
      verifiedAt: now,
    });

    tx.set(db.collection("conversations").doc(`order_${orderId}`), {
      customerId: order.customerId,
      customerName: order.customerName || "Customer",
      contextType: "ORDER",
      contextId: orderId,
      contextTitle: `Order #${orderId.slice(0, 8)} (${items.length} items)`,
      participantIds: [order.customerId],
      status: "OPEN",
      lastMessageText: `New order placed for Rs. ${Number(order.total || 0).toLocaleString("en-IN")}`,
      lastMessageAt: now,
      unreadCountCustomer: 0,
      unreadCountStaff: 1,
    });

    if (issues.length) logger.warn("Order failed verification", { orderId, issues });
  });
});
