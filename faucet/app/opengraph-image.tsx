import { ImageResponse } from "next/og";
import { instanceNetwork } from "@/lib/utils";

export const runtime = "edge";

export const alt = "Drivechain Faucet";
export const size = {
  width: 1200,
  height: 630,
};

export const contentType = "image/png";

export default async function Image() {
  const network = instanceNetwork();

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
          Drivechain Faucet
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
          {network}
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
