import type { Metadata } from "next";
import { Navbar } from "@/components/navbar";
import { Footer } from "@/components/footer";
import { instanceNetwork } from "@/lib/utils";

import "./globals.css";

export const dynamic = "force-dynamic";

const network = instanceNetwork();
const title = `CoinNews (${network})`;
const description = `Hacker News for Bitcoin, indexed straight from the chain (${network}).`;

export const metadata: Metadata = {
  title,
  description,
  metadataBase: process.env.METADATA_BASE_URL
    ? new URL(process.env.METADATA_BASE_URL)
    : undefined,
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

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body className="min-h-screen flex flex-col">
        <Navbar />
        <main className="container mx-auto max-w-4xl px-3 py-3 flex-grow w-full">
          {children}
        </main>
        <Footer />
      </body>
    </html>
  );
}
