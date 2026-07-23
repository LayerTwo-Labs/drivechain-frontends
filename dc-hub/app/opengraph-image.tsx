import { ImageResponse } from "next/og";
import { getNetworkConfig } from "@/lib/config";

// The network is only known at runtime (NETWORK env var), but Next prerenders
// metadata image routes at build time by default — which would bake whichever
// network the build happened to default to into a static PNG, for every
// deployment of the image. The layout's force-dynamic doesn't cover this: an
// opengraph-image is compiled into its own route, with its own segment config.
export const dynamic = "force-dynamic";

export const alt = "Drivechain";
export const size = {
  width: 1200,
  height: 630,
};

export const contentType = "image/png";

export default async function Image() {
  const network = await getNetworkConfig();

  return new ImageResponse(
    <div
      style={{
        background: "linear-gradient(to bottom right, #222222, #000000)",
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: "sans-serif",
        color: "white",
      }}
    >
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          border: "1px solid #333",
          borderRadius: "40px",
          padding: "60px 100px",
          background: "rgba(255, 255, 255, 0.03)",
          boxShadow: "0 4px 30px rgba(0, 0, 0, 0.1)",
        }}
      >
        <div
          style={{
            fontSize: 110,
            fontWeight: 800,
            letterSpacing: "-0.05em",
            marginBottom: 30,
            background: "linear-gradient(to right, #ffffff, #888888)",
            backgroundClip: "text",
            color: "transparent",
            textAlign: "center",
            lineHeight: 1,
          }}
        >
          Drivechain Hub
        </div>
        <div
          style={{
            fontSize: 56,
            fontWeight: 500,
            color: "#888",
            textTransform: "uppercase",
            letterSpacing: "0.2em",
            display: "flex",
            alignItems: "center",
            gap: "24px",
            marginTop: 10,
          }}
        >
          <div
            style={{
              width: 24,
              height: 24,
              borderRadius: "50%",
              background: "#00ff00",
              boxShadow: "0 0 20px #00ff00",
            }}
          />
          {network.display_name}
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          bottom: 40,
          fontSize: 36,
          fontWeight: 600,
          color: "#eeeeee",
          letterSpacing: "0.05em",
        }}
      >
        LayerTwo Labs
      </div>
    </div>,
    {
      ...size,
    }
  );
}
