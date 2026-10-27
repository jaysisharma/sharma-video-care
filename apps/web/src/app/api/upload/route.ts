import { NextResponse } from "next/server";
import crypto from "crypto";

const CLOUD_NAME = process.env.NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME || "esmfahf0";
const API_KEY = process.env.CLOUDINARY_API_KEY || "774116671947288"; // public identifier, not a secret
const API_SECRET = process.env.CLOUDINARY_API_SECRET; // server-only; never commit it
const FIREBASE_WEB_API_KEY = process.env.NEXT_PUBLIC_FIREBASE_API_KEY || "AIzaSyCvU-6LtUec49iLhk2AwcIlrjup2-jwX-4";

const FOLDER_PATTERN = /^[a-z0-9_-]{1,40}(\/[a-z0-9_-]{1,40}){0,3}$/;
const MAX_BYTES = 10 * 1024 * 1024;

/** True when the bearer token is a valid Firebase ID token (anonymous users included). */
async function isSignedIn(req: Request): Promise<boolean> {
  const idToken = req.headers.get("authorization")?.replace(/^Bearer\s+/i, "");
  if (!idToken) return false;
  const res = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${FIREBASE_WEB_API_KEY}`,
    { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ idToken }) }
  );
  if (!res.ok) return false;
  const data = await res.json();
  return Array.isArray(data.users) && data.users.length > 0;
}

export async function POST(req: Request) {
  try {
    if (!API_SECRET) {
      console.error("CLOUDINARY_API_SECRET is not configured");
      return NextResponse.json({ error: "Uploads are not configured" }, { status: 503 });
    }
    if (!(await isSignedIn(req))) {
      return NextResponse.json({ error: "Sign in to upload images" }, { status: 401 });
    }

    const contentType = req.headers.get("content-type") || "";
    let filePayload: string | Blob | null = null;
    let folder = "video_care";

    if (contentType.includes("multipart/form-data")) {
      const formData = await req.formData();
      const file = formData.get("file");
      const folderParam = formData.get("folder");
      if (typeof folderParam === "string" && folderParam.trim()) {
        folder = folderParam.trim();
      }

      if (!file || typeof file === "string") {
        return NextResponse.json({ error: "No file provided in form data" }, { status: 400 });
      }
      if (!file.type.startsWith("image/") || file.size > MAX_BYTES) {
        return NextResponse.json({ error: "Only images up to 10 MB can be uploaded" }, { status: 400 });
      }
      filePayload = file;
    } else {
      const body = await req.json();
      if (typeof body.file !== "string" || !body.file.startsWith("data:image/")) {
        return NextResponse.json({ error: "Only image data can be uploaded" }, { status: 400 });
      }
      if (body.file.length > MAX_BYTES * 1.4) {
        return NextResponse.json({ error: "Only images up to 10 MB can be uploaded" }, { status: 400 });
      }
      filePayload = body.file;
      if (body.folder && typeof body.folder === "string") {
        folder = body.folder.trim();
      }
    }

    if (!FOLDER_PATTERN.test(folder)) {
      return NextResponse.json({ error: "Invalid upload folder" }, { status: 400 });
    }

    const timestamp = Math.floor(Date.now() / 1000);
    const paramsToSign = `folder=${folder}&timestamp=${timestamp}${API_SECRET}`;
    const signature = crypto.createHash("sha1").update(paramsToSign).digest("hex");

    if (!filePayload) {
      return NextResponse.json({ error: "No file provided" }, { status: 400 });
    }

    const cloudinaryFormData = new FormData();
    if (typeof filePayload === "string") {
      cloudinaryFormData.append("file", filePayload);
    } else {
      cloudinaryFormData.append("file", filePayload as Blob, (filePayload as any)?.name || "upload.png");
    }
    cloudinaryFormData.append("api_key", API_KEY);
    cloudinaryFormData.append("timestamp", timestamp.toString());
    cloudinaryFormData.append("folder", folder);
    cloudinaryFormData.append("signature", signature);

    const cloudRes = await fetch(`https://api.cloudinary.com/v1_1/${CLOUD_NAME}/image/upload`, {
      method: "POST",
      body: cloudinaryFormData,
    });

    const data = await cloudRes.json();

    if (!cloudRes.ok || data.error) {
      console.error("Cloudinary error:", data.error);
      return NextResponse.json(
        { error: data.error?.message || "Failed to upload to Cloudinary" },
        { status: cloudRes.status || 500 }
      );
    }

    return NextResponse.json({
      success: true,
      url: data.secure_url || data.url,
      secure_url: data.secure_url,
      public_id: data.public_id,
      format: data.format,
      width: data.width,
      height: data.height,
    });
  } catch (error: any) {
    console.error("Upload API route error:", error);
    return NextResponse.json(
      { error: "Upload failed. Please try again." },
      { status: 500 }
    );
  }
}

