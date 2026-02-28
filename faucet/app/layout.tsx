import type { Metadata } from "next";
import { Inter } from "next/font/google";
import { Footer } from "@/components/footer";
import { Navbar } from "@/components/navbar";
import { instanceNetwork } from "@/lib/utils";

import "./globals.css";

// Force all pages to be dynamically rendered. We don't
// want any caching of data fetched from the server
export const dynamic = "force-dynamic";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: `Drivechain Faucet (${instanceNetwork()})`,
  description: `A Drivechain faucet for obtaining free (and worthless!) coins on ${instanceNetwork()}`,
  metadataBase: process.env.METADATA_BASE_URL ? new URL(process.env.METADATA_BASE_URL) : undefined,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${inter.className} antialiased min-h-screen bg-background text-foreground flex flex-col`}
      >
        <Navbar />
        <main className="container mx-auto py-8 px-4 flex-grow">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
