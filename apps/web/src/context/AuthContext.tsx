"use client";

import React, { createContext, useContext, useEffect, useState } from "react";
import { UserRole, TechnicianType, UserProfile } from "@sharmavideocare/shared";
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut as fbSignOut,
  sendPasswordResetEmail,
  onAuthStateChanged,
  updateProfile as fbUpdateProfile,
  signInAnonymously,
  User as FirebaseUser,
} from "firebase/auth";
import { doc, getDoc, setDoc, onSnapshot } from "firebase/firestore";
import { auth, db } from "../lib/firebase";

export interface DemoPersona {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: UserRole;
  technicianType?: TechnicianType;
  label: string;
  defaultPassword?: string;
}

export const DEMO_PERSONAS: DemoPersona[] = [
  {
    id: "cust-janakpur-01",
    name: "Ramesh Sah",
    email: "ramesh@example.com",
    phone: "+977-9801234567",
    role: "customer",
    label: "Customer (Ramesh - Janakpur)",
    defaultPassword: "Customer123!",
  },
  {
    id: "admin-svc-01",
    name: "Sharma Admin",
    email: "admin@sharmavideocare.com",
    phone: "+977-9851000000",
    role: "admin",
    label: "Admin (Operations & Dispatch)",
    defaultPassword: "Admin123!",
  },
  {
    id: "tech-svc-int-01",
    name: "Bikash Sharma",
    email: "bikash.tech@sharmavideocare.com",
    phone: "+977-9844001122",
    role: "technician",
    technicianType: "INTERNAL",
    label: "Internal Tech (Bikash - Janakpur)",
    defaultPassword: "Technician123!",
  },
  {
    id: "tech-svc-ext-01",
    name: "Sunil Mandal",
    email: "sunil.mandal@example.com",
    phone: "+977-9812334455",
    role: "technician",
    technicianType: "EXTERNAL",
    label: "External Tech (Sunil - Appliances)",
    defaultPassword: "Technician123!",
  },
];

