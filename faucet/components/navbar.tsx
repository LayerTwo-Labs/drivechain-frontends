"use client";

import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn, instanceNetwork } from "@/lib/utils";

export function Navbar() {
  const pathname = usePathname();

  return (
    <nav className="border-b bg-background">
      <div className="flex flex-col md:flex-row md:h-16 items-center px-4 container mx-auto justify-between overflow-hidden py-2 md:py-0 gap-2 md:gap-0">
        <div className="font-bold text-xl flex items-center gap-2 shrink-0 w-full md:w-auto justify-center md:justify-start">
          <div className="h-8 w-8 rounded-lg overflow-hidden shrink-0">
            <Image
              src="/icon.png"
              width={32}
              height={32}
              alt="Faucet Logo"
              className="h-full w-full object-cover"
            />
          </div>
          <span className="truncate">Drivechain Faucet ({instanceNetwork()})</span>
        </div>
        <div className="flex space-x-6 overflow-x-auto no-scrollbar w-full md:w-auto justify-center md:justify-end pb-1 md:pb-0">
          <NavLink href="/" active={pathname === "/"}>
            Faucet
          </NavLink>
          <NavLink href="/explorer" active={pathname?.startsWith("/explorer")}>
            Explorer
          </NavLink>
          <NavLink href="https://drivechain.info/">Info</NavLink>
          <NavLink href="https://www.drivechain.info/dev.txt">Dev</NavLink>
        </div>
        {/* Mobile Menu Placeholder - for now we just hide links on small screens, 
            but ideally we should have a hamburger menu or bottom nav. 
            For simplicity in this pass, we'll just let them wrap or hide if really needed, 
            but the hidden md:flex above hides them on mobile. 
            Let's add a simple mobile view or just let them wrap if we don't hide them.
            Actually, let's NOT hide them, but style them to be scrollable or smaller.
        */}
      </div>
    </nav>
  );
}

function NavLink({
  href,
  active,
  children,
}: {
  href: string;
  active?: boolean;
  children: React.ReactNode;
}) {
  return (
    <Link
      href={href}
      target={href.startsWith("http") ? "_blank" : undefined}
      className={cn(
        "text-sm font-medium transition-colors hover:text-primary",
        active ? "text-foreground" : "text-muted-foreground"
      )}
    >
      {children}
    </Link>
  );
}
