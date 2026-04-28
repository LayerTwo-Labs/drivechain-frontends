import Link from "next/link";
import type { Comment } from "@/gen/coinnews/v1/coinnews_pb";
import { timestampToDate, timeAgo } from "@/lib/api";
import { shortHex } from "@/lib/utils";

export function Thread({ rootIdHex, comments }: { rootIdHex: string; comments: Comment[] }) {
  const tree = buildTree(rootIdHex, comments);
  if (tree.length === 0) {
    return <p className="text-[var(--muted-foreground)] py-2">No comments yet.</p>;
  }
  return (
    <ul className="list-none p-0 m-0">
      {tree.map((node) => (
        <ThreadNode key={node.c.itemIdHex} node={node} depth={0} />
      ))}
    </ul>
  );
}

type Node = { c: Comment; children: Node[] };

function buildTree(rootIdHex: string, comments: Comment[]): Node[] {
  const byId: Record<string, Node> = {};
  for (const c of comments) {
    byId[c.itemIdHex] = { c, children: [] };
  }
  const roots: Node[] = [];
  for (const c of comments) {
    const parent = c.parentIdHex && byId[c.parentIdHex] ? byId[c.parentIdHex] : null;
    if (parent && c.parentIdHex !== rootIdHex) {
      parent.children.push(byId[c.itemIdHex]);
    } else {
      roots.push(byId[c.itemIdHex]);
    }
  }
  return roots;
}

function ThreadNode({ node, depth }: { node: Node; depth: number }) {
  const c = node.c;
  const when = timeAgo(timestampToDate(c.blockTime));
  return (
    <li
      className="border-l border-[var(--border)] pl-2 my-2"
      style={{ marginLeft: depth === 0 ? 0 : 12 }}
    >
      <div className="text-xs text-[var(--muted-foreground)]">
        <Link href={`/u/${c.authorXpkHex}`} className="hover:underline">
          {shortHex(c.authorXpkHex)}
        </Link>{" "}
        · {c.points} {c.points === 1 ? "point" : "points"} · {when} · block {c.blockHeight}
      </div>
      {c.replyQuote && (
        <blockquote className="text-xs text-[var(--muted-foreground)] border-l-2 border-[var(--border)] pl-2 my-1 italic">
          &gt; {c.replyQuote}
        </blockquote>
      )}
      <div className="whitespace-pre-wrap break-words text-sm py-1">
        {c.body}
        {c.url && (
          <>
            {" "}
            <a href={c.url} target="_blank" rel="noreferrer" className="underline">
              {c.url}
            </a>
          </>
        )}
      </div>
      {node.children.length > 0 && (
        <ul className="list-none p-0 m-0">
          {node.children.map((child) => (
            <ThreadNode key={child.c.itemIdHex} node={child} depth={depth + 1} />
          ))}
        </ul>
      )}
    </li>
  );
}
