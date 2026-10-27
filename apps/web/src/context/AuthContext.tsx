"use client";

import React, { createContext, useContext, useEffect, useRef, useState } from "react";
import { UserRole, TechnicianType, UserProfile } from "@sharmavideocare/shared";
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut as fbSignOut,
  sendPasswordResetEmail,
  onAuthStateChanged,
  updateProfile as fbUpdateProfile,
  sendEmailVerification,
  setPersistence,
  reauthenticateWithCredential,
  EmailAuthProvider,
  deleteUser,
  browserLocalPersistence,
  browserSessionPersistence,
  User as FirebaseUser,
} from "firebase/auth";
import { doc, getDoc, setDoc, deleteDoc, onSnapshot } from "firebase/firestore";
import { auth, db } from "../lib/firebase";

// Profile fields a user may edit on their own document (mirrors firestore.rules).
const SELF_EDITABLE_FIELDS = ["name", "phone", "photoUrl"] as const;

export const ADMIN_EMAILS = [
  "jaysisharma@gmail.com",
  "admin@sharmavideocare.com",
  "admin@video.care",
];

export function isAdminEmail(email: string | null | undefined): boolean {
  if (!email) return false;
  return ADMIN_EMAILS.includes(email.trim().toLowerCase());
}

/**
 * Admin UI by email only for verified addresses; otherwise anyone could register an
 * unclaimed address from the list. Data access is still decided by firestore.rules.
 */
function isTrustedAdmin(fbUser: FirebaseUser): boolean {
  return fbUser.emailVerified && isAdminEmail(fbUser.email);
}

interface AuthContextType {
  user: UserProfile | null;
  firebaseUser: FirebaseUser | null;
  role: UserRole;
  technicianType?: TechnicianType;
  isLoading: boolean;
  signIn: (email: string, pass: string, remember?: boolean) => Promise<UserProfile | null>;
  signUp: (name: string, email: string, phone: string, pass: string) => Promise<void>;
  signOut: () => Promise<void>;
  resetPassword: (email: string) => Promise<void>;
  updateProfile: (data: Partial<UserProfile>) => Promise<void>;
  resendVerificationEmail: () => Promise<void>;
  deleteAccount: (currentPassword: string) => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  firebaseUser: null,
  role: "customer",
  isLoading: true,
  signIn: async () => null,
  signUp: async () => {},
  signOut: async () => {},
  resetPassword: async () => {},
  updateProfile: async () => {},
  resendVerificationEmail: async () => {},
  deleteAccount: async () => {},
});

/** Rejects absolute / protocol-relative URLs so `?redirect=` cannot send users off-site. */
export function safeRedirectPath(target: string | null | undefined): string | null {
  if (!target) return null;
  if (!target.startsWith("/") || target.startsWith("//") || target.startsWith("/\\")) return null;
  return target;
}

export function homePathForRole(role: UserRole | undefined, email?: string | null): string {
  if (role === "admin" || isAdminEmail(email)) return "/admin";
  if (role === "technician") return "/technician";
  return "/account";
}

