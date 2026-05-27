import Link from "next/link";
import { notFound } from "next/navigation";
import { ConnectError, Code } from "@connectrpc/connect";
import { Thread } from "@/components/thread";
import { getServerClient } from "@/lib/server-api";
import { timestampToDate, timeAgo } from "@/lib/api";
import { shortHex, topicLabel } from "@/lib/utils";

type Params = Promise<{ id: string }>;

export default async function ItemPage({ params }: { params: Params }) {
  const { id } = await params;
  const client = getServerClient();
  const itemRes = await client.getItem({ itemIdHex: id }).catch((err: unknown) => {
    if (err instanceof ConnectError && err.code === Code.NotFound) return null;
    throw err;
  });
  if (!itemRes?.item) notFound();
  const it = itemRes.item;

  const thread = await client.listThread({ rootIdHex: id });

  const url = it.url || `/item/${it.itemIdHex}`;
  const isExternal = !!it.url;
  const host = it.url ? safeHost(it.url) : "";
  const when = timeAgo(timestampToDate(it.blockTime));

  return (
    <article>
      <h1 className="story__title">
        <Link href={url} target={isExternal ? "_blank" : undefined}>
          {it.headline || "(untitled)"}
        </Link>
        {host && <span className="story__host">› {host}</span>}
      </h1>
      <div className="story__meta">
        <span>
          {it.points} {it.points === 1 ? "PT" : "PTS"}
        </span>
        <span className="sep">·</span>
        <Link href={`/u/${it.authorXpkHex}`}>{shortHex(it.authorXpkHex)}</Link>
        <span className="sep">·</span>
        <span>{when}</span>
        <span className="sep">·</span>
        <Link href={`/t/${it.topicHex}`}>#{topicLabel(it.topicHex)}</Link>
        <span className="sep">·</span>
        <span>
          {it.commentCount} {it.commentCount === 1 ? "REPLY" : "REPLIES"}
        </span>
        <span className="sep">·</span>
        <span>BLK {it.blockHeight}</span>
      </div>
      {it.body && <div className="story__body">{it.body}</div>}
      <hr />
      <Thread rootIdHex={id} comments={thread.comments} />
    </article>
  );
}

function safeHost(u: string): string {
  try {
    return new URL(u).host;
  } catch {
    return "";
  }
}
