"use client";

import { useEffect, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";

function SearchRedirect() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const query = searchParams.get("q") || "";

  useEffect(() => {
    if (query) {
      router.replace(`/shop?q=${encodeURIComponent(query)}`);
    } else {
      router.replace("/shop");
    }
  }, [query, router]);

  return (
    <div
      style={{
        minHeight: "60vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        color: "#64748B",
        fontSize: "14px",
      }}
    >
      Redirecting to search results...
    </div>
  );
}

export default function SearchPage() {
  return (
    <Suspense
      fallback={
        <div
          style={{
            minHeight: "60vh",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            color: "#64748B",
            fontSize: "14px",
          }}
        >
          Loading search...
        </div>
      }
    >
      <SearchRedirect />
    </Suspense>
  );
}
