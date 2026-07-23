"use client";

import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useNetwork } from "@/components/network-provider";
import { faucetEnabled } from "@/lib/network";
import { cn } from "@/lib/utils";

export function Navbar() {
  const pathname = usePathname();
  const network = useNetwork();

  return (
    <nav className="border-b bg-background">
      <div className="flex flex-col md:flex-row md:h-16 items-center px-4 container mx-auto justify-between overflow-hidden py-2 md:py-0 gap-2 md:gap-0">
        <div className="font-bold text-xl flex items-center gap-2 shrink-0 w-full md:w-auto justify-center md:justify-start">
          <div className="h-8 w-8 rounded-lg overflow-hidden shrink-0">
            <Image
              src="/icon.png"
              width={32}
              height={32}
              alt="Drivechain Hub Logo"
              className="h-full w-full object-cover"
            />
          </div>
          <span className="truncate">Drivechain Hub ({network.display_name})</span>
        </div>
        <div className="flex space-x-6 overflow-x-auto no-scrollbar w-full md:w-auto justify-center md:justify-end pb-1 md:pb-0">
          {faucetEnabled(network) && (
            <NavLink href="/" active={pathname === "/"}>
              Faucet
            </NavLink>
          )}
          <NavLink href="/sidechains" active={pathname?.startsWith("/sidechains")}>
            Sidechains
          </NavLink>
          <NavLink href="/info" active={pathname?.startsWith("/info")}>
            Info
          </NavLink>
          <NavLink href="https://www.drivechain.info/dev.txt">Dev</NavLink>
        </div>
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