function newCustomerProfile(fbUser: FirebaseUser, name?: string, phone?: string): UserProfile {
  const now = new Date().toISOString();
  return {
    id: fbUser.uid,
    name: (name || fbUser.displayName || fbUser.email?.split("@")[0] || "Customer").trim(),
    email: fbUser.email || "",
    phone: phone?.trim() || "",
    role: "customer",
    status: "ACTIVE",
    createdAt: now,
    updatedAt: now,
  };
}

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [firebaseUser, setFirebaseUser] = useState<FirebaseUser | null>(null);
  const [user, setUser] = useState<UserProfile | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  // While signUp() is writing the full profile, the auth listener must not create a partial one.
  const signingUpRef = useRef(false);

  useEffect(() => {
    let unsubscribeUserDoc: (() => void) | null = null;

    const unsubscribeAuth = onAuthStateChanged(auth, async (fbUser) => {
      unsubscribeUserDoc?.();
      unsubscribeUserDoc = null;
      setFirebaseUser(fbUser);

      if (!fbUser || fbUser.isAnonymous) {
        setUser(null);
        setIsLoading(false);
        return;
      }

      setIsLoading(true);
      const userDocRef = doc(db, "users", fbUser.uid);

      try {
        if (!signingUpRef.current) {
          const snap = await getDoc(userDocRef);
          if (!snap.exists()) {
            // Accounts created outside signUp() (e.g. console) get a customer profile.
            // Roles are only ever granted by an admin; firestore.rules enforce this.
            await setDoc(userDocRef, newCustomerProfile(fbUser));
          }
        }
      } catch (err) {
        console.error("Firestore user profile sync error:", err);
      }

      unsubscribeUserDoc = onSnapshot(
        userDocRef,
        (s) => {
          const isAdmin = isTrustedAdmin(fbUser);
          if (s.exists()) {
            const data = s.data() as UserProfile;
            setUser({ ...(s.data() as UserProfile), id: fbUser.uid, role: isAdmin ? "admin" : data.role });
            setIsLoading(false);
          } else if (!signingUpRef.current) {
            const profile = newCustomerProfile(fbUser);
            if (isAdmin) profile.role = "admin";
            setUser(profile);
            setIsLoading(false);
          }
        },
        (err) => {
          console.error("User profile listener error:", err);
          const profile = newCustomerProfile(fbUser);
          if (isTrustedAdmin(fbUser)) profile.role = "admin";
          setUser(profile);
          setIsLoading(false);
        }
      );
    });

    return () => {
      unsubscribeAuth();
      unsubscribeUserDoc?.();
    };
  }, []);

  const signIn = async (email: string, pass: string, remember = true) => {
    await setPersistence(auth, remember ? browserLocalPersistence : browserSessionPersistence);
    const cred = await signInWithEmailAndPassword(auth, email.trim(), pass);

    const snap = await getDoc(doc(db, "users", cred.user.uid)).catch(() => null);
    const profile = snap?.exists() ? (snap.data() as UserProfile) : null;

    if (profile && profile.status !== "ACTIVE") {
      await fbSignOut(auth);
      throw Object.assign(new Error("This account has been deactivated."), { code: "auth/user-disabled" });
    }
    return profile;
  };

  const signUp = async (name: string, email: string, phone: string, pass: string) => {
    signingUpRef.current = true;
    try {
      const cred = await createUserWithEmailAndPassword(auth, email.trim(), pass);
      await fbUpdateProfile(cred.user, { displayName: name.trim() });
      const profile = newCustomerProfile(cred.user, name, phone);
      await setDoc(doc(db, "users", cred.user.uid), profile);
      setUser(profile);
      setIsLoading(false);
      sendEmailVerification(cred.user).catch((err) => console.warn("Verification email failed:", err));
    } finally {
      signingUpRef.current = false;
    }
  };

  const signOut = async () => {
    await fbSignOut(auth);
    setUser(null);
  };

  const resetPassword = async (email: string) => {
    await sendPasswordResetEmail(auth, email.trim());
  };

  const updateProfile = async (data: Partial<UserProfile>) => {
    if (!firebaseUser || !user) return;
    const patch: Partial<UserProfile> = {};
    for (const key of SELF_EDITABLE_FIELDS) {
      if (data[key] !== undefined) (patch as Record<string, unknown>)[key] = data[key];
    }
    const updated = { ...patch, updatedAt: new Date().toISOString() };
    await setDoc(doc(db, "users", firebaseUser.uid), updated, { merge: true });
    setUser({ ...user, ...updated });
  };

  const resendVerificationEmail = async () => {
    if (auth.currentUser && !auth.currentUser.emailVerified) {
      await sendEmailVerification(auth.currentUser);
    }
  };

  // Removes the profile and the Firebase Auth account. Orders, repairs and payments
  // are kept as business records.
  const deleteAccount = async (currentPassword: string) => {
    const current = auth.currentUser;
    if (!current?.email) throw new Error("No signed-in user.");
    await reauthenticateWithCredential(current, EmailAuthProvider.credential(current.email, currentPassword));
    await deleteDoc(doc(db, "customers", current.uid)).catch(() => undefined);
    await deleteDoc(doc(db, "users", current.uid));
    await deleteUser(current);
    setUser(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        firebaseUser,
        role: user?.role || "customer",
        technicianType: user?.technicianType,
        isLoading,
        signIn,
        signUp,
        signOut,
        resetPassword,
        updateProfile,
        resendVerificationEmail,
        deleteAccount,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
