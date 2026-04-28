"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn, instanceNetwork } from "@/lib/utils";

export function Navbar() {
  const pathname = usePathname() ?? "/";
  return (
    <nav
      className="bg-[var(--accent)] text-[var(--accent-foreground)] px-3 py-1"
      style={{ fontSize: "13px" }}
    >
      <div className="container mx-auto max-w-4xl flex items-center gap-3 flex-wrap">
        <Link href="/" className="font-bold mr-2">
          CoinNews
        </Link>
        <NavLink href="/" active={pathname === "/"}>
          top
        </NavLink>
        <NavLink href="/new" active={pathname.startsWith("/new")}>
          new
        </NavLink>
        <NavLink href="/show" active={pathname.startsWith("/show")}>
          show
        </NavLink>
        <NavLink href="/ask" active={pathname.startsWith("/ask")}>
          ask
        </NavLink>
        <NavLink href="/jobs" active={pathname.startsWith("/jobs")}>
          jobs
        </NavLink>
        <span className="ml-auto opacity-80 text-xs">{instanceNetwork()}</span>
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
      className={cn(
        "text-sm transition-opacity",
        active ? "font-bold" : "opacity-90 hover:opacity-100"
      )}
    >
      {children}
    </Link>
  );
}
