"use client";

import * as pb from "@bufbuild/protobuf";
import { createClient } from "@connectrpc/connect";
import { format, formatDistanceToNow } from "date-fns";
import { useState } from "react";
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

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
        <BlockCard
          title="Latest Mainchain Block"
          subtitle="Most recent block on the mainchain"
          block={data?.mainchain}
        />
        <BlockCard
          title="Latest Thunder Block"
          subtitle="Most recent block on the Thunder sidechain (L2-S9)"
          block={data?.thunder}
        />
        <BlockCard
          title="Latest BitAssets Block"
          subtitle="Most recent block on the BitAssets sidechain (L2-S4)"
          block={data?.bitassets}
        />
        <BlockCard
          title="Latest BitNames Block"
          subtitle="Most recent block on the BitNames sidechain (L2-S2)"
          block={data?.bitnames}
        />
        <BlockCard
          title="Latest Zside Block"
          subtitle="Most recent block on the Zside sidechain (L2-S98)"
          block={data?.zside}
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
}: {
  title: string;
  subtitle: string;
  block?: ChainTip;
}) {
  if (!block || !block.height) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-base">{title}</CardTitle>
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
        <CardTitle className="text-base">{title}</CardTitle>
        <CardDescription className="text-xs">{subtitle}</CardDescription>
      </CardHeader>
      <CardContent className="flex flex-col gap-1">
        <div className="text-sm">Height: {block.height.toString()}</div>
        <div className="text-sm truncate" title={block.hash}>
          Hash: {block.hash}
        </div>
        <div className="text-sm">Time: {format(blockTime, "yyyy-MM-dd HH:mm:ss")}</div>
        <div className="text-sm font-bold text-orange-500">
          {formatDistanceToNow(blockTime, { addSuffix: true })}
        </div>
      </CardContent>
    </Card>
  );
}
