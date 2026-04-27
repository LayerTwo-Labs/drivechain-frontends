"use client";

import * as pb from "@bufbuild/protobuf";
import type { Timestamp } from "@bufbuild/protobuf/wkt";
import { createClient } from "@connectrpc/connect";
import { SiGithub } from "@icons-pack/react-simple-icons";
import { formatDistanceToNow } from "date-fns";
import { Check, Copy } from "lucide-react";
import { useCallback, useState } from "react";
import { Console } from "@/components/console";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  type ChainTip,
  ExplorerService,
  type GetChainTipsResponseJson,
  GetChainTipsResponseSchema,
} from "@/gen/explorer/v1/explorer_pb";
import { timestampToDate } from "@/lib/api";
import { clientTransport } from "@/lib/client-api";
import { useInterval } from "@/lib/use-interval";
import { blockExplorerBlockUrl } from "@/lib/utils";

interface ExplorerClientProps {
  // We accept any here because the initial data might have BigInts converted to strings
  // but we cast it back to GetChainTipsResponse for usage where safe.
  initialData?: GetChainTipsResponseJson;
}

export function ExplorerClient({ initialData }: ExplorerClientProps) {
  const [data, setData] = useState(
    initialData ? pb.fromJson(GetChainTipsResponseSchema, initialData) : null
  );

  useInterval(async () => {
    try {
      const api = createClient(ExplorerService, clientTransport);
      const response = await api.getChainTips({});
      setData(response);
    } catch (err) {
      console.error("Failed to fetch chain tips", err);
    }
  }, 10_000);

  return (
    <div className="flex flex-col gap-6">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <BlockCard
          title="Mainchain"
          subtitle="Most recent block on the mainchain"
          block={data?.mainchain}
          explorerUrl={blockExplorerBlockUrl}
          staleThresholdMs={20 * 60 * 1000}
        />
        <BlockCard
          title="Thunder"
          subtitle="Most recent block on the Thunder sidechain (L2-S9)"
          block={data?.thunder}
          repoUrl="https://github.com/LayerTwo-Labs/thunder-rust"
          mainchainTimestamp={data?.mainchain?.timestamp}
        />
        <BlockCard
          title="BitAssets"
          subtitle="Most recent block on the BitAssets sidechain (L2-S4)"
          block={data?.bitassets}
          repoUrl="https://github.com/LayerTwo-Labs/plain-bitassets"
          mainchainTimestamp={data?.mainchain?.timestamp}
        />
        <BlockCard
          title="BitNames"
          subtitle="Most recent block on the BitNames sidechain (L2-S2)"
          block={data?.bitnames}
          repoUrl="https://github.com/LayerTwo-Labs/plain-bitnames"
          mainchainTimestamp={data?.mainchain?.timestamp}
        />
        <BlockCard
          title="Zside"
          subtitle="Most recent block on the Zside sidechain (L2-S98)"
          block={data?.zside}
          repoUrl="https://github.com/iwakura-rein/thunder-orchard"
          mainchainTimestamp={data?.mainchain?.timestamp}
        />
        <BlockCard
          title="CoinShift"
          subtitle="Most recent block on the CoinShift sidechain (L2-S255)"
          block={data?.coinshift}
          repoUrl="https://github.com/LayerTwo-Labs/coinshift-rs"
          mainchainTimestamp={data?.mainchain?.timestamp}
        />
        <BlockCard
          title="Photon"
          subtitle="Most recent block on the Photon sidechain (L2-S99)"
          block={data?.photon}
          repoUrl="https://github.com/LayerTwo-Labs/photon"
          mainchainTimestamp={data?.mainchain?.timestamp}
        />
        <BlockCard
          title="Truthcoin"
          subtitle="Most recent block on the Truthcoin sidechain (L2-S13)"
          block={data?.truthcoin}
          repoUrl="https://github.com/LayerTwo-Labs/truthcoin-dc"
          mainchainTimestamp={data?.mainchain?.timestamp}
        />
      </div>

      <Card>
        <CardHeader>
          <CardTitle>BIP300/301 Enforcer RPC</CardTitle>
          <CardDescription>
            Get information from the{" "}
            <a
              href="https://github.com/LayerTwo-Labs/bip300301_enforcer"
              target="_blank"
              className="underline font-bold"
              rel="noopener"
            >
              BIP300/301 enforcer
            </a>
            .
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Console />
        </CardContent>
      </Card>
    </div>
  );
}

function MempoolIcon({ className }: { className?: string }) {
  return (
    <svg
      className={className}
      viewBox="0 0 125 126"
      fill="none"
      role="img"
      aria-label="Block explorer"
    >
      <path
        d="M124.706 110.25C124.706 118.849 117.772 125.791 109.183 125.791H15.5236C6.93387 125.791 0 118.849 0 110.25V16.4837C0 7.88416 6.98561 0.942383 15.5236 0.942383H109.183C117.772 0.942383 124.706 7.88416 124.706 16.4837V110.25Z"
        fill="#2E3349"
      />
      <path
        d="M0 63.5225V110.25C0 118.849 6.98561 125.791 15.5753 125.791H109.183C117.772 125.791 124.758 118.849 124.758 110.25V63.5225H0Z"
        fill="url(#mempoolGrad)"
      />
      <path
        opacity="0.3"
        d="M109.909 109.11C109.909 111.026 108.615 112.581 107.011 112.581H90.8665C89.2624 112.581 87.9688 111.026 87.9688 109.11V17.6232C87.9688 15.7065 89.2624 14.1523 90.8665 14.1523H107.011C108.615 14.1523 109.909 15.7065 109.909 17.6232V109.11Z"
        fill="white"
      />
      <defs>
        <linearGradient
          id="mempoolGrad"
          x1="62.38"
          y1="36.39"
          x2="62.38"
          y2="156.84"
          gradientUnits="userSpaceOnUse"
        >
          <stop stopColor="#AE61FF" />
          <stop offset="1" stopColor="#13EFD8" />
        </linearGradient>
      </defs>
    </svg>
  );
}

