import Link from "next/link";
import type { Item } from "@/gen/coinnews/v1/coinnews_pb";
import { timestampToDate, timeAgo } from "@/lib/api";
import { shortHex, topicLabel } from "@/lib/utils";

export function ItemRow({ item, rank }: { item: Item; rank?: number }) {
  const url = item.url || `/item/${item.itemIdHex}`;
  const isExternal = !!item.url;
  const host = item.url ? safeHost(item.url) : "";
  const when = timeAgo(timestampToDate(item.blockTime));
  const rankLabel = rank !== undefined ? String(rank).padStart(2, "0") : "";

  return (
    <li className="item-row">
      {rank !== undefined && <span className="item-row__rank">{rankLabel}</span>}
      <div className="item-row__body">
        <div className="item-row__title-line">
          <Link
            href={url}
            target={isExternal ? "_blank" : undefined}
            className="item-row__title"
          >
            {item.headline || "(untitled)"}
          </Link>
          {host && <span className="item-row__host">› {host}</span>}
        </div>
        <div className="item-row__meta">
          <span>
            {item.points} {item.points === 1 ? "PT" : "PTS"}
          </span>
          <span className="sep">·</span>
          <Link href={`/u/${item.authorXpkHex}`}>{shortHex(item.authorXpkHex)}</Link>
          <span className="sep">·</span>
          <span>{when}</span>
          <span className="sep">·</span>
          <Link href={`/t/${item.topicHex}`}>#{topicLabel(item.topicHex)}</Link>
          <span className="sep">·</span>
          <Link href={`/item/${item.itemIdHex}`}>
            {item.commentCount} {item.commentCount === 1 ? "REPLY" : "REPLIES"}
          </Link>
          <span className="sep">·</span>
          <span>BLK {item.blockHeight}</span>
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
