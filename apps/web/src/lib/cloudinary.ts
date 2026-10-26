/**
 * Cloudinary Media Client Utilities
 * Provides seamless client-side uploading and dynamic CDN transformation.
 */

import { signInAnonymously } from "firebase/auth";
import { auth } from "./firebase";

export interface CloudinaryUploadResult {
  url: string;
  secure_url: string;
  public_id: string;
  format?: string;
  width?: number;
  height?: number;
}

/** Firebase ID token for the /api/upload route; guests are signed in anonymously. */
async function getUploadToken(): Promise<string> {
  const user = auth.currentUser ?? (await signInAnonymously(auth)).user;
  return user.getIdToken();
}

/**
 * Upload a file, blob, or base64 data URI to Cloudinary via the /api/upload endpoint.
 * Returns the secure HTTPS URL of the hosted asset.
 */
export async function uploadToCloudinary(
  file: File | Blob | string,
  folder = "video_care"
): Promise<string> {
  let response: Response;
  const authorization = `Bearer ${await getUploadToken()}`;

  if (typeof file === "string") {
    response = await fetch("/api/upload", {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: authorization },
      body: JSON.stringify({ file, folder }),
    });
  } else {
    const formData = new FormData();
    formData.append("file", file);
    formData.append("folder", folder);
    response = await fetch("/api/upload", {
      method: "POST",
      headers: { Authorization: authorization },
      body: formData,
    });
  }

  const data = await response.json();

  if (!response.ok || !data.secure_url) {
    throw new Error(data.error || "Failed to upload image to Cloudinary");
  }

  return data.secure_url;
}

/**
 * Injects dynamic Cloudinary transformations (auto-format, auto-quality, resize)
 * into any Cloudinary URL.
 */
export function getOptimizedCloudinaryUrl(
  url: string,
  options: { width?: number; height?: number; quality?: string; crop?: string } = {}
): string {
  if (!url || !url.includes("res.cloudinary.com")) {
    return url;
  }

  const { width, height, quality = "auto", crop = "limit" } = options;
  const transforms: string[] = [`f_auto`, `q_${quality}`];

  if (width) transforms.push(`w_${width}`);
  if (height) transforms.push(`h_${height}`);
  if (width || height) transforms.push(`c_${crop}`);

  const transformString = transforms.join(",");

  // Cloudinary URL format: https://res.cloudinary.com/<cloud>/image/upload/<version>/<public_id>
  const uploadIndex = url.indexOf("/upload/");
  if (uploadIndex === -1) return url;

  return (
    url.slice(0, uploadIndex + 8) +
    transformString +
    "/" +
    url.slice(uploadIndex + 8)
  );
}
