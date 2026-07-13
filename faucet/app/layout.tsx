import type { Metadata } from "next";
import { Inter } from "next/font/google";
import { Footer } from "@/components/footer";
import { Navbar } from "@/components/navbar";
import { NetworkProvider } from "@/components/network-provider";
import { faucetEnabled, serverNetwork } from "@/lib/network";

import "./globals.css";

// Force all pages to be dynamically rendered. We don't
// want any caching of data fetched from the server
export const dynamic = "force-dynamic";

const inter = Inter({ subsets: ["latin"] });

// Runtime metadata: the network comes from the NETWORK env var per request,
// so a single image serves every network.
export async function generateMetadata(): Promise<Metadata> {
  const network = serverNetwork();
  const title = faucetEnabled(network)
    ? `Drivechain Faucet (${network})`
    : `Drivechain Explorer (${network})`;
  const description = faucetEnabled(network)
    ? `A Drivechain faucet for obtaining free (and worthless!) coins on ${network}`
    : `Sidechain explorer and connection info for ${network}`;

  return {
    title,
    description,
    metadataBase: process.env.METADATA_BASE_URL
      ? new URL(process.env.METADATA_BASE_URL)
      : undefined,
    openGraph: {
      title,
      description,
      siteName: title,
      type: "website",
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
    },
  };
}

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
        <NetworkProvider network={serverNetwork()}>
          <Navbar />
          <main className="container mx-auto py-8 px-4 flex-grow">{children}</main>
          <Footer />
        </NetworkProvider>
      </body>
    </html>
  );
}