type ChainStatus = "synced" | "behind" | "unreachable";

function getChainStatus(
  block?: ChainTip,
  mainchainTimestamp?: Timestamp,
  staleThresholdMs?: number
): ChainStatus {
  if (!block?.height) return "unreachable";
  if (staleThresholdMs && block.timestamp) {
    const blockTimeMs = Number(block.timestamp.seconds) * 1000;
    return Date.now() - blockTimeMs > staleThresholdMs ? "behind" : "synced";
  }
  if (!mainchainTimestamp || !block.timestamp) return "synced";
  return Number(block.timestamp.seconds) >= Number(mainchainTimestamp.seconds)
    ? "synced"
    : "behind";
}

function StatusDot({ status, isMainchain }: { status: ChainStatus; isMainchain?: boolean }) {
  const labels = isMainchain
    ? {
        synced: "Blocks arriving at expected intervals",
        behind: "Longer than usual since last block",
        unreachable: "Unable to connect",
      }
    : {
        synced: "In sync with mainchain",
        behind: "Behind mainchain",
        unreachable: "Unable to connect",
      };
  const colors = {
    synced: "bg-emerald-400/80",
    behind: "bg-amber-400",
    unreachable: "bg-red-400",
  };
  const color = colors[status];
  const label = labels[status];
  return (
    <span className="relative group/dot shrink-0 flex items-center justify-center h-4 w-4">
      <span className={`inline-block h-1.5 w-1.5 rounded-full ${color}`} />
      <span className="absolute left-full top-1/2 -translate-y-1/2 ml-1 px-2 py-0.5 text-[11px] leading-tight rounded bg-foreground text-background whitespace-nowrap opacity-0 group-hover/dot:opacity-100 transition-opacity duration-150 pointer-events-none">
        {label}
      </span>
    </span>
  );
}

function BlockCard({
  title,
  subtitle,
  block,
  repoUrl,
  explorerUrl,
  mainchainTimestamp,
  staleThresholdMs,
}: {
  title: string;
  subtitle: string;
  block?: ChainTip;
  repoUrl?: string;
  explorerUrl?: (hash: string) => string;
  mainchainTimestamp?: Timestamp;
  staleThresholdMs?: number;
}) {
  const status = getChainStatus(block, mainchainTimestamp, staleThresholdMs);

  const icons = (
    <>
      {repoUrl && (
        <a href={repoUrl} target="_blank" rel="noopener">
          <SiGithub className="h-4 w-4 fill-current" />
        </a>
      )}
      {explorerUrl && block?.hash && (
        <a href={explorerUrl(block.hash)} target="_blank" rel="noopener">
          <MempoolIcon className="h-4 w-4" />
        </a>
      )}
    </>
  );

  if (status === "unreachable") {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <StatusDot status={status} isMainchain={!!staleThresholdMs} />
            {title}
            {icons}
          </CardTitle>
          <CardDescription className="text-xs">{subtitle}</CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-sm font-bold text-destructive">Unable to connect</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base flex items-center gap-2">
          <StatusDot status={status} isMainchain={!!staleThresholdMs} />
          {title}
          {icons}
        </CardTitle>
        <CardDescription className="text-xs">{subtitle}</CardDescription>
      </CardHeader>
      <CardContent className="flex flex-col gap-1">
        <div className="text-sm">Height: {block?.height.toString()}</div>
        <CopyHash hash={block?.hash ?? ""} />
        {staleThresholdMs && block?.timestamp && (
          <div className="text-sm">
            Last block: {formatDistanceToNow(timestampToDate(block.timestamp), { addSuffix: true })}
          </div>
        )}
        {!staleThresholdMs && status === "behind" && block?.timestamp && (
          <div className="text-xs text-amber-600 dark:text-amber-400">
            Mainchain sync:{" "}
            {formatDistanceToNow(timestampToDate(block.timestamp), { addSuffix: true })}
          </div>
        )}
      </CardContent>
    </Card>
  );
}

function CopyHash({ hash }: { hash: string }) {
  const [copied, setCopied] = useState(false);

  const copy = useCallback(() => {
    navigator.clipboard.writeText(hash);
    setCopied(true);
    setTimeout(() => setCopied(false), 1500);
  }, [hash]);

  const truncated = `${hash.slice(0, 12)}...`;

  return (
    <button
      type="button"
      onClick={copy}
      className={`flex items-center gap-1 text-sm text-left cursor-pointer transition-colors ${
        copied ? "text-green-600 dark:text-green-400" : "hover:text-foreground/80"
      }`}
      title={hash}
    >
      Hash: {truncated}
      {copied ? (
        <Check className="h-3 w-3 shrink-0" />
      ) : (
        <Copy className="h-3 w-3 shrink-0 opacity-50" />
      )}
    </button>
  );
}
