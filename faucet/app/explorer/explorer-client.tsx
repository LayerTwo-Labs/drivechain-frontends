"use client";

import * as pb from "@bufbuild/protobuf";
import { createClient } from "@connectrpc/connect";
import { SiGithub } from "@icons-pack/react-simple-icons";
import { format, formatDistanceToNow } from "date-fns";
import { Check, Copy } from "lucide-react";
import { useCallback, useState } from "react";
import { Console } from "@/components/console";
import { Button } from "@/components/ui/button";
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

interface ExplorerClientProps {
  // We accept any here because the initial data might have BigInts converted to strings
  // but we cast it back to GetChainTipsResponse for usage where safe.
  initialData?: GetChainTipsResponseJson;
}

export function ExplorerClient({ initialData }: ExplorerClientProps) {
  const [data, setData] = useState(
    initialData ? pb.fromJson(GetChainTipsResponseSchema, initialData) : null
  );

  const [loading, setLoading] = useState(false);
  const [nextRefresh, setNextRefresh] = useState(30);

  const fetchData = async () => {
    setLoading(true);
    try {
      const api = createClient(ExplorerService, clientTransport);
      const response = await api.getChainTips({});
      setData(response);
    } catch (err) {
      console.error("Failed to fetch chain tips", err);
    } finally {
      setLoading(false);
      setNextRefresh(30);
    }
  };

  useInterval(
    () =>
      setNextRefresh((prev) => {
        if (prev <= 1) {
          fetchData();
          return 30;
        }
        return prev - 1;
      }),
    1000
  );

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center gap-4">
        <Button onClick={fetchData} loading={loading}>
          Refresh Now
        </Button>
        <span className="text-sm text-muted-foreground italic">
          {nextRefresh > 0 ? `Auto-refreshing in ${nextRefresh} seconds` : "Refreshing..."}
        </span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        <BlockCard
          title="Mainchain"
          subtitle="Most recent block on the mainchain"
          block={data?.mainchain}
        />
        <BlockCard
          title="Thunder"
          subtitle="Most recent block on the Thunder sidechain (L2-S9)"
          block={data?.thunder}
          repoUrl="https://github.com/LayerTwo-Labs/thunder-rust"
        />
        <BlockCard
          title="BitAssets"
          subtitle="Most recent block on the BitAssets sidechain (L2-S4)"
          block={data?.bitassets}
          repoUrl="https://github.com/LayerTwo-Labs/plain-bitassets"
        />
        <BlockCard
          title="BitNames"
          subtitle="Most recent block on the BitNames sidechain (L2-S2)"
          block={data?.bitnames}
          repoUrl="https://github.com/LayerTwo-Labs/plain-bitnames"
        />
        <BlockCard
          title="Zside"
          subtitle="Most recent block on the Zside sidechain (L2-S98)"
          block={data?.zside}
          repoUrl="https://github.com/iwakura-rein/thunder-orchard"
        />
        <BlockCard
          title="CoinShift"
          subtitle="Most recent block on the CoinShift sidechain (L2-S255)"
          block={data?.coinshift}
          repoUrl="https://github.com/LayerTwo-Labs/coinshift-rs"
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

function BlockCard({
  title,
  subtitle,
  block,
  repoUrl,
}: {
  title: string;
  subtitle: string;
  block?: ChainTip;
  repoUrl?: string;
}) {
  if (!block?.height) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            {title}
            {repoUrl && (
              <a href={repoUrl} target="_blank" rel="noopener">
                <SiGithub className="h-4 w-4 fill-current" />
              </a>
            )}
          </CardTitle>
          <CardDescription className="text-xs">{subtitle}</CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-sm font-bold text-destructive">Unable to connect</p>
        </CardContent>
      </Card>
    );
  }

  // timestampToDate expects Timestamp object.
  // If block.timestamp is from initialData (sanitized), seconds might be string.
  // Cast to any to allow safe conversion.
  // biome-ignore lint/suspicious/noExplicitAny: it's OK
  const blockTime = timestampToDate(block.timestamp as any);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base flex items-center gap-2">
          {title}
          {repoUrl && (
            <a href={repoUrl} target="_blank" rel="noopener">
              <SiGithub className="h-4 w-4 fill-current" />
            </a>
          )}
        </CardTitle>
        <CardDescription className="text-xs">{subtitle}</CardDescription>
      </CardHeader>
      <CardContent className="flex flex-col gap-1">
        <div className="text-sm">Height: {block.height.toString()}</div>
        <CopyHash hash={block.hash} />
        <div className="text-sm">Time: {format(blockTime, "yyyy-MM-dd HH:mm:ss")}</div>
        <div className="text-sm font-bold text-orange-500">
          {formatDistanceToNow(blockTime, { addSuffix: true })}
        </div>
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
