"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

export function Navbar() {
  const pathname = usePathname() ?? "/";
  return (
    <nav className="nav">
      <NavLink href="/" active={pathname === "/"}>
        Top
      </NavLink>
      <span className="nav__sep">·</span>
      <NavLink href="/new" active={pathname.startsWith("/new")}>
        New
      </NavLink>
      <span className="nav__sep">·</span>
      <NavLink href="/jobs" active={pathname.startsWith("/jobs")}>
        Jobs
      </NavLink>
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
    <Link href={href} className={`nav__link${active ? " is-active" : ""}`}>
      {children}
    </Link>
  );
}
