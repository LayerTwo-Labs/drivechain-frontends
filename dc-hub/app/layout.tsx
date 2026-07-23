import type { Metadata } from "next";
import { Inter } from "next/font/google";
import { Footer } from "@/components/footer";
import { Navbar } from "@/components/navbar";
import { NetworkProvider } from "@/components/network-provider";
import { getNetworkConfig } from "@/lib/config";
import { faucetEnabled } from "@/lib/network";

import "./globals.css";

// Force all pages to be dynamically rendered. We don't
// want any caching of data fetched from the server
export const dynamic = "force-dynamic";

const inter = Inter({ subsets: ["latin"] });

// Runtime metadata: the network comes from the NETWORK env var per request,
// so a single image serves every network.
export async function generateMetadata(): Promise<Metadata> {
  const network = await getNetworkConfig();
  const title = `Drivechain Hub (${network.display_name})`;
  const description = faucetEnabled(network)
    ? `Faucet, sidechain overview and connection info for ${network.display_name}`
    : `Sidechain overview and connection info for ${network.display_name}`;

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

export default async function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${inter.className} antialiased min-h-screen bg-background text-foreground flex flex-col`}
      >
        <NetworkProvider network={await getNetworkConfig()}>
          <Navbar />
          <main className="container mx-auto py-8 px-4 flex-grow">{children}</main>
          <Footer />
        </NetworkProvider>
      </body>
    </html>
  );
}