interface AuthContextType {
  user: UserProfile | null;
  firebaseUser: FirebaseUser | null;
  role: UserRole;
  technicianType?: TechnicianType;
  isLoading: boolean;
  activePersonaId: string;
  signIn: (email: string, pass: string) => Promise<void>;
  signUp: (name: string, email: string, phone: string, pass: string) => Promise<void>;
  signOut: () => Promise<void>;
  resetPassword: (email: string) => Promise<void>;
  switchPersona: (personaId: string) => Promise<void>;
  updateProfile: (data: Partial<UserProfile>) => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  firebaseUser: null,
  role: "customer",
  isLoading: true,
  activePersonaId: DEMO_PERSONAS[0].id,
  signIn: async () => {},
  signUp: async () => {},
  signOut: async () => {},
  resetPassword: async () => {},
  switchPersona: async () => {},
  updateProfile: async () => {},
});

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [firebaseUser, setFirebaseUser] = useState<FirebaseUser | null>(null);
  const [user, setUser] = useState<UserProfile | null>(null);
  const [activePersonaId, setActivePersonaId] = useState<string>(DEMO_PERSONAS[0].id);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // Subscribe to real Firebase Auth state changes
  useEffect(() => {
    let unsubscribeUserDoc: (() => void) | null = null;

    const unsubscribeAuth = onAuthStateChanged(auth, async (fbUser) => {
      setFirebaseUser(fbUser);

      if (fbUser) {
        try {
          const userDocRef = doc(db, "users", fbUser.uid);
          const snap = await getDoc(userDocRef);

          if (snap.exists()) {
            const data = snap.data() as UserProfile;
            setUser(data);
          } else {
            // Check if this matches a persona email or is a fresh registered user
            const matchedPersona = DEMO_PERSONAS.find((p) => p.email.toLowerCase() === fbUser.email?.toLowerCase());
            const newProfile: UserProfile = {
              id: fbUser.uid,
              name: fbUser.displayName || matchedPersona?.name || fbUser.email?.split("@")[0] || "Customer",
              email: fbUser.email || "",
              phone: matchedPersona?.phone || "+977-9800000000",
              role: matchedPersona?.role || "customer",
              technicianType: matchedPersona?.technicianType,
              status: "ACTIVE",
              createdAt: new Date().toISOString(),
              updatedAt: new Date().toISOString(),
            };

            await setDoc(userDocRef, newProfile);
            setUser(newProfile);
          }

          // Realtime listener for profile updates
          unsubscribeUserDoc = onSnapshot(userDocRef, (s) => {
            if (s.exists()) {
              setUser(s.data() as UserProfile);
            }
          });
        } catch (err) {
          console.error("Firestore user profile sync error:", err);
          // Fallback user representation from Firebase Auth user
          setUser({
            id: fbUser.uid,
            name: fbUser.displayName || fbUser.email?.split("@")[0] || "User",
            email: fbUser.email || "",
            phone: "+977-9800000000",
            role: "customer",
            status: "ACTIVE",
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
          });
        } finally {
          setIsLoading(false);
        }
      } else {
        // Not signed in: User is guest / unauthenticated
        setUser(null);
        setIsLoading(false);
      }
    });

    return () => {
      unsubscribeAuth();
      if (unsubscribeUserDoc) unsubscribeUserDoc();
    };
  }, [activePersonaId]);

  // Sign In with email & password
  const signIn = async (email: string, pass: string) => {
    setIsLoading(true);
    try {
      await signInWithEmailAndPassword(auth, email.trim(), pass);
    } finally {
      setIsLoading(false);
    }
  };

  // Create new customer account
  const signUp = async (name: string, email: string, phone: string, pass: string) => {
    setIsLoading(true);
    try {
      const cred = await createUserWithEmailAndPassword(auth, email.trim(), pass);
      const uid = cred.user.uid;

      if (name) {
        await fbUpdateProfile(cred.user, { displayName: name });
      }

      const profile: UserProfile = {
        id: uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: "customer",
        status: "ACTIVE",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      await setDoc(doc(db, "users", uid), profile);
      setUser(profile);
    } finally {
      setIsLoading(false);
    }
  };

  // Sign out
  const signOut = async () => {
    setIsLoading(true);
    try {
      await fbSignOut(auth);
      setActivePersonaId("");
      setUser(null);
    } finally {
      setIsLoading(false);
    }
  };

  // Password reset
  const resetPassword = async (email: string) => {
    await sendPasswordResetEmail(auth, email.trim());
  };

  // Seamless Demo Persona Switcher (signs into real Firebase Auth if credentials exist or sets persona)
  const switchPersona = async (personaId: string) => {
    setActivePersonaId(personaId);
    const target = DEMO_PERSONAS.find((p) => p.id === personaId) || DEMO_PERSONAS[0];

    try {
      if (target.email && target.defaultPassword) {
        try {
          await signInWithEmailAndPassword(auth, target.email, target.defaultPassword);
          return;
        } catch (loginErr: any) {
          if (loginErr.code === "auth/user-not-found" || loginErr.code === "auth/invalid-credential") {
            try {
              // Attempt to auto-create test user
              const cred = await createUserWithEmailAndPassword(auth, target.email, target.defaultPassword);
              await fbUpdateProfile(cred.user, { displayName: target.name });
              await setDoc(doc(db, "users", cred.user.uid), {
                id: cred.user.uid,
                name: target.name,
                email: target.email,
                phone: target.phone,
                role: target.role,
                technicianType: target.technicianType,
                status: "ACTIVE",
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString(),
              });
              return;
            } catch (createErr) {
              // If email/password creation is restricted, fallback to anonymous sign-in
            }
          }
        }
      }

      // Anonymous sign-in fallback so request.auth != null
      if (!auth.currentUser) {
        try {
          await signInAnonymously(auth);
        } catch {
          // Fallback silently if anonymous auth disabled
        }
      }
    } catch (e) {
      console.warn("Persona auth switch:", e);
    }

    // Set immediate persona state
    setUser({
      id: target.id,
      name: target.name,
      email: target.email,
      phone: target.phone,
      role: target.role,
      technicianType: target.technicianType,
      status: "ACTIVE",
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });
  };

  // Update profile details
  const updateProfile = async (data: Partial<UserProfile>) => {
    if (!user) return;
    const targetUid = firebaseUser?.uid || user.id;
    const userRef = doc(db, "users", targetUid);
    const updated = {
      ...user,
      ...data,
      updatedAt: new Date().toISOString(),
    };
    await setDoc(userRef, updated, { merge: true });
    setUser(updated);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        firebaseUser,
        role: user?.role || "customer",
        technicianType: user?.technicianType,
        isLoading,
        activePersonaId,
        signIn,
        signUp,
        signOut,
        resetPassword,
        switchPersona,
        updateProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
