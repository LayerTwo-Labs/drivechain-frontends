import type { Metadata } from "next";
import Link from "next/link";
import { Navbar } from "@/components/navbar";
import { Footer } from "@/components/footer";
import { instanceNetwork } from "@/lib/utils";

import "./globals.css";

export const dynamic = "force-dynamic";

const network = instanceNetwork();
const title = `CoinNews (${network})`;
const description = `On-chain news indexer (${network}).`;

export const metadata: Metadata = {
  title,
  description,
  metadataBase: process.env.METADATA_BASE_URL ? new URL(process.env.METADATA_BASE_URL) : undefined,
  openGraph: {
    title,
    description,
    siteName: "CoinNews",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title,
    description,
  },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body className="app">
        <header className="topbar">
          <div className="container topbar__inner">
            <Link href="/" className="brand">
              <span className="brand__dot">◉</span>
              <span>CoinNews</span>
            </Link>
            <Navbar />
          </div>
        </header>
        <main className="main">
          <div className="container">{children}</div>
        </main>
        <Footer />
      </body>
    </html>
  );
}
