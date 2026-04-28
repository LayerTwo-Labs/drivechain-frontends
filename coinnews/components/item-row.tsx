import Link from "next/link";
import type { Item } from "@/gen/coinnews/v1/coinnews_pb";
import { timestampToDate, timeAgo } from "@/lib/api";
import { shortHex, topicLabel } from "@/lib/utils";

export function ItemRow({ item, rank }: { item: Item; rank?: number }) {
  const url = item.url || `/item/${item.itemIdHex}`;
  const isExternal = !!item.url;
  const host = item.url ? safeHost(item.url) : "";
  const when = timeAgo(timestampToDate(item.blockTime));

  return (
    <li className="flex gap-2 py-1 items-baseline">
      {rank !== undefined && (
        <span className="text-[var(--muted-foreground)] tabular-nums w-6 text-right">{rank}.</span>
      )}
      <div className="flex-1 min-w-0">
        <div className="flex flex-wrap items-baseline gap-x-1">
          <Link
            href={url}
            target={isExternal ? "_blank" : undefined}
            className="text-foreground hover:underline"
          >
            {item.headline || "(untitled)"}
          </Link>
          {host && (
            <span className="text-xs text-[var(--muted-foreground)]">({host})</span>
          )}
        </div>
        <div className="text-xs text-[var(--muted-foreground)]">
          {item.points} {item.points === 1 ? "point" : "points"} ·{" "}
          <Link href={`/u/${item.authorXpkHex}`} className="hover:underline">
            {shortHex(item.authorXpkHex)}
          </Link>{" "}
          · {when} ·{" "}
          <Link href={`/t/${item.topicHex}`} className="hover:underline">
            {topicLabel(item.topicHex)}
          </Link>{" "}
          ·{" "}
          <Link href={`/item/${item.itemIdHex}`} className="hover:underline">
            {item.commentCount} {item.commentCount === 1 ? "comment" : "comments"}
          </Link>{" "}
          · block {item.blockHeight}
        </div>
      </div>
    </li>
  );
}

function safeHost(u: string): string {
  try {
    return new URL(u).host;
  } catch {
    return "";
  }
}
