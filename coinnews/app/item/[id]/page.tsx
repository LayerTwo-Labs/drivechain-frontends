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
      <h1 className="text-base font-semibold">
        <Link
          href={url}
          target={isExternal ? "_blank" : undefined}
          className="text-foreground hover:underline"
        >
          {it.headline || "(untitled)"}
        </Link>
        {host && <span className="text-xs text-[var(--muted-foreground)] ml-1">({host})</span>}
      </h1>
      <div className="text-xs text-[var(--muted-foreground)] mt-1">
        {it.points} {it.points === 1 ? "point" : "points"} ·{" "}
        <Link href={`/u/${it.authorXpkHex}`} className="hover:underline">
          {shortHex(it.authorXpkHex)}
        </Link>{" "}
        · {when} ·{" "}
        <Link href={`/t/${it.topicHex}`} className="hover:underline">
          {topicLabel(it.topicHex)}
        </Link>{" "}
        · {it.commentCount} comments · block {it.blockHeight}
      </div>
      {it.body && (
        <div className="whitespace-pre-wrap break-words text-sm py-3">{it.body}</div>
      )}
      <hr className="my-3 border-[var(--border)]" />
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
