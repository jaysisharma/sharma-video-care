import React from "react";

export function ACIcon({ size = 36, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <rect x="4" y="12" width="40" height="18" rx="4" fill="#F4F4F6" stroke="#2D2A26" strokeWidth="2.2" />
      <line x1="8" y1="23" x2="40" y2="23" stroke="#2D2A26" strokeWidth="1.8" />
      <rect x="34" y="16" width="6" height="3" rx="1" fill="#E86F1C" />
      <path d="M12 34C14 37 17 37 19 34" stroke="#4A72B2" strokeWidth="2" strokeLinecap="round" />
      <path d="M22 34C24 37 27 37 29 34" stroke="#4A72B2" strokeWidth="2" strokeLinecap="round" />
      <path d="M32 34C34 37 37 37 39 34" stroke="#4A72B2" strokeWidth="2" strokeLinecap="round" />
    </svg>
  );
}

export function WashingMachineIcon({ size = 36, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <rect x="8" y="6" width="32" height="36" rx="4" fill="#F4F4F6" stroke="#2D2A26" strokeWidth="2.2" />
      <circle cx="24" cy="27" r="10" fill="#E8EDF5" stroke="#2D2A26" strokeWidth="2.2" />
      <circle cx="24" cy="27" r="6" stroke="#4A72B2" strokeWidth="1.8" strokeDasharray="3 3" />
      <circle cx="15" cy="12" r="2" fill="#E86F1C" />
      <line x1="21" y1="12" x2="33" y2="12" stroke="#2D2A26" strokeWidth="2" strokeLinecap="round" />
    </svg>
  );
}

export function TVIcon({ size = 36, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <rect x="5" y="8" width="38" height="25" rx="3" fill="#1E1C1A" stroke="#2D2A26" strokeWidth="2.2" />
      <rect x="8" y="11" width="32" height="19" rx="1.5" fill="#3D3A37" />
      <path d="M24 33V39" stroke="#2D2A26" strokeWidth="2.5" strokeLinecap="round" />
      <path d="M16 39H32" stroke="#2D2A26" strokeWidth="2.5" strokeLinecap="round" />
      <circle cx="24" cy="30" r="1" fill="#E86F1C" />
    </svg>
  );
}

export function CameraIcon({ size = 36, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <path d="M7 16C7 14.3431 8.34315 13 10 13H16L18.5 9.5C18.8 9.1 19.3 8.8 19.8 8.8H28.2C28.7 8.8 29.2 9.1 29.5 9.5L32 13H38C39.6569 13 41 14.3431 41 16V35C41 36.6569 39.6569 38 38 38H10C8.34315 38 7 36.6569 7 35V16Z" fill="#2A2724" stroke="#2D2A26" strokeWidth="2" />
      <circle cx="24" cy="25" r="8" fill="#1A1816" stroke="#D18032" strokeWidth="2" />
      <circle cx="24" cy="25" r="4.5" fill="#3D3A37" stroke="#FFFFFF" strokeWidth="1" />
      <circle cx="34" cy="17" r="1.5" fill="#E86F1C" />
    </svg>
  );
}

export function LaptopIcon({ size = 36, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <rect x="9" y="10" width="30" height="21" rx="2.5" fill="#201E1C" stroke="#2D2A26" strokeWidth="2.2" />
      <rect x="12" y="13" width="24" height="15" rx="1" fill="#4B6082" />
      <path d="M4 35C4 33.3431 5.34315 32 7 32H41C42.6569 32 44 33.3431 44 35C44 36.1046 43.1046 37 42 37H6C4.89543 37 4 36.1046 4 35Z" fill="#E5E0D8" stroke="#2D2A26" strokeWidth="2" />
      <line x1="21" y1="33.5" x2="27" y2="33.5" stroke="#9A9289" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

export function CCTVIcon({ size = 36, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <path d="M12 14H36C37.1046 14 38 14.8954 38 16V19H10V16C10 14.8954 10.8954 14 12 14Z" fill="#E2DDD5" stroke="#2D2A26" strokeWidth="2.2" />
      <path d="M10 19H38V22C38 29.732 31.732 36 24 36C16.268 36 10 29.732 10 22V19Z" fill="#F7F5F0" stroke="#2D2A26" strokeWidth="2.2" />
      <circle cx="24" cy="25" r="6" fill="#1C1A18" stroke="#2D2A26" strokeWidth="1.8" />
      <circle cx="24" cy="25" r="3" fill="#3A3835" />
      <circle cx="22.5" cy="23.5" r="1" fill="#4ADE80" />
      <path d="M18 10H30" stroke="#2D2A26" strokeWidth="2" strokeLinecap="round" />
      <path d="M24 10V14" stroke="#2D2A26" strokeWidth="2" />
    </svg>
  );
}

export function MobileIcon({ size = 36, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <rect x="14" y="6" width="20" height="36" rx="4" fill="#1E1C1A" stroke="#2D2A26" strokeWidth="2.2" />
      <rect x="16" y="9" width="16" height="30" rx="2" fill="#363A40" />
      <circle cx="24" cy="11" r="1" fill="#E86F1C" />
      <line x1="21" y1="37" x2="27" y2="37" stroke="#C5BCB0" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

export function HomeApplianceIcon({ size = 36, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      {/* Blender / Food Processor */}
      <path d="M15 11L18 29H30L33 11H15Z" fill="#F0EDE7" stroke="#2D2A26" strokeWidth="2.2" />
      <line x1="16" y1="16" x2="32" y2="16" stroke="#2D2A26" strokeWidth="1.5" strokeDasharray="2 2" />
      <path d="M14 9H34V11H14V9Z" fill="#2D2A26" />
      <rect x="16" y="29" width="16" height="12" rx="3" fill="#D6D0C5" stroke="#2D2A26" strokeWidth="2.2" />
      <circle cx="24" cy="35" r="2.5" fill="#E86F1C" />
      <path d="M30 15H36V23H30" stroke="#2D2A26" strokeWidth="2" strokeLinecap="round" />
    </svg>
  );
}

export function TVWallMountIcon({ size = 36, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <rect x="6" y="14" width="4" height="20" rx="1" fill="#2D2A26" />
      <rect x="38" y="14" width="4" height="20" rx="1" fill="#2D2A26" />
      <line x1="10" y1="18" x2="38" y2="18" stroke="#2D2A26" strokeWidth="2.2" />
      <line x1="10" y1="30" x2="38" y2="30" stroke="#2D2A26" strokeWidth="2.2" />
      <rect x="18" y="10" width="12" height="28" rx="2" fill="#E2DDD5" stroke="#2D2A26" strokeWidth="2" />
      <circle cx="24" cy="24" r="3" fill="#E86F1C" />
    </svg>
  );
}

export function OtherServicesIcon({ size = 36, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <circle cx="24" cy="24" r="7" fill="#EAE5DD" stroke="#2D2A26" strokeWidth="2.2" />
      <path d="M24 8V12M24 36V40M8 24H12M36 24H40M13 13L16 16M32 32L35 35M13 35L16 32M32 16L35 13" stroke="#2D2A26" strokeWidth="2.5" strokeLinecap="round" />
      <circle cx="24" cy="24" r="3" fill="#E86F1C" />
    </svg>
  );
}
