import { initializeApp, getApps, getApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
  projectId: "video-care-456d3",
  appId: "1:753503373289:web:5749dd73c9a70d76a82d78",
  storageBucket: "video-care-456d3.firebasestorage.app",
  apiKey: "AIzaSyCvU-6LtUec49iLhk2AwcIlrjup2-jwX-4",
  authDomain: "video-care-456d3.firebaseapp.com",
  messagingSenderId: "753503373289",
  measurementId: "G-NXT9BNZLB4"
};

const app = getApps().length > 0 ? getApp() : initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

export default app;
