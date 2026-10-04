/**
 * Cloudinary Media Helper for Sharma Video Care
 * Cloud Name: esmfahf0
 */

export const CLOUDINARY_CONFIG = {
  cloudName: process.env.NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME || "esmfahf0",
  apiKey: process.env.CLOUDINARY_API_KEY || "774116671947288",
  uploadUrl: `https://api.cloudinary.com/v1_1/${process.env.NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME || "esmfahf0"}/image/upload`,
};

/**
 * Upload an image file or base64 data to Cloudinary
 * @param file File, Blob, or base64 string
 * @param uploadPreset Optional Cloudinary unsigned upload preset name
 */
export async function uploadToCloudinary(
  file: File | Blob | string,
  uploadPreset: string = "ml_default"
): Promise<{ url: string; secure_url: string; public_id: string }> {
  const formData = new FormData();

  if (typeof file === "string") {
    formData.append("file", file);
  } else {
    formData.append("file", file);
  }

  formData.append("upload_preset", uploadPreset);

  const res = await fetch(CLOUDINARY_CONFIG.uploadUrl, {
    method: "POST",
    body: formData,
  });

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`Cloudinary upload failed: ${errorText}`);
  }

  return res.json();
}
